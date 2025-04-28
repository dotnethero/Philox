from memory import UnsafePointer
from gpu import thread_idx, global_idx
from .stateless import philox4x32, philox4x64, philox4x32f, philox4x64f

alias RngKey = SIMD[_, 2]
alias RngCounter = SIMD[_, 4]
alias RngValue = SIMD[_, 4]

@always_inline
fn fill_one[T: DType, U: DType, //, Gen: fn(SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int, idx: Int):
    var ctr = SIMD[T, 4](idx, 0, 0, 0)
    var val = Gen(ctr)
    buffer.store(idx * 4, val)

fn fill_kernel[
    SourceType: DType,
    ResultType: DType, //,
    Gen: fn(RngKey[SourceType], RngCounter[SourceType]) -> RngValue[ResultType]](buffer: UnsafePointer[Scalar[ResultType]], size: Int):

    var idx = global_idx.x
    var key = SIMD[SourceType, 2](0, 0)
    var ctr = SIMD[SourceType, 4](idx, 0, 0, 0)
    var val = Gen(key, ctr)
    buffer.store(idx * 4, val) # TODO: bound check

alias fill_kernel_32 = fill_kernel[philox4x32[Rounds=7]]
alias fill_kernel_64 = fill_kernel[philox4x64[Rounds=7]]
alias fill_kernel_32f = fill_kernel[philox4x32f[Rounds=7]]
alias fill_kernel_64f = fill_kernel[philox4x64f[Rounds=7]]