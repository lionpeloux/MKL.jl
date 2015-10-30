using Formatting
using Gadfly
using MKL
using Base.LinAlg.BLAS

alpha = 0.01
timing = 0.001
disp_detail = false

# ------------------------------------------------------------------------------
#                              INDIVIDUAL BENCH
# ------------------------------------------------------------------------------

function bstat{T<:Number}(v::Vector{T}, alpha=0.05)
    n = length(v)
    v_mean = mean(v)
    v_min , v_max = extrema(v)
    v_std =  stdm(v, v_mean)
    conf = sqrt(2)*erfinv(1-alpha)*(v_std/sqrt(n)) # v = v_mean +/- conf
    return Float64[v_mean, v_min, v_max, v_std, conf]
end

function idisplay(f, arg, timing, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64})

    nrun = length(res_cpu)-1

    # FORMATER
    fe_sep1 = FormatExpr("{:=>40}")
    fe_sep2 = FormatExpr("{:->40}")
    fe_head = FormatExpr("{:<6s}{:>12s}{:>8s}{:>14s}")
    fe_line = FormatExpr("{:<6s}{:>12.2e}{:>8.2f}{:>14d}")

    # GET STATS
    stat_cpu = bstat(res_cpu[2:end],alpha)
    stat_gc = bstat(res_gc[2:end],alpha)
    stat_alloc = bstat(res_alloc[2:end],alpha)

    # SUMMARY
    println("")
    printfmtln(fe_sep1,"")
    println("Running $f for about $timing s")
    println("Evaluations : $nrun")
    println("CPU time : ",sum(res_cpu),"s")

    # printfmtln(fe_sep1,"")
    # println("N = ",N," | n = ",n," | ",T, " | t = ",timing,"s")
    # printfmtln(fe_sep1,"")

    # HEADER
    printfmtln(fe_sep1,"")
    printfmtln(fe_head,"NAME","CPU (s)", "GC (%)", "ALLOC (byt)")
    printfmtln(fe_sep1,"")

    # RESULTS : MEAN
    printfmtln(fe_line, "MEAN", stat_cpu[1], stat_gc[1], stat_alloc[1])
    printfmtln(fe_line, "MIN", stat_cpu[2], stat_gc[2], stat_alloc[2])
    printfmtln(fe_line, "MAX", stat_cpu[3], stat_gc[3], stat_alloc[3])
    printfmtln(fe_line, "STD", stat_cpu[4], stat_gc[4], stat_alloc[4])
    printfmtln(fe_line, "CONF", stat_cpu[5], stat_gc[5], stat_alloc[5])
    printfmtln(fe_sep2,"")

    # RESULTS : JIT
    printfmtln(fe_line, "JIT", res_cpu[1], res_gc[1], res_alloc[1])
    printfmtln(fe_sep2,"")

    # RESULTS : details
    if disp_detail == true
        for i=1:nrun
            printfmtln(fe_line, i, res_cpu[i+1], res_gc[i+1], res_alloc[i+1])
        end
    end
    return
end

function iplot(f, alpha, res_cpu::Vector{Float64}, res_gc::Vector{Float64}, res_alloc::Vector{Int64})
    n = length(res_cpu)-1

    # GET STATS
    stat_cpu = bstat(res_cpu[2:end],alpha)
    stat_gc = bstat(res_gc[2:end],alpha)
    stat_alloc = bstat(res_alloc[2:end],alpha)

    ys = [stat_cpu[1]]
    ymins = ys .- stat_cpu[5]
    ymaxs = ys .+ stat_cpu[5]

    p = plot(
            layer(  x=1:1, y=ys, ymin=ymins, ymax=ymaxs, Geom.errorbar, Theme(default_color=colorant"red")),
            layer(  y=ys, Geom.bar,Theme(bar_spacing=1cm)),
            Scale.x_continuous(minvalue=0, maxvalue=4),
            Scale.y_continuous(minvalue=0, maxvalue=stat_cpu[1]+2*stat_cpu[4])
            )
    return p
end

function ibench(f,arg,timing=0.0001)

    # TRIGGER JIT : first compilation will be ignored
    # println(f(arg))
    # res = @timed f(arg...)
    res = @timed eval(Expr(:call,f,eval(arg)...)) # everything is pass as symbol
    nrun = max(2,convert(Int64,div(timing,res[2]))) # at least one run

    # allocate results arrays
    res_cpu = Array(Float64,nrun+1)
    res_gc = Array(Float64,nrun+1)
    res_alloc = Array(Int64,nrun+1)

    # Write JIT results
    res_cpu[1] = res[2]
    res_gc[1] = res[4]
    res_alloc[1] = res[3]

    # Write PROFILING results : call f n times
    gc(), gc_enable(false)
    for i=1:nrun
      res = @timed eval(Expr(:call,f,eval(arg)...))
      res_cpu[i+1] = res[2]
      res_gc[i+1] = res[4]
      res_alloc[i+1] = res[3]
    end
    gc_enable(true)

    idisplay(f, arg, timing, res_cpu, res_gc, res_alloc)
    return Any[res_cpu, res_gc, res_alloc]
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
        compare_cpu[i,:] = bstat(res_cpu[2:end],alpha)
        compare_gc[i,:] = bstat(res_gc[2:end],alpha)
        compare_alloc[i,:] = bstat(res_alloc[2:end],alpha)
    end
    return Any[compare_cpu, compare_gc, compare_alloc]
end


function bplot{T<:Number}(labels::Vector{Any}, values_mean::Vector{T}, values_conf::Vector{T})

    nfs = size(labels)

    ys = values_mean
    ymins = ys - values_conf
    ymaxs = ys + values_conf

    p = plot(
        layer(x=[string(l) for l in labels], y=ys, ymin=ymins, ymax=ymaxs, Geom.errorbar, Theme(default_color=colorant"red")),
        layer(x=[string(l) for l in labels], y=ys, Geom.bar, Theme(bar_spacing=0.5cm)),
        Scale.y_continuous(minvalue=0),
        Guide.xticks(orientation=:vertical)
    )
    return p
end



begin
    fnames = Any[]
    fs = Any[]
    args = Any[]
    n = 10000
    a = rand(n)
    b = rand(n)
    y = zeros(n)
    for (fname, f, arg) in ( ("sin",    :sin,    :(a,)      ),
                             ("cos",    :cos,    :(a,)      ),
                             ("sqrt",   :sqrt,   :(a,)      ),
                             ("Add",    :(.+),   :(a,b)     ),
                             ("Sub",    :(.-),   :(a,b)     ),
                             ("Mul",    :(.*),   :(a,b)     ),
                             ("Div",    :(./),   :(a,b)     ),
                             ("Mul2",   :(MKL.mkl_mul!),    :(n,a,b,y)   ),
                             ("BAdd",   :(BLAS.axpy!),      :(2,a,b)      ),
                             ("MAdd",   :(MKL.mkl_add!),    :(n,a,b,y)   ),
                             )
        push!(fnames,fname)
        push!(fs,f)
        push!(args,arg)
    end

    compare_cpu, compare_gc, compare_alloc = bench(fs,args,1)
    bplot(fnames,compare_cpu[:,1],compare_cpu[:,5])
end
#
# fs
# args




# EXPRESION HELP
#
# f = :(MKL.mkl_mul!)
# arg = :(2,Float64[1,2],Float64[1,2],zeros(2))
# res = @time eval(Expr(:call,f,eval(arg)...))
# ibench(f,arg,0.00000001)
#
# r = Expr(:call,:(MKL.mkl_mul!),:(2,Float64[1,2],Float64[1,2],zeros(2)))
# eval(r)
