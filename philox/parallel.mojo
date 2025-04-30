from memory import UnsafePointer
from algorithm.functional import parallelize
from .inplace import generate_inplace, generate_inplace_no_unroll
from .stateless import generate_u32, generate_u64, generate_f32, generate_f64

@always_inline
fn fill_parallel[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4],
    UnrollFactor: Int = 4](buffer: UnsafePointer[Scalar[U]], size: Int):
    alias items_at_once = UnrollFactor * 4
    @parameter
    fn closure(i: Int):
        generate_inplace[Gen, UnrollFactor](buffer, size, i)
    parallelize[func=closure](num_work_items=size//items_at_once)

alias fill_parallel_u32 = fill_parallel[generate_u32[10]]
alias fill_parallel_u64 = fill_parallel[generate_u64[10]]
alias fill_parallel_f32 = fill_parallel[generate_f32[10]]
alias fill_parallel_f64 = fill_parallel[generate_f64[10]]
