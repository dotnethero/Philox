from random import seed, random_ui64
from philox import PhiloxFloat64
from philox.presentation import print_simd, print_array

fn test_histogram(bins: Int = 20):
    var generator = PhiloxFloat64(54321, 98765)
    var samples = 10_000_000
    var histogram = InlineArray[Int, 20](0)
    
    for i in range(samples):
        var values = generator.next()
        for j in range(4):
            var bin = Int(values[j] * bins)
            if bin == bins:  # Edge case for value == 1.0
                bin = bins - 1
            histogram[bin] += 1
    
    var expected = samples * 4 / bins
    print("Expected per bin:", expected)
    
    for i in range(bins):
        print("Bin", i, ":", histogram[i], 
              "Deviation:", (histogram[i] - expected) / Float64(expected) * 100, "%")

fn main():
    test_histogram()

