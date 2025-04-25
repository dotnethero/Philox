fn print_simd[T: DType, Width: Int](items: SIMD[T, Width]):
    @parameter
    for i in range(Width):
        var item = items[i]
        print(item, end = " ")
    print()

fn print_array[T: CollectionElement & Writable, Size: Int](items: InlineArray[T, Size]):
    @parameter
    for i in range(Size):
        var item = items.unsafe_get(i)
        print(item, end = " ")
        if (i & 3 == 3):
            print()
    if (Size & 3 != 0):
        print()

fn print_list[T: CollectionElement & Writable](items: List[T]):
    var size = len(items)
    for i in range(size):
        var item = items.unsafe_get(i)
        print(item, end = " ")
        if (i & 3 == 3):
            print()
    if (size & 3 != 0):
        print()