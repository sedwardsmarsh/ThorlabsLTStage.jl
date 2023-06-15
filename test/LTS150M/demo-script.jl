using Test
using Unitful
using ThorlabsLTStage

ps = ThorlabsLTStage.initialize(PositionerSystem)

@info "Homing PS ..."
ThorlabsLTStage.home(ps)

ThorlabsLTStage.SetVelParams(ps.x.serial, 10, 10)
ThorlabsLTStage.SetVelParams(ps.y.serial, 10, 10)
ThorlabsLTStage.SetVelParams(ps.z.serial, 10, 10)
sleep(2)
target_position_start = 1.05*u"mm"
ThorlabsLTStage.move_x_abs(ps, target_position_start)
ThorlabsLTStage.move_y_abs(ps, target_position_start)
ThorlabsLTStage.move_z_abs(ps, target_position_start)
sleep(2)
target_position_middle = 55 *u"mm"
ThorlabsLTStage.move_x_abs(ps, target_position_middle)
ThorlabsLTStage.move_y_abs(ps, target_position_middle)
ThorlabsLTStage.move_z_abs(ps, target_position_middle)
sleep(2)
target_position_end = 148*u"mm"
ThorlabsLTStage.move_x_abs(ps, target_position_end)
ThorlabsLTStage.move_y_abs(ps, target_position_end)
ThorlabsLTStage.move_z_abs(ps, target_position_end)
sleep(2)
ThorlabsLTStage.home(ps)

terminate(ps)
@info "Terminated PS"