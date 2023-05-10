using Test
using Unitful
using ThorlabsLTStage

# initialize python backend
ThorlabsLTStage.init_python_lib()

ps = ThorlabsLTStage.initialize(PositionerSystem)

@info "check_is_connected() will only return true if .positioner_system_config.yml is configured correctly"

@testset "test connection methods" begin

    @test ThorlabsLTStage.check_is_connected(ps.x.serial) == true
    ThorlabsLTStage.disconnect_device(ps.x.serial)
    @test ThorlabsLTStage.check_is_connected(ps.x.serial) == false
    @test ThorlabsLTStage.Enable(ps.x.serial) == 0

    @test ThorlabsLTStage.check_is_connected(ps.y.serial) == true
    ThorlabsLTStage.disconnect_device(ps.y.serial)
    @test ThorlabsLTStage.check_is_connected(ps.y.serial) == false
    @test ThorlabsLTStage.Enable(serial) == 0

    @test ThorlabsLTStage.check_is_connected(ps.z.serial) == true
    ThorlabsLTStage.disconnect_device(ps.z.serial) == 0
    @test ThorlabsLTStage.check_is_connected(ps.z.serial) == false
    @test ThorlabsLTStage.Enable(ps.z.serial) == 0
end

terminate(ps)
@info "Terminated PS - end of test"
