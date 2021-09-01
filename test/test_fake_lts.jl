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
        move_abs = ThorlabsLTStage.move_x_abs
        move_rel = ThorlabsLTStage.move_x_rel
        pos_axis = ThorlabsLTStage.pos_x
        ThorlabsLTStage.home(lts)
        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        ThorlabsLTStage.move_xyz(lts, .1m, .1m, 1mm)
        @test ThorlabsLTStage.pos(lts) == [0.1m, 0.1m, 0.001m]
    end

    @safetestset "move_along_y_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        move_abs = ThorlabsLTStage.move_y_abs
        move_rel = ThorlabsLTStage.move_y_rel
        pos_axis = ThorlabsLTStage.pos_y
        ThorlabsLTStage.home(lts)
        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        ThorlabsLTStage.move_xyz(lts, .1m, .1m, 1mm)
        @test ThorlabsLTStage.pos(lts) == [0.1m, 0.1m, 0.001m]
    end

    @safetestset "move_along_z_axis" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        move_abs = ThorlabsLTStage.move_z_abs
        move_rel = ThorlabsLTStage.move_z_rel
        pos_axis = ThorlabsLTStage.pos_z
        ThorlabsLTStage.home(lts)
        @test ThorlabsLTStage.pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        ThorlabsLTStage.move_xyz(lts, .1m, .1m, 1mm)
        @test ThorlabsLTStage.pos(lts) == [0.1m, 0.1m, 0.001m]
    end

    @safetestset "test_movement_limits" begin
        using ..SetupTestFakeLts
        lts = ThorlabsLTStage.initialize(ThorlabsLTStage.FakeLTS)
        @test ThorlabsLTStage.get_limits(lts) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        ThorlabsLTStage.set_limits(lts,(0m, 0m, 0m), (0.1m, 0.1m, 0.1m))
        @test ThorlabsLTStage.get_limits(lts) == ((0m, 0m, 0m), (0.1m, 0.1m, 0.1m))
        @test_throws ErrorException("Position 0.101 is outside of the current set limits [0.0, 0.1]") ThorlabsLTStage.move_x_abs(lts, 101mm)
    end
end
