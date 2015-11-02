# Benchmark B1

This benchmark compares the absolute or relative CPU performances of several basic arithmetic functions on `n-dim`vectors :
- compare CPU time for different values of `n` (from 1e1 to 1e6) and different packages (BLAS, MKL, Native Julia)

![CPU](https://github.com/lionpeloux/MKL.jl/blob/master/benchmark/b1/b1_cpu_1000000.png "Logo Title Text 1")

- compare relative performance usage regarding the precision (Float32 vs. Float64)

![Float32/Float64](https://github.com/lionpeloux/MKL.jl/blob/master/benchmark/b1/b1_Float32_vs_Float64_1000000.png "Logo Title Text 1")


