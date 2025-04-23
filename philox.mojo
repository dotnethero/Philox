alias UInt32x2 = Tuple[UInt32, UInt32]
alias UInt32x4 = Tuple[UInt32, UInt32, UInt32, UInt32]

alias UInt64x2 = Tuple[UInt64, UInt64]
alias UInt64x4 = Tuple[UInt64, UInt64, UInt64, UInt64]

@always_inline
fn philox_mulhilo(a: UInt32, b: UInt32) -> UInt32x2:
    var ab = UInt64(a) * UInt64(b)
    var hi = UInt32(ab >> 32)
    var lo = UInt32(ab & 0xFFFFFFFF)
    return (hi, lo)

@always_inline
fn philox_mulhilo(a: UInt64, b: UInt64) -> UInt64x2:
    var ab = UInt128(a) * UInt128(b)
    var hi = UInt64(ab >> 64)
    var lo = UInt64(ab & 0xFFFFFFFFFFFFFFFF)
    return (hi, lo)

@always_inline
fn philox4x_bumpkey(key1: UInt32, key2: UInt32) -> UInt32x2:
    alias PHILOX_W_0: UInt32 = 0x9E3779B9
    alias PHILOX_W_1: UInt32 = 0xBB67AE85
    return (key1 + PHILOX_W_0, key2 + PHILOX_W_1)

@always_inline
fn philox4x_bumpkey(key1: UInt64, key2: UInt64) -> UInt64x2:
    alias PHILOX_W_0: UInt64 = 0x9E3779B97F4A7C15
    alias PHILOX_W_1: UInt64 = 0xBB67AE8584CAA73B
    return (key1 + PHILOX_W_0, key2 + PHILOX_W_1)

@always_inline
fn philox4x_round(ctr1: UInt32, ctr2: UInt32, ctr3: UInt32, ctr4: UInt32, key1: UInt32, key2: UInt32) -> UInt32x4:
    alias PHILOX_M4x_0: UInt32 = 0xD2511F53
    alias PHILOX_M4x_1: UInt32 = 0xCD9E8D57
    hi1, lo1 = philox_mulhilo(PHILOX_M4x_0, ctr1)
    hi2, lo2 = philox_mulhilo(PHILOX_M4x_1, ctr3)
    return (hi2 ^ ctr2 ^ key1, lo2, hi1 ^ ctr4 ^ key2, lo1)

@always_inline
fn philox4x_round(ctr1: UInt64, ctr2: UInt64, ctr3: UInt64, ctr4: UInt64, key1: UInt64, key2: UInt64) -> UInt64x4:
    alias PHILOX_M4x_0: UInt64 = 0xD2E7470EE14C6C93
    alias PHILOX_M4x_1: UInt64 = 0xCA5A826395121157
    hi1, lo1 = philox_mulhilo(PHILOX_M4x_0, ctr1)
    hi2, lo2 = philox_mulhilo(PHILOX_M4x_1, ctr3)
    return (hi2 ^ ctr2 ^ key1, lo2, hi1 ^ ctr4 ^ key2, lo1)

@always_inline
fn philox[R: UInt32 = 10](key: UInt32x2, ctr:UInt32x4) -> UInt32x4:
    ctr1, ctr2, ctr3, ctr4 = ctr
    key1, key2 = key

    @parameter
    for i in range(0, R):
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
        key1, key2 = philox4x_bumpkey(key1, key2);

    return (ctr1, ctr2, ctr3, ctr4)

@always_inline
fn philox[R: UInt32 = 10](key: UInt64x2, ctr:UInt64x4) -> UInt64x4:
    ctr1, ctr2, ctr3, ctr4 = ctr
    key1, key2 = key

    @parameter
    for i in range(0, R):
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
        key1, key2 = philox4x_bumpkey(key1, key2);

    return (ctr1, ctr2, ctr3, ctr4)

from memory import Span

struct PhiloxGenerator[R: UInt32 = 10]:
    var key: UInt64x2
    var counter: UInt64x4

    fn __init__(out self, seed1: UInt64, seed2: UInt64):
        self.key = UInt64x2(seed1, seed2)
        self.counter = UInt64x4(0, 0, 0, 0)

    fn increment_counter(mut self):
        var c0 = self.counter[0] + 1
        var c1 = self.counter[1] + UInt64(c0 == 0)
        var c2 = self.counter[2] + UInt64(c0 == 0 and c1 == 0)
        var c3 = self.counter[3] + UInt64(c0 == 0 and c1 == 0 and c2 == 0)
        self.counter = (c0, c1, c2, c3)

    fn fill(mut self, mut buffer: Span[mut=True, UInt64]):
        var ptr = buffer.unsafe_ptr()
        var size = len(buffer)
        var iterations = size // 4
        var leftover = size - iterations * 4

        for i in range(0, iterations):
            var result = philox(self.key, self.counter)
            var offset = i * 4
            ptr[offset + 0] = result[0]
            ptr[offset + 1] = result[1]
            ptr[offset + 2] = result[2]
            ptr[offset + 3] = result[3]
            self.increment_counter()

        if leftover > 0:
            var result = philox(self.key, self.counter)
            var offset = iterations * 4
            if leftover > 0:
                ptr[offset + 0] = result[0]
            if leftover > 1:
                ptr[offset + 1] = result[1]
            if leftover > 2:
                ptr[offset + 2] = result[2]
            self.increment_counter()


from random import seed, random_ui64

fn main():
    seed()
    var seed1 = 0 # random_ui64(0, 0xFFFFFFFF);
    var seed2 = 0 # random_ui64(0, 0xFFFFFFFF);
    var state = PhiloxGenerator(seed1, seed2)
    var list = InlineArray[UInt64, 12](fill = 10)
    var buffer = Span(list)
    state.fill(buffer)
    for i in range(0, len(list)):
        print(list[i], end = " ")
        if (i % 4 == 3):
            print()
    
