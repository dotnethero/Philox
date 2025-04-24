from memory import UnsafePointer

alias RngKey = SIMD[_, 2]
alias RngCounter = SIMD[_, 4]
alias RngValue = SIMD[_, 4]

@always_inline
fn increment[T: DType](ctr: RngCounter[T]) -> RngCounter[T]:
    var c0 = ctr[0] + 1 # TODO: Skip overflow?
    var c1 = ctr[1] + Scalar[T](c0 == 0)
    var c2 = ctr[2] + Scalar[T](c0 == 0 and c1 == 0)
    var c3 = ctr[3] + Scalar[T](c0 == 0 and c1 == 0 and c2 == 0)
    return RngCounter[T](c0, c1, c2, c3)

@register_passable
struct PhiloxGenerator[
    T: DType, # Underlying type
    U: DType, # Target type
    Philox: fn(RngKey[T], RngCounter[T]) -> RngValue[T],
    Map: fn(RngValue[T]) -> RngValue[U]]:

    var key: RngKey[T]
    var counter: RngCounter[T]

    fn __init__(out self, seed1: Scalar[T], seed2: Scalar[T]):
        self.key = RngKey[T](seed1, seed2)
        self.counter = RngCounter[T](0, 0, 0, 0)

    @always_inline
    fn next(mut self) -> RngValue[U]:
        var value = Map(Philox(self.key, self.counter))
        self.counter = increment(self.counter)
        return value

    @always_inline
    fn fill(mut self, ptr: UnsafePointer[Scalar[U]], size: UInt32):
        var iterations = size // 4
        var leftover = size - iterations * 4
        
        for i in range(0, iterations):
            var result = Map(Philox(self.key, self.counter))
            var offset = i * 4
            ptr.store(offset, result)
            self.counter = increment(self.counter)

        if leftover > 0:
            var result = Map(Philox(self.key, self.counter))
            var offset = iterations * 4
            for i in range(0, leftover):
                ptr[offset + i] = result[i]
            self.counter = increment(self.counter)
