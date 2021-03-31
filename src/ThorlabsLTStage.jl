module ThorlabsLTStage

using Unitful

export 

    backend,
    load_python,

    initialize,
    ThorlabsLTS150,
    move_x_abs,
    move_y_abs,
    move_z_abs,
    move_x_rel,
    move_y_rel,
    move_z_rel,
    move_xyz,
    pos_xyz,
    pos_x,
    pos_y,
    pos_z,
    home,
    home_x,
    home_y,
    home_z,
    set_limits,
    get_limits,
    get_limits_x,
    get_limits_y,
    get_limits_z,
    clear_limits,

    get_max_velocity,
    get_max_velocity_x,
    get_max_velocity_y,
    get_max_velocity_z,

    set_max_velocity_x,
    set_max_velocity_y,
    set_max_velocity_z,

    get_max_acceleration,
    get_max_acceleration_x,
    get_max_acceleration_y,
    get_max_acceleration_z,

    set_max_acceleration_x,
    set_max_acceleration_y,
    set_max_acceleration_z,

    terminate

const m = u"m"
const mm = u"mm"
const s = u"s"
-->(a, b) = uconvert(b, a)
raw_meters(a) = ustrip(a --> m)


include("c/bindings.jl") # C API BACKEND

include("config.jl")
include("models.jl")

# C API BACKEND
include("stage.jl")
include("lts.jl")

# DOT NET API BACKEND
include("dotnet/bindings.jl")

end
