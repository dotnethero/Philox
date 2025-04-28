from testing import assert_equal, assert_almost_equal
from philox.stateless import generate_u64, generate_f64

def test_next_uint64():
    var value = generate_u64(0, 0)
    var expected = SIMD[DType.uint64, 4](1609277786247541068, 15789900245555285980, 15557529670647158635, 9108730954146095675)
    assert_equal(value, expected)

def test_next_float64():
    var value = generate_f64(0, 0)
    var expected = SIMD[DType.float64, 4](0.08723912359911234, 0.8559722074780218, 0.8433753733711671, 0.4937852944535579)
    assert_equal(value, expected)
