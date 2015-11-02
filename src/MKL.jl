module MKL

const debug = true

if debug println("MKL : Intel MKL wrapper") end

Libdl.dlopen(:libmkl_rt) # necessary to preload - don't know why
const libmkl   = :libmkl_rt
const libvml   = :libmkl_vml_avx

# VML
include("vml_service.jl")
include("vml_arithmetic.jl")
include("vml_power_root.jl")

# BLAS
include("blas_level_1.jl")
include("blas_level_2.jl")

# LAPACK

end
