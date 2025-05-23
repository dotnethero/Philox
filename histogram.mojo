from random import seed, random_ui64
from philox.testing import get_histogram_from_fill_cpu_16

fn main() raises:
    alias bins = 20
    alias samples = 10_000_000
    alias max_deviation_percent = 0.5

    var histogram = get_histogram_from_fill_cpu_16[bins](54321, 98765, samples)
    var expected = samples / bins
    print("Expected per bin:", expected)
    
    for i in range(bins):
        var deviation_percent = abs(histogram[i] - expected) * 100.0 / expected
        var result = String("OK") if deviation_percent < max_deviation_percent else "Error"
        var log = String.format("Bin {}: {}, Deviation: {}% - {}", i, histogram[i], deviation_percent, result)
        print(log)
