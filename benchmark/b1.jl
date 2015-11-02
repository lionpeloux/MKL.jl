using MKL
using Base.LinAlg.BLAS
using Gadfly
using DataFrames

include("./utility.jl")

path = Pkg.dir("MKL") * "/benchmark/"

timing = 1
α = 0.01

begin
    df = DataFrame(Generic = ASCIIString[], Implementation = ASCIIString[], Type = ASCIIString[], Method = Any[], CPU_mean = Number[], CPU_conf = Number[])

    n = 1000*10
    a32 = rand(Float32,n)
    b32 = rand(Float32,n)
    y32 = zeros(Float32,n)
    a64 = rand(Float64,n)
    b64 = rand(Float64,n)
    y64 = zeros(Float64,n)

    for (t,a,b,y) in (("Float32",:a32,:b32,:y32),)

        tup = (

        # ("Sin",    "VJulia",    t,  :(sin($a))                  ),
        ("Add",    "VJulia",    t,  :($a + $b)                  ),
        ("Add",    "BLAS"  ,    t,  :(BLAS.axpy!(1.0,$a,$y))    ),
        ("Add",    "MKL"   ,    t,  :(MKL.mkl_add!(n,$a,$b,$y)) ),

        ("Sub",    "VJulia",    t,  :(- $a + $b)                ),
        ("Sub",    "BLAS"  ,    t,  :(BLAS.axpy!(-1.0,$a,$y))   ),
        ("Sub",    "MKL"   ,    t,  :(MKL.mkl_sub!(n,$a,$b,$y)) ),

        ("Mul",    "VJulia",    t,  :($a .* $b)                 ),
        ("Mul",    "BLAS"  ,    t,  :($a .* $b)                 ),
        ("Mul",    "MKL"   ,    t,  :(MKL.mkl_mul!(n,$a,$b,$y)) ),

        )

        for (gm, imp, ty, ex) in tup
            res_cpu, res_gc, res_alloc = ibench(ex,timing ; α=α, print_eval=false, print_stats=true)
            stat_cpu = bstat(res_cpu[2:end],α)
            push!(df,[gm,imp, ty, ex, stat_cpu[1],stat_cpu[5]])
        end
    end
end

begin

    hrow = union(df[:Generic])
    hcol = union(df[:Implementation])
    resdf = DataFrame()

    col = ASCIIString[]
    for i=1:length(hcol)
        push!(col,string(hcol[i]," (mean)"))
        push!(col,string(hcol[i]," (conf)"))
    end
    println(col)
    resdf[:Generic] = col

    for imp in hrow
        resdf[symbol(imp)] = [0.0 for i=1:2*length(hcol)]
    end

    println(df)

    subdf = df[ df[:Type] .== "Float32", :]

    for i=1:nrow(subdf)
        icol = 1 + findfirst(hrow,subdf[i,1])
        irow = 1 + 2*(findfirst(hcol,subdf[i,2])-1)
        resdf[irow,icol] = subdf[i,5]
        resdf[irow+1,icol] = subdf[i,6]
    end
    println(hcol)
    println(hrow)
    println(subdf)
    println(resdf)
    # writetable("output.csv", resdf, separator='\t')
    writetable(path * "b1.csv", resdf, separator='\t')
    writetable(path * "output.csv", df, separator='\t')
end



set_default_plot_size(10cm, 10cm)
p = plot(df, ygroup="Type", x="Method", y="CPU_mean", color="Implementation", Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical)),Theme(bar_spacing=0.1cm))
