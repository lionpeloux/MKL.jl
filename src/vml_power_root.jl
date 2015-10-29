# ------------------------------------------------------------------------------
#                        VML POWER AND ROOT FUNCTIONS
# ------------------------------------------------------------------------------

## ?Inv
for (fname, elty) in ((:vdInv,:Float64),
                      (:vsInv,:Float32))
    @eval begin
        function mkl_inv!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float64
    a = T[1,0,2,2]
    mkl_inv!(4,a,a)
end

## ?Div
for (fname, elty) in ((:vdDiv,:Float64),
                      (:vsDiv,:Float32))
    @eval begin
        function mkl_div!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float32
    a = T[1,0,2,2]
    b = T[0.5,2,2,-4]
    mkl_div!(4,a,b,b)
end

## ?Sqrt
for (fname, elty) in ((:vdSqrt,:Float64),
                      (:vsSqrt,:Float32))
    @eval begin
        function mkl_sqrt!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float32
    a = T[1,0,2,2]
    mkl_sqrt!(4,a,a)
end

## ?InvSqrt
for (fname, elty) in ((:vdInvSqrt,:Float64),
                      (:vsInvSqrt,:Float32))
    @eval begin
        function mkl_invsqrt!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float64
    a = T[1,0,2,2]
    mkl_invsqrt!(4,a,a)
end

## ?Cbrt
for (fname, elty) in ((:vdCbrt,:Float64),
                      (:vsCbrt,:Float32))
    @eval begin
        function mkl_cbrt!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float64
    a = T[1,0,8,27]
    mkl_cbrt!(4,a,a)
end

## ?InvCbrt
for (fname, elty) in ((:vdInvCbrt,:Float64),
                      (:vsInvCbrt,:Float32))
    @eval begin
        function mkl_invcbrt!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float32
    a = T[1,0,8,27]
    mkl_invcbrt!(4,a,a)
end

## ?Pow
for (fname, elty) in ((:vdPow,:Float64),
                      (:vsPow,:Float32))
    @eval begin
        function mkl_pow!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float32
    a = T[1,2,3,4]
    b = T[1,2,3,2]
    mkl_pow!(4,a,b,b)
end

## ?Powx
for (fname, elty) in ((:vdPowx,:Float64),
                      (:vsPowx,:Float32))
    @eval begin
        function mkl_powx!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::$elty, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, $elty, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float64
    a = T[1,2,3,4]
    b = convert(T,2)
    mkl_powx!(4,a,b,a)
end

## ?Hypot
for (fname, elty) in ((:vdHypot,:Float64),
                      (:vsHypot,:Float32))
    @eval begin
        function mkl_hypot!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
begin
    T = Float32
    a = T[1,5,2,1]
    b = T[3,5,6,1]
    mkl_hypot!(4,a,b,b)
end
