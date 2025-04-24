from testing import assert_almost_equal, assert_true
from philox import PhiloxFloat64

fn test_basic_statistics() raises:
    alias samples = 10_000_000
    alias numbers_per_sample = 4
    var generator = PhiloxFloat64(123451, 67890)
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

fn test_histogram_uniformity() raises:
    alias bins = 20
    alias samples = 10_000_000
    alias numbers_per_sample = 4
    alias total_numbers = samples * numbers_per_sample
    
    var generator = PhiloxFloat64(54321, 98765)
    var histogram = InlineArray[Int, 20](0)
    
    for _ in range(samples):
        var values = generator.next()
        for j in range(numbers_per_sample):
            var bin = Int(values[j] * bins)
            if bin == bins:  # Edge case for value == 1.0
                bin = bins - 1
            histogram[bin] += 1
    
    var expected_per_bin = total_numbers / bins
    
    # Chi-square test for uniformity
    var chi_square = 0.0
    for i in range(bins):
        var diff = Float64(histogram[i] - expected_per_bin)
        chi_square += (diff * diff) / expected_per_bin
    
    # For a uniform distribution, chi-square should be approximately equal to df
    # with a standard deviation of sqrt(2*df)
    var degrees_of_freedom = bins - 1
    var expected_chi_square = Float64(degrees_of_freedom)
    var chi_square_std_dev = (2.0 * degrees_of_freedom) ** 0.5
    
    # Allow for 3 standard deviations (99.7% confidence)
    var max_acceptable = expected_chi_square + 3 * chi_square_std_dev
    
    print("Chi-square value:", chi_square)
    print("Expected value:", expected_chi_square)
    print("Max acceptable:", max_acceptable)
    
    assert_true(chi_square < max_acceptable, "Chi-square test failed: distribution may not be uniform")

    # Also check individual bin deviations
    for i in range(bins):
        var deviation_percent = abs(histogram[i] - expected_per_bin) * 100.0 / expected_per_bin
        assert_true(deviation_percent < 0.25, "Bin " + String(i) + " has deviation " + String(deviation_percent) + "% larger than 0.25%")