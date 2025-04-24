from random import seed, random_ui64
from generators import PhiloxFloat64

fn main():
    seed()
    var seed1 = 0 # random_ui64(0, 0xFFFFFFFF);
    var seed2 = 0 # random_ui64(0, 0xFFFFFFFF);
    var generator = PhiloxFloat64(seed1, seed2)
    var list = InlineArray[Float64, 12](fill = 0)
    generator.fill(list.unsafe_ptr(), len(list))
    
    for i in range(0, len(list)):
        print(list[i], end = " ")
        if (i % 4 == 3):
            print()
