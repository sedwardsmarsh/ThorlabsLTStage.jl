"""
# Available Functions

- `initialize` 
- `move_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `get_pos(xyz)`
- `get_pos_x(xyz)`
- `get_pos_y(xyz)`
- `get_pos_z(xyz)`
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
- `set_limits(xyz, low, high)`
- `get_limits(xyz)`
- `get_limits_x(xyz)`
- `get_limits_y(xyz)`
- `get_limits_z(xyz)`
- `clear_limits(xyz)`

# Example
```
ps = initialize(ThorlabsLTS150)

move_xyz(ps, 0.1, 0.1, 0.1)

# Move 0.05 meters forwards
move_x_rel(ps, 0.05)

# Get position of x stage (0.05 here)
pos_x(ps)

# Move 0.05 meters backwards
move_x_rel(ps, -0.05)

# Moves device to home position
home(ps)

# Returns x,y,z positions
pos_xyz(ps)

# First tuple contains lower limits, second contains upper limits
# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)
# Arrays can be used instead of tuples as well []
set_limits(ps, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))

# Will return a pair of tuples with limits you just set
get_limits(ps)

# Will return lower and upper limit for x stage
lower_x, upper_x = get_limits_x(ps)

# Will stay at 0.1 (upper limit)
move_x_abs(ps, 0.2)

# Beyond device limit but will stay at 0.1 (upper limit)
move_x_abs(ps, 5)

# Will move to 0.01 (lower limit)
move_x_abs(ps, 0)

# Clear limits
clear_limits(ps)

# Moving beyond your physical device with no limits will throw an error
# Don't do this
move_x_abs(ps, 5)
```

"""

abstract type PositionerSystem end
abstract type LinearTranslationStage end

mutable struct Stage <: LinearTranslationStage
    serial::String
    info::String
    origin_pos::Unitful.Length
    min_pos::Unitful.Length
    max_pos::Unitful.Length
    lower_limit::Unitful.Length
    upper_limit::Unitful.Length
    is_moving::Bool
    pos_accuracy::Unitful.Length
    function Stage(serial)
        serial = "$serial"
        stage = new(serial, "", 0mm, 0mm, 0mm, 0mm, 0mm, false, 0mm)
        initialize_stage(stage)
        return stage
    end
end

function Base.show(io::IO, stage::Stage)
    println(io, "         serial: ", stage.serial)
    println(io, "           info: ", stage.info)
    println(io, "      is_moving: ", stage.is_moving)
    println(io, "    current_pos: ", round(get_pos(stage), get_position_accuracy(stage)))
    println(io, "    lower_limit: ", round(get_lower_limit(stage), get_position_accuracy(stage)))
    println(io, "    upper_limit: ", round(get_upper_limit(stage), get_position_accuracy(stage)))
    println(io, "        min_pos: ", round(get_min_position(stage), get_position_accuracy(stage)))
    println(io, "        max_pos: ", round(get_max_position(stage), get_position_accuracy(stage)))
end

function Base.show(io::IO, positioner_system::PositionerSystem)
    println(io, typeof(positioner_system))
    for fieldname in fieldnames(typeof(positioner_system))
        println(io, fieldname, ": ")
        Base.show(getfield(positioner_system, fieldname))
        println()
    end
end


struct PS_2D <: PositionerSystem
    x::Stage
    y::Stage
end

"""
# Available functions
- `move_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `get_pos(xyz)`
- `get_pos_x(xyz)`
- `get_pos_y(xyz)`
- `get_pos_z(xyz)`
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
- `set_limits(xyz, low, high)`
- `get_limits(xyz)`
- `get_limits_x(xyz)`
- `get_limits_y(xyz)`
- `get_limits_z(xyz)`
- `reset_limits(xyz)`
"""
struct PS_3D <: PositionerSystem
    x::Stage
    y::Stage
    z::Stage
end

struct PS_5D <: PositionerSystem
    x::Stage
    y::Stage
    z::Stage
    a::Stage
    b::Stage
end

"""
- `move_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `get_pos(xyz)`
- `get_pos_x(xyz)`
- `get_pos_y(xyz)`
- `get_pos_z(xyz)`
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
- `set_limits(xyz, low, high)`
- `get_limits(xyz)`
- `get_limits_x(xyz)`
- `get_limits_y(xyz)`
- `get_limits_z(xyz)`
- `clear_limits(xyz)`
"""

mutable struct ThorlabsLTS150 # Python
    positioner_system
end
