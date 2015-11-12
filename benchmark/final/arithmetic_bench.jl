using Formatting
using MKL
using Base.LinAlg.BLAS
using Gadfly
using DataFrames
using Colors

include("../utility.jl")

"""
In this benchmark (b1), we provide a comparison between functions from
Julia, OpenBLAS and MKL that runs on a n-dim vector.
The comparison is also made between Float32 / Float64.
"""
# BENCH PARAMETERS
path = Pkg.dir("MKL") * "/benchmark/final/"
timing = .5
α = 0.05

N = [10_000] # ne pas prendre de valeur inférieure
T = [Float32,Float64]


function ibench(f, args, timing=0.001 ; α=0.05)

    # TRIGGER JIT : first compilation will be ignored
    res = @timed f(args...)

    # eval nrun to match timing
    t = @elapsed f(args...)
    nrun = max(2,convert(Int64,div(timing,t))) # at least one run

    # allocate results arrays
    res_cpu = Array(Float64,nrun+1)
    res_gc = Array(Float64,nrun+1)
    res_alloc = Array(Int64,nrun+1)

    # write JIT results
    res_cpu[1] = res[2]
    res_gc[1] = res[4]
    res_alloc[1] = res[3]

    # write PROFILING results : call f n times
    gc()
    for i=1:nrun
        # gcdisable ? gc_enable(false) : ""
        res = @timed f(args...)
        # gcdisable ? gc_enable(true) : ""
        res_cpu[i+1] = res[2]
        res_gc[i+1] = res[4]
        res_alloc[i+1] = res[3]
    end

    return res_cpu, res_gc, res_alloc
end

function write_csv(fname,df)
    head = transpose([string(name) for name in names(df)])
    data = convert(Array,df)
    data = vcat(head,data)
    writedlm(fname,data,",")
end

