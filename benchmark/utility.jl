using Formatting

# ------------------------------------------------------------------------------
#                              INDIVIDUAL BENCH
# ------------------------------------------------------------------------------

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
function ibench(ex::Expr, timing=0.0001, gcdisable=true ; α=0.05, print_eval=false, print_stats=false, print_detail=false)

    # HOW-TO : construct an expression for unary and multiary functions
    # s1 = :f
    # s2 = (:a,:b)
    # s3 = (:c,)
    # Expr(:call,s1,s2...)
    # Expr(:call,s1,s3...)

    # TRIGGER JIT : first compilation will be ignored
    # res = @timed f(arg...)
    # res = @timed eval(Expr(:call,f,eval(arg)...)) # everything is pass as symbol

    res = @timed eval(ex)
    nrun = max(2,convert(Int64,div(timing,res[2]))) # at least one run

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
        gcdisable ? gc_enable(false) : ""
        res = @timed eval(ex)
        gcdisable ? gc_enable(true) : ""
        res_cpu[i+1] = res[2]
        res_gc[i+1] = res[4]
        res_alloc[i+1] = res[3]
    end

    idisplay(ex, timing, res_cpu, res_gc, res_alloc ; α=α, print_eval=print_eval, print_stats=print_stats, print_detail=print_detail)
    return res_cpu, res_gc, res_alloc
end

# TUTORIAL
# a = [0.0,1.0]
# b = [1.0,2.0]
#
# f = :+
# arg = (:a,:b)
# e = Expr(:call,f,arg...)
# ibench(e, 0.01, true ; print_stats=true, print_detail=false, print_eval=true)
#
# f = :sin
# arg = (:a,)
# e = Expr(:call,f,arg...)
# ibench(e, 0.01, true ; print_stats=true, print_detail=false, print_eval=true)


"""
`ìdisplay` prints the results of an individual bench `ìbench` performed on a
function `f` with the given input arguments `arg`.
`detail` printing defaults to `false`.
`res` prints a sample evaluation (for checking) is `true` ; defaults to `false`
"""
function idisplay(ex::Expr, timing, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64} ; α=0.05, print_eval=false, print_stats=true, print_detail=false)

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
    println("Running $ex for about $timing s")
    println("Evaluations : $nrun")
    println("CPU time : ",sum(res_cpu),"s")
    # PRINT EVAL
    if print_eval
        println(ex, " = ")
        println(eval(ex))
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

"""
"""
function iplot(f, α, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64})
    n = length(res_cpu)-1

    # GET STATS
    stat_cpu = bstat(res_cpu[2:end],α)
    stat_gc = bstat(res_gc[2:end],α)
    stat_alloc = bstat(res_alloc[2:end],α)

    ys = [stat_cpu[1]]
    ymins = ys .- stat_cpu[5]
    ymaxs = ys .+ stat_cpu[5]

    p = plot(
            layer(  x=1:1, y=ys, ymin=ymins, ymax=ymaxs, Geom.errorbar, Theme(default_color="red")),
            layer(  y=ys, Geom.bar,Theme(bar_spacing=1cm)),
            Scale.x_continuous(minvalue=0, maxvalue=4),
            Scale.y_continuous(minvalue=0, maxvalue=stat_cpu[1]+2*stat_cpu[4])
            )
    return p
end

# ------------------------------------------------------------------------------
#                    MULTI BENCH : provide comparison
# ------------------------------------------------------------------------------

function bench(fs,args,timing=0.0001)
    nfs = length(fs)

    compare_cpu     = zeros(Float64, nfs, 5)
    compare_gc      = zeros(Float64 ,nfs, 5)
    compare_alloc   = zeros(Int64, nfs, 5)

    for i=1:nfs
        f = fs[i]
        arg=args[i]
        # # perform individual bench
        res_cpu, res_gc, res_alloc = ibench(f,arg,timing)
        # # push stat data to the comparison table
        compare_cpu[i,:] = bstat(res_cpu[2:end],α)
        compare_gc[i,:] = bstat(res_gc[2:end],α)
        compare_alloc[i,:] = bstat(res_alloc[2:end],α)
    end
    return Any[compare_cpu, compare_gc, compare_alloc]
end


function bplot{T<:Number}(labels::Vector{Any}, values_mean::Vector{T}, values_conf::Vector{T})

    nfs = size(labels)

    ys = values_mean
    ymins = ys - values_conf
    ymaxs = ys + values_conf

    p = plot(
        layer(x=[string(l) for l in labels], y=ys, ymin=ymins, ymax=ymaxs, Geom.errorbar, Theme(default_color="red")),
        layer(x=[string(l) for l in labels], y=ys, Geom.bar, Theme(bar_spacing=0.5cm)),
        Scale.y_continuous(minvalue=0),
        Guide.xticks(orientation=:vertical)
    )
    return p
end
