alias UInt32x2 = SIMD[DType.uint32, 2]
alias UInt64x2 = SIMD[DType.uint64, 2]

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

@always_inline
fn mulhilo(a: UInt32, b: UInt32) -> UInt32x2:
    var ab = UInt64(a) * UInt64(b)
    var hi = UInt32(ab >> 32)
    var lo = UInt32(ab & 0xFFFFFFFF)
    return UInt32x2(hi, lo)

@always_inline
fn mulhilo(a: UInt64, b: UInt64) -> UInt64x2:
    var ab = UInt128(a) * UInt128(b)
    var hi = UInt64(ab >> 64)
    var lo = UInt64(ab & 0xFFFFFFFFFFFFFFFF)
    return UInt64x2(hi, lo)
