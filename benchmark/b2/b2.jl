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
path = Pkg.dir("MKL") * "/benchmark/b1/"


N = [   10,20,30,40,50,100,250,500,750,1000,
        2500,5000,7500,10000,
        25000,50000,75000,100000,
        # 250000,500000,750000,1000000,
        # 2500000,5000000,7500000,10000000,
        ]

f_julia = sqrt
f_mkl = mkl_sqrt!

# df = DataFrame(N = Int[], Julia = Float64[], MKL = Float64[], ratio = Float64[])
t = Float64

# for n in N
#
#     a = rand(n)
#     y = rand(n)
#
#     args = (a,)
#     res_cpu, res_gc, res_alloc = ibench(f_julia, args,timing ; α=α, print_eval=false, print_stats=true)
#     stat_cpu_julia = bstat(res_cpu[2:end],α)
#
#     args = (n,a,y)
#     res_cpu, res_gc, res_alloc = ibench(f_mkl, args,timing ; α=α, print_eval=false, print_stats=true)
#     stat_cpu_mkl = bstat(res_cpu[2:end],α)
#
#     push!(df,[n,stat_cpu_julia[1],stat_cpu_mkl[5],stat_cpu_julia[1]/stat_cpu_mkl[5]])
# end
#
# println(df)
#
#
# plot(
#         # layer(df, x="N", y="ratio", Geom.line),
#         layer(df, x="N", y="Julia", Geom.line),
#         layer(df, x="N", y="MKL", Geom.line),
#          Scale.x_log10, Scale.y_log10)

a = Float64[1,2,4,6,9]
y = rand(5)
broadcast!(sqrt,y,a)

df = DataFrame(N = Int[], VJulia_1 = Float64[], OJulia_1 = Float64[], MKL_1 = Float64[], VJulia_2 = Float64[], OJulia_2= Float64[], MKL_2 = Float64[])

# function bench(f,args,timing)
#
#     f(args...)
#     t = @elapsed f(args...)
#     nrun = round(timing/t)+2
#     println(nrun)
#     return mean([(@timed f(args...))[2] for i=1:nrun])
# end
#
#
# n = 1000*1000
# a = rand(n)
# y = rand(n)
# ibench3(mkl_sqrt!,(n,a,y),1)*1e9/n
#
# mean([(@timed mkl_sqrt!(n,a,y))[2] for i=1:500])*1e9/n
# mean([@elapsed mkl_sqrt!(n,a,y) for i=1:500])*1e9/n


for n in N

    a = rand(n)
    y = rand(n)

    t_vj_1 = mean([@elapsed sqrt(a) for i=1:500])* (1e9/n)
    t_oj_1 =  mean([@elapsed broadcast!(sqrt,y,a) for i=1:500])* (1e9/n)
    t_mkl_1 = mean([@elapsed mkl_sqrt!(n,a,y) for i=1:1000])* (1e9/n)

    res_cpu, res_gc, res_alloc = ibench(sqrt,(a,),timing ; α=α, print_eval=false, print_stats=true)
    stat_cpu_julia = bstat(res_cpu[2:end] * (1e9/n),α)
    t_vj_2 = stat_cpu_julia[1]

    res_cpu, res_gc, res_alloc = ibench(broadcast!,(sqrt,y,a,),timing ; α=α, print_eval=false, print_stats=true)
    stat_cpu_julia = bstat(res_cpu[2:end] * (1e9/n),α)
    t_oj_2 = stat_cpu_julia[1]

    res_cpu, res_gc, res_alloc = ibench(mkl_sqrt!, (n,a,y),timing, false ; α=α, print_eval=false, print_stats=true)
    stat_cpu_mkl = bstat(res_cpu[2:end] * (1e9/n),α)
    t_mkl_2 = stat_cpu_mkl[1]

    push!(df,[n,t_vj_1,t_oj_1,t_mkl_1,t_vj_2,t_oj_2,t_mkl_2])
end


println(df)

#
# plot(
#         # layer(df, x="N", y="ratio", Geom.line),
#         layer(df, x="N", y="VJulia_1", Geom.line),
#         layer(df, x="N", y="OJulia_1", Geom.line),
#         layer(df, x="N", y="MKL_1", Geom.line),
#          Scale.x_log10, Scale.y_log10)
#


# trace1 = [
#   "x" => df[:N],
#   "y" => df[:Julia],
#   "type" => "scatter"
# ]
# trace2 = [
#   "x" => df[:N],
#   "y" => df[:MKL],
#   "type" => "scatter"
# ]
# data = [trace1, trace2]
# layout = [
#   "xaxis" => [
#     "type" => "log",
#     "autorange" => true
#   ],
#   "yaxis" => [
#     # "type" => "log",
#     "autorange" => true
#   ]
# ]
# # response = Plotly.plot(data, ["layout" => layout, "filename" => "plotly-log-axes", "fileopt" => "overwrite"])
# # plot_url = response["url"]
# # println(plot_url)









# set_default_plot_size(10cm, 10cm)
# p = plot(df, ygroup="Type", x="Method", y="CPU_mean", color="Implementation", Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical)),Theme(bar_spacing=0.1cm))
