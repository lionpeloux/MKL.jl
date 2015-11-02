Libdl.dlopen(:libmkl_rt) # necessary to preload - don't know why
const libmkl   = :libmkl_rt
const libvml   = :libmkl_vml_avx

## ?gemv
function mkl_gemv!( layout::Cint, trans::Char,
                    m::Integer, n::Integer,
                    alpha::Float64, A::Union{Ptr{Float64},DenseArray{Float64}}, lda::Integer, X::Union{Ptr{Float64},DenseArray{Float64}}, incx::Integer,
                    beta::(Float64), Y::Union{Ptr{Float64},DenseArray{Float64}}, incy::Integer)

    ccall((:dgemv, libmkl), Void,
            (Ptr{Cint}, Ptr{Int},
            Ptr{Int}, Ptr{Int},
            Ptr{Float64}, Ptr{Float64}, Ptr{Int}, Ptr{Float64}, Ptr{Int},
            Ptr{Float64}, Ptr{Float64}, Ptr{Int}),
            &layout, &trans,
            &m, &n,
            &alpha, A, &lda, X, incx,
            &beta, Y, &incy)
    Y
end



A = [1.0 2.0 3.0 ; 3.0 4.0 5.0]
m,n = size(A,1),size(A,2)

X = [1.0,2.0,3.0]
Y = [1.0,1.0]

# Native Julia
2*A*X+Y

# LinAlg.BLAS.gemv!('N',2.0,A,X,1.0,Y)

convert(Cint,102)

mkl_gemv!(  convert(Cint,102), 'N',
            2, 3,
            2.0, A, 3, X, 1,
            1.0, Y, 1)
