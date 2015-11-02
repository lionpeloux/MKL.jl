# ------------------------------------------------------------------------------
#                           BLAS SERVICE FUNCTION
# ------------------------------------------------------------------------------
#=
enum CBLAS_LAYOUT {
   CblasRowMajor=101,  /* row-major arrays */
   CblasColMajor=102};   /* column-major arrays */
enum CBLAS_TRANSPOSE {
   CblasNoTrans=111,     /* trans='N' */
   CblasTrans=112,       /* trans='T' */
   CblasConjTrans=113};  /* trans='C' */
enum CBLAS_UPLO {
   CblasUpper=121,        /* uplo ='U' */
   CblasLower=122};       /* uplo ='L' */
enum CBLAS_DIAG {
   CblasNonUnit=131,      /* diag ='N' */
   CblasUnit=132};        /* diag ='U' */
enum CBLAS_SIDE {
   CblasLeft=141,         /* side ='L' */
   CblasRight=142};       /* side ='R' */


   #ifndef __MKL_CBLAS_H__
   #define __MKL_CBLAS_H__
   #include <stddef.h>

   #include "mkl_types.h"

   #ifdef __cplusplus
   extern "C" {            /* Assume C declarations for C++ */
   #endif /* __cplusplus */


   /*
    * Enumerated and derived types
    */
   #define CBLAS_INDEX size_t  /* this may vary between platforms */

   typedef enum {CblasRowMajor=101, CblasColMajor=102} CBLAS_ORDER;
   typedef enum {CblasNoTrans=111, CblasTrans=112, CblasConjTrans=113} CBLAS_TRANSPOSE;
   typedef enum {CblasUpper=121, CblasLower=122} CBLAS_UPLO;
   typedef enum {CblasNonUnit=131, CblasUnit=132} CBLAS_DIAG;
   typedef enum {CblasLeft=141, CblasRight=142} CBLAS_SIDE;
=#

immutable BLAS

# credit : Simon Kornblith (VML.jl)
immutable VMLAccuracy
    mode::UInt
end

const VML_LA = VMLAccuracy(0x00000001)
const VML_HA = VMLAccuracy(0x00000002)
const VML_EP = VMLAccuracy(0x00000003)

Base.show(io::IO, m::VMLAccuracy) = print(io, m == VML_LA ? "VML_LA" :
                                              m == VML_HA ? "VML_HA" : "VML_EP")

vml_get_mode() = ccall((:_vmlGetMode, libvml), Cuint, ())
vml_set_mode(mode::Integer) = (ccall((:_vmlSetMode, libvml), Cuint, (UInt,), mode); nothing)

vml_set_accuracy(m::VMLAccuracy) = vml_set_mode((vml_get_mode() & ~0x03) | m.mode)
vml_get_accuracy() = VMLAccuracy(vml_get_mode() & 0x3)

vml_set_mode((vml_get_mode() & ~0x0000FF00))

function vml_check_error()
    vml_error = ccall((:_vmlClearErrStatus, libvml), Cint, ())
    if vml_error != 0
        if vml_error == 1
            error(DomainError())
        elseif vml_error == 2 || vml_error == 3 || vml_error == 4
            # Singularity, overflow, or underflow
            # I don't think Base throws on these
        elseif vml_error == 1000
            warn("VML does not support $(vml_get_accuracy); lower accuracy used instead")
        else
            error("an unexpected error occurred in VML ($vml_error)")
        end
    end
end
