@always_inline
fn asfloat[Width: Int](x: SIMD[DType.uint32, Width]) -> SIMD[DType.float32, Width]:
    alias Mantissa = UInt32(1) << 23
    alias Multiplier = Float32(1) / Float32(Mantissa)
    return (x >> 9).cast[DType.float32]() * Multiplier

@always_inline
fn asfloat[Width: Int](x: SIMD[DType.uint64, Width]) -> SIMD[DType.float64, Width]:
    alias Mantissa = UInt64(1) << 52
    alias Multiplier = Float64(1) / Float64(Mantissa)
    return (x >> 12).cast[DType.float64]() * Multiplier
