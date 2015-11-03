using MKL
using Base.LinAlg.BLAS
using Gadfly
using DataFrames

include("../utility.jl")

"""
In this benchmark (b1), we provide a comparison between functions from
Julia, OpenBLAS and MKL that runs on a n-dim vector.
The comparison is also made between Float32 / Float64.
"""
# BENCH PARAMETERS
timing = 1
α = 0.01
path = Pkg.dir("MKL") * "/benchmark/b1/"

# DEFINE VECTORIZED JULIA FONCTIONS
vj_dot(a,b) = sum(a.*b)
vj_axpy(λ,a,b) = λ*a+b
vj_invsqrt{T<:Number}(a::Vector{T}) = 1 ./ sqrt(a)

# DEFINE OPTIMIZED JULIA FUNCTIONS
# TOOD : loop @inbounds to see how fast it is.

# GENERATE RAW DATA
begin
    df = DataFrame(Generic = ASCIIString[], Implementation = ASCIIString[], Type = ASCIIString[], Method = Any[], CPU_mean = Number[], CPU_conf = Number[])

    n = 1000*1000

    λ32 = convert(Float32,pi) # keep it to 1.0 otherwise scal is going inf
    a32 = rand(Float32,n)
    b32 = rand(Float32,n)
    y32 = zeros(Float32,n)
    z32 = zeros(Float32,n)

    λ64 = convert(Float64,pi) # keep it to 1.0 otherwise scal is going inf
    a64 = rand(Float64,n)
    b64 = rand(Float64,n)
    y64 = zeros(Float64,n)
    z64 = ones(Float64,n)

    for (t,λ,a,b,y,z) in ((Float32,λ32,a32,b32,y32,z32),(Float64,λ64,a64,b64,y64,z64))

        tup = (

        ("<X|Y>",   "VJulia",    t,  vj_dot     ,   (a,b)       ),
        ("<X|Y>",   "BLAS"  ,    t,  BLAS.dot   ,   (n,a,1,b,1) ),
        ("<X|Y>",   "MKL"   ,    t,  mkl_dot    ,   (n,a,1,b,1) ),

        ("aX",      "VJulia",    t,  *          ,   (λ,a)       ),
        ("aX",      "BLAS"  ,    t,  BLAS.scal! ,   (n,λ,a,1)   ),
        ("aX",      "MKL"   ,    t,  mkl_scal!  ,   (n,λ,a,1)   ),

        ("X+Y",     "VJulia",    t,  +          ,   (a,b)       ),
        ("X+Y",     "BLAS"  ,    t,  BLAS.axpy! ,   (1.0,a,b)   ),
        ("X+Y",     "MKL"   ,    t,  mkl_add!   ,   (n,a,b,y)   ),

        ("X-Y",     "VJulia",    t,  -          ,   (a,b)       ),
        ("X-Y",     "BLAS"  ,    t,  BLAS.axpy! ,   (-1.0,a,b)  ),
        ("X-Y",     "MKL"   ,    t,  mkl_sub!   ,   (n,a,b,y)   ),

        ("aX+Y",    "VJulia",    t,  vj_axpy    ,   (λ,a,b)     ),
        ("aX+Y",    "BLAS"  ,    t,  BLAS.axpy! ,   (λ,a,b)     ),
        ("aX+Y",    "MKL"   ,    t,  mkl_axpy!  ,   (n,λ,a,1,b,1)),

        ("X.Y",     "VJulia",    t,  .*         ,   (a,b)       ),
        ("X.Y",     "MKL"   ,    t,  mkl_mul!   ,   (n,a,b,y)   ),

        ("X^2",     "VJulia",    t,  .^         ,   (a,convert(t,2))    ),
        ("X^2",     "MKL"   ,    t,  mkl_powx!  ,   (n,a,convert(t,2),y)),

        ("X/Y",     "VJulia",    t,  ./         ,   (a,b)       ),
        ("X/Y",     "MKL"   ,    t,  mkl_div!   ,   (n,a,b,y)   ),

        ("1/X",     "VJulia",    t,  ./         ,   (convert(t,1),b)),
        ("1/X",     "MKL"   ,    t,  mkl_inv!   ,   (n,a,y)   ),

        ("|X|",     "VJulia",    t,  abs        ,   (a,)        ),
        ("|X|",     "MKL"   ,    t,  mkl_abs!   ,   (n,a,y)     ),

        ("sqrt(X)", "VJulia",    t,  sqrt       ,   (a,)        ),
        ("sqrt(X)", "MKL"   ,    t,  mkl_sqrt!  ,   (n,a,y)     ),

        ("1/sqrt(X)", "VJulia",  t,  vj_invsqrt ,   (a,)        ),
        ("1/sqrt(X)", "MKL"   ,  t,  mkl_invsqrt!,  (n,a,y)     ),

        )

        for (gm, imp, ty, f, args) in tup
            res_cpu, res_gc, res_alloc = ibench(f, args,timing ; α=α, print_eval=false, print_stats=true)
            stat_cpu = bstat(res_cpu[2:end] * (1e9/n),α) # in micro second per op
            push!(df,[gm,imp, string(ty), f, stat_cpu[1],stat_cpu[5]])
        end
    end
