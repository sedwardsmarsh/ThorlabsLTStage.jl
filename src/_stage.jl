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

function pause(stage::Stage, p)
    while !isapprox(position(stage), p)
        sleep(0.1)
    end
    stage.is_moving = false
end

function check_limits(stage, position)
    if position < lower_limit(stage) || position > upper_limit(stage)
        error("Position $position is outside of the current set limits $([stage.lower_limit, stage.upper_limit])")
    end
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

function close!(stage::Stage)
    Close(stage.serial)
end

function acceleration(stage::Stage)
    return GetAcceleration(stage.serial)
end

function acceleration!(stage::Stage, acc)
    return SetAcceleration(stage.serial, acc)
end

function velocity(stage::Stage)
    return GetVelocity(stage.serial)
end

function velocity!(stage::Stage, vel)
    return SetVelocity(stage.serial, vel)
end

