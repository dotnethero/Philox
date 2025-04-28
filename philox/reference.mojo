from memory import UnsafePointer
from algorithm.functional import vectorize, parallelize
from .stateless import philox4x32f, philox4x64f
from .helpers import asfloat

@always_inline
fn cpu_kernel_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int, idx: Int):
    var key = SIMD[DType.uint32, 2](0, 0)
    var ctr = SIMD[DType.uint32, 4](idx, 0, 0, 0)
    var rng = philox4x32f[Rounds=7](key, ctr)
    buffer.store(idx * 4, rng) # TODO: bound check

@always_inline
fn cpu_kernel_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int, idx: Int):
    var key = SIMD[DType.uint64, 2](0, 0)
    var ctr = SIMD[DType.uint64, 4](idx, 0, 0, 0)
    var rng = philox4x64f[Rounds=7](key, ctr)
    buffer.store(idx * 4, rng) # TODO: bound check

fn cpu_fill_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int):
    @parameter
    fn closure(i: Int):
        cpu_kernel_32(buffer, size, i)
    parallelize[func=closure](num_work_items=size//4)

fn cpu_fill_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int):
    @parameter
    fn closure(i: Int):
        cpu_kernel_64(buffer, size, i)
    parallelize[func=closure](num_work_items=size//4)
