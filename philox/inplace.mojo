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
        buffer.store(idx * 4 * UnrollFactor + i * 4, rng) # TODO: check bounds

@always_inline
fn generate_inplace_unroll_2[
    T: DType,
    U: DType, //,
    Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]](buffer: UnsafePointer[Scalar[U]], size: Int, idx: Int):

    var key = SIMD[T, 2](0, 0) # TODO: seed
    var ctr0 = SIMD[T, 4](idx, 0, 0, 0)
    var ctr1 = SIMD[T, 4](idx, 1, 0, 0)
    var rng0 = Gen(key, ctr0)
    var rng1 = Gen(key, ctr1)
    buffer.store(idx * 8 + 0 * 4, rng0)
    buffer.store(idx * 8 + 1 * 4, rng1)