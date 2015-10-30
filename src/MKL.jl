module MKL

Libdl.dlopen(:libmkl_rt) # necessary to preload - don't know why
const libmkl   = :libmkl_rt
const libvml   = :libmkl_vml_avx

include("blas_level_1.jl")
include("vml_service.jl")
include("vml_arithmetic.jl")
include("vml_power_root.jl")

end
