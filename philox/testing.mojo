from .streams import Stream16F, Stream32F, Stream64F
from .parallel import fill_parallel_f64, fill_parallel_f32, fill_parallel_f16
from .kernels import fill_kernel_f64, fill_kernel_f32, fill_kernel_f16
from memory import UnsafePointer
from random import rand
from math import ceildiv
from gpu.host import DeviceContext, DeviceBuffer, Dim

fn get_histogram_from_stream_16[bins: Int](seed1: UInt16, seed2: UInt16, samples: Int) -> InlineArray[Int, bins]:
    alias width = 4
    var generator = Stream16F(seed1, seed2)
    var histogram = InlineArray[Int, bins](fill = 0)
    var i = 0
    for _ in range(samples // width):
        var values = generator.next()
        for j in range(width):
            i += 1
            if i > samples:
                break
            var bin = Int(values[j] * bins)
            histogram[bin] += 1
    return histogram

fn get_histogram_from_stream_32[bins: Int](seed1: UInt32, seed2: UInt32, samples: Int) -> InlineArray[Int, bins]:
    alias width = 4
    var generator = Stream32F(seed1, seed2)
    var histogram = InlineArray[Int, bins](fill = 0)
    var i = 0
    for _ in range(samples // width):
        var values = generator.next()
        for j in range(width):
            i += 1
            if i > samples:
                break
            var bin = Int(values[j] * bins)
            histogram[bin] += 1
    return histogram

fn get_histogram_from_stream_64[bins: Int](seed1: UInt64, seed2: UInt64, samples: Int) -> InlineArray[Int, bins]:
    alias width = 4
    var generator = Stream64F(seed1, seed2)
    var histogram = InlineArray[Int, bins](fill = 0)
    var i = 0
    for _ in range(samples // width):
        var values = generator.next()
        for j in range(width):
            i += 1
            if i > samples:
                break
            var bin = Int(values[j] * bins)
            histogram[bin] += 1
    return histogram

fn get_histogram_from_fill_cpu_64[bins: Int](seed1: UInt64, seed2: UInt64, samples: Int) -> InlineArray[Int, bins]:
    var data = UnsafePointer[Float64].alloc(samples)
    fill_parallel_f64(data, samples)
    var histogram = get_histogram_from_array[bins](data, samples)
    data.free()
    return histogram

fn get_histogram_from_fill_cpu_32[bins: Int](seed1: UInt32, seed2: UInt32, samples: Int) -> InlineArray[Int, bins]:
    var data = UnsafePointer[Float32].alloc(samples)
    fill_parallel_f32(data, samples)
    var histogram = get_histogram_from_array[bins](data, samples)
    data.free()
    return histogram

fn get_histogram_from_fill_cpu_16[bins: Int](seed1: UInt16, seed2: UInt16, samples: Int) -> InlineArray[Int, bins]:
    var data = UnsafePointer[Float16].alloc(samples)
    fill_parallel_f16(data, samples)
    var histogram = get_histogram_from_array[bins](data, samples)
    data.free()
    return histogram

fn get_histogram_from_fill_gpu[bins: Int](seed1: UInt64, seed2: UInt64, samples: Int) raises -> InlineArray[Int, bins]:
    alias block_size = 128
    var grid_size = ceildiv(samples // 4, block_size) # we fill 4 values per thread

    var ctx = DeviceContext()
    var output_host = ctx.enqueue_create_host_buffer[DType.float64](samples)
    var output_dev = ctx.enqueue_create_buffer[DType.float64](samples)

    ctx.enqueue_function[fill_kernel_f64](output_dev, samples, grid_dim=grid_size, block_dim=block_size)
    output_dev.enqueue_copy_to(output_host)
    ctx.synchronize()

    var histogram = get_histogram_from_array[bins](output_host.unsafe_ptr(), samples)
    return histogram

fn get_histogram_from_array[T: DType, //, bins: Int](data: UnsafePointer[Scalar[T]], samples: Int) -> InlineArray[Int, bins]:
    var histogram = InlineArray[Int, bins](fill = 0)
    for j in range(samples):
        var bin = Int(data[j] * bins)
        histogram[bin] += 1
    return histogram
