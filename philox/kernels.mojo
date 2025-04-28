from .kernel import fill_kernel
from .stateless import philox4x32, philox4x64, philox4x32f, philox4x64f

alias fill_kernel_32 = fill_kernel[philox4x32[Rounds=7]]
alias fill_kernel_64 = fill_kernel[philox4x64[Rounds=7]]
alias fill_kernel_32f = fill_kernel[philox4x32f[Rounds=7]]
alias fill_kernel_64f = fill_kernel[philox4x64f[Rounds=7]]
