using Gadfly
using DataFrames

include("../utility.jl")

# ------------------------------------------------------------------------------
# coût de l'allocation aux petits n
# ------------------------------------------------------------------------------

function main1()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    cpu = Vector{Float64}(length(N))
    @inbounds for i in 1:length(N)
        n = N[i]
        a = rand(n)
        # sqrt(a)
        gc()
        tsum = 0.0
        tsum2 = 0.0

        ncycle = 10_000 ÷ n + 1
        nrep = 500

        for j in 1:nrep
            t = @elapsed for k in 1:ncycle
                Vector{Float64}(n)
                # sqrt(a)
            end
            t = t / ncycle / n * 1e9
            tsum += t
            # tsum2 += t^2
        end
        #
        tavg = tsum / nrep
        # tavg = (@timed for j in 1:nrep Vector{Float64}(n) end)[2] / nrep / n * 1e9
        # tavg2 = tsum2 / nrep
        # tunc = sqrt((tavg2 - tavg^2) / (nrep - 1))

        # tavg = mean([@elapsed sqrt(a) for i in 1:100]) * (1e9 / n)
        cpu[i] = tavg
    end
    N, cpu
end

function main2()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    cpu = Vector{Float64}(length(N))
    @inbounds for i in 1:length(N)
        n = N[i]
        a = rand(n)
        sqrt(a)
        gc()
        tsum = 0.0
        tsum2 = 0.0

        ncycle = 10_000 ÷ n + 1
        nrep = 100

        for j in 1:nrep
            t = @elapsed for k in 1:ncycle
                # Vector{Float64}(n)
                sqrt(a)
            end
            t = t / ncycle / n * 1e9
            tsum += t
            # tsum2 += t^2
        end
        #
        tavg = tsum / nrep
        # tavg = (@timed for j in 1:nrep sqrt(a) end)[2] / nrep / n * 1e9
        # tavg2 = tsum2 / nrep
        # tunc = sqrt((tavg2 - tavg^2) / (nrep - 1))

        # tavg = mean([@elapsed sqrt(a) for i in 1:100]) * (1e9 / n)
        cpu[i] = tavg
    end
    N, cpu
end

layers = Layer[]

main1()
main2()

df = DataFrame() ; df[:N], df[:CPU1] = main1()
push!(layers,layer(df, x="N", y="CPU1", Geom.line, Theme(default_color=color("blue")))[1])

df[:CPU2] = main2()[2]
push!(layers,layer(df, x="N", y="CPU2", Geom.line, Theme(default_color=color("yellow")))[1])
println(df)
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

path = Pkg.dir("MKL") * "/benchmark/cpu_regarding_n/"
draw(PNG(path*"sqrt_yichao2.png", 20cm, 20cm), p)

# ------------------------------------------------------------------------------
# comparaison des différentes méthodes de bench : problème pour les petits n
# ------------------------------------------------------------------------------



function main3()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    df = DataFrame(N=Int64[],ALLOC=Float64[],CPU1=Float64[],CPU2=Float64[],CPU3=Float64[],CPU4=Float64[],CPU5=Float64[])

    @inbounds for i in 1:length(N)
        n = N[i]
        a = rand(n)
        sqrt(a)

        gc()

        tavg1 = mean([@elapsed sqrt(a) for i in 1:100]) * (1e9 / n)

        ncycle = 10_000 ÷ n + 1
        nrep = 1000
        tsum = 0.0
        for j in 1:nrep
            t = @elapsed for k in 1:ncycle sqrt(a) end
            tsum+=  t / ncycle / n * 1e9
        end
        tavg2 = tsum / nrep

        tavg3 = (@timed for j in 1:nrep sqrt(a) end)[2]
        tavg3 = tavg3 / nrep / n * 1e9

        tavg4 = ibench2(sqrt,(a,),n,0.1)[1][2]*1e9/n

        tavg5 = ibench(sqrt,(a,),0.1)[1][2]*1e9/n

        talloc = 0.0

        # talloc = (@timed for j in 1:nrep Array(Float64,n) end)[2] / nrep / n * 1e9

        push!(df,[n,talloc, tavg1,tavg2,tavg3,tavg4,tavg5])
    end
    df
end

df = main3();
println(df)

# ------------------------------------------------------------------------------
# comparaison allocation vs fonction sur sqrt
# ------------------------------------------------------------------------------


function main4()
    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    df = DataFrame(N=Int64[],ALLOC=Float64[],SQRT=Float64[])
    @inbounds for i in 1:length(N)
        T = Float64
        n = N[i]
        a = rand(n)
        sqrt(a)
        nrep = 1000

        gc()
        # tcpu = (@timed for j in 1:nrep sqrt(a) end)[2]
        # tcpu = tcpu / nrep / n * 1e9
        ncycle = 10_000 ÷ n + 1
        tcpu = 0.0
        for j in 1:nrep
            tcpu += @elapsed for k in 1:ncycle sqrt(a) end
        end
        tcpu = tcpu / nrep / ncycle / n * 1e9

        gc()
        # talloc = (@timed for j in 1:nrep Vector{T}(n) end)[2]
        # talloc = talloc / nrep / n * 1e9
        ncycle = 10_000 ÷ n + 1
        talloc = 0.0
        for j in 1:nrep
            talloc += @elapsed for k in 1:ncycle Vector{T}(n) end
        end
        talloc = talloc / nrep / ncycle / n * 1e9

        push!(df,[n,talloc, tcpu])
    end
    df
end

df = main4();
df[:diff] = df[:SQRT]-df[:ALLOC]
println(df)
