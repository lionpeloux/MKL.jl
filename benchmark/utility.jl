using Formatting
using MKL
using Base.LinAlg.BLAS
using Gadfly
using DataFrames
using Colors

# ------------------------------------------------------------------------------
#                              INDIVIDUAL BENCH
# ------------------------------------------------------------------------------

# custom colors
Tblue = RGB(104/255,135/255,255/255)
Tred = RGB(255/255,110/255,103/255)
Tlightgray = RGB(0.7,0.7,0.7)
Tdarkgray = RGB(0.5,0.5,0.5)

"""
`bstat`retrieves basic statistics for a collection of numbers.
'α' is the risk error (defaults to 0.05).
`v_conf` is the *confidence interval* regarding `α` : v = μ +/- δμ with probability 1-α
"""
function bstat{T<:Number}(v::Vector{T}, α=0.05)
    n = length(v)
    μ = mean(v) # mean
    v_min , v_max = extrema(v) # min and max
    σ =  stdm(v, μ) # standard deviation
    δμ = sqrt(2)*erfinv(1-α)*(σ/sqrt(n)) # confidence interval : v = μ +/- δμ
    return μ, v_min, v_max, σ, δμ
end

"""
`ìbench` performs a benchmark on a function `f` with arguments `arg`.
`f` is evaluated sevral times so the benchmark last approximatively `timing`.
`JIT` is triggered and results are stored in the return arrays at item `1`.
`gcdisable` allows to disable the GC during evaluations (defaults to `true`).
"""
function ibench(f, args, timing=0.0001, gcdisable=true ; α=0.05, print_header = true, print_eval=false, print_stats=false, print_detail=false)

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
    gcdisable ? gc() : ""
    for i=1:nrun
        # gcdisable ? gc_enable(false) : ""
        res = @timed f(args...)
        # gcdisable ? gc_enable(true) : ""
        res_cpu[i+1] = res[2]
        res_gc[i+1] = res[4]
        res_alloc[i+1] = res[3]
    end

    # if print_header==true || print_stats==true || print_detail==true
    #     idisplay(f, args, timing, res_cpu, res_gc, res_alloc ; α=α, print_eval=print_eval, print_stats=print_stats, print_detail=print_detail)
    # end
    return res_cpu, res_gc, res_alloc
end

"""
`ìdisplay` prints the results of an individual bench `ìbench` performed on a
function `f` with the given input arguments `arg`.
`detail` printing defaults to `false`.
`res` prints a sample evaluation (for checking) is `true` ; defaults to `false`
"""
function idisplay(f, args, timing, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64} ; α=0.05, print_eval=false, print_stats=true, print_detail=false)

    nrun = length(res_cpu)-1

    # FORMATER
    fe_sep1 = FormatExpr("{:=>44}")
    fe_sep2 = FormatExpr("{:->44}")
    fe_head = FormatExpr("{:<10s}{:>12s}{:>8s}{:>14s}")
    fe_line = FormatExpr("{:<10s}{:>12.2e}{:>8.2f}{:>14d}")

    # GET STATS
    stat_cpu = bstat(res_cpu[2:end],α)
    stat_gc = bstat(res_gc[2:end],α)
    stat_alloc = bstat(res_alloc[2:end],α)

    # SUMMARY
    println("")
    printfmtln(fe_sep1,"")
    println("Running $f for about $timing s")
    println("Evaluations : $nrun")
    println("CPU time : ",sum(res_cpu),"s")
    # PRINT EVAL
    if print_eval
        println(string(f)," = ")
        println(f(args...))
    end

    # HEADER
    printfmtln(fe_sep1,"")
    printfmtln(fe_head,"NAME","CPU (s)", "GC (%)", "ALLOC (byt)")
    printfmtln(fe_sep2,"")

    # RESULTS : MEAN
    conf = convert(Int32,100*(1-α))
    printfmtln(fe_line, "MEAN", stat_cpu[1], stat_gc[1], stat_alloc[1])
    if print_stats
        printfmtln(fe_line, "MIN", stat_cpu[2], stat_gc[2], stat_alloc[2])
        printfmtln(fe_line, "MAX", stat_cpu[3], stat_gc[3], stat_alloc[3])
        printfmtln(fe_line, "STD", stat_cpu[4], stat_gc[4], stat_alloc[4])
        printfmtln(fe_line, "CONF($conf%)", stat_cpu[5], stat_gc[5], stat_alloc[5])
        printfmtln(fe_sep2,"")
    end

    # RESULTS : JIT
    printfmtln(fe_line, "JIT", res_cpu[1], res_gc[1], res_alloc[1])
    printfmtln(fe_sep2,"")

    # RESULTS : details
    if print_detail == true
        for i=1:nrun
            printfmtln(fe_line, i, res_cpu[i+1], res_gc[i+1], res_alloc[i+1])
        end
    end
    return
