from memory import UnsafePointer
from gpu import global_idx
from .inplace import generate_inplace
from .stateless import generate_u32, generate_u64, generate_f32, generate_f64

fn fill_kernel[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int):
    generate_inplace[Gen](buffer, size, global_idx.x)

alias fill_kernel_u32 = fill_kernel[generate_u32[10]]
alias fill_kernel_u64 = fill_kernel[generate_u64[10]]
alias fill_kernel_f32 = fill_kernel[generate_f32[10]]
alias fill_kernel_f64 = fill_kernel[generate_f64[10]]
