# Philox in Mojo 🔥

This repository contains an implementation of the Philox Random Number Generator in Mojo programming language. Philox is a counter-based random number generator (RNG) that provides high-quality random numbers with excellent statistical properties.

## Features

- Stateless generators
- Statefull CPU streams
- Parallel CPU fill functions
- Reusable GPU kernel
- GPU fill functions

## Usage

### Basic Example

```mojo
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
```

## Benchmarks

CPU benchmark is against built-in `rand` function

```bash
$ magic run cpu
Philox 4x32:
CPU time: 9.581642800000001 ms
CPU time: 602.7851763 ms
Philox 4x64:
CPU time: 11.082465899999999 ms
CPU time: 579.7956587 ms
```

GPU benchmark measures only kernel time, without memory copy to host.

```bash
$ magic run gpu
Philox 4x32:
Kernel time: 14.6847747 ms
Philox 4x64:
Kernel time: 44.880999700000004 ms
```

```bash
$ ./benchmark_curanddx.sh 
Performance Statistics:
Average time: 14.92 ms
Standard deviation: 0.13 ms
```

## Testing

Tests include statistics verification for mean, variance, histogram uniformity, and chi-square test

```bash
$ magic run test
Testing Time: 2.187s

Total Discovered Tests: 5

Passed : 5 (100.00%)
Failed : 0 (0.00%)
Skipped: 0 (0.00%)
```
