module MKL

const libmkl   = :libmkl_rt

include("blas_level_1.jl")
include("vml_service.jl")
include("vml_arithmeticjl")
include("vml_power_root.jl")

end
