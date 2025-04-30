from memory import UnsafePointer

@always_inline
fn generate_inplace[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4],
    UnrollFactor: Int = 4](buffer: UnsafePointer[Scalar[U]], size: Int, idx: Int):

    var key = SIMD[T, 2](0, 0) # TODO: seed

    @parameter
    for i in range(0, UnrollFactor):
        var ctr = SIMD[T, 4](idx, i, 0, 0)
        var rng = Gen(key, ctr)
        buffer.store(idx * 4 + i * 4, rng) # TODO: check bounds

@always_inline
fn generate_inplace_4x4[ # Manually unrolled
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int, idx: Int):

    var key = SIMD[T, 2](0, 0) # TODO: seed
    var ctr0 = SIMD[T, 4](idx, 0, 0, 0)
    var ctr1 = SIMD[T, 4](idx, 1, 0, 0)
    var ctr2 = SIMD[T, 4](idx, 2, 0, 0)
    var ctr3 = SIMD[T, 4](idx, 3, 0, 0)
    var rng0 = Gen(key, ctr0)
    var rng1 = Gen(key, ctr1)
    var rng2 = Gen(key, ctr2)
    var rng3 = Gen(key, ctr3)
    buffer.store(idx * 4 + 0 * 4, rng0)
    buffer.store(idx * 4 + 1 * 4, rng1)
    buffer.store(idx * 4 + 2 * 4, rng2)
    buffer.store(idx * 4 + 3 * 4, rng3)