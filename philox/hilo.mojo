from sys import bitwidthof
from utils.numerics import max_finite

@always_inline
fn double_type_of[U: DType]() -> DType:
    @parameter
    if (U is DType.uint16):
        return DType.uint32
    if (U is DType.uint32):
        return DType.uint64
    if (U is DType.uint64):
        return DType.uint128
    return DType.invalid

@always_inline
fn mulhilo[U: DType, //](a: SIMD[U, 1], b: SIMD[U, 1]) -> SIMD[U, 2]:
    alias D = double_type_of[U]()
    alias bitwidth = bitwidthof[U]()
    alias mask = SIMD[D, 1](max_finite[U]())
    var ab = SIMD[D, 1](a) * SIMD[D, 1](b)
    var hi = SIMD[U, 1](ab >> bitwidth)
    var lo = SIMD[U, 1](ab & mask)
    return SIMD[U, 2](hi, lo)
