## setup & teardown
function initialize_stage(stage::Stage)
    is_connected = check_is_connected(stage.serial)
    println("Stage $(stage.serial) connected: $(is_connected)")
    connect_device(stage.serial)
    is_connected = check_is_connected(stage.serial)
    println("Stage $(stage.serial) connected: $(is_connected)")

    ClearQueue(stage.serial)
    println("Loading settings")
    stage.info = get_stage_name(stage)
    LoadNamedSettings(stage.serial, stage.info)
    println("Settings loaded")
    set_stage_default_min_max_pos(stage)
    Enable(stage.serial)
    milliseconds_until_next_poll = 50
    Poll(stage.serial, milliseconds_until_next_poll)

    stage.origin_pos = get_intrinsic_position(stage)
    stage.min_pos = get_device_min_position(stage)
    stage.max_pos = get_device_max_position(stage)
    stage.lower_limit = stage.min_pos
    stage.upper_limit = stage.max_pos
    stage.is_moving = false
    stage.pos_accuracy = 0.01mm

    finalizer(s -> disconnect_device(s.serial), stage)
    return nothing
end

function get_stage_name(stage::Stage)
    model, _ = GetHardwareInfo(stage.serial)
    if model == "LTS150"
        setting_name = "HS LTS150 150mm Stage"
    elseif model == "LTS300"
        setting_name = "HS LTS300 300mm Stage"
    else
        error("Model name unrecognized: $model")
    end
    return setting_name
end

function set_stage_default_min_max_pos(stage::Stage)
    stage_info = stage.info
    if stage_info == "HS LTS150 150mm Stage"
        set_stage_min_max_pos(stage, -150mm, 150mm)
    elseif stage_info == "HS LTS300 300mm Stage"
        set_stage_min_max_pos(stage, -300mm, 300mm)
    else
        error("Stage info not recognized: $stage_info")
    end
    return nothing
end

function set_stage_min_max_pos(stage::Stage, min_pos::Unitful.Length, max_pos::Unitful.Length)
    min_position = MillimetersToDeviceUnit(stage.serial, raw_millimeters(min_pos))
    max_position = MillimetersToDeviceUnit(stage.serial, raw_millimeters(max_pos))
    set_stage_axis_min_max_pos(stage.serial, min_position, max_position)
    return nothing
end

function get_device_min_position(stage::Stage)
    return DeviceUnitToMillimeters(stage.serial, get_stage_axis_min_pos(stage.serial)) * mm
end

function get_device_max_position(stage::Stage)
    return DeviceUnitToMillimeters(stage.serial, get_stage_axis_max_pos(stage.serial)) * mm
end

function disconnect(stage::Stage)
    disconnect_device(stage.serial)
end


## position
get_pos(stage::LinearTranslationStage) = intrinsic_to_extrinsic_position(stage, get_intrinsic_position(stage))

function get_intrinsic_position(stage::Stage)
    return DeviceUnitToMillimeters(stage.serial, GetPos(stage.serial)) * mm
end

function intrinsic_to_extrinsic_position(stage::LinearTranslationStage, intrinsic_position::Unitful.Length)
    return intrinsic_position - get_origin(stage)
end

function extrinsic_to_intrinsic_position(stage::LinearTranslationStage, extrinsic_position::Unitful.Length)
    return extrinsic_position + get_origin(stage)
end

function move_to_position(stage::LinearTranslationStage, extrinsic_position::Unitful.Length)
    intrinsic_position = extrinsic_to_intrinsic_position(stage, extrinsic_position)
    move_to_intrinsic_position(stage, intrinsic_position)
    return nothing
end

function move_to_intrinsic_position(stage::Stage, intrinsic_position::Unitful.Length; block=true)
    intrinsic_position = round(intrinsic_position, get_position_accuracy(stage))
    extrinsic_position = intrinsic_to_extrinsic_position(stage, intrinsic_position)
    check_limits(stage, extrinsic_position)
    stage.is_moving = true
    MoveAbs(stage.serial, intrinsic_position)
    block && pause(stage, intrinsic_position)
    return
end

function get_position_accuracy(stage::LinearTranslationStage)
    return stage.pos_accuracy
end

function round(value::Unitful.Length, multiple::Unitful.Length)
    return Base.round(value / multiple) * multiple
end

function pause(stage::Stage, target_intrinsic_position::Unitful.Length)
    while !isapprox(get_intrinsic_position(stage), target_intrinsic_position)
        sleep(0.1)
    end
    stage.is_moving = false
end

function move_rel(stage::LinearTranslationStage, distance::Unitful.Length)
    move_to_intrinsic_position(stage, get_intrinsic_position(stage) + distance)
end

function home(stage::LinearTranslationStage)
    move_to_intrinsic_position(stage, 0mm)
end

function set_origin(stage::LinearTranslationStage)
    stage.origin_pos = get_intrinsic_position(stage)
    return nothing
end

function get_origin(stage::LinearTranslationStage)
    return stage.origin_pos
end

function move_to_origin(stage::LinearTranslationStage)
    move_to_intrinsic_position(stage, stage.origin_pos)
    return nothing
