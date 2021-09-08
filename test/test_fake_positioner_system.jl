using Test
using SafeTestsets


module SetupTestFakePs
    using ThorlabsLTStage
    using Unitful

    export ThorlabsLTStage
    export m, mm

    const m = u"m"
    const mm = u"mm"
end


@testset "test_fake_positioner_system" begin
    @safetestset "move_along_x_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)
        ThorlabsLTStage.home(positioner_system)

        ThorlabsLTStage.move_x_abs(positioner_system, 0.15m)
        @test ThorlabsLTStage.get_pos_x(positioner_system) == 150mm

        ThorlabsLTStage.move_x_rel(positioner_system, -1mm)
        @test ThorlabsLTStage.get_pos_x(positioner_system) == 149mm
    end


    @safetestset "move_along_y_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)
        ThorlabsLTStage.home(positioner_system)

        ThorlabsLTStage.move_y_abs(positioner_system, 0.15m)
        @test ThorlabsLTStage.get_pos_y(positioner_system) == 150mm

        ThorlabsLTStage.move_y_rel(positioner_system, -1mm)
        @test ThorlabsLTStage.get_pos_y(positioner_system) == 149mm
    end


    @safetestset "move_along_z_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)
        ThorlabsLTStage.home(positioner_system)

        ThorlabsLTStage.move_z_abs(positioner_system, 0.15m)
        @test ThorlabsLTStage.get_pos_z(positioner_system) == 150mm

        ThorlabsLTStage.move_z_rel(positioner_system, -1mm)
        @test ThorlabsLTStage.get_pos_z(positioner_system) == 149mm
    end

    
    @safetestset "move_along_all_three_axes" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        ThorlabsLTStage.move_xyz(positioner_system, 14mm, 15mm, 16mm)
        @test ThorlabsLTStage.get_pos(positioner_system) == [14mm, 15mm, 16mm]

        ThorlabsLTStage.home_x(positioner_system)
        ThorlabsLTStage.home_y(positioner_system)
        ThorlabsLTStage.home_z(positioner_system)
        @test ThorlabsLTStage.get_pos(positioner_system) == [0mm, 0mm, 0mm]
    end

    @safetestset "invalid_limits" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        @test_throws ErrorException ThorlabsLTStage.set_limits(positioner_system.x, 10mm, -10mm)
    end


    @safetestset "movement_limits_in_x_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        @test ThorlabsLTStage.get_pos(positioner_system) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_x_rel(positioner_system, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_x_rel(positioner_system, 151mm)
        ThorlabsLTStage.move_x_abs(positioner_system, 11mm)

        ThorlabsLTStage.home(positioner_system)
        ThorlabsLTStage.set_limits(positioner_system, (0m, 0m, 0m), (0.01m, 0.01m, 0.01m))
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0mm, 0mm, 0mm), (10mm, 10mm, 10mm))
        @test_throws ErrorException ThorlabsLTStage.move_x_abs(positioner_system, 11mm)
    end


    @safetestset "movement_limits_in_y_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        @test ThorlabsLTStage.get_pos(positioner_system) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_y_rel(positioner_system, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_y_rel(positioner_system, 151mm)
        ThorlabsLTStage.move_y_abs(positioner_system, 21mm)

        ThorlabsLTStage.home(positioner_system)
        ThorlabsLTStage.set_limits(positioner_system, (0m, 0m, 0m), (0.02m, 0.02m, 0.02m))
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0mm, 0mm, 0mm), (20mm, 20mm, 20mm))
        @test_throws ErrorException ThorlabsLTStage.move_y_abs(positioner_system, 21mm)
    end


    @safetestset "movement_limits_in_z_axis" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        @test ThorlabsLTStage.get_pos(positioner_system) == [0m, 0m, 0m]
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException ThorlabsLTStage.move_z_rel(positioner_system, -1mm)
        @test_throws ErrorException ThorlabsLTStage.move_z_rel(positioner_system, 151mm)
        ThorlabsLTStage.move_z_abs(positioner_system, 31mm)

        ThorlabsLTStage.home(positioner_system)
        ThorlabsLTStage.set_limits(positioner_system, (0m, 0m, 0m), (0.03m, 0.03m, 0.03m))
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0mm, 0mm, 0mm), (30mm, 30mm, 30mm))
        @test_throws ErrorException ThorlabsLTStage.move_z_abs(positioner_system, 31mm)
    end

    @safetestset "reset_limits" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        @test ThorlabsLTStage.get_limits(positioner_system) == ((0m, 0m, 0m), (150mm, 150mm, 150mm))
        ThorlabsLTStage.set_limits_x(positioner_system, 0m, 0.03m)
        ThorlabsLTStage.set_limits_y(positioner_system, 0m, 0.03m)
        ThorlabsLTStage.set_limits_z(positioner_system, 0m, 0.03m)
        @test ThorlabsLTStage.get_limits(positioner_system) == ((0m, 0m, 0m), (30mm, 30mm, 30mm))

        ThorlabsLTStage.reset_limits(positioner_system)
        @test ThorlabsLTStage.get_limits_x(positioner_system) == (0m, 150mm)
        @test ThorlabsLTStage.get_limits_y(positioner_system) == (0m, 150mm)
        @test ThorlabsLTStage.get_limits_z(positioner_system) == (0m, 150mm)
    end

    @safetestset "get_and_set_origin" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        ThorlabsLTStage.move_xyz(positioner_system, 11mm, 12mm, 13mm)
        @test ThorlabsLTStage.get_origin(positioner_system) == [0mm, 0mm, 0mm]
        ThorlabsLTStage.set_origin(positioner_system)
        @test ThorlabsLTStage.get_origin(positioner_system) == [11mm, 12mm, 13mm]
    end

    @safetestset "coordinate_change_with_new_origin" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        ThorlabsLTStage.move_xyz(positioner_system, 10mm, 10mm, 10mm)
        @test ThorlabsLTStage.get_pos(positioner_system) == [10mm, 10mm, 10mm]
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.x) == 10mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.y) == 10mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.z) == 10mm

        ThorlabsLTStage.set_origin(positioner_system)
        ThorlabsLTStage.move_xyz(positioner_system, 1mm, 2mm, 3mm)
        @test ThorlabsLTStage.get_pos(positioner_system) == [1mm, 2mm, 3mm]
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.x) == 11mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.y) == 12mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.z) == 13mm
    end

    @safetestset "move_to_origin" begin
        using ..SetupTestFakePs
        positioner_system = ThorlabsLTStage.initialize(ThorlabsLTStage.FakePS_3D)

        ThorlabsLTStage.move_xyz(positioner_system, 4mm, 5mm, 6mm)
        ThorlabsLTStage.set_origin(positioner_system)
        ThorlabsLTStage.move_xyz(positioner_system, 1mm, 2mm, 3mm)
        ThorlabsLTStage.move_to_origin(positioner_system)
        @test ThorlabsLTStage.get_pos(positioner_system) == [0mm, 0mm, 0mm]
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.x) == 4mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.y) == 5mm
        @test ThorlabsLTStage.get_intrinsic_position(positioner_system.z) == 6mm
    end
end
