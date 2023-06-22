using Test
using Unitful
using ThorlabsLTStage

@info "Initializing Positioner System"
ps = ThorlabsLTStage.initialize(PositionerSystem)

# Set stages velocities
velocity = 20
acceleration = 20
@info "Set move velocity: $velocity mm/sec and move acceleration: $acceleration mm/sec^2"
ThorlabsLTStage.SetVelParams(ps.x.serial, velocity, acceleration)
ThorlabsLTStage.SetVelParams(ps.y.serial, velocity, acceleration)
ThorlabsLTStage.SetVelParams(ps.z.serial, velocity, acceleration)
# Set home velocity
home_velocity = 5
@info "Set home velocity: $home_velocity  mm/sec"
ThorlabsLTStage.set_home_velocity(ps.x, home_velocity)
ThorlabsLTStage.set_home_velocity(ps.y, home_velocity)
ThorlabsLTStage.set_home_velocity(ps.z, home_velocity)

@info "True home Positioner System ..."
ThorlabsLTStage.true_home(ps.x)
ThorlabsLTStage.true_home(ps.y)
ThorlabsLTStage.true_home(ps.z)

target_position_start = 1.05*u"mm"
@info "Moving to $target_position_start"
ThorlabsLTStage.move_xyz(ps, target_position_start, target_position_start, target_position_start)

target_position_middle = 55 *u"mm"
@info "Moving to $target_position_middle"
ThorlabsLTStage.move_xyz(ps, target_position_middle, target_position_middle, target_position_middle)

target_position_end = 148*u"mm"
@info "Moving to $target_position_end"
ThorlabsLTStage.move_xyz(ps, target_position_end, target_position_end, target_position_end)

@info "Homing Positioner System ..."
ThorlabsLTStage.home(ps)

terminate(ps)
@info "Terminated Positioner System"