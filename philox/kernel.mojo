from memory import UnsafePointer
from gpu import global_idx

alias RngKey = SIMD[_, 2]
alias RngCounter = SIMD[_, 4]
alias RngValue = SIMD[_, 4]

fn fill_kernel[
    T: DType,
    U: DType, //,
    Gen: fn(RngKey[T], RngCounter[T]) -> RngValue[U]](buffer: UnsafePointer[Scalar[U]], size: Int):

    var idx = global_idx.x
    var key = SIMD[T, 2](0, 0)
    var ctr = SIMD[T, 4](idx, 0, 0, 0)
    var val = Gen(key, ctr)
    buffer.store(idx * 4, val) # TODO: bound check