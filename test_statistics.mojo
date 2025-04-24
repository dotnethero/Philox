from testing import assert_almost_equal
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