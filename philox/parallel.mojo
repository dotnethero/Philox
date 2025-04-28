from memory import UnsafePointer
from algorithm.functional import parallelize
from .inplace import generate_inplace
from .stateless import generate_u32, generate_u64, generate_f32, generate_f64

@always_inline
fn fill_parallel[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int):
    @parameter
    fn closure(i: Int):
        generate_inplace[Gen](buffer, size, i)
    parallelize[func=closure](num_work_items=size//4)

alias fill_parallel_u32 = fill_parallel[generate_u32[10]]
alias fill_parallel_u64 = fill_parallel[generate_u64[10]]
alias fill_parallel_f32 = fill_parallel[generate_f32[10]]
alias fill_parallel_f64 = fill_parallel[generate_f64[10]]