end

function idisplay2(f, args, n, timing, neval, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64}; print_eval=false, print_scale=true)

    # FORMATER
    fe_sep1 = FormatExpr("{:=>44}")
    fe_sep2 = FormatExpr("{:->44}")
    fe_head = FormatExpr("{:<10s}{:>12s}{:>8s}{:>14s}")

    # SUMMARY
    println("")
    printfmtln(fe_sep1,"")
    println("Running '$f' for about $timing s")
    println("Evaluations : $neval")
    # PRINT EVAL
    if print_eval
        println(string(f)," = ")
        println(f(args...))
    end

    # HEADER

    if print_scale
        fe_line = FormatExpr("{:<10s}{:>12.1f}{:>8.1f}{:>14d}")
        printfmtln(fe_sep1,"")
        printfmtln(fe_head,"n=$n","CPU (ns/el)", "GC (%)", "ALLOC (by/el)")
        printfmtln(fe_sep2,"")
        printfmtln(fe_line, "MEAN", res_cpu[2]*(1e9/n), res_gc[2]*(1e9/n), res_alloc[2]÷n)
        printfmtln(fe_line, "JIT", res_cpu[1]*(1e9/n), res_gc[1]*(1e9/n), res_alloc[1]÷n)
        printfmtln(fe_sep2,"")
    else
        fe_line = FormatExpr("{:<10s}{:>12.1e}{:>8.1f}{:>14d}")
        printfmtln(fe_sep1,"")
        printfmtln(fe_head,"n=$n","CPU (s)", "GC (%)", "ALLOC (by)")
        printfmtln(fe_sep2,"")
        printfmtln(fe_line, "MEAN", res_cpu[2], res_gc[2], res_alloc[2])
        printfmtln(fe_line, "JIT", res_cpu[1], res_gc[1], res_alloc[1])
        printfmtln(fe_sep2,"")
    end



    return
end

function ibench2(f, args, n, nrep=500, gcdisable=true)

    # TRIGGER JIT : first compilation will be ignored
    res = @timed f(args...)

    # eval nrun to match timing
    t = @elapsed f(args...)

    # allocate results arrays
    res_cpu = Array(Float64,2)
    res_gc = Array(Float64,2)
    res_alloc = Array(Int64,2)

    # write JIT results
    res_cpu[1] = res[2]
    res_gc[1] = res[4]
    res_alloc[1] = res[3]

    tcpu = 0.0
    tgc = 0.0
    alloc = 0

    gc()

    if n <= 10_000
        nchunk = 10_000 ÷ n + 1
        @inbounds for j in 1:nrep
            res = @timed for k in 1:nchunk f(args...) end
            tcpu += res[2]
            tgc += res[4]
            alloc += res[3]
        end
    else
        nchunk = 1.0
        @inbounds for j in 1:nrep
            res = @timed f(args...)
            tcpu += res[2]
            tgc += res[4]
            alloc += res[3]
        end
    end

    res_cpu[2] = tcpu / (nrep * nchunk)
    res_gc[2] = tgc / (nrep * nchunk)
    res_alloc[2] = alloc ÷ (nrep * nchunk)

    return res_cpu, res_gc, res_alloc
end

# ------------------------------------------------------------------------------
#                              FUNCTIONS
# ------------------------------------------------------------------------------


# FOR NON EXISTING BLAS FUNCTIONS
nanf() = ""

# DEFINE VECTORIZED JULIA FONCTIONS
vj_dot(a,b) = sum(a.*b)
vj_axpy(λ,a,b) = λ*a+b
vj_invsqrt{T<:Number}(a::Vector{T}) = 1 ./ sqrt(a)

# sqrt(X)
function lj_sqrt{T<:Number}(dest,x::T)
    for i in eachindex(x) dest[i] = sqrt(x[i]) end
    dest
end
function ilj_sqrt{T<:Number}(dest,x::T)
    @inbounds for i in eachindex(x) dest[i] = sqrt(x[i]) end
    dest
end
