using Test
using Unitful
using ThorlabsLTStage

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"

# initialize python backend
# ThorlabsLTStage.init_python_lib()

ps = ThorlabsLTStage.initialize(PositionerSystem)

ThorlabsLTStage.home(ps)
set_origin(ps)

@testset "test position commands" begin
    @testset "Move absolute 1.05mm" begin
    target_position_start = 1.05*u"mm"
        ThorlabsLTStage.move_x_abs(ps, target_position_start)
        pos = ThorlabsLTStage.get_pos_x(ps)
        @test target_position_start == pos
        ThorlabsLTStage.move_y_abs(ps, target_position_start)
        pos = ThorlabsLTStage.get_pos_y(ps)
        @test target_position_start == pos
        ThorlabsLTStage.move_z_abs(ps, target_position_start)
        pos = ThorlabsLTStage.get_pos_z(ps)
        @test target_position_start == pos
    end
    @testset "Move absolute 55 mm" begin
        target_position_middle = 55 *u"mm"
        ThorlabsLTStage.move_x_abs(ps, target_position_middle)
        pos = ThorlabsLTStage.get_pos_x(ps)
        @test target_position_middle == pos
        ThorlabsLTStage.move_y_abs(ps, target_position_middle)
        pos = ThorlabsLTStage.get_pos_y(ps)
        @test target_position_middle == pos
        ThorlabsLTStage.move_z_abs(ps, target_position_middle)
        pos = ThorlabsLTStage.get_pos_z(ps)
        @test target_position_middle == pos
    end
    @testset "Move absolute 150mm" begin
        target_position_end = 150*u"mm"
        ThorlabsLTStage.move_x_abs(ps, target_position_end)
        pos = ThorlabsLTStage.get_pos_x(ps)
        @test target_position_end == pos
        ThorlabsLTStage.move_y_abs(ps, target_position_end)
        pos = ThorlabsLTStage.get_pos_y(ps)
        @test target_position_end == pos
        ThorlabsLTStage.move_z_abs(ps, target_position_end)
        pos = ThorlabsLTStage.get_pos_z(ps)
        @test target_position_end == pos
    end

    @test ThorlabsLTStage.GetMotorTravelLimits("12345678") == (0u"mm", 150u"mm")
    # testing noop functions
    @test ThorlabsLTStage.SetMoveAbsolutePosition("12345678", 150) == 0
    @test ThorlabsLTStage.MoveAbsolute("12345678") == 0
    @test ThorlabsLTStage.get_stage_axis_min_pos("12345678") == 0
    @test ThorlabsLTStage.set_stage_axis_min_max_pos("12345678", 0, 150) == 0

    terminate(ps)
    @info "Terminated PS - end of test"
end
