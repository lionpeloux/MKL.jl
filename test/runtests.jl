# push!(LOAD_PATH, "/Users/Lionel/Documents/2 - pro/3 - ENPC/5 - thèse/05 - elastica/MKL")
using Base.Test
import MKL

# BLAS LEVEL 1
##############

## ?asum
res = mkl_asum(4,Float32[1,2,3,4],1)
@test  res == 10 && typeof(res) == Float32
res = mkl_asum(4,Float64[1,2,3,4],1)
@test  res == 10 && typeof(res) == Float64

## ?axpy!
res = mkl_axpy!(4,convert(Float32,2.0),Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
@test  res == Float32[1,3,5,7] && typeof(res) == Vector{Float32}
res = mkl_axpy!(4,convert(Float64,2.0),Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
@test  res == Float64[1,3,5,7] && typeof(res) == Vector{Float64}

## ?copy!
res = mkl_copy!(4,Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
@test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
res = mkl_copy!(4,Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
@test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}

## ?dot
res = mkl_dot(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
@test  res == 30 && typeof(res) == Float32
res = mkl_dot(4,Float64[1,2,3,4],1,Float64[1,2,3,4],1)
@test  res == 30 && typeof(res) == Float64

## sdot
res = mkl_sdot(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
@test  res == 30 && typeof(res) == Float64

## nrm2
res = mkl_nrm2(4,Float32[1,2,3,4],1)
@test  res == convert(Float32,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float32
res = mkl_nrm2(4,Float64[1,2,3,4],1)
@test  res == convert(Float64,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float64

## scal!
res = mkl_scal!(4,convert(Float32,2.0),Float32[1,2,3,4],1)
@test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
res = mkl_scal!(4,convert(Float64,2.0),Float64[1,2,3,4],1)
@test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}


# MATH VECTOR LIBRARY
#####################

## Add!
res = mkl_add!(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
@test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
res = mkl_add!(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
@test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}

# Sub!
res = mkl_sub!(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
@test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
res = mkl_sub!(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
@test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}

## Sqr!
res = mkl_sqr!(4,Float32[1,2,3,4],Float32[1,2,3,4])
@test  res == Float32[1,4,9,16] && typeof(res) == Vector{Float32}
res = mkl_sqr!(4,Float64[1,2,3,4],Float64[1,2,3,4])
@test  res == Float64[1,4,9,16] && typeof(res) == Vector{Float64}

# Mul!
res = mkl_mul(4,Float32[1,2,3,4],2*Float32[1,2,3,4], zeros(Float32,4))
@test  res == Float32[2,8,18,32] && typeof(res) == Vector{Float32}
res = mkl_sub!(4,Float64[1,2,3,4],2*Float64[1,2,3,4], zeros(Float64,4))
@test  res == Float64[2,8,18,32] && typeof(res) == Vector{Float64}

## Abs!
res = mkl_abs!(4,Float32[-1,2,-3,4],zeros(Float32,4))
@test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
res = mkl_abs!(4,Float64[-1,2,-3,4],zeros(Float32,4))
@test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}
