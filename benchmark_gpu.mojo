from math import ceildiv
from philox.kernels import fill_kernel_f16, fill_kernel_f32, fill_kernel_f64, fill_kernel_f16_unroll_2, fill_kernel_f32_unroll_2
from gpu import thread_idx, global_idx
from gpu.host import DeviceContext, DeviceBuffer, Dim
from memory import UnsafePointer

fn run_test[T: DType, //, kernel: fn(UnsafePointer[SIMD[T, 1]], Int) -> None, UnrollFactor: Int = 1]() raises:
    alias iterations = 10
    alias size = 1_000_000_000
    alias block_size = 64
    alias elements_per_thread = 4 * UnrollFactor
    alias grid_size = ceildiv(size // elements_per_thread, block_size) # we fill 4 values per thread

    var ctx = DeviceContext()
    var output_host = ctx.enqueue_create_host_buffer[T](size)
    var output_dev = ctx.enqueue_create_buffer[T](size)

    fn fut(ctx: DeviceContext) raises capturing:
        ctx.enqueue_function[kernel](output_dev, size, grid_dim=grid_size, block_dim=block_size) # TODO: compile?

    var time_ns = ctx.execution_time[fut](iterations)
    print("Kernel time:", time_ns / 1_000_000.0 / iterations, "ms")

    output_dev.enqueue_copy_to(output_host) # ctx.enqueue_copy(output_dev, output_host) ?
    ctx.synchronize()
    

fn main() raises:
    print("Philox 4x16:")
    run_test[fill_kernel_f16]()
    # Kernel time: 14.8379 ms | RTX 4060Ti

    print("Philox 4x16, manual unroll:")
    run_test[fill_kernel_f16_unroll_2, UnrollFactor = 2]()
    # Kernel time: 14.8379 ms | RTX 4060Ti

    print("Philox 4x32:")
    run_test[fill_kernel_f32]()
    # Kernel time: 14.8379 ms | RTX 4060Ti
    
    print("Philox 4x32, manual unroll:")
    run_test[fill_kernel_f32_unroll_2, UnrollFactor = 2]()
    # Kernel time: 14.8379 ms | RTX 4060Ti

    print("Philox 4x64:")
    run_test[fill_kernel_f64]()
    # Kernel time: 41.9962 ms | RTX 4060Ti

