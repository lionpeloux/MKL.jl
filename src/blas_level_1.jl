# ------------------------------------------------------------------------------
#                           BLAS LEVEL 1
# ------------------------------------------------------------------------------

if debug println("MKL : BLAS LEVEL 1") end
for fname in (  :mkl_asum,
                :mkl_axpy!,
                :mkl_copy!,
                :mkl_dot,
                :mkl_sdot,
                :mkl_nrm2,
                :mkl_scal!)

                if debug println("export : ", fname) end
                @eval export $fname
end

# ------------------------------------------------------------------------------


## ?asum
fname = :mkl_asum
for (fmkl, elty, ret_type) in ((:dasum,:Float64,:Float64),
                                (:sasum,:Float32,:Float32))

        @eval begin
        function $fname(n::Integer, X::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fmkl)), libmkl), $ret_type,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, X, &incx)
        end
    end
end
# ------------------------------------------------------------------------------


## ?axpy!
fname = :mkl_axpy!
for (fmkl, elty) in ((:daxpy,:Float64),
                      (:saxpy,:Float32))

        @eval begin
        function $fname(n::Integer, alpha::($elty), dx::Union{Ptr{$elty}, DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty}, DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fmkl)), libmkl), Void,
                (Ptr{Int}, Ptr{$elty}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, &alpha, dx, &incx, dy, &incy)
            dy
        end
    end
end
# ------------------------------------------------------------------------------


## ?copy!
fname = :mkl_copy!
for (fmkl, elty) in ((:dcopy,:Float64),
                      (:scopy,:Float32))

        @eval begin
        function $fname(n::Integer, dx::Union{Ptr{$elty},StridedArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},StridedArray{$elty}}, incy::Integer)
            ccall(($(string(fmkl)), libmkl), Void,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
            dy
        end
    end
end
# ------------------------------------------------------------------------------


## ?dot
fname = :mkl_dot
for (fmkl, elty) in ((:ddot,:Float64),
                      (:sdot,:Float32))

        @eval begin
        function $fname(n::Integer, dx::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fmkl)), libmkl), $elty,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
        end
    end
end
# ------------------------------------------------------------------------------


## ?sdot
fname = :mkl_sdot
for (fmkl, elty) in ((:dsdot,:Float32),)

        @eval begin
        function $fname(n::Integer, dx::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fmkl)), libmkl), Float64,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
        end
    end
end
# ------------------------------------------------------------------------------


## nrm2
fname = :mkl_nrm2
for (fmkl, elty, ret_type) in ((:dnrm2_,:Float64,:Float64),
                                (:snrm2_,:Float32,:Float32))

        @eval begin
        function $fname(n::Integer, X::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fmkl)), libmkl), $ret_type,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, X, &incx)
        end
    end
end
# ------------------------------------------------------------------------------


## scal!
fname = :mkl_scal!
for (fmkl, elty) in ((:dscal,:Float64),
                      (:sscal,:Float32))

        @eval begin
        function $fname(n::Integer, alpha::$elty, DX::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fmkl)), libmkl), Void,
                  (Ptr{Int}, Ptr{$elty}, Ptr{$elty}, Ptr{Int}),
                  &n, &alpha, DX, &incx)
            DX
        end
    end
end
# ------------------------------------------------------------------------------
