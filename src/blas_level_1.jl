## ?asum
for (fname, elty, ret_type) in ((:dasum,:Float64,:Float64),
                                (:sasum,:Float32,:Float32))
    @eval begin
        function mkl_asum(n::Integer, X::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fname)), libmkl), $ret_type,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, X, &incx)
        end
    end
end

## ?axpy!
for (fname, elty) in ((:daxpy,:Float64),
                      (:saxpy,:Float32))
    @eval begin
        function mkl_axpy!(n::Integer, alpha::($elty), dx::Union{Ptr{$elty}, DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty}, DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fname)), libmkl), Void,
                (Ptr{Int}, Ptr{$elty}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, &alpha, dx, &incx, dy, &incy)
            dy
        end
    end
end

## ?copy!
for (fname, elty) in ((:dcopy,:Float64),
                      (:scopy,:Float32))
    @eval begin
        function mkl_copy!(n::Integer, dx::Union{Ptr{$elty},StridedArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},StridedArray{$elty}}, incy::Integer)
            ccall(($(string(fname)), libmkl), Void,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
            dy
        end
    end
end

## ?dot
for (fname, elty) in ((:ddot,:Float64),
                      (:sdot,:Float32))
    @eval begin
        function mkl_dot(n::Integer, dx::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fname)), libmkl), $elty,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
        end
    end
end

## ?sdot
for (fname, elty) in ((:dsdot,:Float32),)
    @eval begin
        function mkl_sdot(n::Integer, dx::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer, dy::Union{Ptr{$elty},DenseArray{$elty}}, incy::Integer)
            ccall(($(string(fname)), libmkl), Float64,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, dx, &incx, dy, &incy)
        end
    end
end

## nrm2
for (fname, elty, ret_type) in ((:dnrm2_,:Float64,:Float64),
                                (:snrm2_,:Float32,:Float32))
    @eval begin
        # SUBROUTINE DNRM2(N,X,INCX)
        function mkl_nrm2(n::Integer, X::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fname)), libmkl), $ret_type,
                (Ptr{Int}, Ptr{$elty}, Ptr{Int}),
                 &n, X, &incx)
        end
    end
end

## scal!
for (fname, elty) in ((:dscal,:Float64),
                      (:sscal,:Float32))
    @eval begin
        function mkl_scal!(n::Integer, alpha::$elty, DX::Union{Ptr{$elty},DenseArray{$elty}}, incx::Integer)
            ccall(($(string(fname)), libmkl), Void,
                  (Ptr{Int}, Ptr{$elty}, Ptr{$elty}, Ptr{Int}),
                  &n, &alpha, DX, &incx)
            DX
        end
    end
end
