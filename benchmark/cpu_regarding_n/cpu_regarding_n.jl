using Gadfly
using DataFrames
using VML

include("../utility.jl")

function main()

    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    df = DataFrame(N=Int64[],ALLOC=Float64[],JULIA=Float64[])

    @inbounds for i in 1:length(N)

        T = Float32
        n = N[i]
        a = rand(T,n)
        # println(n)

        Vector{T}(n)
        sqrt(a)
        VML.sqrt(a)
        VML.sqrt!(a,a)

        if n <= 1000
            gc()
            t1 = (@elapsed for k in 1:1000 Vector{T}(n) end)/1000
            t2 = (@elapsed for k in 1:1000 sqrt(a) end)/1000
        end

        if n > 1000
            gc()
            t1 = mean([@elapsed Vector{T}(n) for k in 1:100])
            t2 = mean([@elapsed sqrt(a) for k in 1:100])
        end

        push!(df,[n,t1*(1e9/n),t2*(1e9/n)])
    end
    df
end

df = main()
println(df)
# @code_warntype main()

layers = Layer[]

df = DataFrame() ; df[:N], df[:CPU] = main1()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("blue")))[1])

df = DataFrame() ; df[:N], df[:CPU] = main2()
push!(layers,layer(df, x="N", y="CPU", Geom.line, Theme(default_color=color("yellow")))[1])


p = Gadfly.plot(layers,
                # Scale.y_log10,
                Scale.x_log10,
                Guide.xlabel("n-element vector"),
                Guide.ylabel("CPU time in nsec/element"),
                Guide.title("CPU time with n elements"),
                Guide.manual_color_key("",
                ["ALLOC", "Base.sqrt"],
                ["blue","yellow"])
                )

path = Pkg.dir("MKL") * "/benchmark/sqrt_cpu_regarding_n/"
draw(PNG(path*"sqrt_yichao.png", 20cm, 20cm), p)

n = 1

f1(n) = for i=1:1000 Vector{Float64}(n) end
f2(n) = [@elapsed Vector{Float64}(n) for i=1:1000]

@time f1(1)
sum(f2(1))

df = main3();
println(df)

a = rand(2)
t = ibench2(sqrt,(a,),0.1)
