# Philox in Mojo 🔥

This repository contains an implementation of the Philox Random Number Generator in Mojo programming language. Philox is a counter-based random number generator (RNG) that provides high-quality random numbers with excellent statistical properties.

## Features

- Multiple data type support:
  - `PhiloxUInt32` - 32-bit unsigned integers
  - `PhiloxUInt64` - 64-bit unsigned integers
  - `PhiloxFloat32` - 32-bit floating point numbers
  - `PhiloxFloat64` - 64-bit floating point numbers
- Stateless operation with seed control
- SIMD-optimized implementation

## Usage

### Basic Example

```mojo
from random import seed, random_ui64
from philox import PhiloxFloat64
from philox.presentation import print_simd, print_array

fn main():
    seed()
    var seed1 = random_ui64(0, UInt64.MAX)
    var seed2 = random_ui64(0, UInt64.MAX)

    # Create a generator with specific seeds
    var generator = PhiloxFloat64(seed1, seed2)
    
    # Generate a SIMD vector of 4 random numbers
    var random_quad = generator.next()
    print_simd(random_quad)
    
    # Fill a buffer with random numbers
    var random_array = InlineArray[Float64, 13](uninitialized = True)
    generator.fill(random_array.unsafe_ptr(), len(random_array))
    print_array(random_array)
```

## Playground

```bash
$ magic run mojo playground.mojo
```

## Testing

```bash
$ magic run mojo test
Testing Time: 1.987s
Total Discovered Tests: 7
Passed : 7 (100.00%)
Failed : 0 (0.00%)
Skipped: 0 (0.00%)
```
