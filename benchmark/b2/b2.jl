using MKL
using Base.LinAlg.BLAS
# using Gadfly
using DataFrames
# using Plotly

include("../utility.jl")

"""
In this benchmark (b1), we provide a comparison between functions from
Julia, OpenBLAS and MKL that runs on a n-dim vector.
The comparison is also made between Float32 / Float64.
"""

# BENCH PARAMETERS
timing = .1
α = 0.01
path = Pkg.dir("MKL") * "/benchmark/b2/"


N = [   1,2,5,7,10,
        20,30,40,50,100,250,500,750,1000,
        2500,5000,7500,10000,
        25000,50000,75000,100000,
        250000,500000,750000,1000000,
        2500000,5000000,7500000,10000000,
        ]


df = DataFrame(N = Int[], Float32 = Float64[], Float64 = Float64[])


for n in N

    T = Float32
    a = rand(T,n)
    y = rand(T,n)

    res_cpu, res_gc, res_alloc = ibench(mkl_sqrt!, (n,a,y),timing, false ; α=α, print_eval=false, print_stats=true)
    stat_cpu_mkl = bstat(res_cpu[2:end] * (1e9/n),α)
    t_mkl_32 = stat_cpu_mkl[1]

    T = Float32
    a = rand(T,n)
    y = rand(T,n)

    res_cpu, res_gc, res_alloc = ibench(mkl_sqrt!, (n,a,y),timing, false ; α=α, print_eval=false, print_stats=true)
    stat_cpu_mkl = bstat(res_cpu[2:end] * (1e9/n),α)
    t_mkl_64 = stat_cpu_mkl[1]

    # t_mkl_3 = mean([(@timed mkl_sqrt!(n,a,y))[2] for i=1:1000])* (1e9/n)

    push!(df,[n,t_mkl_32,t_mkl_64])
end

println(df)

#
p = plot(
        # layer(df, x="N", y="ratio", Geom.line),
        layer(df, x="N", y="Float32", Geom.line),
        layer(df, x="N", y="Float64", Geom.line),
        Scale.x_log10, Scale.y_log10,
        Guide.xlabel("n-dim element vector"), Guide.ylabel("CPU in ns/n"),
        Guide.title("CPU time for sqrt (Float32 vs. Float64)"))

filepath = string(path, "sqrt_Float32_Float64.png")

println(filepath)
draw(PNG(filepath, 15cm, 15cm), p)
p

# df = DataFrame(N = Int[], VJulia = Float64[], OJulia = Float64[], MKL = Float64[])
# T = Float64
# for n in N
#
#     a = rand(T,n)
#     y = rand(T,n)
#
#     res_cpu, res_gc, res_alloc = ibench(./,(1,a),timing ; α=α, print_eval=false, print_stats=true)
#     stat_cpu_julia = bstat(res_cpu[2:end] * (1e9/n),α)
#     t_vj = stat_cpu_julia[1]
#
#     res_cpu, res_gc, res_alloc = ibench(broadcast!,(/,y,1,a),timing ; α=α, print_eval=false, print_stats=true)
#     stat_cpu_julia = bstat(res_cpu[2:end] * (1e9/n),α)
#     t_oj = stat_cpu_julia[1]
#
#     res_cpu, res_gc, res_alloc = ibench(mkl_inv!, (n,a,y),timing, false ; α=α, print_eval=false, print_stats=true)
#     stat_cpu_mkl = bstat(res_cpu[2:end] * (1e9/n),α)
#     t_mkl = stat_cpu_mkl[1]
#
#     # t_mkl_3 = mean([(@timed mkl_sqrt!(n,a,y))[2] for i=1:1000])* (1e9/n)
#
#     push!(df,[n,t_vj/t_mkl,t_oj/t_mkl,t_mkl/t_mkl])
# end
# println(df)
#
# #
# p = plot(
#         # layer(df, x="N", y="ratio", Geom.line),
#         layer(df, x="N", y="VJulia", Geom.line),
#         layer(df, x="N", y="OJulia", Geom.line),
#         layer(df, x="N", y="MKL", Geom.line),
#         Scale.x_log10,
#         Guide.xlabel("n-dim element vector ($T)"), Guide.ylabel("CPU in ns/n"),
#         Guide.title("relative CPU time for sqrt (MKL = 1)"))
#
# filepath = string(path, "sqrt_",T,".png")
#
# println(filepath)
# draw(PNG(filepath, 15cm, 15cm), p)
# p
