module ThorlabsLTStage

using Unitful

export backend, load_python

export initialize, terminate
export ThorlabsLTS150, LTS, LTS150_3D, LTS150_2D
export move_x_abs, move_y_abs, move_z_abs
export move_x_rel, move_y_rel, move_z_rel
export move_xyz, pos_xyz
export pos_x, pos_y, pos_z
export home, home_x, home_y, home_z
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

const m = u"m"
const mm = u"mm"
const s = u"s"
-->(a::Unitful.AbstractQuantity, b::Unitful.Units) = uconvert(b, a)
raw_meters(a) = Float64(ustrip(a --> m))

export -->


include("c/bindings.jl") # C API BACKEND

include("config.jl")
include("models.jl")

# C API BACKEND
include("stage.jl")
include("lts.jl")

include("emulator/fake_lts.jl")

# DOT NET API BACKEND
include("dotnet/bindings.jl")

end
