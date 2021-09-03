mutable struct FakeStage <: LinearTranslationStage
    serial::String
    info::String
    origin_pos::Float64
    min_pos::Float64
    max_pos::Float64
    lower_limit::Float64
    upper_limit::Float64
    is_moving::Bool
    # additional fields that Stage does not have
    current_pos::Float64
    max_velocity::Float64
    max_acceleration::Float64
end

function FakeStage(serial)
    return FakeStage(serial, "HS FakeStage 150mm", 0, 0, 0.15, 0, 0.15, false, 0, 20, 20)
end

struct FakePS_3D <: PositionerSystem
    x::FakeStage
    y::FakeStage
    z::FakeStage
end