# GENERATE RAW DATA
function bench_b1()

    df = DataFrame( Generic = ASCIIString[], Implementation = ASCIIString[], Type = ASCIIString[], Method = Any[],
                    N = Int64[],
                    CPU_mean = Float64[], CPU_conf = Float64[],
                    GC_mean = Float64[], GC_conf = Float64[],
                    ALLOC_mean = Float64[], ALLOC_conf = Float64[])

    for n in N

        println("#################################################################")
        println("N = $n")
        println("#################################################################")

        for t in T

            λ = convert(t,pi) # keep it to 1.0 otherwise scal is going inf
            a = rand(t,n)
            b = rand(t,n)
            y = zeros(t,n)
            z = zeros(t,n)

        # for (t,λ,a,b,y,z) in ((Float32,λ32,a32,b32,y32,z32),(Float64,λ64,a64,b64,y64,z64))

            tup = (

            ("{\$ X.Y \$}",         "BLAS"  ,    t,  BLAS.dot   ,   (n,a,1,b,1) ),
            ("{\$ X.Y \$}",         "MKL"   ,    t,  mkl_dot    ,   (n,a,1,b,1) ),
            ("{\$ X.Y \$}",         "Julia" ,    t,  vj_dot     ,   (a,b)       ),

            ("{\$ \\lambda X \$}",    "BLAS"  ,    t,  BLAS.scal! ,   (n,convert(t,0.9999),a,1)   ),
            ("{\$ \\lambda X \$}",    "MKL"   ,    t,  mkl_scal!  ,   (n,convert(t,0.9999),a,1)   ),
            ("{\$ \\lambda X \$}",    "Julia" ,    t,  *          ,   (λ,a)       ),

            ("{\$ X+Y \$}",           "BLAS"  ,    t,  BLAS.axpy! ,   (1.0,a,b)   ),
            ("{\$ X+Y \$}",           "MKL"   ,    t,  mkl_add!   ,   (n,a,b,y)   ),
            ("{\$ X+Y \$}",           "Julia" ,    t,  +          ,   (a,b)       ),

            ("{\$ X-Y \$}",           "BLAS"  ,    t,  BLAS.axpy! ,   (-1.0,a,b)  ),
            ("{\$ X-Y \$}",           "MKL"   ,    t,  mkl_sub!   ,   (n,a,b,y)   ),
            ("{\$ X-Y \$}",           "Julia" ,    t,  -          ,   (a,b)       ),
            #
            ("{\$ \\lambda X+Y \$}",  "BLAS"  ,    t,  BLAS.axpy! ,   (λ,a,b)     ),
            ("{\$ \\lambda X+Y \$}",  "MKL"   ,    t,  mkl_axpy!  ,   (n,λ,a,1,b,1)),
            ("{\$ \\lambda X+Y \$}",  "Julia" ,    t,  vj_axpy    ,   (λ,a,b)     ),

            ("{\$ X*Y \$}",           "BLAS"  ,    t,  nanf       ,   ()          ),
            ("{\$ X*Y \$}",           "MKL"   ,    t,  mkl_mul!   ,   (n,a,b,y)   ),
            ("{\$ X*Y \$}",           "Julia" ,    t,  .*         ,   (a,b)       ),

            ("{\$ X^2 \$}",           "BLAS"  ,    t,  nanf       ,   ()                  ),
            ("{\$ X^2 \$}",           "MKL"   ,    t,  mkl_powx!  ,   (n,a,convert(t,2),y)),
            ("{\$ X^2 \$}",           "Julia" ,    t,  .^         ,   (a,convert(t,2))    ),

            ("{\$ X/Y \$}",           "BLAS"  ,    t,  nanf       ,   ()          ),
            ("{\$ X/Y \$}",           "MKL"   ,    t,  mkl_div!   ,   (n,a,b,y)   ),
            ("{\$ X/Y \$}",           "Julia" ,    t,  ./         ,   (a,b)       ),

            ("{\$ 1/X \$}",           "BLAS"  ,    t,  nanf       ,   ()              ),
            ("{\$ 1/X \$}",           "MKL"   ,    t,  mkl_inv!   ,   (n,a,y)         ),
            ("{\$ 1/X \$}",           "Julia" ,    t,  ./         ,   (convert(t,1),b)),

            ("{\$ |X| \$}",           "BLAS"  ,    t,  nanf       ,   ()         ),
            ("{\$ |X| \$}",           "MKL"   ,    t,  mkl_abs!   ,   (n,a,y)     ),
            ("{\$ |X| \$}",           "Julia" ,    t,  abs        ,   (a,)        ),

            ("{\$ \\sqrt{X} \$}",     "BLAS"  ,    t,  nanf        ,   ()         ),
            ("{\$ \\sqrt{X} \$}",     "MKL"   ,    t,  mkl_sqrt!   ,   (n,a,y)    ),
            ("{\$ \\sqrt{X} \$}",     "Julia" ,    t,  sqrt        ,   (a,)       ),

            ("{\$ 1/\\sqrt{X} \$}",   "BLAS"  ,    t,  nanf        ,   ()          ),
            ("{\$ 1/\\sqrt{X} \$}",   "MKL"   ,    t,  mkl_invsqrt!,   (n,a,y)     ),
            ("{\$ 1/\\sqrt{X} \$}",   "Julia" ,    t,  vj_invsqrt  ,   (a,)        ),
            )

            for (gm, imp, ty, f, args) in tup
                if length(args) == 0 # void function
                    push!(df, [gm, imp, string(ty), f, n, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
                else
                    res_cpu, res_gc, res_alloc = ibench(f, args,timing ; α=α)
                    stat_cpu = bstat(res_cpu[2:end].*(1e9/n), α) # in micro second per op * (1e9/n)
                    stat_gc = bstat(res_gc[2:end].*(1e9/n), α)
                    stat_alloc = bstat(res_alloc[2:end], α)
                    push!(df, [gm, imp, string(ty), f, n, stat_cpu[1], stat_cpu[5], stat_gc[1], stat_gc[5], stat_alloc[1], stat_alloc[5]])
                end
            end
        end
    end
    # writetable(path * "arithmetic_bench_data.csv", df)
    df
end

function plot_gadfly()

    df = DataFrames.readtable(path*"arithmetic_bench_data.csv")

    N = union(df[:N])
    T = union(df[:Type])
    imp = union(df[:Implementation])
    gen = union(df[:Generic])

    for n in N
        for t in T

            println(n)
            println(t)

            filter_set = (df[:Type] .== string(t)) & (df[:N] .== n)
            sdf = df[filter_set , :]
            println(sdf)

            set_default_plot_size(20cm, 20cm)
            p = Gadfly.plot(
                        sdf, xgroup="Generic", x="Implementation", y="CPU_mean",
                        color="Implementation",
                        Scale.color_discrete_manual(Tdarkgray,Tblue,Tlightgray),
                        Scale.y_continuous(minvalue=0, maxvalue=15),
                        Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical, label=false)),
                        Guide.xlabel(""),
                        Guide.ylabel(""),
                        Guide.title("CPU time on n-dim vectors (n=1e"*string(convert(Int32,log10(n)))),
                        Theme(bar_spacing=0.1cm)
                        )

            draw(PNG(path*"b1_$t"*"_$n.png", 30cm, 20cm), p)
            # draw(SVG(path*"output/b1_$t"*"_$n.svg", 25cm, 12cm), p)
            p
        end
    end

    for n in N

        println(n)

        filter_set = (df[:N] .== n)
        sdf = df[filter_set , :]
        println(sdf)

        p = Gadfly.plot(
                    layer(
                    sdf, xgroup="Generic", ygroup="Type", x="Implementation", y="CPU_mean",
                    color="Implementation",
                    Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical, label=false))
                    ),
                    Scale.color_discrete_manual(Tdarkgray,Tblue,Tlightgray),
                    Scale.y_continuous(minvalue=0, maxvalue=15),
                    Guide.xlabel(""),
                    Guide.ylabel(""),
                    Guide.title("CPU time on n-dim vectors (n=1e"*string(convert(Int32,log10(n)))*")"),
                    Theme(bar_spacing=0.1cm)
                    )

        # draw(PNG(path*"output/b1_$n.png", 25cm, 12cm), p)
        # draw(SVG(path*"b1_$n.svg", 29cm, 20cm), p)
        draw(PDF(path*"b1_$n.pdf", 30cm, 20cm), p)
        p
    end
