from random import seed, random_ui64
from philox.streams import Stream16F, Stream32F, Stream64F

fn main():
    seed()
    var seed1 = 0 # UInt16(random_ui64(0, UInt64(UInt16.MAX)))
    var seed2 = 0 # UInt16(random_ui64(0, UInt64(UInt16.MAX)))

    # Create a generator with specific seeds
    var generator = Stream16F(seed1, seed2)
    
    # Generate a SIMD vector of 4 random numbers
    var random_quad = generator.next()
    print(random_quad)
    
    # Fill a buffer with random numbers
    var random_array = InlineArray[Float16, 42](uninitialized = True)
    generator.fill(random_array.unsafe_ptr(), len(random_array))

    for i in range(len(random_array)):
        print(random_array[i], end = " ")
        if i % 4 == 3:
            print()
    print()
