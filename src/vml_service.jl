# ------------------------------------------------------------------------------
#                              VML SERVICE FUNCTION
# ------------------------------------------------------------------------------

println("MKL : VML SERVICE")
for fname in (  :vml_get_mode, :vml_set_mode,
                :vml_get_accuracy, :vml_set_accuracy,
                :vml_check_error)

                println("export : ", string(fname))
                @eval begin
                    export $fname
                end
end

# ------------------------------------------------------------------------------


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
