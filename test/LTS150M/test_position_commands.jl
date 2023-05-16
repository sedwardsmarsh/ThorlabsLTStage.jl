using Test
using Unitful
using ThorlabsLTStage

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"

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

const ONE_MM_TO_DEVICE_UNITS = 409600

@testset "test position commands" begin
    for serial in serials
        target_position_start = Int(1.05 * ONE_MM_TO_DEVICE_UNITS)
        ThorlabsLTStage.MoveAbs(serial, target_position_start)
        pos = ThorlabsLTStage.GetPos(serial)
        @test target_position_start == pos

        target_position_middle = Int(55 * ONE_MM_TO_DEVICE_UNITS)
        ThorlabsLTStage.MoveAbs(serial, target_position_middle)
        pos = ThorlabsLTStage.GetPos(serial)
        @test target_position_middle == pos

        target_position_end = Int(150 * ONE_MM_TO_DEVICE_UNITS)
        ThorlabsLTStage.MoveAbs(serial, target_position_end)
        pos = ThorlabsLTStage.GetPos(serial)
        @test target_position_end == pos
    end

    @test ThorlabsLTStage.GetMotorTravelLimits("12345678") == (0u"mm", 150u"mm")

    # testing noop functions
    @test ThorlabsLTStage.SetMoveAbsolutePosition("12345678", 150) == 0
    @test ThorlabsLTStage.MoveAbsolute("12345678") == 0
    @test ThorlabsLTStage.get_stage_axis_min_pos("12345678") == 0
    @test ThorlabsLTStage.set_stage_axis_min_max_pos("12345678", 0, 150) == 0
end