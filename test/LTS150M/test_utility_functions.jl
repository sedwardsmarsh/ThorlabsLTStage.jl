using Test
using Unitful
using ThorlabsLTStage

# initialize python backend
# ThorlabsLTStage.init_python_lib()

ps = ThorlabsLTStage.initialize(PositionerSystem)
@info "check_is_connected() will only return true if .positioner_system_config.yml is configured correctly"

@testset "Velocity and accleration getters and setters" begin
    ThorlabsLTStage.SetVelParams(ps.x.serial, 5, 5)
    @test ThorlabsLTStage.acceleration(ps.x) == 5
    @test ThorlabsLTStage.velocity(ps.x) == 5
    @test ThorlabsLTStage.GetVelParams(ps.x.serial) == (5.0, 5.0)
    ThorlabsLTStage.set_home_velocity(ps.x, 10)
    @test ThorlabsLTStage.get_home_velocity(ps.x) == 10

    ThorlabsLTStage.SetVelParams(ps.y.serial, 6, 6)
    @test ThorlabsLTStage.acceleration(ps.y) == 6
    @test ThorlabsLTStage.velocity(ps.y) == 6
    @test ThorlabsLTStage.GetVelParams(ps.y.serial) == (6.0, 6.0)
    ThorlabsLTStage.set_home_velocity(ps.y, 11)
    @test ThorlabsLTStage.get_home_velocity(ps.y) == 11

    ThorlabsLTStage.SetVelParams(ps.z.serial, 4, 4)
    @test ThorlabsLTStage.acceleration(ps.z) == 4
    @test ThorlabsLTStage.velocity(ps.z) == 4
    @test ThorlabsLTStage.GetVelParams(ps.z.serial) == (4.0, 4.0)
    ThorlabsLTStage.set_home_velocity(ps.z, 8)
    @test ThorlabsLTStage.get_home_velocity(ps.z) == 8
end

@testset "test utility functions" begin
    test_serial::String = ps.x.serial

    @test ThorlabsLTStage.check_conversion_type(0) == 0
    @test ThorlabsLTStage.WaitForMessage(test_serial) == 0
    
    @testset "test convert device units to real values" begin
        # test acceleration conversion
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 13.9, 2) == 62634
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 14.7, 2) == 66239
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 22.4, 2) == 100936
        
        # test velocity conversion
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 16.3, 1) == 358440791
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 45.3, 1) == 996157535
        @test ThorlabsLTStage.GetDeviceUnitFromRealValue(test_serial, 16.4, 1) == 360639814
    end

    @testset "test convert real values to device units" begin
        # test acceleration conversion
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 62634, 2) == 13.9
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 66239, 2) == 14.7
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 100936, 2) == 22.4
        
        # test velocity conversion
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 358440791, 1) == 16.3
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 996157535, 1) == 45.3
        @test ThorlabsLTStage.GetRealValueFromDeviceUnit(test_serial, 360639814, 1) == 16.4
    end

    terminate(ps)
    @info "Terminated PS - end of test"
end