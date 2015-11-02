# ------------------------------------------------------------------------------
#                        VML ARITHMETIC FUNCTIONS
# ------------------------------------------------------------------------------

if debug println("MKL : VML ARITHMETIC") end
for fname in (  :mkl_add!,
                :mkl_sub!,
                :mkl_sqr!,
                :mkl_mul!,
                :mkl_abs!,
                :mkl_linearfrac!)

                if debug println("export : ", fname) end
                @eval export $fname
end

# ------------------------------------------------------------------------------

## ?Add
fname = :mkl_add!
for (fmkl, elty) in ((:vdAdd,:Float64),
                      (:vsAdd,:Float32))

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
fname = :mkl_sub!
for (fmkl, elty) in ((:vdSub,:Float64),
                      (:vsSub,:Float32))

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
fname = :mkl_sqr!
for (fmkl, elty) in ((:vdSqr,:Float64),
                      (:vsSqr,:Float32))

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
fname = :mkl_mul!
for (fmkl, elty) in ((:vdMul,:Float64),
                      (:vsMul,:Float32))

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
fname = :mkl_abs!
for (fmkl, elty) in ((:vdAbs,:Float64),
                      (:vsAbs,:Float32))

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
fname = :mkl_linearfrac
for (fmkl, elty) in ((:vdLinearFrac,:Float64),
                      (:vsLinearFrac,:Float32))

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
