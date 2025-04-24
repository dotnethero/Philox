from testing import assert_equal
from philox import PhiloxUInt64, PhiloxFloat64

def test_next_uint64():
    var generator = PhiloxUInt64(0, 0)
    var value = generator.next()
    var expected = SIMD[DType.uint64, 4](1609277786247541068, 15789900245555285980, 15557529670647158635, 9108730954146095675)
    assert_equal(value, expected)

def test_fill_uint64():
    var generator = PhiloxUInt64(0, 0)
    var list = List[UInt64](0, 0, 0, 0)
    generator.fill(list.unsafe_ptr(), len(list))
    var expected = List[UInt64](1609277786247541068, 15789900245555285980, 15557529670647158635, 9108730954146095675)
    assert_equal(list, expected)

def test_next_float64():
    var generator = PhiloxFloat64(0, 0)
    var value = generator.next()
    var expected = SIMD[DType.float64, 4](0.08723912359911234, 0.8559722074780218, 0.8433753733711671, 0.4937852944535579)
    assert_equal(value, expected)

def test_fill_float64():
    var generator = PhiloxFloat64(0, 0)
    var list = List[Float64](0, 0, 0, 0)
    generator.fill(list.unsafe_ptr(), len(list))
    var expected = List[Float64](0.08723912359911234, 0.8559722074780218, 0.8433753733711671, 0.4937852944535579)
    assert_equal(list, expected)
