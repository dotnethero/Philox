from .helpers import mulhilo, asfloat

alias UInt32x2 = SIMD[DType.uint32, 2]
alias UInt32x4 = SIMD[DType.uint32, 4]

alias UInt64x2 = SIMD[DType.uint64, 2]
alias UInt64x4 = SIMD[DType.uint64, 4]

alias Float32x = SIMD[DType.float32, _]
alias Float64x = SIMD[DType.float64, _]

@always_inline
fn bump_key(key: UInt32x2) -> UInt32x2:
    alias W = UInt32x2(0x9E3779B9, 0xBB67AE85)
    return key + W

@always_inline
fn bump_key(key: UInt64x2) -> UInt64x2:
    alias W = UInt64x2(0x9E3779B97F4A7C15, 0xBB67AE8584CAA73B)
    return key + W

@always_inline
fn bump_counter(key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    alias M4 = UInt32x2(0xD2511F53, 0xCD9E8D57)
    var hilo1 = mulhilo(M4[0], ctr[0])
    var hilo2 = mulhilo(M4[1], ctr[2])
    var a = UInt32x4(hilo2[0], hilo2[1], hilo1[0], hilo1[1])
    var b = UInt32x4(ctr[1], 0, ctr[3], 0)
    var c = UInt32x4(key[0], 0, key[1], 0)
    return a ^ b ^ c

@always_inline
fn bump_counter(key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    alias M4 = UInt64x2(0xD2E7470EE14C6C93, 0xCA5A826395121157)
    var hilo1 = mulhilo(M4[0], ctr[0])
    var hilo2 = mulhilo(M4[1], ctr[2])
    var a = UInt64x4(hilo2[0], hilo2[1], hilo1[0], hilo1[1])
    var b = UInt64x4(ctr[1], 0, ctr[3], 0)
    var c = UInt64x4(key[0], 0, key[1], 0)
    return a ^ b ^ c

@always_inline
fn philox4x32[Rounds: UInt32 = 10](key: UInt32x2, ctr: UInt32x4) -> UInt32x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, Rounds):
        ctrx = bump_counter(keyx, ctrx);
        keyx = bump_key(keyx);
    return ctrx

@always_inline
fn philox4x64[Rounds: UInt32 = 10](key: UInt64x2, ctr: UInt64x4) -> UInt64x4:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, Rounds):
        ctrx = bump_counter(keyx, ctrx);
        keyx = bump_key(keyx);
    return ctrx

@always_inline
fn philox4x32f[Rounds: UInt32 = 10](key: UInt32x2, ctr: UInt32x4) -> Float32x[4]:
    var rng = philox4x32[Rounds](key, ctr)
    return asfloat(rng)

@always_inline
fn philox4x64f[Rounds: UInt32 = 10](key: UInt64x2, ctr: UInt64x4) -> Float64x[4]:
    var rng = philox4x64[Rounds](key, ctr)
    return asfloat(rng)
