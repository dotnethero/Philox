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
fn philox4x_bumpkey(key: UInt32x2) -> UInt32x2:
    alias PHILOX_W_0: UInt32 = 0x9E3779B9
    alias PHILOX_W_1: UInt32 = 0xBB67AE85
    return UInt32x2(key[0] + PHILOX_W_0, key[1] + PHILOX_W_1)

@always_inline
fn philox4x_bumpkey(key: UInt64x2) -> UInt64x2:
    alias PHILOX_W_0: UInt64 = 0x9E3779B97F4A7C15
    alias PHILOX_W_1: UInt64 = 0xBB67AE8584CAA73B
    return UInt64x2(key[0] + PHILOX_W_0, key[1] + PHILOX_W_1)

@always_inline
fn philox4x_round(key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    alias PHILOX_M4x_0: UInt32 = 0xD2511F53
    alias PHILOX_M4x_1: UInt32 = 0xCD9E8D57
    var hilo1 = philox_mulhilo(PHILOX_M4x_0, ctr[0])
    var hilo2 = philox_mulhilo(PHILOX_M4x_1, ctr[2])
    return UInt32x4(hilo2[0] ^ ctr[1] ^ key[0], hilo2[1], hilo1[0] ^ ctr[3] ^ key[1], hilo1[1])

@always_inline
fn philox4x_round(key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    alias PHILOX_M4x_0: UInt64 = 0xD2E7470EE14C6C93
    alias PHILOX_M4x_1: UInt64 = 0xCA5A826395121157
    var hilo1 = philox_mulhilo(PHILOX_M4x_0, ctr[0])
    var hilo2 = philox_mulhilo(PHILOX_M4x_1, ctr[2])
    return UInt64x4(hilo2[0] ^ ctr[1] ^ key[0], hilo2[1], hilo1[0] ^ ctr[3] ^ key[1], hilo1[1])

alias Key = SIMD[_, 2]
alias Counter = SIMD[_, 4]

@always_inline
fn philox4x[
    T: DType,
    BumpKey: fn(Key[T]) -> Key[T],
    Round: fn(Key[T], Counter[T]) -> Counter[T],
    R: UInt32 = 10](key: Key[T], ctr: Counter[T]) -> Counter[T]:
    """
    Runs the Philox algorithm for R rounds. Returns four values.
    """
    var ctrx = ctr
    var keyx = key
    
    @parameter
    for i in range(0, R):
        ctrx = Round(keyx, ctrx);
        keyx = BumpKey(keyx);

    return ctrx

from memory import Span, UnsafePointer

@register_passable
struct PhiloxGenerator[T: DType, BumpKey: fn(Key[T]) -> Key[T], Round: fn(Key[T], Counter[T]) -> Counter[T], R: UInt32 = 10]:
    var key: Key[T]
    var counter: Counter[T]

    fn __init__(out self, seed1: Scalar[T], seed2: Scalar[T]):
        self.key = Key[T](seed1, seed2)
        self.counter = Counter[T](0, 0, 0, 0)

    @always_inline
    fn increment_counter(mut self):
        var c0 = self.counter[0] + 1
        var c1 = self.counter[1] + Scalar[T](c0 == 0)
        var c2 = self.counter[2] + Scalar[T](c0 == 0 and c1 == 0)
        var c3 = self.counter[3] + Scalar[T](c0 == 0 and c1 == 0 and c2 == 0)
        self.counter = Counter[T](c0, c1, c2, c3)

    @always_inline
    fn fill(mut self, ptr: UnsafePointer[Scalar[T]], size: UInt32):
        var iterations = size // 4
        var leftover = size - iterations * 4

        for i in range(0, iterations):
            var result = philox4x[T, BumpKey, Round, R](self.key, self.counter)
            var offset = i * 4
            ptr[offset + 0] = result[0]
            ptr[offset + 1] = result[1]
            ptr[offset + 2] = result[2]
            ptr[offset + 3] = result[3]
            self.increment_counter()

        if leftover > 0:
            var result = philox4x[T, BumpKey, Round, R](self.key, self.counter)
            var offset = iterations * 4
            if leftover > 0:
                ptr[offset + 0] = result[0]
            if leftover > 1:
                ptr[offset + 1] = result[1]
            if leftover > 2:
                ptr[offset + 2] = result[2]
            self.increment_counter()

    @always_inline
    fn fill(mut self, mut buffer: Span[Scalar[T]]):
        self.fill(buffer.unsafe_ptr(), len(buffer))
        pass
        
alias PhiloxGenerator32 = PhiloxGenerator[DType.uint32, philox4x_bumpkey, philox4x_round, _]
alias PhiloxGenerator64 = PhiloxGenerator[DType.uint64, philox4x_bumpkey, philox4x_round, _]

from random import seed, random_ui64

fn main():
    seed()
    var seed1 = 0 # random_ui64(0, 0xFFFFFFFF);
    var seed2 = 0 # random_ui64(0, 0xFFFFFFFF);
    var state = PhiloxGenerator64(seed1, seed2)
    var list = InlineArray[UInt64, 13]()
    var buffer = Span(list)
    state.fill(buffer)
    for i in range(0, len(list)):
        print(list[i], end = " ")
        if (i % 4 == 3):
            print()
    
