"""
# Available Functions

- `initialize` 
- `move_xyz(xyz, x, y, z)` 
- `pos_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `pos_xyz(xyz)`
- `pos_x(xyz)`
- `pos_y(xyz)`
- `pos_z(xyz)`
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
lts = initialize(ThorlabsLTS150)

move_xyz(lts, 0.1, 0.1, 0.1)

# Move 0.05 meters forwards
move_x_rel(lts, 0.05)

# Get position of x stage (0.05 here)
pos_x(lts)

# Move 0.05 meters backwards
move_x_rel(lts, -0.05)

# Moves device to home position
home(lts)

# Returns x,y,z positions
pos_xyz(lts)

# First tuple contains lower limits, second contains upper limits
# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)
# Arrays can be used instead of tuples as well []
set_limits(lts, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))

# Will return a pair of tuples with limits you just set
get_limits(lts)

# Will return lower and upper limit for x stage
lower_x, upper_x = get_limits_x(lts)

# Will stay at 0.1 (upper limit)
move_x_abs(lts, 0.2)

# Beyond device limit but will stay at 0.1 (upper limit)
move_x_abs(lts, 5)

# Will move to 0.01 (lower limit)
move_x_abs(lts, 0)

# Clear limits
clear_limits(lts)

# Moving beyond your physical device with no limits will throw an error
# Don't do this
move_x_abs(lts, 5)
```

"""
mutable struct ThorlabsLTS150 # Python
    lts
end

# C API
mutable struct Stage
    serial::String
    info::String
    min_pos::Float64
    max_pos::Float64
    lower_limit::Float64
    upper_limit::Float64
    is_moving::Bool
    function Stage(serial)
        serial = "$serial"
        stage = new(serial, "", NaN, NaN, NaN, NaN, false)
        stage.info = init(stage)
        finalizer(s->Close(s.serial), stage)
        stage.min_pos, stage.max_pos = raw_meters.(travel_limits(stage))
        stage.lower_limit = stage.min_pos
        stage.upper_limit = stage.max_pos
        stage.is_moving = false
        return stage
    end
end

function init(stage)
    is_connected = check_is_connected(stage.serial)
    println("Stage $(stage.serial) connection status: $(is_connected)")
    err = OpenDevice(stage.serial)
    is_connected = check_is_connected(stage.serial)
    println("Stage $(stage.serial) connection status: $(is_connected)")
    model, _ = GetHardwareInfo(stage.serial)
    setting_name = if model == "LTS150"
        "HS LTS150 150mm Stage"
    elseif model == "LTS300"
        "HS LTS300 300mm Stage"
    else
        error("Model name unrecognized: $model")
    end
    Poll(stage.serial, 50)
    sleep(6.5)
    ClearQueue(stage.serial)
    println("Loading settings")
    LoadNamedSettings(stage.serial, setting_name)
    LoadSettings(stage.serial)
    println("Settings loaded")
    Enable(stage.serial)
    return setting_name
end

abstract type LTS end

struct LTS_2D <: LTS
    x::Stage
    y::Stage
end

"""
# Available functions
- `move_xyz(xyz, x, y, z)` 
- `pos_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `pos_xyz(xyz)`
- `pos_x(xyz)`
- `pos_y(xyz)`
- `pos_z(xyz)`
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
struct LTS_3D <: LTS
    x::Stage
    y::Stage
    z::Stage
end

struct LTS_5D <: LTS
    x::Stage
    y::Stage
    z::Stage
    a::Stage
    b::Stage
end

"""
- `move_xyz(xyz, x, y, z)` 
- `pos_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `pos_xyz(xyz)`
- `pos_x(xyz)`
- `pos_y(xyz)`
- `pos_z(xyz)`
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
