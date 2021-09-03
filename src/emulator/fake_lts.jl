import InstrumentConfig: initialize, terminate

mutable struct FakeStage
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
    return FakeStage(serial, "HS FakeLTS 150mm", 0, 0, 0.15, 0, 0.15, false, 0, 20, 20)
end

struct FakeLTS <: LTS
    x::FakeStage
    y::FakeStage
    z::FakeStage
end

function initialize(::Type{FakeLTS}) 
    return FakeLTS(map(FakeStage, ["1", "2", "3"])...)
end


## FakeLTS functions
stages(lts::FakeLTS) = (lts.x, lts.y, lts.z)

function move(lts::FakeLTS, x, y, z; move_func=false)
    move_abs!(lts.x, x)
    move_abs!(lts.y, y)
    move_abs!(lts.z, z)
end

home_xyz(lts::FakeLTS) = move(lts, raw_meters(0m), raw_meters(0m), raw_meters(0m))


## FakeStage functions
# position
home(s::FakeStage) = move_abs!(s, 0)

pos(s::FakeStage) = s.current_pos * m

function move_abs(stage::FakeStage, position::Unitful.Length)
    move_abs!(stage, raw_meters(position))
    return nothing
end

function move_abs!(s::FakeStage, position)
    check_limits(s, position)
    s.current_pos = position
end

move_rel(s::FakeStage, position::Unitful.Length) = move_abs!(s, raw_meters(pos(s)+position))


# position limits
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


# velocity
get_max_velocity(st::FakeStage) = st.max_velocity
set_max_velocity(st::FakeStage, max::Unitful.Velocity) = st.max_velocity = uconvert(mm/s, max)


# acceleration
get_max_acceleration(st::FakeStage) = st.max_acceleration
set_max_acceleration(st::FakeStage, max::Unitful.Acceleration) = st.max_acceleration = uconvert(mm/s^2, max)
