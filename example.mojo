from random import seed, random_ui64
from philox.streams import Stream64F

fn main():
    seed()
    var seed1 = random_ui64(0, UInt64.MAX)
    var seed2 = random_ui64(0, UInt64.MAX)

    # Create a generator with specific seeds
    var generator = Stream64F(seed1, seed2)
    
    # Generate a SIMD vector of 4 random numbers
    var random_quad = generator.next()
    print(random_quad)
    
    # Fill a buffer with random numbers
    var random_array = InlineArray[Float64, 42](uninitialized = True)
    generator.fill(random_array.unsafe_ptr(), len(random_array))
    print(random_array[0])
