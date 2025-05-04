from .hilo import mulhilo

@always_inline
fn get_M4[U: DType]() -> SIMD[U, 2]:
    @parameter
    if U is DType.uint16:
        return SIMD[U, 2](0x8003, 0x9007)
    elif U is DType.uint32:
        return SIMD[U, 2](0xD2511F53, 0xCD9E8D57)
    elif U is DType.uint64:
        return SIMD[U, 2](0xD2E7470EE14C6C93, 0xCA5A826395121157)
    else:
        constrained[False, "Unsupported type for M4"]()
        return SIMD[U, 2](0, 0)

@always_inline
fn get_W[U: DType]() -> SIMD[U, 2]:
    @parameter
    if U is DType.uint16:
        return SIMD[U, 2](0x9E37, 0x9E38)
    elif U is DType.uint32:
        return SIMD[U, 2](0x9E3779B9, 0xBB67AE85)
    elif U is DType.uint64:
        return SIMD[U, 2](0x9E3779B97F4A7C15, 0xBB67AE8584CAA73B)
    else:
        constrained[False, "Unsupported type for W"]()
        return SIMD[U, 2](0, 0)

@always_inline
fn bump_key_any[U: DType](key: SIMD[U, 2]) -> SIMD[U, 2]:
    alias W = get_W[U]()
    return key + W

@always_inline
fn bump_counter_any[U: DType](key: SIMD[U, 2], ctr: SIMD[U, 4]) -> SIMD[U, 4]:
    alias M4 = get_M4[U]()
    var hilo1 = mulhilo(M4[0], ctr[0])
    var hilo2 = mulhilo(M4[1], ctr[2])
    var a = SIMD[U, 4](hilo2[0], hilo2[1], hilo1[0], hilo1[1])
    var b = SIMD[U, 4](ctr[1], 0, ctr[3], 0)
    var c = SIMD[U, 4](key[0], 0, key[1], 0) # TODO: SIMD shuffle
    return a ^ b ^ c

@always_inline
fn generate_any[U: DType, //, Rounds: UInt8 = 10](key: SIMD[U, 2], ctr: SIMD[U, 4]) -> SIMD[U, 4]:
    var ctrx = ctr
    var keyx = key
    @parameter
    for i in range(0, Rounds):
        ctrx = bump_counter_any(keyx, ctrx);
        keyx = bump_key_any(keyx);
    return ctrx
