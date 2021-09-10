# position
get_intrinsic_position(stage::FakeStage) = stage.current_pos

function move_to_intrinsic_position(stage::FakeStage, intrinsic_position::Unitful.Length)
    extrinsic_position = intrinsic_to_extrinsic_position(stage, intrinsic_position)
    check_limits(stage, extrinsic_position)
    stage.current_pos = intrinsic_position
    return nothing
end


# velocity
get_max_velocity(stage::FakeStage) = stage.max_velocity
set_max_velocity(stage::FakeStage, max::Unitful.Velocity) = stage.max_velocity = uconvert(mm/s, max)


# acceleration
get_max_acceleration(stage::FakeStage) = stage.max_acceleration
set_max_acceleration(stage::FakeStage, max::Unitful.Acceleration) = stage.max_acceleration = uconvert(mm/s^2, max)
