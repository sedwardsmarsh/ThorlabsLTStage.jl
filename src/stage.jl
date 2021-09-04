## setup & teardown
function disconnect(stage::Stage)
    disconnect_device(stage.serial)
end


## position
home(s::Stage) = home!(s)

pos(s::Stage) = position(s) * m

move_abs(s::Stage, position::Unitful.Length) = move_abs!(s, s.origin_pos + raw_meters(position))

move_rel(s::Stage, position::Unitful.Length) = move_rel!(s, raw_meters(position))

function set_origin(stage::Stage)
    stage.origin_pos = position(stage)
    return nothing
end

function get_origin(stage::Stage)
    return stage.origin_pos * m
end

function move_to_origin(stage::Stage)
    move_abs!(stage, stage.origin_pos)
    return nothing
end

function pause(stage::Stage, p)
    while !isapprox(position(stage), p)
        sleep(0.1)
    end
    stage.is_moving = false
end

function move_abs!(stage::Stage, position; block=true)
    check_limits(stage, position)
    stage.is_moving = true
    MoveAbs(stage.serial, position)
    block && pause(stage, position)
    return
end

function move_rel!(stage::Stage, position; block=true)
    p = raw_meters(pos(stage))
    move_abs!(stage, p + position; block=block)
end

function home!(stage::Stage)
    move_abs!(stage, 0)
end

function position(stage::Stage)
    return DeviceUnitToMeters(stage.serial, GetPos(stage.serial))
end


## position limits
get_limits(s::Stage) = limits(s) .* m

function set_limits(s::Stage, min::Unitful.Length, max::Unitful.Length)
    limits!(s, raw_meters(min), raw_meters(max))
end

function travel_limits(stage::Stage)
    lower, upper = GetMotorTravelLimits(stage.serial)
    return m(lower * mm), m(upper * mm)
end

reset_limits(stage::Stage) = limits!(stage, stage.min_pos, stage.max_pos)

function set_lower_limit(stage::Stage, position::Unitful.Length)
    stage.lower_limit = raw_meters(position)
    return nothing
end

function set_upper_limit(stage::Stage, position::Unitful.Length)
    stage.upper_limit = raw_meters(position)
    return nothing
end

function get_lower_limit(stage::Stage)
    return stage.lower_limit * m
end

function get_upper_limit(stage::Stage)
    return stage.upper_limit * m
end

upper_limit(stage::Stage) = stage.upper_limit
lower_limit(stage::Stage) = stage.lower_limit

function lower_limit!(stage::Stage, limit) 
    if upper_limit(stage) > stage.max_pos
        error("Min Position of $(stage.min_pos). Limit $(lower_limit(stage)) cannot be set")
    end
    stage.lower_limit  = limit
end

function upper_limit!(stage::Stage, limit) 
    if upper_limit(stage) > stage.max_pos
        error("Max Position of $(stage.max_pos). Limit $(upper_limit(stage)) cannot be set")
    end
    stage.upper_limit  = limit
end

function limits!(stage::Stage, lower, upper)
    if upper < lower
        error("Upper limit ($upper) is less than lower limit ($lower)")
    end
    lower_limit!(stage, lower)
    upper_limit!(stage, upper)
end

limits(stage::Stage) = lower_limit(stage), upper_limit(stage)

function check_limits(stage, position)
    if position < lower_limit(stage) || position > upper_limit(stage)
        error("Position $position is outside of the current set limits $([stage.lower_limit, stage.upper_limit])")
    end
end


## velocity
get_max_velocity(st::Stage) = velocity(st) * mm/s

set_max_velocity(st::Stage, max::Unitful.Velocity) = velocity!(st, ustrip(uconvert(mm/s, max)))

function velocity(stage::Stage)
    return GetVelocity(stage.serial)
end

function velocity!(stage::Stage, vel)
    return SetVelocity(stage.serial, vel)
end


## acceleration
get_max_acceleration(st::Stage) = acceleration(st) * mm/s^2

set_max_acceleration(st::Stage, max::Unitful.Acceleration) = acceleration!(st, ustrip(uconvert(mm/s^2, max)))

function acceleration(stage::Stage)
    return GetAcceleration(stage.serial)
end

function acceleration!(stage::Stage, acc)
    return SetAcceleration(stage.serial, acc)
end
