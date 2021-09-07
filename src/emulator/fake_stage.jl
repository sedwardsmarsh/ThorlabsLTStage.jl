# position
home(stage::FakeStage) = move_abs!(stage, 0mm)

get_pos(stage::FakeStage) = stage.current_pos

function move_abs(stage::FakeStage, position::Unitful.Length)
    move_abs!(stage, position)
    return nothing
end

function move_abs!(stage::FakeStage, position::Unitful.Length)
    check_limits(stage, position)
    stage.current_pos = position
    return nothing
end

function move_rel(stage::FakeStage, position::Unitful.Length) 
    move_abs!(stage, get_pos(stage) + position)
    return nothing
end


# velocity
get_max_velocity(stage::FakeStage) = stage.max_velocity
set_max_velocity(stage::FakeStage, max::Unitful.Velocity) = stage.max_velocity = uconvert(mm/s, max)


# acceleration
get_max_acceleration(stage::FakeStage) = stage.max_acceleration
set_max_acceleration(stage::FakeStage, max::Unitful.Acceleration) = stage.max_acceleration = uconvert(mm/s^2, max)
