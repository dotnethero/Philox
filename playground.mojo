from random import seed, random_ui64
from philox import PhiloxFloat64
from philox.presentation import print_simd, print_array

fn main():
    seed()
    var seed1 = 0 # random_ui64(0, 0xFFFFFFFF);
    var seed2 = 0 # random_ui64(0, 0xFFFFFFFF);
    var generator = PhiloxFloat64(seed1, seed2)
    var list = InlineArray[Float64, 12](fill = 0)

    generator.fill(list.unsafe_ptr(), len(list))
    print_array(list)

    var next = generator.next()
    print_simd(next)

