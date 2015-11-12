using Gadfly
using DataFrames
using VML

include("../utility.jl")

function main()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    df = DataFrame(N=Int64[],ALLOC=Float64[],VJULIA=Float64[],BJULIA=Float64[],VML=Float64[])

    @inbounds for i in 1:length(N)
        T = Float64
        n = N[i]
        a = rand(n)
        dest = zeros(n)

        sqrt(a)

        nrep = 100
        ncycle = 10_000 ÷ n + 1

        # n < 100 ? gc_enable(false) : gc_enable(true)

        # gc()
        talloc = 0.0
        for j in 1:nrep
            talloc += @elapsed for k in 1:ncycle Vector{T}(n) end
        end
        talloc = talloc / nrep / ncycle / n * 1e9

        # gc()
        tvjulia = 0.0
        for j in 1:nrep
            tvjulia += @elapsed for k in 1:ncycle sqrt(a) end
        end
        tvjulia = tvjulia / nrep / ncycle / n * 1e9

        # gc()
        tbjulia = 0.0
        # for j in 1:nrep
        #     tbjulia += @elapsed for k in 1:ncycle broadcast!(sqrt,dest,a) end
        # end
        # tbjulia = tbjulia / nrep / ncycle / n * 1e9

        # gc()
        tvml = 0.0
        # for j in 1:nrep
        #     tvml += @elapsed for k in 1:ncycle VML.sqrt!(dest,a) end
        # end
        # tvml = tvml / nrep / ncycle / n * 1e9

        # n < 100 ? gc_enable(false) : gc_enable(true)

        push!(df,[n,talloc, tvjulia, tbjulia, tvml])

    end
    df
end


df = main();
df[:diff] = df[:VJULIA]-df[:ALLOC]
println(df)

layers = Layer[]

bench_alloc(),bench_jvect(),bench_jbroadcast!(),bench_mkl(),bench_mkl!(),bench_jvect2()

df = DataFrame() ; df[:N], df[:CPU] = bench_alloc()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("blue")))[1])

df = DataFrame() ; df[:N], df[:CPU] = bench_jvect()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("yellow")))[1])

df = DataFrame() ; df[:N], df[:CPU] = bench_jbroadcast!()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("green")))[1])

df = DataFrame() ; df[:N], df[:CPU] = bench_mkl()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("orange")))[1])

df = DataFrame() ; df[:N], df[:CPU] = bench_mkl!()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("red")))[1])

df = DataFrame() ; df[:N], df[:CPU] = bench_jvect2()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("black")))[1])

println(df)

p = Gadfly.plot(layers,
                # Scale.y_log10,
                Scale.x_log10,
                Guide.xlabel("n-element vector"),
                Guide.ylabel("CPU time in nsec/element"),
                Guide.title("CPU time with n elements"),
                Guide.manual_color_key("",
                ["ALLOC", "Base.sqrt","broadcast!","VML.sqrt","VML.sqrt!","ibench"],
                ["blue","yellow","green","orange","red","black"])
                )

path = Pkg.dir("MKL") * "/benchmark/sqrt_cpu_regarding_n/"
draw(PNG(path*"sqrt_map!.png", 20cm, 20cm), p)