end

# POST TREATMENT FOR .CSV EXPORT (using DatFrames)
begin
    hrow = union(df[:Generic]) # list of generic functions
    hcol = ("BLAS","MKL","VJulia") #union(df[:Implementation])
    resdf = DataFrame()

    col = ASCIIString[]
    for i=1:length(hcol)
        push!(col,string(hcol[i]," (mean)"))
        push!(col,string(hcol[i]," (conf)"))
    end
    resdf[:Generic] = col

    for imp in hrow
        resdf[symbol(imp)] = [0.0 for i=1:2*length(hcol)]
    end

    subdf = df[ df[:Type] .== "Float32", :]

    for i=1:nrow(subdf)
        icol = 1 + findfirst(hrow,subdf[i,1])
        irow = 1 + 2*(findfirst(hcol,subdf[i,2])-1)
        resdf[irow,icol] = subdf[i,5]
        resdf[irow+1,icol] = subdf[i,6]
    end
    # println(hcol)
    # println(hrow)
    println(df)
    println(subdf)

    println(resdf)
    # writetable("output.csv", resdf, separator='\t')
    writetable(path * "b1_cpu_$n.csv", resdf, separator='\t')
    # writetable(path * "output.csv", df, separator='\t')
end

# Float32 / Float64 PERFORMANCE COMPARISON
begin
    hrow = union(df[:Generic]) # list of generic functions
    hcol = ("BLAS","MKL","VJulia") #union(df[:Implementation])
    resdf = DataFrame()

    col = ASCIIString[]
    for i=1:length(hcol)
        push!(col,string(hcol[i],""))
    end
    resdf[:Generic] = col

    for imp in hrow
        resdf[symbol(imp)] = [0.0 for i=1:1*length(hcol)]
    end

    subdf_32 = df[ df[:Type] .== "Float32", :]
    subdf_64 = df[ df[:Type] .== "Float64", :]

    for i=1:nrow(subdf_64)
        subdf_64[i,5] = subdf_64[i,5] / subdf_32[i,5]
        println(subdf_64[i,5])
    end

    for i=1:nrow(subdf_64)
        icol = 1 + findfirst(hrow,subdf_64[i,1])
        irow = 1 + 1*(findfirst(hcol,subdf_64[i,2])-1)
        resdf[irow,icol] = subdf_64[i,5]
    end

    # println(subdf_64)
    # println(resdf)
    writetable(path * "b1_Float32_vs_Float64_$n.csv", resdf, separator='\t')

    # println(resdf)
    # writetable("output.csv", resdf, separator='\t')

    # writetable(path * "output.csv", df, separator='\t')
end




# set_default_plot_size(10cm, 10cm)
# p = plot(df, ygroup="Type", x="Method", y="CPU_mean", color="Implementation", Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical)),Theme(bar_spacing=0.1cm))
