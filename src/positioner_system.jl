import InstrumentConfig: initialize,terminate

## setup & teardown
function initialize(::Type{PositionerSystem})
    BuildDeviceList()
    stages = get(get_config(), "ThorlabsLTS", Dict())
    if isempty(stages)
        return initialize_positioner_system()
    end

    x_stage = stages["x"]
    y_stage = stages["y"]
    z_stage = stages["z"]
    device_list = map(s->s["serial"], [x_stage, y_stage, z_stage])
    positioner_system = initialize_positioner_system(device_list)

    setup(positioner_system.x, x_stage)
    setup(positioner_system.y, y_stage)
    setup(positioner_system.z, z_stage)
    return positioner_system
end

function initialize_positioner_system(serials = GetDeviceList())
    num_stages = length(serials)
    if num_stages == 0
        error("No stages detected")
    elseif num_stages == 3
        x, y, z = serials

        x_stage = Stage(x)
        println("X Stage: $(x_stage.serial) $(x_stage.info)")

        y_stage = Stage(y)
        println("Y Stage: $(y_stage.serial) $(y_stage.info)")

        z_stage = Stage(z)
        println("Z Stage: $(z_stage.serial) $(z_stage.info)")

        return PS_3D(x_stage, y_stage, z_stage)
    else
        error("$num_stages unexpectedly found: $serials")
    end
end

function setup(stage, stage_config)
    # Set position limits from config
    min_pos, max_pos = limits(stage)
    min_pos = get(stage_config, "min_position", min_pos)
    max_pos = get(stage_config, "max_position", max_pos)
    limits!(stage, min_pos, max_pos)

    # Set velocity limits from config
    max_vel = get(
        stage_config, "max_velocity", velocity(stage)
    )
    velocity!(stage, max_vel)

    # Set acceleration limits from config
    max_acc = get(
        stage_config, "max_acceleration", acceleration(stage)
    )
    acceleration!(stage, max_acc)
end

function Base.show(io::IO, ::MIME"text/plain", positioner_system::T) where T <: PositionerSystem
    println(io, "Thorlabs positioner system")
    function p_stage(io, s)
        print(io, " ")
        Base.show(io, s)
        println() 
    end
    p_stage(io, positioner_system.x)
    p_stage(io, positioner_system.y)
    p_stage(io, positioner_system.z)
end

stages(positioner_system::PS_3D) = (positioner_system.x, positioner_system.y, positioner_system.z)

terminate(positioner_system::T) where T <: PositionerSystem = close!(positioner_system)

function close!(positioner_system::T) where T <: PositionerSystem
    s = stages(positioner_system)
    map(close!, s)
    return nothing
end


## position
home_xyz(positioner_system::PS_3D) = move(positioner_system, 0, 0, 0)

pos(positioner_system::T) where T <:  PositionerSystem = [map(pos, stages(positioner_system))...]

function move(positioner_system::PS_3D, x, y, z; move_func=move_abs!)
    move_func(positioner_system.x, x; block=false)
    move_func(positioner_system.y, y; block=false)
    move_func(positioner_system.z, z; block=false)
    pause(positioner_system.x, x)
    pause(positioner_system.y, y)
    pause(positioner_system.z, z)

    return nothing
end

function set_origin(positioner_system::PS_3D)
    map(set_origin, stages(positioner_system))
    return nothing
end

function get_origin(positioner_system::PS_3D)
    return [map(get_origin, stages(positioner_system))...]
end

function move_to_origin(positioner_system::PS_3D)
    map(move_to_origin, stages(positioner_system))
    return nothing
end


## position limits
function limits(positioner_system::T) where T <: PositionerSystem
    s = stages(positioner_system)
    return map(x->lower_limit(x)*m, s), map(x->upper_limit(x)*m, s)
end

function limits!(positioner_system::T, lower, upper) where T <: PositionerSystem
    s = stages(positioner_system)
    num_stages = length(s)
    length(lower) != num_stages && error("Expected $(num_stages) elements in $lower")
    length(upper) != num_stages && error("Expected $(num_stages) elements in $upper")
    for i in 1:num_stages
        set_limits(s[i], lower[i], upper[i])
    end
    return nothing
end

reset_limits(positioner_system::T) where T <: PositionerSystem = map(reset_limits, stages(positioner_system))


## velocity & acceleration
get_max_velocity(positioner_system) = map(get_max_velocity, stages(positioner_system))
get_max_acceleration(positioner_system) = map(get_max_acceleration, stages(positioner_system))


## syntactic sugar
get_limits(positioner_system) = limits(positioner_system)
set_limits(positioner_system, lower, upper) = limits!(positioner_system, raw_meters.(lower), raw_meters.(upper))

get_limits_x(positioner_system) = get_limits(positioner_system.x)
get_limits_y(positioner_system) = get_limits(positioner_system.y)
get_limits_z(positioner_system) = get_limits(positioner_system.z)

set_limits_x(positioner_system, l, u) = set_limits(positioner_system.x, l, u)
set_limits_y(positioner_system, l, u) = set_limits(positioner_system.y, l, u)
set_limits_z(positioner_system, l, u) = set_limits(positioner_system.z, l, u)

move_xyz(positioner_system, x, y, z) = move(positioner_system, raw_meters(x), raw_meters(y), raw_meters(z))

move_x_abs(positioner_system, x) = move_abs(positioner_system.x, x)
move_y_abs(positioner_system, y) = move_abs(positioner_system.y, y)
move_z_abs(positioner_system, z) = move_abs(positioner_system.z, z)

move_x_rel(positioner_system, x) = move_rel(positioner_system.x, x)
move_y_rel(positioner_system, y) = move_rel(positioner_system.y, y)
move_z_rel(positioner_system, z) = move_rel(positioner_system.z, z)

pos_xyz(positioner_system) = pos(positioner_system)
pos_x(positioner_system) = pos(positioner_system.x)
pos_y(positioner_system) = pos(positioner_system.y)
pos_z(positioner_system) = pos(positioner_system.z)

home(positioner_system) = home_xyz(positioner_system)
home_x(positioner_system) = home(positioner_system.x)
home_y(positioner_system) = home(positioner_system.y)
home_z(positioner_system) = home(positioner_system.z)
