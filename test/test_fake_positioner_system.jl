using Test
using SafeTestsets


module SetupTestFakePs
    using Unitful: m, mm
    export m, mm
end


@testset "test_fake_positioner_system" begin
    @safetestset "move_along_x_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)
        home(ps)

        move_x_abs(ps, 0.15m)
        @test get_pos_x(ps) == 150mm

        move_x_rel(ps, -1mm)
        @test get_pos_x(ps) == 149mm
    end


    @safetestset "move_along_y_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)
        home(ps)

        move_y_abs(ps, 0.15m)
        @test get_pos_y(ps) == 150mm

        move_y_rel(ps, -1mm)
        @test get_pos_y(ps) == 149mm
    end


    @safetestset "move_along_z_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)
        home(ps)

        move_z_abs(ps, 0.15m)
        @test get_pos_z(ps) == 150mm

        move_z_rel(ps, -1mm)
        @test get_pos_z(ps) == 149mm
    end

    
    @safetestset "move_along_all_three_axes" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        move_xyz(ps, 14mm, 15mm, 16mm)
        @test get_pos(ps) == [14mm, 15mm, 16mm]

        home_x(ps)
        home_y(ps)
        home_z(ps)
        @test get_pos(ps) == [0mm, 0mm, 0mm]
    end

    @safetestset "invalid_limits" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        @test_throws ErrorException set_lower_limit(ps.x, -1mm)
        @test_throws ErrorException set_upper_limit(ps.x, 151mm)
        @test_throws ErrorException set_limits(ps.x, 10mm, -10mm)

        @test_throws ErrorException ThorlabsLTStage.set_intrinsic_lower_limit(ps.x, -1mm)
        @test_throws ErrorException ThorlabsLTStage.set_intrinsic_upper_limit(ps.x, 151mm)
        @test_throws ErrorException ThorlabsLTStage.set_intrinsic_limits(ps.x, 40mm, 30mm)
        ThorlabsLTStage.set_intrinsic_limits(ps.x, 30mm, 40mm)
        @test ThorlabsLTStage.get_intrinsic_limits(ps.x) == (30mm, 40mm)
    end


    @safetestset "movement_limits_in_x_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        @test get_pos(ps) == [0m, 0m, 0m]
        @test get_limits(ps) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException move_x_rel(ps, -1mm)
        @test_throws ErrorException move_x_rel(ps, 151mm)
        move_x_abs(ps, 11mm)

        home(ps)
        set_limits(ps, (0m, 0m, 0m), (0.01m, 0.01m, 0.01m))
        @test get_limits(ps) == ((0mm, 0mm, 0mm), (10mm, 10mm, 10mm))
        @test_throws ErrorException move_x_abs(ps, 11mm)
    end


    @safetestset "movement_limits_in_y_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        @test get_pos(ps) == [0m, 0m, 0m]
        @test get_limits(ps) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException move_y_rel(ps, -1mm)
        @test_throws ErrorException move_y_rel(ps, 151mm)
        move_y_abs(ps, 21mm)

        home(ps)
        set_limits(ps, (0m, 0m, 0m), (0.02m, 0.02m, 0.02m))
        @test get_limits(ps) == ((0mm, 0mm, 0mm), (20mm, 20mm, 20mm))
        @test_throws ErrorException move_y_abs(ps, 21mm)
    end


    @safetestset "movement_limits_in_z_axis" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        @test get_pos(ps) == [0m, 0m, 0m]
        @test get_limits(ps) == ((0m, 0m, 0m), (0.15m, 0.15m, 0.15m))
        @test_throws ErrorException move_z_rel(ps, -1mm)
        @test_throws ErrorException move_z_rel(ps, 151mm)
        move_z_abs(ps, 31mm)

        home(ps)
        set_limits(ps, (0m, 0m, 0m), (0.03m, 0.03m, 0.03m))
        @test get_limits(ps) == ((0mm, 0mm, 0mm), (30mm, 30mm, 30mm))
        @test_throws ErrorException move_z_abs(ps, 31mm)
    end

    @safetestset "reset_limits" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        @test get_limits(ps) == ((0m, 0m, 0m), (150mm, 150mm, 150mm))
        set_limits_x(ps, 0m, 0.03m)
        set_limits_y(ps, 0m, 0.03m)
        set_limits_z(ps, 0m, 0.03m)
        @test get_limits(ps) == ((0m, 0m, 0m), (30mm, 30mm, 30mm))

        reset_limits(ps)
        @test get_limits_x(ps) == (0m, 150mm)
        @test get_limits_y(ps) == (0m, 150mm)
        @test get_limits_z(ps) == (0m, 150mm)
    end

    @safetestset "positioner_outside_of_limits" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        set_limits(ps, (20mm, 20mm, 20mm), (30mm, 30mm, 30mm))
        @test_throws ErrorException move_xyz(ps, 15mm, 15mm, 15mm)

        # positioner can move from outside the limits to inside the limits
        move_xyz(ps, 25mm, 25mm, 25mm)
    end

    @safetestset "get_and_set_origin" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        move_xyz(ps, 11mm, 12mm, 13mm)
        @test get_origin(ps) == [0mm, 0mm, 0mm]
        set_origin(ps)
        @test get_origin(ps) == [11mm, 12mm, 13mm]
    end

    @safetestset "coordinate_change_with_new_origin" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        move_xyz(ps, 10mm, 10mm, 10mm)
        @test get_pos(ps) == [10mm, 10mm, 10mm]
        @test ThorlabsLTStage.get_intrinsic_position(ps.x) == 10mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.y) == 10mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.z) == 10mm

        set_origin(ps)
        move_xyz(ps, 1mm, 2mm, 3mm)
        @test get_pos(ps) == [1mm, 2mm, 3mm]
        @test ThorlabsLTStage.get_intrinsic_position(ps.x) == 11mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.y) == 12mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.z) == 13mm
    end

    @safetestset "move_to_origin" begin
        using ..SetupTestFakePs
        using ThorlabsLTStage
        ps = initialize(ThorlabsLTStage.FakePS_3D)

        move_xyz(ps, 4mm, 5mm, 6mm)
        set_origin(ps)
        move_xyz(ps, 1mm, 2mm, 3mm)
        move_to_origin(ps)
        @test get_pos(ps) == [0mm, 0mm, 0mm]
        @test ThorlabsLTStage.get_intrinsic_position(ps.x) == 4mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.y) == 5mm
        @test ThorlabsLTStage.get_intrinsic_position(ps.z) == 6mm
    end
end
