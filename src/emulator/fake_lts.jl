import InstrumentConfig: initialize,terminate

mutable struct FakeStage
    serial::String
    info::String
    min_pos
    max_pos
    lower_limit
    upper_limit
    max_velocity
    max_acceleration
    pos
    is_moving::Bool
end

function FakeStage(serial)
    return FakeStage(
        serial, "HS FakeLTS 150mm", 0m, .15m, 0, .15, 20mm/s, 20mm/s^2, 0m, false
    )
end

home(s::FakeStage) = move_abs(s, 0)

pos(s::FakeStage) = s.pos

get_max_velocity(st::FakeStage) = st.max_velocity

set_max_velocity(st::FakeStage, max::Unitful.Velocity) = st.max_velocity = max --> mm/s

get_max_acceleration(st::FakeStage) = st.max_acceleration

set_max_acceleration(st::FakeStage, max::Unitful.Acceleration) = st.max_acceleration = max -->mm/s^2

function move_abs(s::FakeStage, position::Unitful.Length)
    pos = Float64(position --> m)
    check_limits(s, raw_meters(pos))
    s.pos = pos
end

move_rel(s::FakeStage, position::Unitful.Length) = move_abs(s, pos(s) + position)

lower_limit(s::FakeStage) = s.lower_limit
upper_limit(s::FakeStage) = s.upper_limit

get_limits(s::FakeStage) = s.lower_limit * m, s.upper_limit * m

function set_limits(s::FakeStage, lower, upper)
    s.lower_limit = ustrip(lower)
    s.upper_limit = ustrip(upper)
end

function reset_limits(stage::FakeStage)
    stage.upper_limit = stage.max_pos
    stage.lower_limit = stage.min_pos
end

struct FakeLTS <: LTS
    x::FakeStage
    y::FakeStage
    z::FakeStage
end

initialize(::Type{FakeLTS}) = FakeLTS(map(FakeStage, ["1", "2", "3"])...)

stages(lts::FakeLTS) = (lts.x, lts.y, lts.z)

function move(lts::FakeLTS, x,y,z; move_func=false)
    move_abs(lts.x, x)
    move_abs(lts.y, y)
    move_abs(lts.z, z)
end

home_xyz(lts::FakeLTS) = move(lts, 0m, 0m, 0m)
