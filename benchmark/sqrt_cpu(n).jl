using Gadfly
using DataFrames

include("./utility.jl")
function bench_cpu_regarding_n()
    N = [   1,2,3,4,5,6,7,8,9,
            10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
            1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    cpu = Float64[]
    for n in N
        a = rand(n)
        sqrt(a)
        gc()
        gc_enable(false)
        t = mean([@elapsed sqrt(a) for i=1:100])*(1e9/n)
        # t = mean(ibench(sqrt, (a,),0.1 ; print_eval=false, print_stats=true)[1])*(1e9/n)
        gc_enable(true)
        push!(cpu,t)
        println(round(cpu[end]))
    end

    df = DataFrame()
    df[:N] = N
    df[:CPU] = cpu

    path = Pkg.dir("MKL") * "/benchmark/"
    p = Gadfly.plot(
                    layer(df,x="N",y="CPU",Geom.line),
                    Scale.x_log10,
                    Guide.xlabel("n-element vector"),
                    Guide.ylabel("CPU time in nsec/element"),
                    Guide.title("CPU time for sqrt(X) where X = Float64[] with n elements"))
    draw(PNG(path*"sqrt_cpu(n).png", 20cm, 20cm), p)
    p
end

bench_cpu_regarding_n()
@time bench_cpu_regarding_n()


begin
    N = 1_000_000
    p = convert(Int64,log10(N))
    cpu = []
    for i=0:p
        n = 10^(p-i)
        ne = div(N,n)
        a = [rand(n) for j=1:ne]
        println("ne = $ne | n = $n | nexn = ", ne*n)
        t = mean([
            @elapsed  begin
                        for j=1:ne
                            sqrt(a[j])
                        end
                    end
            for i=1:100])*(1e9/N)
        push!(cpu,t)
    end
end
println(cpu)
p = 6
df = DataFrame()
df[:N] = [10^(i) for i=0:p]
df[:CPU] = reverse(cpu)
df

p = Gadfly.plot(
                layer(df,x="N",y="CPU",Geom.line),
                Scale.x_log10,
                Guide.xlabel("n-element vector"),
                Guide.ylabel("CPU time in nsec/element"),
                Guide.title("CPU time for sqrt(X) where X = Float64[] with n elements"))

path = Pkg.dir("MKL") * "/benchmark/"
draw(PNG(path*"sqrt_frag.png", 20cm, 20cm), p)
p


function main()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    cpu = Vector{Float64}(length(N))
    @inbounds for i in 1:length(N)
        n = N[i]
        a = rand(n)
        dest = rand(n)

        # mkl_sqrt!(n,a,dest)
        map!(sqrt,dest,a)
        # broadcast!(sqrt,dest,a)
        # sqrt(a)

        gc()
        tsum = 0.0
        tsum2 = 0.0

        ncycle = 10_000 ÷ n + 1
        nrep = 100

        for j in 1:nrep
            t = @elapsed for k in 1:ncycle
                # Vector{Float64}(n)
                # mkl_sqrt!(n,a,dest)
                map!(sqrt,dest,a)
                # broadcast!(sqrt,dest,a)
                # sqrt(a)
            end
            t = t / ncycle / n * 1e9
            tsum += t
            # tsum2 += t^2
        end

        tavg = tsum / nrep
        # tavg2 = tsum2 / nrep
        # tunc = sqrt((tavg2 - tavg^2) / (nrep - 1))

        # tavg = mean([@elapsed sqrt(a) for i in 1:100]) * (1e9 / n)
        cpu[i] = tavg
    end
    N, cpu
end


df = DataFrame()
df[:N], df[:CPU] = main()

p = Gadfly.plot(layer(df, x="N", y="CPU", Geom.line),
                Scale.x_log10,
                Guide.xlabel("n-element vector"),
                Guide.ylabel("CPU time in nsec/element"),
                Guide.title("CPU time with n elements")
                )

path = Pkg.dir("MKL") * "/benchmark/"
draw(PNG(path*"sqrt_map!.png", 20cm, 20cm), p)
