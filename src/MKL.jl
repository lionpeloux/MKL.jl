module MKL

println("MKL : Intel MKL wrapper")
const prefix = :mkl_

Libdl.dlopen(:libmkl_rt) # necessary to preload - don't know why
const libmkl   = :libmkl_rt
const libvml   = :libmkl_vml_avx

# VML
include("vml_service.jl")
include("vml_arithmetic.jl")
include("vml_power_root.jl")

# BLAS
include("blas_level_1.jl")

# LAPACK

# this way re-export submodules to the MKL namespace.
# using .BLAS, .VML

end
