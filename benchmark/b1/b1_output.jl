include("../utility.jl")

path = Pkg.dir("MKL") * "/benchmark/b1/"

df = DataFrames.readtable(path*"b1_data.csv")
N = union(df[:N])
T = union(df[:Type])
imp = union(df[:Implementation])
gen = union(df[:Generic])

# this is an option to get normalized data relatively to MKL
# for i in 1:nrow(df)
#     imkl = 3*div(i-1,3) + 2 # MKL row
#     df[i,:CPU_mean] = df[i,:CPU_mean] / df[imkl,:CPU_mean]
#     println(df[i,:CPU_mean])
# end

for n in N
    for t in T

        println(n)
        println(t)

        filter_set = (df[:Type] .== string(t)) & (df[:N] .== n)
        sdf = df[filter_set , :]
        println(sdf)

        set_default_plot_size(20cm, 10cm)
        p = Gadfly.plot(
                    sdf, xgroup="Generic", x="Implementation", y="CPU_mean",
                    color="Implementation",
                    Scale.color_discrete_manual(Tdarkgray,Tblue,Tlightgray),
                    Scale.y_continuous(minvalue=0, maxvalue=20),
                    Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical, label=false)),
                    Guide.xlabel(""),
                    Guide.ylabel(""),
                    Guide.title("CPU time on n-dim vectors (n=1e"*string(convert(Int32,log10(n)))),
                    Theme(bar_spacing=0.1cm)
                    )

        draw(PNG(path*"output/b1_$t"*"_$n.png", 25cm, 12cm), p)
        # draw(SVG(path*"output/b1_$t"*"_$n.svg", 25cm, 12cm), p)
        p
    end
end


for n in N

    println(n)

    filter_set = (df[:N] .== n)
    sdf = df[filter_set , :]
    println(sdf)

    p = Gadfly.plot(
                layer(
                sdf, xgroup="Generic", ygroup="Type", x="Implementation", y="CPU_mean",
                color="Implementation",
                Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical, label=false))
                ),
                Scale.color_discrete_manual(Tdarkgray,Tblue,Tlightgray),
                Scale.y_continuous(minvalue=0, maxvalue=20),
                Guide.xlabel(""),
                Guide.ylabel(""),
                Guide.title("CPU time on n-dim vectors (n=1e"*string(convert(Int32,log10(n)))*")"),
                Theme(bar_spacing=0.1cm)
                )

    # draw(PNG(path*"output/b1_$n.png", 25cm, 12cm), p)
    draw(SVG(path*"output/b1_$n.svg", 29cm, 20cm), p)
    draw(PDF(path*"output/b1_$n.pdf", 29cm, 20cm), p)
    p
end





# POST TREATMENT FOR .CSV EXPORT (using DatFrames)
# begin
#     hrow = union(df[:Generic]) # list of generic functions
#     hcol = ("BLAS","MKL","VJulia") #union(df[:Implementation])
#     resdf = DataFrame()
#
#     col = ASCIIString[]
#     for i=1:length(hcol)
#         push!(col,string(hcol[i]," (mean)"))
#         push!(col,string(hcol[i]," (conf)"))
#     end
#     resdf[:Generic] = col
#
#     for imp in hrow
#         resdf[symbol(imp)] = [0.0 for i=1:2*length(hcol)]
#     end
#
#     subdf = df[ df[:Type] .== "Float32", :]
#
#     for i=1:nrow(subdf)
#         icol = 1 + findfirst(hrow,subdf[i,1])
#         irow = 1 + 2*(findfirst(hcol,subdf[i,2])-1)
#         resdf[irow,icol] = subdf[i,5]
#         resdf[irow+1,icol] = subdf[i,6]
#     end
#     # println(hcol)
#     # println(hrow)
#     println(df)
#     println(subdf)
#
#     println(resdf)
#     # writetable("output.csv", resdf, separator='\t')
#     writetable(path * "b1_cpu_$n.csv", resdf, separator='\t')
#     # writetable(path * "output.csv", df, separator='\t')
# end

# Float32 / Float64 PERFORMANCE COMPARISON
# begin
#     hrow = union(df[:Generic]) # list of generic functions
#     hcol = ("BLAS","MKL","VJulia") #union(df[:Implementation])
#     resdf = DataFrame()
#
#     col = ASCIIString[]
#     for i=1:length(hcol)
#         push!(col,string(hcol[i],""))
#     end
#     resdf[:Generic] = col
#
#     for imp in hrow
#         resdf[symbol(imp)] = [0.0 for i=1:1*length(hcol)]
#     end
#
#     subdf_32 = df[ df[:Type] .== "Float32", :]
#     subdf_64 = df[ df[:Type] .== "Float64", :]
#
#     for i=1:nrow(subdf_64)
#         subdf_64[i,5] = subdf_64[i,5] / subdf_32[i,5]
#         println(subdf_64[i,5])
#     end
#
#     for i=1:nrow(subdf_64)
#         icol = 1 + findfirst(hrow,subdf_64[i,1])
#         irow = 1 + 1*(findfirst(hcol,subdf_64[i,2])-1)
#         resdf[irow,icol] = subdf_64[i,5]
#     end
#
#     # println(subdf_64)
#     # println(resdf)
#     writetable(path * "b1_Float32_vs_Float64_$n.csv", resdf, separator='\t')
#
#     # println(resdf)
#     # writetable("output.csv", resdf, separator='\t')
#
#     # writetable(path * "output.csv", df, separator='\t')
# end




# set_default_plot_size(10cm, 10cm)
# p = plot(df, ygroup="Type", x="Method", y="CPU_mean", color="Implementation", Geom.subplot_grid(Geom.bar, Guide.xticks(orientation=:vertical)),Theme(bar_spacing=0.1cm))
