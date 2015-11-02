# push!(LOAD_PATH, "/Users/Lionel/Documents/2 - pro/3 - ENPC/5 - thèse/05 - elastica/MKL")
using Base.Test
importall MKL


# BLAS LEVEL 1
##############

## ?asum
name = :asum
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],1)
    @test  res == 10 && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1)
    @test  res == 10 && typeof(res) == Float64
end

## ?axpy!
name = :axpy!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,convert(Float32,2.0),Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
    @test  res == Float32[1,3,5,7] && typeof(res) == Vector{Float32}
    res = $fname(4,convert(Float64,2.0),Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
    @test  res == Float64[1,3,5,7] && typeof(res) == Vector{Float64}
end

## ?copy!
name = :copy!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[-1,-1,-1,-1],1)
    @test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],1,Float64[-1,-1,-1,-1],1)
    @test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}
end

## ?dot
name = :dot
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1,Float64[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float64
end

## sdot
name = :sdot
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],1,Float32[1,2,3,4],1)
    @test  res == 30 && typeof(res) == Float64
end

## nrm2
name = :nrm2
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],1)
    @test  res == convert(Float32,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float32
    res = $fname(4,Float64[1,2,3,4],1)
    @test  res == convert(Float64,sqrt(1+2^2+3^2+4^2)) && typeof(res) == Float64
end

## scal!
name = :scal!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,convert(Float32,2.0),Float32[1,2,3,4],1)
    @test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
    res = $fname(4,convert(Float64,2.0),Float64[1,2,3,4],1)
    @test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}
end

# MATH VECTOR LIBRARY
#####################

## Add!
name = :add!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[2,4,6,8] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[2,4,6,8] && typeof(res) == Vector{Float64}
end

# Sub!
name = :sub!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[0,0,0,0] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[0,0,0,0] && typeof(res) == Vector{Float64}
end

## Sqr!
name = :sqrt!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],Float32[1,2,3,4])
    println(res)
    @test  res == sqrt(Float32[1,4,9,16]) && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],Float64[1,2,3,4])
    @test  res == sqrt(Float64[1,4,9,16]) && typeof(res) == Vector{Float64}
end

# Mul!
name = :mul!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[1,2,3,4],2*Float32[1,2,3,4], zeros(Float32,4))
    @test  res == Float32[2,8,18,32] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[1,2,3,4],2*Float64[1,2,3,4], zeros(Float64,4))
    @test  res == Float64[2,8,18,32] && typeof(res) == Vector{Float64}
end

## Abs!
name = :abs!
fname = symbol(string(MKL.prefix)*string(name))
@eval begin
    res = $fname(4,Float32[-1,2,-3,4],zeros(Float32,4))
    @test  res == Float32[1,2,3,4] && typeof(res) == Vector{Float32}
    res = $fname(4,Float64[-1,2,-3,4],zeros(Float64,4))
    @test  res == Float64[1,2,3,4] && typeof(res) == Vector{Float64}
end
