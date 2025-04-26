from random import seed, random_ui64
from philox import philox4x32, philox4x64, to_float32, to_float64
from philox.presentation import print_simd, print_array
from philox.testing import get_histogram
from memory import UnsafePointer
from time import perf_counter_ns

fn cpu_kernel_32(buffer: UnsafePointer[Scalar[DType.float32]], size: Int, idx: Int):
    var key = SIMD[DType.uint32, 2](0, 0)
    var ctr = SIMD[DType.uint32, 4](idx, 0, 0, 0)
    var rng = philox4x32[Rounds=7](key, ctr)
    var val = to_float32(rng)
    buffer.store(idx * 4, val) # TODO: bound check

fn cpu_kernel_64(buffer: UnsafePointer[Scalar[DType.float64]], size: Int, idx: Int):
    var key = SIMD[DType.uint64, 2](0, 0)
    var ctr = SIMD[DType.uint64, 4](idx, 0, 0, 0)
    var rng = philox4x64[Rounds=7](key, ctr)
    var val = to_float64(rng)
    buffer.store(idx * 4, val) # TODO: bound check

fn run_test[T: DType, //, cpu_kernel: fn(UnsafePointer[SIMD[T, 1]], Int, Int) -> None]() raises:
    alias iterations = 10
    alias size = 1_000_000_000

    var output_ptr = UnsafePointer[Scalar[T]].alloc(size)

    var start = perf_counter_ns()
    for i in range(iterations):
        for j in range(size // 4):
            cpu_kernel(output_ptr, size, j)

    var end = perf_counter_ns()
    var time_ns = end - start
    print("CPU time:", time_ns / 1_000_000.0 / iterations, "ms")

    for i in range(0, 12):
        print(output_ptr[i], end = " ")
        if (i & 3 == 3):
            print()

fn main() raises:
    print("Philox 4x32:")
    run_test[cpu_kernel_32]()
    # CPU time: 2403.7057 ms | AMD Ryzen 7 5700X

    print("Philox 4x64:")
    run_test[cpu_kernel_64]()
    # CPU time: 3681.977 ms | AMD Ryzen 7 5700X
