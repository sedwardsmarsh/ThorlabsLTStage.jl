using Test
using SafeTestsets


module SetupTestFakeLts
    using ThorlabsLTStage
    using Unitful

    export ThorlabsLTStage
    export m, mm

    const m = u"m"
    const mm = u"mm"
end


@testset "test_fake_lts" begin
    @safetestset "move_along_x_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        ThorlabsLTStage.home(lts)

        ThorlabsLTStage.move_x_abs(lts, 0.15m)
        @test ThorlabsLTStage.pos_x(lts) == 150mm

        ThorlabsLTStage.move_x_rel(lts, -1mm)
        @test ThorlabsLTStage.pos_x(lts) == 149mm
    end


    @safetestset "move_along_y_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        ThorlabsLTStage.home(lts)

        ThorlabsLTStage.move_y_abs(lts, 0.15m)
        @test ThorlabsLTStage.pos_y(lts) == 150mm

        ThorlabsLTStage.move_y_rel(lts, -1mm)
        @test ThorlabsLTStage.pos_y(lts) == 149mm
    end


    @safetestset "move_along_z_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        ThorlabsLTStage.home(lts)

        ThorlabsLTStage.move_z_abs(lts, 0.15m)
        @test ThorlabsLTStage.pos_z(lts) == 150mm

        ThorlabsLTStage.move_z_rel(lts, -1mm)
        @test ThorlabsLTStage.pos_z(lts) == 149mm
    end

    
    @safetestset "move_along_all_three_axes" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        ThorlabsLTStage.home(lts)

        ThorlabsLTStage.move_xyz(lts, 14mm, 15mm, 16mm)
        @test ThorlabsLTStage.pos(lts) == [14mm, 15mm, 16mm]
    end


    @safetestset "movement_limits_in_x_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)

        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(lts) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_x_rel(lts, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_x_rel(lts, 151mm)
        ThorlabsLTStage.move_x_abs(lts, 11mm)

        ThorlabsLTStage.home(lts)
        ThorlabsLTStage.set_limits(lts,(0m, 0m, 0m), (0.01m, 0.01m, 0.01m))
        @test ThorlabsLTStage.get_limits(lts) == ((0mm, 0mm, 0mm), (10mm, 10mm, 10mm))
        @test_throws ErrorException("Position 0.011 is outside of the current set limits [0.0, 0.01]") ThorlabsLTStage.move_x_abs(lts, 11mm)
    end


    @safetestset "movement_limits_in_y_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)

        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(lts) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_y_rel(lts, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_y_rel(lts, 151mm)
        ThorlabsLTStage.move_y_abs(lts, 21mm)

        ThorlabsLTStage.home(lts)
        ThorlabsLTStage.set_limits(lts,(0m, 0m, 0m), (0.02m, 0.02m, 0.02m))
        @test ThorlabsLTStage.get_limits(lts) == ((0mm, 0mm, 0mm), (20mm, 20mm, 20mm))
        @test_throws ErrorException ThorlabsLTStage.move_y_abs(lts, 21mm)
    end


    @safetestset "movement_limits_in_z_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)

        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(lts) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_z_rel(lts, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_z_rel(lts, 151mm)
        ThorlabsLTStage.move_z_abs(lts, 31mm)

        ThorlabsLTStage.home(lts)
        ThorlabsLTStage.set_limits(lts,(0m, 0m, 0m), (0.03m, 0.03m, 0.03m))
        @test ThorlabsLTStage.get_limits(lts) == ((0mm, 0mm, 0mm), (30mm, 30mm, 30mm))
        @test_throws ErrorException ThorlabsLTStage.move_z_abs(lts, 31mm)
    end
end
