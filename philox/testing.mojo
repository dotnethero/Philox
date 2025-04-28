from .streams import Stream64F

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
