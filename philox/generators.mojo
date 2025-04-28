from .generator import PhiloxGenerator
from .stateless import philox4x32, philox4x64, philox4x32f, philox4x64f

alias PhiloxUInt32 = PhiloxGenerator[philox4x32[Rounds = 10]]
alias PhiloxUInt64 = PhiloxGenerator[philox4x64[Rounds = 10]]
alias PhiloxFloat32 = PhiloxGenerator[philox4x32f[Rounds = 10]]
alias PhiloxFloat64 = PhiloxGenerator[philox4x64f[Rounds = 10]]
