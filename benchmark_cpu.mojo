from time import perf_counter_ns
from random import seed, rand
from memory import UnsafePointer
from philox.parallel import fill_parallel_f32, fill_parallel_f64

fn bench[fut: fn() capturing -> None](iterations: Int):
    var start = perf_counter_ns()
    for _ in range(iterations):
        fut() # Function under test

    var end = perf_counter_ns()
    var time_ns = end - start
    print("CPU time:", time_ns / 1_000_000.0 / iterations, "ms")

fn run_test[T: DType, //, cpu_kernel: fn(UnsafePointer[SIMD[T, 1]], Int) -> None]() raises:
    alias size = 10_000_000
    var output_ptr = UnsafePointer[Scalar[T]].alloc(size)

    fn baseline() capturing:
        rand(output_ptr, size)
        
    fn fut() capturing:
        cpu_kernel(output_ptr, size)

    bench[fut](10)
    bench[baseline](10)

    output_ptr.free()

fn main() raises:
    print("Philox 4x32:")
    run_test[fill_parallel_f32]()
    # CPU time:   4.9347 ms | AMD Ryzen 7 5700X
    # CPU time: 600.0941 ms | Baseline: rand

    print("Philox 4x64:")
    run_test[fill_parallel_f64]()
    # CPU time:   6.093 ms | AMD Ryzen 7 5700X
    # CPU time: 613.295 ms | Baseline: rand
