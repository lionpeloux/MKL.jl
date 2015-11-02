# ------------------------------------------------------------------------------
#                                   TESTS
# ------------------------------------------------------------------------------

using Base.Test
importall MKL

# ==============================================================================
# BLAS LEVEL 1
# ==============================================================================

## ?asum
fname = :mkl_asum
@eval begin
    res = $fname(4,Float32[1,2,3,4],1)
    @test  res == 10 && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1)
    @test  res == 10 && typeof(res) == Float64
end
# ------------------------------------------------------------------------------

## ?axpy!
fname = :mkl_axpy!
@eval begin
    res = $fname(4,convert(Float32,2.0),Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
    @test  res == Float32[1,3,5,7] && typeof(res) == Vector{Float32}
    res = $fname(4,convert(Float64,2.0),Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
    @test  res == Float64[1,3,5,7] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

## ?copy!
fname = :mkl_copy!
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
    @test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
    @test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

## ?dot
fname = :mkl_dot
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1,Float64[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float64
end
# ------------------------------------------------------------------------------

## sdot
fname = :mkl_sdot
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float64
end
# ------------------------------------------------------------------------------

## nrm2
fname = :mkl_nrm2
@eval begin
    res = $fname(4,Float32[1,2,3,4],1)
    @test  res == convert(Float32,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1)
    @test  res == convert(Float64,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float64
end
# ------------------------------------------------------------------------------

## scal!
fname = :mkl_scal!
@eval begin
    res = $fname(4,convert(Float32,2.0),Float32[1,2,3,4],1)
    @test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
    res = $fname(4,convert(Float64,2.0),Float64[1,2,3,4],1)
    @test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

# ==============================================================================
# VML
# ==============================================================================

## Add!
fname = :mkl_add!
@eval begin
    res = $fname(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

# Sub!
fname = :mkl_sub!
@eval begin
    res = $fname(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[0,0,0,0] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[0,0,0,0] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

## Sqr!
fname = :mkl_sqrt!
@eval begin
    res = $fname(4,Float32[1,4,9,16],Float32[1,1,1,1])
    @test  res == sqrt(Float32[1,4,9,16]) && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,4,9,16],Float64[1,1,1,1])
    @test  res == sqrt(Float64[1,4,9,16]) && typeof(res) == Vector{Float64}
end

# ------------------------------------------------------------------------------

# Mul!
fname = :mkl_mul!
@eval begin
    res = $fname(4,Float32[1,2,3,4],2*Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[2,8,18,32] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],2*Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[2,8,18,32] && typeof(res) == Vector{Float64}
end
# ------------------------------------------------------------------------------

## Abs!
fname = :mkl_abs!
@eval begin
    res = $fname(4,Float32[-1,2,-3,4],zeros(Float32,4))
    @test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[-1,2,-3,4],zeros(Float64,4))
    @test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}
end
