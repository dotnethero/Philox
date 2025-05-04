from testing import assert_almost_equal, assert_true
from philox.streams import Stream64F
from philox.testing import get_histogram_from_stream, get_histogram_from_fill_parallel

fn test_basic_statistics() raises:
    alias samples = 10_000_000
    alias numbers_per_sample = 4
    var generator = Stream64F(123451, 67890)
    var sum = 0.0
    var sum_squared = 0.0
    
    for _ in range(samples):
        var values = generator.next()
        var values_squared = values * values
        sum += values.reduce_add()
        sum_squared += values_squared.reduce_add()

    var mean = sum / (samples * numbers_per_sample)
    var variance = (sum_squared / (samples * numbers_per_sample)) - (mean * mean)
    assert_almost_equal(mean, 0.5, atol=0.001)
    assert_almost_equal(variance, 1.0 / 12.0, atol=0.001)

fn test_histogram_uniformity_stream() raises:
    alias bins = 20
    alias samples = 10_000_000
    var histogram = get_histogram_from_stream[bins](54321, 98765, samples)
    histogram_uniformity_for[bins](histogram, samples)

fn test_histogram_uniformity_fill_cpu() raises:
    alias bins = 20
    alias samples = 10_000_000
    var histogram = get_histogram_from_fill_parallel[bins](54321, 98765, samples)
    histogram_uniformity_for[bins](histogram, samples)

fn histogram_uniformity_for[bins: Int](histogram: InlineArray[Int, bins], samples: Int) raises:
    alias max_deviation_percent = 0.5

    var expected_per_bin = samples / bins
    
    for i in range(bins):
        var deviation_percent = abs(histogram[i] - expected_per_bin) * 100.0 / expected_per_bin
        var log = String.format("Bin {}: Deviation: {}% - {}", i, deviation_percent, String("OK") if deviation_percent < max_deviation_percent else "Error")
        print(log)

    for i in range(bins):
        var deviation_percent = abs(histogram[i] - expected_per_bin) * 100.0 / expected_per_bin
        var error = String.format("Bin {}: Deviation: {}% > {}%", i, deviation_percent, max_deviation_percent)
        assert_true(deviation_percent < max_deviation_percent, error)

fn test_chi_square_stream() raises:
    alias bins = 100
    alias samples = 10_000_000
    var histogram = get_histogram_from_stream[bins](54321, 98765, samples)
    chi_square_for[bins](histogram, samples)

fn test_chi_square_fill_cpu() raises:
    alias bins = 100
    alias samples = 10_000_000
    var histogram = get_histogram_from_fill_parallel[bins](54321, 98765, samples)
    chi_square_for[bins](histogram, samples)

fn chi_square_for[bins: Int](histogram: InlineArray[Int, bins], samples: Int) raises:
    alias degrees_of_freedom = bins - 1
    alias expected_chi_square = Float64(degrees_of_freedom)
    alias chi_square_std_dev = (2.0 * degrees_of_freedom) ** 0.5
    alias max_acceptable = expected_chi_square + 1 * chi_square_std_dev

    # Chi-square test for uniformity
    var expected_per_bin = samples / bins
    var chi_square = 0.0
    for i in range(bins):
        var diff = Float64(histogram[i] - expected_per_bin)
        chi_square += (diff * diff) / expected_per_bin

    print("Chi-square value:", chi_square)
    print("Expected value:", expected_chi_square)
    print("Max acceptable:", max_acceptable)
    assert_true(chi_square < max_acceptable, "Chi-square test failed: distribution may not be uniform")
