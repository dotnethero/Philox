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
