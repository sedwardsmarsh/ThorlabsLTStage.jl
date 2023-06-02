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

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"

@testset "test messaging configuration" begin
    for serial in serials
        @test ThorlabsLTStage.LoadSettings(serial) == true
        @test ThorlabsLTStage.LoadNamedSettings(serial, "stage name") == true
        @test ThorlabsLTStage.Poll(serial, 50) == true
        @test ThorlabsLTStage.ClearQueue(serial) == true
    end
end