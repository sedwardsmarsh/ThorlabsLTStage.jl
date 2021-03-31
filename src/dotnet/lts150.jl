import InstrumentConfig: initialize, terminate
lts_lib = nothing

function init_python_lib()
    global lts_lib
    if PyCall.python != "python"
        @info """The following needs to be in your $(lts_config.name) config:
            backend: python

        Then please call:
            load_python()
        """
        return
    end
    scriptdir = @__DIR__
    pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
    if ! Sys.iswindows()
        @info "You must use a windows computer: Cannot load dynamic libraries"
        return

    end
    lts_lib = pyimport("lts")
end

"""
    xyz = initialize(ThorlabsLTS150)

Connect to Thorlabs LTS

Returns:
   - ThorlabsLTS150: Device Handle 
"""
function initialize(::Type{ThorlabsLTS150}) 
    !Sys.iswindows() && error("Windows is needed to connect to ThorlabsLTS150")
    lts_lib == nothing && error("Call ThorlabsLTStage.load_config()")
    lts = lts_lib.LTS()

    stages = get(get_config(), "ThorlabsLTS150", Dict())

    if isempty(stages)
        return ThorlabsLTS150(lts.init())
    end

    x_stage = stages["x"]
    y_stage = stages["y"]
    z_stage = stages["z"]
    serials = map(s->s["serial"], [x_stage, y_stage, z_stage])
    lts.init_custom(serials)

    lts150 = ThorlabsLTS150(lts)

    # Set position limits from config
    (low_x, low_y, low_z), (high_x, high_y, high_z) = get_limits(lts150)
    low_x = get(x_stage, "min_position", low_x)
    high_x = get(x_stage, "max_position", high_x)

    low_y = get(y_stage, "min_position", low_y)
    high_y = get(y_stage, "max_position", high_y)

    low_z = get(z_stage, "min_position", low_z)
    high_z = get(z_stage, "max_position", high_z)

    set_limits(lts150, (low_x, low_y, low_z), (high_x, high_y, high_z))

    # Set velocity limits from config
    x_vel = get(x_stage, "max_velocity", get_max_velocity_x(lts150))
    y_vel = get(y_stage, "max_velocity", get_max_velocity_y(lts150))
    z_vel = get(z_stage, "max_velocity", get_max_velocity_z(lts150))
    set_max_velocity_x(lts150, x_vel)
    set_max_velocity_y(lts150, y_vel)
    set_max_velocity_z(lts150, z_vel)

    # Set acceleration limits from config
    x_acc = get(
        x_stage, "max_acceleration", get_max_acceleration_x(lts150)
    )
    y_acc = get(
        y_stage, "max_acceleration", get_max_acceleration_y(lts150)
    )
    z_acc = get(
        z_stage, "max_acceleration", get_max_acceleration_z(lts150)
    )
    set_max_acceleration_x(lts150, x_acc)
    set_max_acceleration_y(lts150, y_acc)
    set_max_acceleration_z(lts150, z_acc)

    return lts150
end

function terminate(lts::ThorlabsLTS150)
    lts.lts.close()
    lts.lts = nothing
end

"""
    move_xyz(xyz, x, y, z)

Simulatenously moves x, y and z stage to desired location
"""
function move_xyz(xyz::ThorlabsLTS150, x, y, z) 
    safe_move(xyz, xyz.lts.move_xyz, x, y, z)
end

"""
    pos_xyz(xyz)

Returns location of x, y and z stages in the form of a Array: [x, y, z]
"""
pos_xyz(xyz::ThorlabsLTS150) = [xyz.lts.pos_x(), xyz.lts.pos_y(), xyz.lts.pos_z()]


"""
    move_x(xyz, x)

Moves x stage to desired absolute location
"""
function move_x_abs(xyz::ThorlabsLTS150, x) 
    safe_move(xyz, xyz.lts.move_x, x)
end

"""
    move_y(xyz, y)

Moves y stage to desired absolute location
"""
function move_y_abs(xyz::ThorlabsLTS150, y) 
    safe_move(xyz, xyz.lts.move_y, y)
end

"""
    move_z(xyz, z)

Moves z stage to desired absolute location
"""
function move_z_abs(xyz::ThorlabsLTS150, z) 
    safe_move(xyz, xyz.lts.move_z, z)
end

"""
    move_x(xyz, x)

Moves x stage forward or backwards.

A positive number will move it forwards along the x axis while
a negative number will move it backwards.
"""
move_x_rel(xyz::ThorlabsLTS150, x) = xyz.lts.move_x(x + xyz.lts.pos_x())

"""
    move_y(xyz, y)

Moves y stage forward or backwards.

A positive number will move it forwards along the y axis while
a negative number will move it backwards.
"""
move_y_rel(xyz::ThorlabsLTS150, y) = xyz.lts.move_y(y + xyz.lts.pos_y())

"""
    move_z(xyz, z)

Moves z stage forward or backwards.

A positive number will move it forwards along the z axis while
a negative number will move it backwards.
"""
move_z_rel(xyz::ThorlabsLTS150, z) = xyz.lts.move_z(z + xyz.lts.pos_z())

