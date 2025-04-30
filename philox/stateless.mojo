from .core import bump_key, bump_counter
from .converters import asfloat

# Keys
alias UInt32x2 = SIMD[DType.uint32, 2]
alias UInt64x2 = SIMD[DType.uint64, 2]

# Counters and outputs
alias UInt32x4 = SIMD[DType.uint32, 4]
alias UInt64x4 = SIMD[DType.uint64, 4]
alias Float32x4 = SIMD[DType.float32, 4]
alias Float64x4 = SIMD[DType.float64, 4]

@always_inline
fn generate_u32[Rounds: UInt32 = 10](key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, Rounds):
        ctrx = bump_counter(keyx, ctrx);
        keyx = bump_key(keyx);
    return ctrx

@always_inline
fn generate_u64[Rounds: UInt32 = 10](key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, Rounds):
        ctrx = bump_counter(keyx, ctrx);
        keyx = bump_key(keyx);
    return ctrx

@always_inline
fn generate_f32[Rounds: UInt32 = 10](key: UInt32x2, ctr: UInt32x4) -> Float32x4:
    var rng = generate_u32[Rounds](key, ctr)
    return asfloat(rng)

@always_inline
fn generate_f64[Rounds: UInt32 = 10](key: UInt64x2, ctr: UInt64x4) -> Float64x4:
    var rng = generate_u64[Rounds](key, ctr)
    return asfloat(rng)
