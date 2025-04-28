from memory import UnsafePointer
from .stateless import generate_u32, generate_u64, generate_f32, generate_f64

struct Stream[T: DType, U: DType, //, Gen: fn(SIMD[T, 2], SIMD[T, 4]) -> SIMD[U, 4]]:
    var key: SIMD[T, 2]
    var idx: Int

    fn __init__(out self, seed1: SIMD[T, 1], seed2: SIMD[T, 1]):
        self.key = SIMD[T, 2](seed1, seed2)
        self.idx = 0

    @always_inline
    fn next(mut self) -> SIMD[U, 4]:
        var ctr = SIMD[T, 4](self.idx, 0, 0, 0)
        var rng = Gen(self.key, ctr)
        self.idx += 1
        return rng

    @always_inline
    fn fill(mut self, ptr: UnsafePointer[Scalar[U]], size: UInt32):
        var iterations = size // 4
        var leftover = size - iterations * 4
        
        for i in range(0, iterations):
            var ctr = SIMD[T, 4](self.idx, 0, 0, 0)
            var result = Gen(self.key, ctr)
            var offset = i * 4
            ptr.store(offset, result)
            self.idx += 1

        if leftover > 0:
            var ctr = SIMD[T, 4](self.idx, 0, 0, 0)
            var result = Gen(self.key, ctr)
            var offset = iterations * 4
            for i in range(0, leftover):
                ptr[offset + i] = result[i]
            self.idx += 1

alias Stream32U = Stream[generate_u32[10]]
alias Stream64U = Stream[generate_u64[10]]
alias Stream32F = Stream[generate_f32[10]]
alias Stream64F = Stream[generate_f64[10]]
