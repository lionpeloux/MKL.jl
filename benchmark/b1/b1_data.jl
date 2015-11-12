include("../utility.jl")

"""
In this benchmark (b1), we provide a comparison between functions from
Julia, OpenBLAS and MKL that runs on a n-dim vector.
The comparison is also made between Float32 / Float64.
"""
# BENCH PARAMETERS
path = Pkg.dir("MKL") * "/benchmark/b1/"
timing = .1
α = 0.05

# N = [10,20,30,40,50,100,200,300,400,500,1_000,5_000,10_000,25_000,50_000,100_000,250_000,500_000,750_000,1_000_000]
""" attention : ibench valide pour n>1e4 en dessous, utiliser ibench2 """
N = [10_000,]
T = [Float32,Float64]

# GENERATE RAW DATA
function bench_b1()

    df = DataFrame( Generic = ASCIIString[], Implementation = ASCIIString[], Type = ASCIIString[], Method = Any[],
                    N = Int64[],
                    CPU_mean = Float64[], CPU_conf = Float64[],
                    GC_mean = Float64[], GC_conf = Float64[],
                    ALLOC_mean = Float64[], ALLOC_conf = Float64[])

    println("approx total CPU timing = ", 30*timing*length(N)*length(T), "(s)")

    for n in N

        println("#################################################################")
        println("N = $n")
        println("#################################################################")

        for t in T

            λ = convert(t,pi) # keep it to 1.0 otherwise scal is going inf
            a = rand(t,n)
            b = rand(t,n)
            y = zeros(t,n)
            z = zeros(t,n)

        # for (t,λ,a,b,y,z) in ((Float32,λ32,a32,b32,y32,z32),(Float64,λ64,a64,b64,y64,z64))

            tup = (

            ("dot(X.Y)",   "BLAS"  ,    t,  BLAS.dot   ,   (n,a,1,b,1) ),
            ("dot(X,Y)",   "MKL"   ,    t,  mkl_dot    ,   (n,a,1,b,1) ),
            ("dot(X,Y)",   "Julia" ,    t,  vj_dot     ,   (a,b)       ),

            ("aX",      "BLAS"  ,    t,  BLAS.scal! ,   (n,convert(t,0.9999),a,1)   ),
            ("aX",      "MKL"   ,    t,  mkl_scal!  ,   (n,convert(t,0.9999),a,1)   ),
            ("aX",      "Julia" ,    t,  *          ,   (λ,a)       ),

            ("X+Y",     "BLAS"  ,    t,  BLAS.axpy! ,   (1.0,a,b)   ),
            ("X+Y",     "MKL"   ,    t,  mkl_add!   ,   (n,a,b,y)   ),
            ("X+Y",     "Julia" ,    t,  +          ,   (a,b)       ),

            ("X-Y",     "BLAS"  ,    t,  BLAS.axpy! ,   (-1.0,a,b)  ),
            ("X-Y",     "MKL"   ,    t,  mkl_sub!   ,   (n,a,b,y)   ),
            ("X-Y",     "Julia" ,    t,  -          ,   (a,b)       ),
            #
            ("aX+Y",    "BLAS"  ,    t,  BLAS.axpy! ,   (λ,a,b)     ),
            ("aX+Y",    "MKL"   ,    t,  mkl_axpy!  ,   (n,λ,a,1,b,1)),
            ("aX+Y",    "Julia" ,    t,  vj_axpy    ,   (λ,a,b)     ),

            ("X.Y",     "BLAS"  ,    t,  nanf       ,   ()         ),
            ("X.Y",     "MKL"   ,    t,  mkl_mul!   ,   (n,a,b,y)   ),
            ("X.Y",     "Julia" ,    t,  .*         ,   (a,b)       ),

            ("X^2",     "BLAS"  ,    t,  nanf       ,   ()         ),
            ("X^2",     "MKL"   ,    t,  mkl_powx!  ,   (n,a,convert(t,2),y)),
            ("X^2",     "Julia" ,    t,  .^         ,   (a,convert(t,2))    ),
            #
            ("X/Y",     "BLAS"  ,    t,  nanf       ,   ()         ),
            ("X/Y",     "MKL"   ,    t,  mkl_div!   ,   (n,a,b,y)   ),
            ("X/Y",     "Julia" ,    t,  ./         ,   (a,b)       ),

            ("1/X",     "BLAS"  ,    t,  nanf       ,   ()         ),
            ("1/X",     "MKL"   ,    t,  mkl_inv!   ,   (n,a,y)   ),
            ("1/X",     "Julia" ,    t,  ./         ,   (convert(t,1),b)),

            ("|X|",     "BLAS"  ,    t,  nanf       ,   ()         ),
            ("|X|",     "MKL"   ,    t,  mkl_abs!   ,   (n,a,y)     ),
            ("|X|",     "Julia" ,    t,  abs        ,   (a,)        ),

            ("sqrt(X)", "BLAS" ,    t,  nanf        ,   ()         ),
            ("sqrt(X)", "MKL"       ,    t,  mkl_sqrt!   ,   (n,a,y)    ),
            ("sqrt(X)", "Julia"    ,    t,  sqrt        ,   (a,)       ),

            ("1/sqrt(X)", "BLAS"      ,    t,  nanf        ,   ()          ),
            ("1/sqrt(X)", "MKL"       ,    t,  mkl_invsqrt!,   (n,a,y)     ),
            ("1/sqrt(X)"  , "Julia"    ,    t,  vj_invsqrt  ,   (a,)       ),
            )

            for (gm, imp, ty, f, args) in tup
                if length(args) == 0 # void function
                    push!(df, [gm, imp, string(ty), f, n, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
                else
                    res_cpu, res_gc, res_alloc = ibench(f, args,timing ; α=α, print_eval=false, print_stats=true)
                    stat_cpu = bstat(res_cpu[2:end].*(1e9/n), α) # in micro second per op * (1e9/n)
                    stat_gc = bstat(res_gc[2:end].*(1e9/n), α)
                    stat_alloc = bstat(res_alloc[2:end], α)
                    push!(df, [gm, imp, string(ty), f, n, stat_cpu[1], stat_cpu[5], stat_gc[1], stat_gc[5], stat_alloc[1], stat_alloc[5]])

                    # res_cpu, res_gc, res_alloc = ibench2(f, args, n)
                    # stat_cpu = res_cpu[2]*(1e9/n)
                    # stat_gc = res_gc[2]*(1e9/n)
                    # stat_alloc = res_alloc[2]
                    # push!(df, [gm, imp, string(ty), f, n, stat_cpu, 0.0, stat_gc, 0, stat_alloc, 0])
                end
            end
        end
    end
    writetable(path * "b1_data.csv", df)
    df
end

df = bench_b1()


# a = [1.0,2.0,3.0]
# f = mkl_scal!
# args = (2,1.9999,a,1)
# ibench(f, args,1 ; print_eval=true, print_stats=true)
