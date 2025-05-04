from .streams import Stream64F
from .parallel import fill_parallel_f64
from memory import UnsafePointer
from random import rand

fn get_histogram[bins: Int](seed1: UInt64, seed2: UInt64, samples: Int) -> InlineArray[Int, bins]:
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

fn get_histogram_from_array[bins: Int](seed1: UInt64, seed2: UInt64, samples: Int) -> InlineArray[Int, bins]:
    var data = UnsafePointer[Float64].alloc(samples)
    fill_parallel_f64(data, samples)
    var histogram = InlineArray[Int, bins](fill = 0)
    for j in range(samples):
        var bin = Int(data[j] * bins)
        if bin == 0 and j > samples - 100:
            print(data[j])
        histogram[bin] += 1
    data.free()
    return histogram
