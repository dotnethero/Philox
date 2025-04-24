from .generator import PhiloxGenerator
from .stateless import philox4x32, philox4x64
from .helpers import identity, to_float32, to_float64

alias PhiloxUInt32 = PhiloxGenerator[DType.uint32, DType.uint32, philox4x32[Rounds = 10], identity[SIMD[DType.uint32, 4]]]
alias PhiloxUInt64 = PhiloxGenerator[DType.uint64, DType.uint64, philox4x64[Rounds = 10], identity[SIMD[DType.uint64, 4]]]
alias PhiloxFloat32 = PhiloxGenerator[DType.uint32, DType.float32, philox4x32[Rounds = 10], to_float32[4]]
alias PhiloxFloat64 = PhiloxGenerator[DType.uint64, DType.float64, philox4x64[Rounds = 10], to_float64[4]]
