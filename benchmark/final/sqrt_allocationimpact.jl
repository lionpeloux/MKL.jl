using DataFrames, VML

function sqrt_bench()

    N = [1,2,3,4,5,6,7,8,9,
         10,20,30,40,50,60,70,80,90,100,200,300,400,500,750,
         1_000,2_500,5_000,7_500,10_000,100_000,1_000_000]

    # df = DataFrame(N=Int64[],ALLOC=Float64[],JULIA=Float64[],MKL=Float64[])
    df = DataFrame(N=Int64[],ALLOC=Float64[],JULIA=Float64[])


    @inbounds for i in 1:length(N)
        T = Float64
        n = N[i]
        a = rand(T,n)
        dest = zeros(T,n)
        # sqrt(a)
        # VML.sqrt!(dest,a)

        nrep = 1000
        ncycle = 10_000 ÷ n + 1

        gc()
        tcpu1 = 0.0 ; tcpu2 = 0.0 ; talloc = 0.0
        for j in 1:nrep
            talloc += @elapsed for k in 1:ncycle Vector{T}(n) end
            tcpu1 += @elapsed for k in 1:ncycle sqrt(a) end
            # tcpu2 += @elapsed for k in 1:ncycle VML.sqrt!(dest,a) end
        end
        talloc = talloc / nrep / ncycle / n * 1e9
        tcpu1 = tcpu1 / nrep / ncycle / n * 1e9
        # tcpu2 = tcpu2 / nrep / ncycle / n * 1e9

        # push!(df,[n,talloc, tcpu1, tcpu2])
        push!(df,[n,talloc, tcpu1])
    end
    df
end

df = sqrt_bench();
df[:diff] = df[:JULIA]-df[:ALLOC]
println(df)

path = Pkg.dir("MKL") * "/benchmark/final/"
writetable(path * "sqrt_allocationimpact_data.csv", df, separator=',')
