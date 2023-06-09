using Test
using Unitful
using ThorlabsLTStage

# initialize python backend
# ThorlabsLTStage.init_python_lib()

ps = ThorlabsLTStage.initialize(PositionerSystem)

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"

@testset "test messaging configuration" begin
    @test ThorlabsLTStage.LoadSettings(ps.x.serial) == true
    @test ThorlabsLTStage.LoadNamedSettings(ps.x.serial, "stage name") == true
    @test ThorlabsLTStage.Poll(ps.x.serial, 50) == true
    @test ThorlabsLTStage.ClearQueue(ps.x.serial) == true

    @test ThorlabsLTStage.LoadSettings(ps.y.serial) == true
    @test ThorlabsLTStage.LoadNamedSettings(ps.y.serial, "stage name") == true
    @test ThorlabsLTStage.Poll(ps.y.serial, 50) == true
    @test ThorlabsLTStage.ClearQueue(ps.y.serial) == true

    @test ThorlabsLTStage.LoadSettings(ps.z.serial) == true
    @test ThorlabsLTStage.LoadNamedSettings(ps.z.serial, "stage name") == true
    @test ThorlabsLTStage.Poll(ps.z.serial, 50) == true
    @test ThorlabsLTStage.ClearQueue(ps.z.serial) == true
end

terminate(ps)
@info "Terminated PS - end of test"
