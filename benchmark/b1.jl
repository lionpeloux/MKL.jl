using Formatting
using Gadfly

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
    res = @timed f(arg...)
    nrun = convert(Int64,div(timing,res[2]))

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
      res = @timed f(arg...)
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


function bplot(compare_tb)
    nfs = size(compare_tb,1)

    ys = compare_tb[:,1]
    ymins = ys - compare_tb[:,5]
    ymaxs = ys + compare_tb[:,5]
    println(ys)
    println(compare_tb[:,5])
    println(ymins)
    println(ymaxs)
    p = plot(
            layer(  x=1:nfs, y=ys, ymin=ymins, ymax=ymaxs, Geom.errorbar, Theme(default_color=colorant"red")),
            layer(  y=ys, Geom.bar,Theme(bar_spacing=1cm)),
            Scale.x_continuous(minvalue=0, maxvalue=4),
            Scale.y_continuous(minvalue=0, maxvalue=0.02)
            )
    return p
end


# rand(10)@
# sin(randn(3))
# .+([1,2],[2,3])
# args = [1,2],[2,3]
# .+(args...)
#
# a,b,c = ibench(.+,([1,2],[-1,2]),0.0001)
# res_cpu
# a
# iplot(sin, alpha, res_cpu, res_gc, res_alloc)
# sqrt([1,2,3])


# begin
#     fns = Any[]
#     args = Any[]
#
#     for (fname, arg) in ((sin,  (Float32[0.0,pi/2],)),
#                          (cos,  (Float32[0.0,pi/2],)),
#                          (sqrt, (Float32[0.0,2],)),
#                          )
#         push!(fns,fname)
#         push!(args,arg)
#     end
# end

begin
    fns = Any[]
    args = Any[]
    ne = 1000*1000
    for (fname, arg) in ((sin,  (rand(ne),)),
                         (cos,  (rand(ne),)),
                         (sqrt, (rand(ne),)),
                         )
        push!(fns,fname)
        push!(args,arg)
    end
end

fns
args
compare_cpu, compare_gc, compare_alloc = bench(fns,args,1)
bplot(compare_cpu)




# bench(Any[sin, sqrt],Any[(rand(10),),(rand(10),)],0.0001)
