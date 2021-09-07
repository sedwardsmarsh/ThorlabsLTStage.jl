## setup & teardown
function disconnect(stage::Stage)
    disconnect_device(stage.serial)
end


## position
pos(s::Stage) = position(s) * m

function position(stage::Stage)
    return DeviceUnitToMeters(stage.serial, GetPos(stage.serial))
end

move_abs(s::Stage, position::Unitful.Length) = move_abs!(s, s.origin_pos + raw_meters(position))

function move_abs!(stage::Stage, position; block=true)
    check_limits(stage, position)
    stage.is_moving = true
    MoveAbs(stage.serial, position)
    block && pause(stage, position)
    return
end

function pause(stage::Stage, p)
    while !isapprox(position(stage), p)
        sleep(0.1)
    end
    stage.is_moving = false
end

move_rel(s::Stage, position::Unitful.Length) = move_rel!(s, raw_meters(position))

function move_rel!(stage::Stage, position; block=true)
    p = raw_meters(pos(stage))
    move_abs!(stage, p + position; block=block)
end

home(s::Stage) = home!(s)

function home!(stage::Stage)
    move_abs!(stage, 0)
end

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


## position limits
function travel_limits(stage::Stage)
    lower, upper = GetMotorTravelLimits(stage.serial)
    return m(lower * mm), m(upper * mm)
end

function check_limits(stage::LinearTranslationStage, position)
    check_lower_limit(stage, position)
    check_upper_limit(stage, position)
    return nothing
end

function check_lower_limit(stage::LinearTranslationStage, position)
    lower_limit = get_lower_limit(stage)
    if position < lower_limit
        error("Desired position ($position) is past the lower limit ($lower_limit)")
    end
    return nothing
end

function check_upper_limit(stage::LinearTranslationStage, position)
    upper_limit = get_upper_limit(stage)
    if position > upper_limit
        error("Desired position ($position) is past the upper limit ($upper_limit)")
    end
    return nothing
end

function get_lower_limit(stage::LinearTranslationStage)
    return stage.lower_limit
end

function get_upper_limit(stage::LinearTranslationStage)
    return stage.upper_limit
end

get_limits(stage::LinearTranslationStage) = get_lower_limit(stage), get_upper_limit(stage)

function set_limits(stage::LinearTranslationStage, lower_limit, upper_limit)
    if lower_limit > upper_limit
        error("Lower limit ($lower_limit) cannot be greater than upper limit ($upper_limit)")
    end
    set_lower_limit(stage, lower_limit)
    set_upper_limit(stage, upper_limit)
    return nothing
end

function set_lower_limit(stage::LinearTranslationStage, position)
    device_min_position = get_device_min_position(stage)
    if position < device_min_position
        error("Desired lower limit ($position) is less than the device's min position ($device_min_position)")
    end
    stage.lower_limit = position
    return nothing
end

function set_upper_limit(stage::LinearTranslationStage, position)
    device_max_position = get_device_max_position(stage)
    if position > device_max_position
        error("Desired upper limit ($position) is greater than the device's max position ($device_max_position)")
    end
    stage.upper_limit = position
    return nothing
end

function get_device_min_position(stage::LinearTranslationStage)
    return stage.min_pos
end

function get_device_max_position(stage::LinearTranslationStage)
    return stage.max_pos
end

function reset_limits(stage::LinearTranslationStage)
    set_lower_limit(stage, get_device_min_position(stage))
    set_upper_limit(stage, get_device_max_position(stage))
    return nothing
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
