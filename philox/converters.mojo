@always_inline
fn asfloat[Width: Int](x: SIMD[DType.uint16, Width]) -> SIMD[DType.float16, Width]:
    # Exponent width is 8 bits
    # Mantissa width is 7 bits = 16 - 8 - 1 (sign)
    alias Mantissa = UInt16(1) << 7
    alias Multiplier = Float16(1) / Float16(Mantissa)
    return (x >> 9).cast[DType.float16]() * Multiplier

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
