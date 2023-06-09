using Test
using Unitful
using ThorlabsLTStage

# get serials of the connected stages
# serials = Vector{String}(undef, 0)
# for stage_config in ThorlabsLTStage.get_config()["ThorlabsLTS"]
#     try 
#         serial_string = string(stage_config[2]["serial"])
#         push!(serials, serial_string)
#     catch e
#         if e isa KeyError
#             continue
#         end
#     end
# end

ps = ThorlabsLTStage.initialize(ThorlabsLTStage.PositionerSystem)
serials = [stage.serial for stage in ThorlabsLTStage.get_stages(ps)]

@testset "test python connection" begin
    for test_number in range(start=0, stop=200)
        println("test number: $test_number")
        ThorlabsLTStage.MoveAbs(serials[1], 1.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[2], 1.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[3], 1.0u"mm")

        ThorlabsLTStage.MoveAbs(serials[2], 75.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[1], 75.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[3], 75.0u"mm")

        ThorlabsLTStage.MoveAbs(serials[1], 148.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[2], 148.0u"mm")
        ThorlabsLTStage.MoveAbs(serials[3], 148.0u"mm")
        println("test number: $test_number complete\n")
    end
end
ThorlabsLTStage.terminate(ps)
