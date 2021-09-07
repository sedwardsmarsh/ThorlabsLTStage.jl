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

struct FakePS_3D <: PositionerSystem
    x::FakeStage
    y::FakeStage
    z::FakeStage
end
