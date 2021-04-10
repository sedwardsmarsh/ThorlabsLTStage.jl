using ThorlabsLTStage
using Unitful
using Test

const m = u"m"
const mm = u"mm"

@testset "ThorlabsLTStage.jl" begin
    lts = initialize(ThorlabsLTStage.FakeLTS)
    @testset "Movement X" begin
        move_abs = move_x_abs
        move_rel = move_x_rel
        pos_axis = pos_x
        home(lts)
        @test pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_x_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        move_xyz(lts, .1m, .1m, 1mm)
        @test pos(lts) == [0.1m, 0.1m, 0.001m]

    end
    @testset "Movement Y" begin
        move_abs = move_y_abs
        move_rel = move_y_rel
        pos_axis = pos_y
        home(lts)
        @test pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_x_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        move_xyz(lts, .1m, .1m, 1mm)
        @test pos(lts) == [0.1m, 0.1m, 0.001m]

    end
    @testset "Movement Z" begin
        move_abs = move_z_abs
        move_rel = move_z_rel
        pos_axis = pos_z
        home(lts)
        @test pos(lts) == [0m, 0m, 0m]

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_x_abs(lts, .151m)

        move_abs(lts, .15m)
        @test pos_axis(lts) == 150mm
        @test pos_axis(lts) == .15m

        @test_throws ErrorException("Position 0.151 is outside of the current set limits [0.0, 0.15]") move_rel(lts, 1mm)

        move_rel(lts, -1mm)
        @test pos_axis(lts) == 149mm
        @test pos_axis(lts) == .149m

        move_xyz(lts, .1m, .1m, 1mm)
        @test pos(lts) == [0.1m, 0.1m, 0.001m]

    end
    @testset "Limits" begin
        @test get_limits(lts) == ((0m, 0m, 0m), (.15m, .15m, .15m))
        set_limits(lts,(0m, 0m, 0m), (.1m, .1m, .1m))
        @test get_limits(lts) == ((0m, 0m, 0m), (.1m, .1m, .1m))
        @test_throws ErrorException("Position 0.101 is outside of the current set limits [0.0, 0.1]") move_x_abs(lts, 101mm)
    end

end
