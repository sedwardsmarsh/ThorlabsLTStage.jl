mutable struct FakeStage <: LinearTranslationStage
    serial::String
    info::String
    origin_pos::Unitful.Length
    min_pos::Unitful.Length
    max_pos::Unitful.Length
    lower_limit::Unitful.Length
    upper_limit::Unitful.Length
    is_moving::Bool
    # additional fields that Stage does not have
    current_pos::Unitful.Length
    max_velocity::Unitful.Velocity
    max_acceleration::Unitful.Acceleration
end

function FakeStage(serial)
    return FakeStage(serial, "HS FakeStage 150mm", 0mm, 0mm, 150mm, 0mm, 150mm, false, 0mm, 20*mm/s, 20*mm/s^2)
end

function Base.show(io::IO, stage::FakeStage)
    println(io, "         serial: ", stage.serial)
    println(io, "           info: ", stage.info)
    println(io, "      is_moving: ", stage.is_moving)
    println(io, "    current_pos: ", round(mm, get_pos(stage); digits=2))
    println(io, "    lower_limit: ", round(mm, get_lower_limit(stage); digits=2))
    println(io, "    upper_limit: ", round(mm, get_upper_limit(stage); digits=2))
    println(io, "        min_pos: ", round(mm, get_min_position(stage); digits=2))
    println(io, "        max_pos: ", round(mm, get_max_position(stage); digits=2))
    println(io, "   max_velocity: ", round(mm/s, get_max_velocity(stage); digits=2))
    println(io, "max_accelration: ", round(mm/s^2, get_max_acceleration(stage); digits=2))
end

struct FakePS_3D <: PositionerSystem
    x::FakeStage
    y::FakeStage
    z::FakeStage
end
