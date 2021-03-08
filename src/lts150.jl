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
    initialize_lts()
end

function initialize_lts() 
    @assert Sys.iswindows() "Windows is needed to connect to ThorlabsLTS150"
    @assert lts_lib != nothing "add python: python to top of config file then call load_python(). You must be on a windows computer to use this device"
    lts = lts_lib.LTS()

    stages = get(get_config(), "ThorlabsLTS150", "")
    @info get_config()

    if isempty(stages)
        lts.init()
    else
        lts.init_custom([stages["X"], stages["Y"], stages["Z"]])
    end
    ThorlabsLTS150(lts)
end

"""
    move_xyz(xyz, x, y, z)

Simulatenously moves x, y and z stage to desired location
"""
move_xyz(xyz, x, y, z) = xyz.lts.move_xyz(x, y, z)

"""
    pos_xyz(xyz)

Returns location of x, y and z stages in the form of a Array: [x, y, z]
"""
pos_xyz(xyz) = [xyz.lts.pos_x(), xyz.lts.pos_y(), xyz.lts.pos_z()]

"""
    move_x(xyz, x)

Moves x stage to desired absolute location
"""
move_x_abs(xyz, x) = xyz.lts.move_x(x)

"""
    move_y(xyz, y)

Moves y stage to desired absolute location
"""
move_y_abs(xyz, y) = xyz.lts.move_y(y)

"""
    move_z(xyz, z)

Moves z stage to desired absolute location
"""
move_z_abs(xyz, z) = xyz.lts.move_z(z)

"""
    move_x(xyz, x)

Moves x stage forward or backwards.

A positive number will move it forwards along the x axis while
a negative number will move it backwards.
"""
move_x_rel(xyz, x) = xyz.lts.move_x(x + xyz.lts.pos_x())

"""
    move_y(xyz, y)

Moves y stage forward or backwards.

A positive number will move it forwards along the y axis while
a negative number will move it backwards.
"""
move_y_rel(xyz, y) = xyz.lts.move_y(y + xyz.lts.pos_y())

"""
    move_z(xyz, z)

Moves z stage forward or backwards.

A positive number will move it forwards along the z axis while
a negative number will move it backwards.
"""
move_z_rel(xyz, z) = xyz.lts.move_z(z + xyz.lts.pos_z())

"""
    home(xyz)

This will home the x, y and z stages at the same time
"""
home(xyz) = xyz.lts.home_xyz()

"""
    home_x(xyz)

This will home the x stage
"""
home_x(xyz) = xyz.lts.home_x() 

"""
    home_y(xyz)

This will home the y stage
"""
home_y(xyz) = xyz.lts.home_y() 

"""
    home_z(xyz)

This will home the z stage
"""
home_z(xyz) = xyz.lts.home_z() 

"""
    pos_x(xyz)

Returns the current position of x stage
"""
pos_x(xyz) = xyz.lts.pos_x()

"""
    pos_y(xyz)

Returns the current position of y stage
"""
pos_y(xyz) = xyz.lts.pos_y()

"""
    pos_z(xyz)

Returns the current position of z stage
"""
pos_z(xyz) = xyz.lts.pos_z()

"""
    set_limits(xyz, (x_low_lim, y_low_lim, z_low_lim), (x_high_lim, y_high_lim, z_high_lim))

# Arguments
- `low`: A Pair or an Array of three positions: (lts.x_low_limit, lts.y_low_limit, lts.z_low_limit)
- `high`: A Pair or an Array of three positions: (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)

"""
function set_limits(xyz, low, high)
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
function get_limits(xyz)
    return xyz.lts.get_limits()
end

"""
Returns

    (x_low_limit, x_high_limit)
"""
function get_limits_x(xyz)
    low, high = xyz.lts.get_limits()
    return low[1], high[1]
end

"""
Returns

    (y_low_limit, y_high_limit)
"""
function get_limits_y(xyz)
    low, high = xyz.lts.get_limits()
    return low[2], high[2]
end

"""
Returns

    (z_low_limit, z_high_limit)
"""
function get_limits_z(xyz)
    low, high = xyz.lts.get_limits()
    return low[3], high[3]
end

function clear_limits(xyz)
    xyz.lts.remove_limits()
end
