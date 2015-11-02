# ------------------------------------------------------------------------------
#                        VML POWER AND ROOT FUNCTIONS
# ------------------------------------------------------------------------------

println("MKL : VML POWER AND ROOT")
for name in (   :inv!,
                :div!,
                :sqrt!,
                :invsqrt!,
                :cbrt!,
                :invcbrt!,
                :pow!,
                :powx!,
                :hypot!)

                fname = symbol(string(prefix)*string(name))
                println("export : ", fname)
                @eval begin
                    export $fname
                end
end

# ------------------------------------------------------------------------------


## ?Inv
name = :inv!
for (fmkl, elty) in ((:vdInv,:Float64),
                      (:vsInv,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :div!
for (fmkl, elty) in ((:vdDiv,:Float64),
                      (:vsDiv,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :sqrt!
for (fmkl, elty) in ((:vdSqrt,:Float64),
                      (:vsSqrt,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :invsqrt!
for (fmkl, elty) in ((:vdInvSqrt,:Float64),
                      (:vsInvSqrt,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :cbrt!
for (fmkl, elty) in ((:vdCbrt,:Float64),
                      (:vsCbrt,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :invcbrt!
for (fmkl, elty) in ((:vdInvCbrt,:Float64),
                      (:vsInvCbrt,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :pow!
for (fmkl, elty) in ((:vdPow,:Float64),
                      (:vsPow,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :powx!
for (fmkl, elty) in ((:vdPowx,:Float64),
                      (:vsPowx,:Float32))

    fname = symbol(string(prefix)*string(name))
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
name = :hypot!
for (fmkl, elty) in ((:vdHypot,:Float64),
                      (:vsHypot,:Float32))

    fname = symbol(string(prefix)*string(name))
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
