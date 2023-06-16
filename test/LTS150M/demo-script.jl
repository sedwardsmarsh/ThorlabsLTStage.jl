using Test
using Unitful
using ThorlabsLTStage

@info "Initializing PositionerSystem"
ps = ThorlabsLTStage.initialize(PositionerSystem)

@info "Homing PS ..."

ThorlabsLTStage.SetVelParams(ps.x.serial, 40, 5)
ThorlabsLTStage.SetVelParams(ps.y.serial, 5, 3)
ThorlabsLTStage.SetVelParams(ps.z.serial, 40, 5)

ThorlabsLTStage.home(ps)

ThorlabsLTStage.SetVelParams(ps.x.serial, 50, 50)
ThorlabsLTStage.SetVelParams(ps.z.serial, 50, 50)

target_position_start = 1.05*u"mm"
ThorlabsLTStage.move_xyz(ps, target_position_start, target_position_start, target_position_start)
@info "Moved to $target_position_start"
target_position_middle = 55 *u"mm"
ThorlabsLTStage.move_xyz(ps, target_position_middle, target_position_middle, target_position_middle)
@info "Moved to $target_position_middle"
target_position_end = 148*u"mm"
ThorlabsLTStage.move_xyz(ps, target_position_end, target_position_end, target_position_end)
@info "Moved to $target_position_end"

ThorlabsLTStage.SetVelParams(ps.x.serial, 40, 5)
ThorlabsLTStage.SetVelParams(ps.z.serial, 40, 5)

ThorlabsLTStage.home(ps)

terminate(ps)
@info "Terminated PS"