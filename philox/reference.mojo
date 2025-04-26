from memory import UnsafePointer

@always_inline
fn cpu_kernel_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int, idx: Int):
    var key = SIMD[DType.uint32, 2](0, 0)
    var ctr = SIMD[DType.uint32, 4](idx, 0, 0, 0)
    var rng = philox4x32[Rounds=7](key, ctr)
    var val = to_float32(rng)
    buffer.store(idx * 4, val) # TODO: bound check

@always_inline
fn cpu_kernel_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int, idx: Int):
    var key = SIMD[DType.uint64, 2](0, 0)
    var ctr = SIMD[DType.uint64, 4](idx, 0, 0, 0)
    var rng = philox4x64[Rounds=7](key, ctr)
    var val = to_float64(rng)
    buffer.store(idx * 4, val) # TODO: bound check

fn cpu_fill_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int):
    for i in range(size // 4):
        cpu_kernel_32(buffer, size, i)

fn cpu_fill_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int):
    for i in range(size // 4):
        cpu_kernel_64(buffer, size, i)
