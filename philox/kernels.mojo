from memory import UnsafePointer
from gpu import global_idx
from .inplace import generate_inplace, generate_inplace_unroll_2
from .stateless import generate_u32, generate_u64, generate_f32, generate_f64

fn fill_kernel[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4],
    UnrollFactor: Int = 1](buffer: UnsafePointer[Scalar[U]], size: Int):
    generate_inplace[Gen, UnrollFactor](buffer, size, global_idx.x)

fn fill_kernel_unroll_2[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int):
    generate_inplace_unroll_2[Gen](buffer, size, global_idx.x)

alias fill_kernel_u32 = fill_kernel[generate_u32[10]]
alias fill_kernel_u64 = fill_kernel[generate_u64[10]]
alias fill_kernel_f32 = fill_kernel[generate_f32[10]]
alias fill_kernel_f64 = fill_kernel[generate_f64[10]]

# Manual unroll for testing
alias fill_kernel_f32_unroll_2 = fill_kernel_unroll_2[generate_f32[10]]