end


## position limits
function check_limits(stage::LinearTranslationStage, position::Unitful.Length)
    check_lower_limit(stage, position)
    check_upper_limit(stage, position)
    return nothing
end

function check_lower_limit(stage::LinearTranslationStage, position::Unitful.Length)
    extrinsic_lower_limit = get_lower_limit(stage)
    if position < extrinsic_lower_limit
        error("Desired position ($position) is past the lower limit ($extrinsic_lower_limit)")
    end
    return nothing
end

function check_upper_limit(stage::LinearTranslationStage, position::Unitful.Length)
    extrinsic_upper_limit = get_upper_limit(stage)
    if position > extrinsic_upper_limit
        error("Desired position ($position) is past the upper limit ($extrinsic_upper_limit)")
    end
    return nothing
end

function get_lower_limit(stage::LinearTranslationStage)
    intrinsic_lower_limit = get_intrinsic_lower_limit(stage)
    return intrinsic_to_extrinsic_position(stage, intrinsic_lower_limit)
end

function get_upper_limit(stage::LinearTranslationStage)
    intrinsic_upper_limit = get_intrinsic_upper_limit(stage)
    return intrinsic_to_extrinsic_position(stage, intrinsic_upper_limit)
end

function get_intrinsic_lower_limit(stage::LinearTranslationStage)
    return stage.lower_limit
end

function get_intrinsic_upper_limit(stage::LinearTranslationStage)
    return stage.upper_limit
end

get_limits(stage::LinearTranslationStage) = get_lower_limit(stage), get_upper_limit(stage)
get_intrinsic_limits(stage::LinearTranslationStage) = get_intrinsic_lower_limit(stage), get_intrinsic_upper_limit(stage)

function set_limits(stage::LinearTranslationStage, lower_limit::Unitful.Length, upper_limit::Unitful.Length)
    if lower_limit > upper_limit
        error("Lower limit ($lower_limit) cannot be greater than upper limit ($upper_limit)")
    end
    set_lower_limit(stage, lower_limit)
    set_upper_limit(stage, upper_limit)
    return nothing
end

function set_lower_limit(stage::LinearTranslationStage, extrinsic_position::Unitful.Length)
    extrinsic_min_position = get_min_position(stage)
    if extrinsic_position < extrinsic_min_position
        error("Desired lower limit ($extrinsic_position) is less than the device's min position ($extrinsic_min_position)")
    end
    stage.lower_limit = extrinsic_to_intrinsic_position(stage, extrinsic_position)
    return nothing
end

function set_upper_limit(stage::LinearTranslationStage, extrinsic_position::Unitful.Length)
    extrinsic_max_position = get_max_position(stage)
    if extrinsic_position > extrinsic_max_position
        error("Desired upper limit ($extrinsic_position) is greater than the device's max position ($extrinsic_max_position)")
    end
    stage.upper_limit = extrinsic_to_intrinsic_position(stage, extrinsic_position)
    return nothing
end

function get_min_position(stage::LinearTranslationStage)
    intrinsic_min_position = get_intrinsic_min_position(stage)
    return intrinsic_to_extrinsic_position(stage, intrinsic_min_position)
end

function get_max_position(stage::LinearTranslationStage)
    intrinsic_max_position = get_intrinsic_max_position(stage)
    return intrinsic_to_extrinsic_position(stage, intrinsic_max_position)
end

function get_intrinsic_min_position(stage::LinearTranslationStage)
    return stage.min_pos
end

function get_intrinsic_max_position(stage::LinearTranslationStage)
    return stage.max_pos
end

function set_intrinsic_limits(stage::LinearTranslationStage, lower_limit::Unitful.Length, upper_limit::Unitful.Length)
    if lower_limit > upper_limit
        error("Lower limit ($lower_limit) cannot be greater than upper limit ($upper_limit)")
    end
    set_intrinsic_lower_limit(stage, lower_limit)
    set_intrinsic_upper_limit(stage, upper_limit)
    return nothing
end

function set_intrinsic_lower_limit(stage::LinearTranslationStage, intrinsic_position::Unitful.Length)
    intrinsic_min_position = get_intrinsic_min_position(stage)
    if intrinsic_position < intrinsic_min_position
        error("Desired intrinsic lower limit ($intrinsic_position) is less than the device's intrinsic min position ($intrinsic_min_position)")
    end
    stage.lower_limit = intrinsic_position
    return nothing
end

function set_intrinsic_upper_limit(stage::LinearTranslationStage, intrinsic_position::Unitful.Length)
    intrinsic_max_position = get_intrinsic_max_position(stage)
    if intrinsic_position > intrinsic_max_position
        error("Desired intrinsic upper limit ($intrinsic_position) is greater than the device's intrinsic max position ($intrinsic_max_position)")
    end
    stage.upper_limit = intrinsic_position
    return nothing
end

function reset_limits(stage::LinearTranslationStage)
    set_lower_limit(stage, get_min_position(stage))
    set_upper_limit(stage, get_max_position(stage))
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
