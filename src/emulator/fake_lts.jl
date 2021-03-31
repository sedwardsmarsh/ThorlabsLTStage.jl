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
        serial, "HS FakeLTS 150mm", 0m, .15m, 0m, .15m, 20mm/s, 20mm/s^2, 0m, false
    )
end

home(s::FakeStage) = move_abs(s, 0)

pos(s::FakeStage) = s.pos

get_max_velocity(st::FakeStage) = st.max_velocity

set_max_velocity(st::FakeStage, max::Speed) = st.max_velocity = max --> mm/s

get_max_acceleration(st::FakeStage) = st.max_acceleration

set_max_acceleration(st::FakeStage, max::typeof(mm/s^2)) = st.max_acceleration = max

move_abs(s::FakeStage, position::Unitful.Length) = s.pos = position

move_rel(s::FakeStage, position::Unitful.Length) = s.pos = position + pos(s)

lower_limit(s::FakeStage) = s.lower_limit *m
upper_limit(s::FakeStage) = s.upper_limit *m

get_limits(s::FakeStage) = s.lower_limit, s.upper_limit

function set_limits(s::FakeStage, lower, upper) 
    s.lower_limit = lower
    s.upper_limit = upper
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

function initialize(::Type{FakeLTS})
    return FakeLTS(FakeStage("1"), FakeStage("2"), FakeStage("3"))
end

stages(lts::FakeLTS) = (lts.x, lts.y, lts.z)

function move(lts::FakeLTS, x,y,z; move_func=false)
    move_abs(lts.x, x)
    move_abs(lts.y, y)
    move_abs(lts.z, z)
end


home_xyz(lts::FakeLTS) = move(lts, 0, 0, 0)

