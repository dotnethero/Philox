alias UInt32x2 = SIMD[DType.uint32, 2]
alias UInt32x4 = SIMD[DType.uint32, 4]

alias UInt64x2 = SIMD[DType.uint64, 2]
alias UInt64x4 = SIMD[DType.uint64, 4]

@always_inline
fn philox_mulhilo(a: UInt32, b: UInt32) -> UInt32x2:
    var ab = UInt64(a) * UInt64(b)
    var hi = UInt32(ab >> 32)
    var lo = UInt32(ab & 0xFFFFFFFF)
    return UInt32x2(hi, lo)

@always_inline
fn philox_mulhilo(a: UInt64, b: UInt64) -> UInt64x2:
    var ab = UInt128(a) * UInt128(b)
    var hi = UInt64(ab >> 64)
    var lo = UInt64(ab & 0xFFFFFFFFFFFFFFFF)
    return UInt64x2(hi, lo)

@always_inline
fn philox4x32_bumpkey(key: UInt32x2) -> UInt32x2:
    alias W = UInt32x2(0x9E3779B9, 0xBB67AE85)
    return key + W

@always_inline
fn philox4x64_bumpkey(key: UInt64x2) -> UInt64x2:
    alias W = UInt64x2(0x9E3779B97F4A7C15, 0xBB67AE8584CAA73B)
    return key + W

@always_inline
fn philox4x32_round(key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    alias M4 = UInt32x2(0xD2511F53, 0xCD9E8D57)
    var hilo1 = philox_mulhilo(M4[0], ctr[0])
    var hilo2 = philox_mulhilo(M4[1], ctr[2])
    var a = UInt32x4(hilo2[0], hilo2[1], hilo1[0], hilo1[1])
    var b = UInt32x4(ctr[1], 0, ctr[3], 0)
    var c = UInt32x4(key[0], 0, key[1], 0)
    return a ^ b ^ c

@always_inline
fn philox4x64_round(key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    alias M4 = UInt64x2(0xD2E7470EE14C6C93, 0xCA5A826395121157)
    var hilo1 = philox_mulhilo(M4[0], ctr[0])
    var hilo2 = philox_mulhilo(M4[1], ctr[2])
    var a = UInt64x4(hilo2[0], hilo2[1], hilo1[0], hilo1[1])
    var b = UInt64x4(ctr[1], 0, ctr[3], 0)
    var c = UInt64x4(key[0], 0, key[1], 0)
    return a ^ b ^ c

@always_inline
fn philox4x32[R: UInt32 = 10](key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, R):
        ctrx = philox4x32_round(keyx, ctrx);
        keyx = philox4x32_bumpkey(keyx);
    return ctrx

@always_inline
fn philox4x64[R: UInt32 = 10](key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, R):
        ctrx = philox4x64_round(keyx, ctrx);
        keyx = philox4x64_bumpkey(keyx);
    return ctrx

alias RngKey = SIMD[_, 2]
alias RngCounter = SIMD[_, 4]
alias RngValue = SIMD[_, 4]

@always_inline
fn increment[T: DType](ctr: RngCounter[T]) -> RngCounter[T]:
    var c0 = ctr[0] + 1 # TODO: Skip overflow?
    var c1 = ctr[1] + Scalar[T](c0 == 0)
    var c2 = ctr[2] + Scalar[T](c0 == 0 and c1 == 0)
    var c3 = ctr[3] + Scalar[T](c0 == 0 and c1 == 0 and c2 == 0)
    return RngCounter[T](c0, c1, c2, c3)

from memory import UnsafePointer

@register_passable
struct PhiloxGenerator[
    T: DType, # Underlying type
    U: DType, # Target type
    Philox: fn(RngKey[T], RngCounter[T]) -> RngValue[T],
    Map: fn(RngValue[T]) -> RngValue[U]]:

    var key: RngKey[T]
    var counter: RngCounter[T]

    fn __init__(out self, seed1: Scalar[T], seed2: Scalar[T]):
        self.key = RngKey[T](seed1, seed2)
        self.counter = RngCounter[T](0, 0, 0, 0)

    @always_inline
    fn next(mut self) -> RngValue[U]:
        var value = Map(Philox(self.key, self.counter))
        return value

    @always_inline
    fn fill(mut self, ptr: UnsafePointer[Scalar[U]], size: UInt32):
        var iterations = size // 4
        var leftover = size - iterations * 4
        
        for i in range(0, iterations):
            var result = Map(Philox(self.key, self.counter))
            var offset = i * 4
            ptr.store(offset, result)
            self.counter = increment(self.counter)

        if leftover > 0:
            var result = Map(Philox(self.key, self.counter))
            var offset = iterations * 4
            for i in range(0, leftover):
                ptr[offset + i] = result[i]
            self.counter = increment(self.counter)

@always_inline
fn identity[T: DType, Width: Int](x: SIMD[T, Width]) -> SIMD[T, Width]:
    return x

@always_inline
fn to_float32[Width: Int](x: SIMD[DType.uint32, Width]) -> SIMD[DType.float32, Width]:
    alias Mantissa = UInt32(1) << 23
    alias Multiplier = Float32(1) / Float32(Mantissa)
    return (x >> 9).cast[DType.float32]() * Multiplier

@always_inline
fn to_float64[Width: Int](x: SIMD[DType.uint64, Width]) -> SIMD[DType.float64, Width]:
    alias Mantissa = UInt64(1) << 52
    alias Multiplier = Float64(1) / Float64(Mantissa)
    return (x >> 12).cast[DType.float64]() * Multiplier

alias PhiloxUInt32 = PhiloxGenerator[DType.uint32, DType.uint32, philox4x32[R = 10], identity[DType.uint32, 4]]
alias PhiloxUInt64 = PhiloxGenerator[DType.uint64, DType.uint64, philox4x64[R = 10], identity[DType.uint64, 4]]
alias PhiloxFloat32 = PhiloxGenerator[DType.uint32, DType.float32, philox4x32[R = 10], to_float32[4]]
alias PhiloxFloat64 = PhiloxGenerator[DType.uint64, DType.float64, philox4x64[R = 10], to_float64[4]]

from random import seed, random_ui64

fn main():
    seed()
    var seed1 = 0 # random_ui64(0, 0xFFFFFFFF);
    var seed2 = 0 # random_ui64(0, 0xFFFFFFFF);
    var generator = PhiloxFloat64(seed1, seed2)
    var list = InlineArray[Float64, 12](fill = 0)
    generator.fill(list.unsafe_ptr(), len(list))
    
    for i in range(0, len(list)):
        print(list[i], end = " ")
        if (i % 4 == 3):
            print()
