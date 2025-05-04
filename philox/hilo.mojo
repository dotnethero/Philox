alias UInt16x2 = SIMD[DType.uint16, 2]
alias UInt32x2 = SIMD[DType.uint32, 2]
alias UInt64x2 = SIMD[DType.uint64, 2]

@always_inline
fn mulhilo(a: UInt16, b: UInt16) -> UInt16x2:
    var ab = UInt32(a) * UInt32(b)
    var hi = UInt16(ab >> 16)
    var lo = UInt16(ab & 0xFFFF)
    return UInt16x2(hi, lo)

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
