# ------------------------------------------------------------------------------
#                        VML ARITHMETIC FUNCTIONS
# ------------------------------------------------------------------------------

println("MKL : VML ARITHMETIC")
for name in (   :add!,
                :sub!,
                :sqr!,
                :mul!,
                :abs!,
                :linearfrac!)

                fname = symbol(string(prefix)*string(name))
                println("export : ", fname)
                @eval begin
                    export $fname
                end
end

# ------------------------------------------------------------------------------

## ?Add
name = :add!
for (fmkl, elty) in ((:vdAdd,:Float64),
                      (:vsAdd,:Float32))

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


## ?Sub
name = :sub!
for (fmkl, elty) in ((:vdSub,:Float64),
                      (:vsSub,:Float32))

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


## ?Sqr
name = :sqr!
for (fmkl, elty) in ((:vdSqr,:Float64),
                      (:vsSqr,:Float32))

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

## ?Mul
name = :mul!
for (fmkl, elty) in ((:vdMul,:Float64),
                      (:vsMul,:Float32))

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


## ?Abs
name = :abs!
for (fmkl, elty) in ((:vdAbs,:Float64),
                      (:vsAbs,:Float32))

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


# ?LinearFrac
name = :linearfrac
for (fmkl, elty) in ((:vdLinearFrac,:Float64),
                      (:vsLinearFrac,:Float32))

    fname = symbol(string(prefix)*string(name))
    @eval begin
        function $fname(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}},
          scalea::$elty, shifta::$elty, scaleb::$elty, shiftb::$elty, y::Union{Ptr{$elty},DenseArray{$elty}})
          ccall(($(string(fmkl)), libmkl), Void,
              (Int, Ptr{$elty}, Ptr{$elty}, $elty, $elty, $elty, $elty, Ptr{$elty}),
               n, a, b, scalea, shifta, scaleb, shiftb, y)
          # vml_check_error()
          y
        end
    end
end
# ------------------------------------------------------------------------------
