include("../utility.jl")

path = Pkg.dir("MKL") * "/benchmark/b2/"

df = DataFrames.readtable(path*"b2_data_bak.csv", separator = '\t')
N = union(df[:N])
T = union(df[:Type])
imp = union(df[:Implementation])
gen = union(df[:Generic])


for gen in ("sqrt(X)",)
    for t in T

        filter_set = (df[:Type] .== string(t)) & (df[:Generic] .== "sqrt(X)")
        sdf = df[filter_set , :]
        println(sdf)

        imps = union(sdf[:Implementation])
        layers = Layer[]; legend = []; colors = []

        nlayer = 0
        for imp in imps
            linedf = sdf[sdf[:Implementation] .== imp,:]
            if linedf[1,:CPU_mean] > 0
                nlayer += 1
                push!(legend,imp)
                rgb = 0.5+nlayer/20
                imp == "MKL" ?  push!(colors, colorant"deepskyblue") :
                                imp == "BLAS" ? push!(colors, colorant"red") : push!(colors, RGB(rgb,rgb,rgb))
                push!(layers,layer(linedf, x="N", y="CPU_mean", Geom.line, Theme(default_color=colors[nlayer]))[1])
            end
        end


        p = Gadfly.plot(
                layers,
                Scale.x_log10(minvalue=10,maxvalue  =100_000),
                # Scale.y_log10,
                Guide.xlabel("n-dim"),
                Guide.ylabel("relative CPU time"),
                Guide.title("relative CPU time against MKL"),
                Guide.manual_color_key("Legend",
                        legend,
                        colors),
                )

        draw(PNG(path*"$gen"*"_$t.png", 20cm, 10cm), p)
    end
end


# ("1/sqrt(X)",   "BLAS"      ,    t,  nanf        ,   ()          ),
# ("1/sqrt(X)",   "MKL"       ,    t,  mkl_invsqrt!,   (n,a,y)     ),
# ("sqrt(X)",     "VJulia"    ,    t,  vj_invsqrt  ,   (y,a)       ),
# ("sqrt(X)",     "LJulia"    ,    t,  lj_invsqrt  ,   (y,a)       ),
# ("sqrt(X)",     "iLJulia"   ,    t,  ilj_invsqrt ,   (y,a)       ),
# ("sqrt(X)",     "MJulia"    ,    t,  map!        ,   (sqrt,y,a)  ),
# ("sqrt(X)",     "BJulia"    ,    t,  broadcast!  ,   (sqrt,y,a)  ),
