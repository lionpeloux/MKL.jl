# ------------------------------------------------------------------------------
#                        VML POWER AND ROOT FUNCTIONS
# ------------------------------------------------------------------------------

if debug println("MKL : VML POWER AND ROOT") end
for fname in (  :mkl_inv!,
                :mkl_div!,
                :mkl_sqrt!,
                :mkl_invsqrt!,
                :mkl_cbrt!,
                :mkl_invcbrt!,
                :mkl_pow!,
                :mkl_powx!,
                :mkl_hypot!)

                if debug println("export : ", fname) end
                @eval export $fname
end

# ------------------------------------------------------------------------------


## ?Inv
fname = :mkl_inv!
for (fmkl, elty) in ((:vdInv,:Float64),
                      (:vsInv,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Div
fname = :mkl_div!
for (fmkl, elty) in ((:vdDiv,:Float64),
                      (:vsDiv,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Sqrt
fname = :mkl_sqrt!
for (fmkl, elty) in ((:vdSqrt,:Float64),
                      (:vsSqrt,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?InvSqrt
fname = :mkl_invsqrt!
for (fmkl, elty) in ((:vdInvSqrt,:Float64),
                      (:vsInvSqrt,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Cbrt
fname = :mkl_cbrt!
for (fmkl, elty) in ((:vdCbrt,:Float64),
                      (:vsCbrt,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?InvCbrt
fname = :mkl_invcbrt!
for (fmkl, elty) in ((:vdInvCbrt,:Float64),
                      (:vsInvCbrt,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Pow
fname = :mkl_pow!
for (fmkl, elty) in ((:vdPow,:Float64),
                      (:vsPow,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Powx
fname = :mkl_powx!
for (fmkl, elty) in ((:vdPowx,:Float64),
                      (:vsPowx,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::$elty, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, $elty, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------


## ?Hypot
fname = :mkl_hypot!
for (fmkl, elty) in ((:vdHypot,:Float64),
                      (:vsHypot,:Float32))

    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fmkl)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
# ------------------------------------------------------------------------------
