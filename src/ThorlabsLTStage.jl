module ThorlabsLTStage

using Unitful
using Unitful: m, mm, s

export backend, load_python

export initialize, terminate
export ThorlabsLTS150, PositionerSystem, LTS150_3D, LTS150_2D
export move_x_abs, move_y_abs, move_z_abs
export move_x_rel, move_y_rel, move_z_rel
export move_xyz, get_pos
export get_pos_x, get_pos_y, get_pos_z
export home, home_x, home_y, home_z
export set_origin, get_origin, move_to_origin
export set_lower_limit, set_upper_limit
export get_lower_limit, get_upper_limit
export set_limits, get_limits, clear_limits
export get_limits_x, get_limits_y, get_limits_z
export set_limits_x, set_limits_y, set_limits_z
export get_max_velocity
export get_max_velocity_x, get_max_velocity_y, get_max_velocity_z
export set_max_velocity_x, set_max_velocity_y, set_max_velocity_z
export get_max_acceleration
export get_max_acceleration_x, get_max_acceleration_y, get_max_acceleration_z
export set_max_acceleration_x, set_max_acceleration_y, set_max_acceleration_z

export pos, reset_limits

raw_meters(a) = Float64(ustrip(uconvert(m, a)))


include("c/bindings.jl") # C API BACKEND

include("config.jl")

include("models.jl")
include("stage.jl")
include("positioner_system.jl")

include("emulator/models.jl")
include("emulator/fake_positioner_system.jl")
include("emulator/fake_stage.jl")

# DOT NET API BACKEND
include("dotnet/bindings.jl")

end
