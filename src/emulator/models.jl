mutable struct FakeStage <: LinearTranslationStage
    serial::String
    info::String
    origin_pos::Unitful.Length
    min_pos::Unitful.Length
    max_pos::Unitful.Length
    lower_limit::Unitful.Length
    upper_limit::Unitful.Length
    is_moving::Bool
    pos_accuracy::Unitful.Length
    # additional fields that Stage does not have
    current_pos::Unitful.Length
    max_velocity::Unitful.Velocity
    max_acceleration::Unitful.Acceleration
end

function FakeStage(serial)
    return FakeStage(serial, "HS FakeStage 150mm", 0mm, 0mm, 150mm, 0mm, 150mm, false, 0.01mm, 0mm, 20*mm/s, 20*mm/s^2)
end

function Base.show(io::IO, stage::FakeStage)
    println(io, "         serial: ", stage.serial)
    println(io, "           info: ", stage.info)
    println(io, "      is_moving: ", stage.is_moving)
    println(io, "    current_pos: ", round(get_pos(stage), get_position_accuracy(stage)))
    println(io, "    lower_limit: ", round(get_lower_limit(stage), get_position_accuracy(stage)))
    println(io, "    upper_limit: ", round(get_upper_limit(stage), get_position_accuracy(stage)))
    println(io, "        min_pos: ", round(get_min_position(stage), get_position_accuracy(stage)))
    println(io, "        max_pos: ", round(get_max_position(stage), get_position_accuracy(stage)))
    println(io, "   pos_accuracy: ", get_position_accuracy(stage))
    println(io, "   max_velocity: ", get_max_velocity(stage))
    println(io, "max_accelration: ", get_max_acceleration(stage))
end

struct FakePS_3D <: PositionerSystem
    x::FakeStage
    y::FakeStage
    z::FakeStage
end
