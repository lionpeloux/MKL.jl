using MKL
using Base.LinAlg.BLAS
using Gadfly
using DataFrames
using Colors

include("../utility.jl")


# BENCH PARAMETERS
path = Pkg.dir("MKL") * "/benchmark/b2/"

# Define

tup = (
    ("sqrt(X)",   "VJulia" ,    t,  sqrt        ,   (a,)         ),
    ("sqrt(X)",   "LJulia" ,    t,  lj_sqrt     ,   (n,a,1,b,1)  ),
    ("sqrt(X)",   "iLJulia",    t,  ilj_sqrt    ,   (a,b)        ),
    ("sqrt(X)",   "MJulia" ,    t,  map!        ,   (a,b)        ),
    ("sqrt(X)",   "BJulia" ,    t,  broadcast!  ,   (a,b)        ),
    ("sqrt(X)",   "BLAS"   ,    t,  nanf        ,   ()           ),
    ("sqrt(X)",   "MKL"    ,    t,  vj_dot      ,   (a,b)        ),
    )

# BENCH

bench_b2


function bench_sqrt(N::Vector{Int}, T::DataType, timing=0.01, gcdisable=true; α=0.05, print_header=true, print_eval=false, print_stats=false, print_detail=false)

    df = DataFrame( Generic = ASCIIString[],
                    N = Int[],
                    VJulia = Float64[],     # vectorized Julia
                    LJulia = Float64[],     # loop Julia
                    iLJulia = Float64[],    # @inbounds loop Julia
                    MJulia = Float64[],     # map! Julia
                    BJulia = Float64[],     # broadcast! Julia
                    MKL = Float64[])        # MKL

    for n in N

        a = rand(T,n)
        dest = rand(T,n)
        factor = 1e9/n

        t_vj = mean(ibench(sqrt,(a,),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])
        t_lj = mean(ibench(lj_sqrt,(dest,a),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])
        t_ilj = mean(ibench(ilj_sqrt,(dest,a),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])
        t_mj = mean(ibench(map!, (sqrt,dest,a),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])
        t_bj = mean(ibench(broadcast!, (sqrt,dest,a),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])

        t_mkl = mean(ibench(mkl_sqrt!, (n,a,dest),timing, gcdisable ; α=α, print_header= print_header, print_stats=print_stats, print_detail=print_detail)[1])

        push!(df,["sqrt(X)",n, t_vj*factor, t_lj*factor, t_ilj*factor, t_mj*factor, t_bj*factor, t_mkl]*factor)
        # push!(df,["sqrt(X)",n, t_vj/t_mkl, t_lj/t_mkl, t_ilj/t_mkl, t_mj/t_mkl, t_bj/t_mkl, t_mkl/t_mkl])
        # push!(res,[t_vj/t_mkl t_lj/t_mkl t_ilj/t_mkl t_mj/t_mkl t_bj/t_mkl t_mkl])
    end
    df
end

T = Float32
N = [
        10,20,30,40,50,100,250,500,750,1000,
        2500,5000,7500,10000,
        25000,50000,75000,100000,
        # 250_000,500_000,750_000,1_000_000,
        # 2500000,5000000,7500000,10000000,
        ]

using RDatasets
println(dataset("Zelig", "approval"))

df = bench_sin(N, T, 0.01, true)
println(df)
colors = colormap("Grays",10)[3:7]
colors[4]=colorant"red"
push!(colors,colorant"deepskyblue")

p = Gadfly.plot(
        layer(df, x="N", y="VJulia", Geom.line, Theme(default_color=colors[1])),
        layer(df, x="N", y="LJulia", Geom.line, Theme(default_color=colors[2])),
        layer(df, x="N", y="iLJulia", Geom.line, Theme(default_color=colors[3])),
        layer(df, x="N", y="MJulia", Geom.line, Theme(default_color=colors[4])),
        layer(df, x="N", y="BJulia", Geom.line, Theme(default_color=colors[5])),
        layer(df, x="N", y="MKL", Geom.line,Theme(default_color=colors[6])),
        Scale.x_log10(minvalue=10,maxvalue  =100_000),
        Scale.y_log10,
        Guide.xlabel("n-dim"),
        Guide.ylabel("relative CPU time"),
        Guide.title("relative CPU time against MKL ($T)"),
        # Guide.manual_color_key("Legend", ["Julia", "Julia", "MKL"], ["red", "gray", "deepskyblue"]),
        Guide.manual_color_key("Legend",
                ["Julia vectorized", "Julia loop", "Julia inbounds loop", "Julia map!", "Julia broadcast!", "MKL"],
                colors),
        )

filepath = string(path, "sqrt_$T.png")
println(filepath)
draw(PNG(filepath, 20cm, 10cm), p)
p
