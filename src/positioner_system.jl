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
    min_pos, max_pos = get_intrinsic_limits(stage)
    min_pos = get(stage_config, "min_position", raw_millimeters(min_pos))
    max_pos = get(stage_config, "max_position", raw_millimeters(max_pos))
    set_intrinsic_limits(stage, min_pos*mm, max_pos*mm)

    # Set velocity limits from config
    max_vel = get(stage_config, "max_velocity", velocity(stage))
    velocity!(stage, max_vel)

    # Set acceleration limits from config
    max_acc = get(stage_config, "max_acceleration", acceleration(stage))
    acceleration!(stage, max_acc)

    # set position accuracy from config
    position_accuracy = get_position_accuracy(stage)
    position_accuracy = get(stage_config, "position_accuracy", raw_millimeters(position_accuracy))
    set_position_accuracy(stage, position_accuracy*mm)
end

get_stages(positioner_system::T) where T <: PositionerSystem = Tuple(getfield(positioner_system, fieldname) for fieldname in fieldnames(typeof(positioner_system)))

function terminate(positioner_system::T) where T <: PositionerSystem
    map(disconnect, get_stages(positioner_system))
    return nothing
end


## position
get_pos(positioner_system::T) where T <:  PositionerSystem = [map(get_pos, get_stages(positioner_system))...]

function set_origin(positioner_system::PositionerSystem)
    map(set_origin, get_stages(positioner_system))
    return nothing
end

function get_origin(positioner_system::PositionerSystem)
    return [map(get_origin, get_stages(positioner_system))...]
end

function move_to_origin(positioner_system::PositionerSystem)
    map(move_to_origin, get_stages(positioner_system))
    return nothing
end


## position limits
function get_limits(positioner_system::T) where T <: PositionerSystem
    stages = get_stages(positioner_system)
    return map(x -> get_lower_limit(x), stages), map(x -> get_upper_limit(x), stages)
end

function set_limits(positioner_system::T, lower_limits, upper_limits) where T <: PositionerSystem
    stages = get_stages(positioner_system)
    num_stages = length(stages)
    length(lower_limits) != num_stages && error("Expected $(num_stages) elements in $lower_limits")
    length(upper_limits) != num_stages && error("Expected $(num_stages) elements in $upper_limits")
    for idx in 1:num_stages
        set_limits(stages[idx], lower_limits[idx], upper_limits[idx])
    end
    return nothing
end

reset_limits(positioner_system::T) where T <: PositionerSystem = map(reset_limits, get_stages(positioner_system))


## velocity & acceleration
get_max_velocity(positioner_system) = map(get_max_velocity, get_stages(positioner_system))
get_max_acceleration(positioner_system) = map(get_max_acceleration, get_stages(positioner_system))


## syntactic sugar
get_limits_x(positioner_system) = get_limits(positioner_system.x)
get_limits_y(positioner_system) = get_limits(positioner_system.y)
get_limits_z(positioner_system) = get_limits(positioner_system.z)

set_limits_x(positioner_system, l, u) = set_limits(positioner_system.x, l, u)
set_limits_y(positioner_system, l, u) = set_limits(positioner_system.y, l, u)
set_limits_z(positioner_system, l, u) = set_limits(positioner_system.z, l, u)

function move_xyz(positioner_system, x_position, y_position, z_position)
    move_to_position(positioner_system.x, x_position)
    move_to_position(positioner_system.y, y_position)
    move_to_position(positioner_system.z, z_position)
    return nothing
end
move_x_abs(positioner_system, x) = move_to_position(positioner_system.x, x)
move_y_abs(positioner_system, y) = move_to_position(positioner_system.y, y)
move_z_abs(positioner_system, z) = move_to_position(positioner_system.z, z)

move_x_rel(positioner_system, x) = move_rel(positioner_system.x, x)
move_y_rel(positioner_system, y) = move_rel(positioner_system.y, y)
move_z_rel(positioner_system, z) = move_rel(positioner_system.z, z)

get_pos_x(positioner_system) = get_pos(positioner_system.x)
get_pos_y(positioner_system) = get_pos(positioner_system.y)
get_pos_z(positioner_system) = get_pos(positioner_system.z)

home(positioner_system) = map(home, get_stages(positioner_system))
home_x(positioner_system) = home(positioner_system.x)
home_y(positioner_system) = home(positioner_system.y)
home_z(positioner_system) = home(positioner_system.z)
