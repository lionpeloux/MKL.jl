using VML, DataFrames

# add single result to dataframe
function addresult!(df::DataFrame, op, res)
    push!(df,[op, res[2], res[3], res[4]])
end

# wrap functions to avoid global scoping while testing
sqrt_jvectorized{T<:Number}(a::Vector{T}) =
    Base.sqrt(a)
sqrt_jbroadcast{T<:Number}(a::Vector{T}) =
    broadcast(sqrt,a)
sqrt_jbroadcast!{T<:Number}(dest::Vector{T}, a::Vector{T}) =
    broadcast!(sqrt,dest,a)
sqrt_jmap{T<:Number}(a::Vector{T}) =
    map!(sqrt,a)
sqrt_jmap!{T<:Number}(dest::Vector{T}, a::Vector{T}) =
    map!(sqrt,dest,a)
sqrt_jloop{T<:Number}(dest::Vector{T},a::Vector{T}) =
    @inbounds for i in eachindex(a) dest[i]=sqrt(a[i]) end

function sqrt_bench()
    # define vector size and floating precision
    n = 1_000
    T = Float64
    df = DataFrame(SQRT=[], CPU=Float64[], ALLOC=Int64[], GC=Float64[])

    # allocate vectors
    @timed dest  = ones(T,n)
    r1 = (@timed a = rand(T,n))

    # bench
    gc()
    gc_enable(false)
    addresult!(df, symbol("Allocation")        , r1)
    addresult!(df, symbol("Julia vectorized")  , @timed sqrt_jvectorized(a))
    addresult!(df, symbol("Julia broadcast")   , @timed sqrt_jbroadcast(a))
    addresult!(df, symbol("Julia broadcast!")  , @timed sqrt_jbroadcast!(dest,a))
    addresult!(df, symbol("Julia map")         , @timed sqrt_jmap(a))
    addresult!(df, symbol("Julia map!")        , @timed sqrt_jmap!(dest,a))
    addresult!(df, symbol("VML (allocation)")    , @timed VML.sqrt(a))
    addresult!(df, symbol("VML (in-place)")      , @timed VML.sqrt!(dest,a))
    gc_enable(true)

    n, df
end

n, df = sqrt_bench()

# println(df)
df[:CPU] *= 1e9/n
println(df)

path = Pkg.dir("MKL") * "/benchmark/final/"
writetable(path * "sqrt_memoryusage_data.csv", df, separator=',')
