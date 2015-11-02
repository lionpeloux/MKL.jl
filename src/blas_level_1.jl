# ------------------------------------------------------------------------------
#                           BLAS LEVEL 1
# ------------------------------------------------------------------------------

println("MKL : BLAS LEVEL 1")
for name in (   :asum,
                :axpy!,
                :copy!,
                :dot,
                :sdot,
                :nrm2,
                :scal!)

                fname = symbol(string(prefix)*string(name))
                println("export : ", fname)
                @eval begin
                    export $fname
                end
end

# ------------------------------------------------------------------------------


## ?asum
name = :asum
for (fmkl, elty, ret_type) in ((:dasum,:Float64,:Float64),
                                (:sasum,:Float32,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :axpy!
for (fmkl, elty) in ((:daxpy,:Float64),
                      (:saxpy,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :copy!
for (fmkl, elty) in ((:dcopy,:Float64),
                      (:scopy,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :dot
for (fmkl, elty) in ((:ddot,:Float64),
                      (:sdot,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :sdot
for (fmkl, elty) in ((:dsdot,:Float32),)

    fname = symbol(string(prefix)*string(name))
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
name = :nrm2
for (fmkl, elty, ret_type) in ((:dnrm2_,:Float64,:Float64),
                                (:snrm2_,:Float32,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :scal!
for (fmkl, elty) in ((:dscal,:Float64),
                      (:sscal,:Float32))

    fname = symbol(string(prefix)*string(name))
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
