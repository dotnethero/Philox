from sys import bitwidthof
from builtin.dtype import _unsigned_integral_type_of
from utils.numerics import FPUtils

@always_inline
fn asfloat[U: DType, Width: Int, //, T: DType](x: SIMD[U, Width]) -> SIMD[T, Width]:
    constrained[U is _unsigned_integral_type_of[T](), "U should be unsigned integer type for T"]()
    alias mantissa_width = FPUtils[T].mantissa_width()
    alias exponent_width = bitwidthof[T]() - mantissa_width # Ignore sign
    alias mantissa = SIMD[U, Width](1) << mantissa_width
    alias multiplier = SIMD[T, Width](1) / SIMD[T, Width](mantissa)
    return (x >> exponent_width).cast[T]() * multiplier
