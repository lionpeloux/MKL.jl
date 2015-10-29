# ------------------------------------------------------------------------------
#                        VML ARITHMETIC FUNCTIONS
# ------------------------------------------------------------------------------

## ?Add
for (fname, elty) in ((:vdAdd,:Float64),
                      (:vsAdd,:Float32))
    @eval begin
        function mkl_add!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
                 n, a, b, y)
            # vml_check_error()
            y
        end
    end
end
begin
  T = Float64
  a = T[1,2,3,4]
  y = zeros(T,4)
  mkl_add!(2,a,a,y)
end

## ?Sub
for (fname, elty) in ((:vdSub,:Float64),
                      (:vsSub,:Float32))
    @eval begin
        function mkl_sub!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
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
  y = zeros(T,4)
  mkl_sub!(2,a,a,y)
end

## ?Sqr
for (fname, elty) in ((:vdSqr,:Float64),
                      (:vsSqr,:Float32))
    @eval begin
        function mkl_sqr!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
            ccall(($(string(fname)), libmkl), Void,
                (Int, Ptr{$elty}, Ptr{$elty}),
                 n, a, y)
            # vml_check_error()
            y
        end
    end
end

## ?Mul
for (fname, elty) in ((:vdMul,:Float64),
                      (:vsMul,:Float32))
  @eval begin
    function mkl_mul!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
        ccall(($(string(fname)), libmkl), Void,
            (Int, Ptr{$elty}, Ptr{$elty}, Ptr{$elty}),
             n, a, b, y)
        # vml_check_error()
        y
    end
  end
end

## ?Abs
for (fname, elty) in ((:vdAbs,:Float64),
                      (:vsAbs,:Float32))
    @eval begin
      function mkl_abs!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, y::Union{Ptr{$elty},DenseArray{$elty}})
          ccall(($(string(fname)), libmkl), Void,
              (Int, Ptr{$elty}, Ptr{$elty}),
               n, a, y)
          # vml_check_error()
          y
      end
    end
end

# ?LinearFrac
for (fname, elty) in ((:vdLinearFrac,:Float64),
                      (:vsLinearFrac,:Float32))
    @eval begin
        function mkl_linearfrac!(n::Integer, a::Union{Ptr{$elty},DenseArray{$elty}}, b::Union{Ptr{$elty},DenseArray{$elty}},
          scalea::$elty, shifta::$elty, scaleb::$elty, shiftb::$elty, y::Union{Ptr{$elty},DenseArray{$elty}})
          ccall(($(string(fname)), libmkl), Void,
              (Int, Ptr{$elty}, Ptr{$elty}, $elty, $elty, $elty, $elty, Ptr{$elty}),
               n, a, b, scalea, shifta, scaleb, shiftb, y)
          # vml_check_error()
          y
        end
    end
end
begin
    T = Float32
    a = T[1,1,2,2]
    b = T[2,2,4,4]
    y = zeros(T,4)
    mkl_linearfrac!(4,a,b,convert(T,1),convert(T,0),convert(T,1),convert(T,0),y)
end
