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

@testset "test connection methods" begin
    for serial in serials
        @test ThorlabsLTStage.check_is_connected(serial) == true
        @test ThorlabsLTStage.connect_device(serial) == 0
        @test ThorlabsLTStage.disconnect_device(serial) == 0
        @test ThorlabsLTStage.Enable(serial) == 0
    end
end