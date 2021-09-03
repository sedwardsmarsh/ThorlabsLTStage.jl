import InstrumentConfig: initialize,terminate

terminate(lts::T) where T <: PositionerSystem = close!(lts)

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

        return LTS_3D(x_stage, y_stage, z_stage)
    else
        error("$num_stages unexpectedly found: $serials")
    end
end

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
    lts = initialize_positioner_system(device_list)

    setup(lts.x, x_stage)
    setup(lts.y, y_stage)
    setup(lts.z, z_stage)
    return lts
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


get_limits(lts) = limits(lts)
set_limits(lts, lower, upper) = limits!(lts, raw_meters.(lower), raw_meters.(upper))

get_limits_x(lts) = get_limits(lts.x)
get_limits_y(lts) = get_limits(lts.y)
get_limits_z(lts) = get_limits(lts.z)

set_limits_x(lts, l, u) = set_limits(lts.x, l, u)
set_limits_y(lts, l, u) = set_limits(lts.y, l, u)
set_limits_z(lts, l, u) = set_limits(lts.z, l, u)

move_xyz(lts, x, y, z) = move(lts, raw_meters(x), raw_meters(y), raw_meters(z))

move_x_abs(lts, x) = move_abs(lts.x, x)
move_y_abs(lts, y) = move_abs(lts.y, y)
move_z_abs(lts, z) = move_abs(lts.z, z)

move_x_rel(lts, x) = move_rel(lts.x, x)
move_y_rel(lts, y) = move_rel(lts.y, y)
move_z_rel(lts, z) = move_rel(lts.z, z)

pos_xyz(lts) = pos(lts)
pos_x(lts) = pos(lts.x)
pos_y(lts) = pos(lts.y)
pos_z(lts) = pos(lts.z)

home(lts) = home_xyz(lts)
home_x(lts) = home(lts.x)
home_y(lts) = home(lts.y)
home_z(lts) = home(lts.z)

get_max_velocity(lts) = map(get_max_velocity, stages(lts))
get_max_acceleration(lts) = map(get_max_acceleration, stages(lts))



stages(lts::LTS_3D) = (lts.x, lts.y, lts.z)

function close!(lts::T) where T <: PositionerSystem
    s = stages(lts)
    map(close!, s)

    return nothing
end

function limits(lts::T) where T <: PositionerSystem
    s = stages(lts)
    return map(x->lower_limit(x)*m, s), map(x->upper_limit(x)*m, s)
end


function limits!(lts::T, lower, upper) where T <: PositionerSystem
    s = stages(lts)
    num_stages = length(s)
    length(lower) != num_stages && error("Expected $(num_stages) elements in $lower")
    length(upper) != num_stages && error("Expected $(num_stages) elements in $upper")
    for i in 1:num_stages
        set_limits(s[i], lower[i], upper[i])
    end

    return nothing
end

function move(lts::LTS_3D, x, y, z; move_func=move_abs!)
    move_func(lts.x, x; block=false)
    move_func(lts.y, y; block=false)
    move_func(lts.z, z; block=false)
    pause(lts.x, x)
    pause(lts.y, y)
    pause(lts.z, z)

    return nothing
end

home_xyz(lts::LTS_3D) = move(lts, 0, 0, 0)

pos(lts::T) where T <:  PositionerSystem = [map(pos, stages(lts))...]

reset_limits(lts::T) where T <: PositionerSystem = map(reset_limits, stages(lts))

function Base.show(io::IO, ::MIME"text/plain", lts::T) where T <: PositionerSystem
   println(io, "Thorlabs positioner system")
   function p_stage(io, s)
       print(io, " ")
       Base.show(io, s)
       println() 
   end
   p_stage(io, lts.x)
   p_stage(io, lts.y)
   p_stage(io, lts.z)
end

function set_origin(lts::LTS_3D)
    map(set_origin, stages(lts))
    return nothing
end

function get_origin(lts::LTS_3D)
    return [map(get_origin, stages(lts))...]
end

function move_to_origin(lts::LTS_3D)
    map(move_to_origin, stages(lts))
    return nothing
end
