using Test
using Unitful
using ThorlabsLTStage

# initialize python backend
ThorlabsLTStage.init_python_lib()

# get serials of the connected stages
serials = Vector{String}(undef, 0)
for stage_config in ThorlabsLTStage.get_config()["ThorlabsLTS"]
    try 
        serial_string = string(stage_config[2]["serial"])
        push!(serials, serial_string)
    catch e
        if e isa KeyError
            continue
        end
    end
end

@info "check_is_connected() will only return true if .positioner_system_config.yml is configured correctly"

@testset "test utility functions" begin
    test_serial::String = serials[1]

    @test ThorlabsLTStage.GetHardwareInfo(test_serial) == 0
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
end