"""
    home(xyz)

This will home the x, y and z stages at the same time
"""
home(xyz::ThorlabsLTS150) = xyz.lts.home_xyz()

"""
    home_x(xyz)

This will home the x stage
"""
home_x(xyz::ThorlabsLTS150) = xyz.lts.home_x() 

"""
    home_y(xyz)

This will home the y stage
"""
home_y(xyz::ThorlabsLTS150) = xyz.lts.home_y() 

"""
    home_z(xyz)

This will home the z stage
"""
home_z(xyz::ThorlabsLTS150) = xyz.lts.home_z() 

"""
    pos_x(xyz)

Returns the current position of x stage
"""
pos_x(xyz::ThorlabsLTS150) = xyz.lts.pos_x()

"""
    pos_y(xyz)

Returns the current position of y stage
"""
pos_y(xyz::ThorlabsLTS150) = xyz.lts.pos_y()

"""
    pos_z(xyz)

Returns the current position of z stage
"""
pos_z(xyz::ThorlabsLTS150) = xyz.lts.pos_z()

"""
    set_limits(xyz, (x_low_lim, y_low_lim, z_low_lim), (x_high_lim, y_high_lim, z_high_lim))

# Arguments
- `low`: A Pair or an Array of three positions: `(lts.x_low_limit, lts.y_low_limit, lts.z_low_limit)`
- `high`: A Pair or an Array of three positions: `(lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)`

"""
function set_limits(xyz::ThorlabsLTS150, low, high)
    if length(low) != 3 || length(high) != 3
        error("Cannot set device to these limits\nUse `help>set_limits` to see example of proper inputs")
    end
    xyz.lts.set_limits(low, high)
end

"""
Returns

    (lts.x_low_limit, lts.y_low_limit, lts.z_low_limit),
       (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)
"""
function get_limits(xyz::ThorlabsLTS150)
    return xyz.lts.get_limits()
end

"""
Returns

    (x_low_limit, x_high_limit)
"""
function get_limits_x(xyz::ThorlabsLTS150)
    low, high = xyz.lts.get_limits()
    return low[1], high[1]
end

"""
Returns

    (y_low_limit, y_high_limit)
"""
function get_limits_y(xyz::ThorlabsLTS150)
    low, high = xyz.lts.get_limits()
    return low[2], high[2]
end

"""
Returns

    (z_low_limit, z_high_limit)
"""
function get_limits_z(xyz::ThorlabsLTS150)
    low, high = xyz.lts.get_limits()
    return low[3], high[3]
end

function clear_limits(xyz::ThorlabsLTS150)
    xyz.lts.remove_limits()
end

get_max_velocity(xyz::ThorlabsLTS150) = xyz.lts.get_max_velocity()
get_max_velocity_x(xyz::ThorlabsLTS150) = xyz.lts.x_stage.get_max_velocity()
get_max_velocity_y(xyz::ThorlabsLTS150) = xyz.lts.y_stage.get_max_velocity()
get_max_velocity_z(xyz::ThorlabsLTS150) = xyz.lts.z_stage.get_max_velocity()

set_max_velocity_x(xyz::ThorlabsLTS150, v) = xyz.lts.x_stage.set_max_velocity(v)
set_max_velocity_y(xyz::ThorlabsLTS150, v) = xyz.lts.y_stage.set_max_velocity(v)
set_max_velocity_z(xyz::ThorlabsLTS150, v) = xyz.lts.z_stage.set_max_velocity(v)

get_max_acceleration(xyz::ThorlabsLTS150) = xyz.lts.get_max_acceleration()
get_max_acceleration_x(xyz::ThorlabsLTS150) = xyz.lts.x_stage.get_max_acceleration()
get_max_acceleration_y(xyz::ThorlabsLTS150) = xyz.lts.y_stage.get_max_acceleration()
get_max_acceleration_z(xyz::ThorlabsLTS150) = xyz.lts.z_stage.get_max_acceleration()

set_max_acceleration_x(xyz::ThorlabsLTS150, a) = xyz.lts.x_stage.set_max_acceleration(a)
set_max_acceleration_y(xyz::ThorlabsLTS150, a) = xyz.lts.y_stage.set_max_acceleration(a)
set_max_acceleration_z(xyz::ThorlabsLTS150, a) = xyz.lts.z_stage.set_max_acceleration(a)

# TODO: Eventually this should be a part of stage movement
function safe_move(xyz, move_func, x, y, z)
    try
        move_func(x, y, z)
    catch err
        if isa(err, InterruptException) 
            move_xyz(xyz, pos_xyz(xyz)...)
            print("Stopping device")
        else
            rethrow(err)
        end
    end
end

function safe_move(xyz, move_func, position)
    try
        move_func(position)
    catch err
        if isa(err, InterruptException) 
            move_xyz(xyz, pos_xyz(xyz)...)
            print("Stopping device")
        else
            rethrow(err)
        end
    end
end
