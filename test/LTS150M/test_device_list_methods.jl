using Test
using Unitful
using ThorlabsLTStage

# instantiate the python backend
# ThorlabsLTStage.init_python_lib()

@testset "test device list methods" begin
    @test ThorlabsLTStage.BuildDeviceList() == []
    @test ThorlabsLTStage.GetDeviceListSize() == 3
    @test length(ThorlabsLTStage.GetDeviceList()) == 3
end