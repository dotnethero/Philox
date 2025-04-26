from memory import UnsafePointer
from gpu import thread_idx, global_idx

fn fill_kernel_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int):
    var idx = global_idx.x
    var key = SIMD[DType.uint32, 2](0, 0)
    var ctr = SIMD[DType.uint32, 4](idx, 0, 0, 0)
    var rng = philox4x32[Rounds=7](key, ctr)
    var val = to_float32(rng)
    buffer.store(idx * 4, val) # TODO: bound check

fn fill_kernel_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int):
    var idx = global_idx.x
    var key = SIMD[DType.uint64, 2](0, 0)
    var ctr = SIMD[DType.uint64, 4](idx, 0, 0, 0)
    var rng = philox4x64[Rounds=7](key, ctr)
    var val = to_float64(rng)
    buffer.store(idx * 4, val) # TODO: bound check
