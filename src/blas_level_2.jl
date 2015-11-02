# ------------------------------------------------------------------------------
#                           BLAS LEVEL 2
# ------------------------------------------------------------------------------

if debug println("MKL : BLAS LEVEL 2") end
for fname in (  :mkl_gemv!,)

                if debug println("export : ", fname) end
                @eval export $fname
end

# ------------------------------------------------------------------------------

## ?gemv
# fname = :mkl_gemv!
# for (fmkl, elty) in ((:dgemv,:Float64),
#                       (:sgemv,:Float32))
#
#     @eval begin
#         function $fname(layout::Cint, trans::Char,
#                         m::Integer, n::Integer,
#                         alpha::Float64, A::Union{Ptr{Float64},DenseArray{Float64}}, lda::Integer, X::Union{Ptr{Float64},DenseArray{Float64}}, incx::Integer,
#                         beta::(Float64), Y::Union{Ptr{Float64},DenseArray{Float64}}, incy::Integer)
#
#             # m,n = size(A,1),size(A,2)
#             # lda = max(1,stride(A,2))
#             #
#             # if trans == 'N' && (length(X) != n || length(Y) != m)
#             #     throw(DimensionMismatch("A has dimensions $(size(A)), X has length $(length(X)) and Y has length $(length(Y))"))
#             # elseif trans == 'C' && (length(X) != m || length(Y) != n)
#             #     throw(DimensionMismatch("A' has dimensions $n, $m, X has length $(length(X)) and Y has length $(length(Y))"))
#             # elseif trans == 'T' && (length(X) != m || length(Y) != n)
#             #     throw(DimensionMismatch("A.' has dimensions $n, $m, X has length $(length(X)) and Y has length $(length(Y))"))
#             # end
#
#             ccall((:dgemv, libmkl), Void,
#                     (Ptr{Cint}, Ptr{Int},
#                     Ptr{Int}, Ptr{Int},
#                     Ptr{Float64}, Ptr{Float64}, Ptr{Int}, Ptr{Float64}, Ptr{Int},
#                     Ptr{Float64}, Ptr{Float64}, Ptr{Int}),
#                     &layout, &trans,
#                     &m, &n,
#                     &alpha, A, &lda, X, incx,
#                     &beta, Y, &incy)
#             Y
#         end
#     end
# end
