# position
home(stage::FakeStage) = move_abs!(stage, 0)

pos(stage::FakeStage) = stage.current_pos * m

function move_abs(stage::FakeStage, position::Unitful.Length)
    move_abs!(stage, raw_meters(position))
    return nothing
end

function move_abs!(stage::FakeStage, position)
    check_limits(stage, position)
    stage.current_pos = position
    return nothing
end

function move_rel(stage::FakeStage, position::Unitful.Length) 
    move_abs!(stage, raw_meters(pos(stage)+position))
    return nothing
end


# position limits
lower_limit(stage::FakeStage) = stage.lower_limit
upper_limit(stage::FakeStage) = stage.upper_limit

get_limits(stage::FakeStage) = stage.lower_limit * m, stage.upper_limit * m

function set_limits(stage::FakeStage, lower, upper)
    stage.lower_limit = ustrip(lower)
    stage.upper_limit = ustrip(upper)
end

function reset_limits(stage::FakeStage)
    stage.upper_limit = stage.max_pos
    stage.lower_limit = stage.min_pos
end


# velocity
get_max_velocity(stage::FakeStage) = stage.max_velocity
set_max_velocity(stage::FakeStage, max::Unitful.Velocity) = stage.max_velocity = uconvert(mm/s, max)


# acceleration
get_max_acceleration(stage::FakeStage) = stage.max_acceleration
set_max_acceleration(stage::FakeStage, max::Unitful.Acceleration) = stage.max_acceleration = uconvert(mm/s^2, max)
