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
from philox import PhiloxFloat64

fn main():
    # Create a generator with specific seeds
    var generator = PhiloxFloat64(seed1=0, seed2=0)
    
    # Generate a SIMD vector of 4 random numbers
    var random_values = generator.next()
    
    # Fill a buffer with random numbers
    var list = InlineArray[Float64, 4](fill=0)
    generator.fill(list.unsafe_ptr(), len(list))
```

## Playground

```bash
$ magic run mojo playground.mojo
0.08723912359911234 0.8559722074780218 0.8433753733711671 0.4937852944535579 
0.011546754286331451 0.24154919656271812 0.11142585551493811 0.5644146216071337 
0.5023796042735054 0.27760557688455356 0.946544292789214 0.9860662462666749 
0.25382274039248487 0.19505057563074701 0.7117099077319216 0.1312646653406948 
```

## Testing

```bash
$ magic run mojo test test_zero_seed.mojo
Testing Time: 1.844s
Total Discovered Tests: 4
Passed : 4 (100.00%)
Failed : 0 (0.00%)
Skipped: 0 (0.00%)
```
