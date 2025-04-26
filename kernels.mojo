from math import ceildiv
from philox import philox4x64, to_float64
from gpu import thread_idx, global_idx
from gpu.host import DeviceContext, DeviceBuffer, Dim
from memory import UnsafePointer

fn fill_kernel(buffer: UnsafePointer[Scalar[DType.float64]], size: Int):
    var idx = global_idx.x
    var key = SIMD[DType.uint64, 2](0, 0)
    var ctr = SIMD[DType.uint64, 4](idx, 0, 0, 0)
    var rng = philox4x64[Rounds=7](key, ctr)
    var val = to_float64(rng)
    buffer.store(idx * 4, val) # TODO: bound check

fn main() raises:
    alias iterations = 100
    alias size = 1_000_000_000
    alias block_size = 256
    alias grid_size = ceildiv(size // 4, block_size) # we fill 4 values per thread
    var ctx = DeviceContext()
    var output_host = ctx.enqueue_create_host_buffer[DType.float64](size)
    var output_dev = ctx.enqueue_create_buffer[DType.float64](size)

    fn fut(ctx: DeviceContext) raises capturing:
        ctx.enqueue_function[fill_kernel](output_dev, size, grid_dim=grid_size, block_dim=block_size) # TODO: compile?

    var time_ns = ctx.execution_time[fut](iterations)
    print("Kernel time:", time_ns / 1_000_000.0 / iterations, "ms")

    # ctx.enqueue_copy(output_dev, output_host) # TODO: doesn't work?
    
    output_dev.enqueue_copy_to(output_host)
    ctx.synchronize()

    for i in range(0, 12):
        print(output_host[i], end = " ")
        if (i & 3 == 3):
            print()