end

df = bench_b1()
plot_gadfly()

write_csv(path*"arithmetic_bench_data.csv",df)
df
# .csv pour histogramme temps cpu absolu & interval de confiance
function histo_cpu_conf(df::DataFrame, n::Integer, T::DataType)
    df_type = df[(df[:Type] .== string(T)) & (df[:N] .== n),:]
    gens = union(df_type[:Generic])
    imps = union(df_type[:Implementation])
    res = DataFrame()
    res[:Generic] = gens
    for imp in imps
        df_imp = df_type[df_type[:Implementation] .== imp,:]
        res[symbol(string("CPU_mean_",imp))] = df_imp[:CPU_mean]
        res[symbol(string("CPU_conf_",imp))] = df_imp[:CPU_conf]
    end
    res
end


res = histo_cpu_conf(df, 10000, Float64)
write_csv(path * "arithmetic_cpu_conf_Float64.csv", res)
res = histo_cpu_conf(df, 10000, Float32)
write_csv(path * "arithmetic_cpu_conf_Float32.csv", res)

# .csv pour histogramme temps cpu relatif à MKL sans interval de confiance
function histo_cpu_rel(df::DataFrame, n::Integer, T::DataType)
    res = histo_cpu_conf(df, n, T)[[1,2,4,6]]
    res[2] = res[2] ./ res[3]
    res[3] = res[3] ./ res[3]
    res[4] = res[4] ./ res[3]
    res
end
res = histo_cpu_rel(df, 10000, Float64)
write_csv(path * "arithmetic_cpu_rel_Float64.csv", res)
res = histo_cpu_rel(df, 10000, Float32)
write_csv(path * "arithmetic_cpu_rel_Float32.csv", res)

# .csv pour histogramme temps cpu relatif Float64/Float32
function histo_cpu_type(df::DataFrame, n::Integer)
    df_32 = histo_cpu_conf(df, n, Float32)[[1,2,4,6]]
    df_64 = histo_cpu_conf(df, n, Float64)[[1,2,4,6]]
    df_64[2] = df_64[2] ./ df_32[2]
    df_64[3] = df_64[3] ./ df_32[3]
    df_64[4] = df_64[4] ./ df_32[4]
    # replace NaN values by zero
    for i in 1:nrow(df_64)
        for j in 2:ncol(df_64)
            if isnan(df_64[i,j])
                df_64[i,j]=0.0
            end
        end
    end
    df_64
end
res = histo_cpu_type(df, 10000)
write_csv(path * "arithmetic_cpu_type.csv", res)


# println(df_blas)
