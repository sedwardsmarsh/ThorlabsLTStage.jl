using Test
using Unitful
using ThorlabsLTStage

"""
Spec: 
1. Setup ./.positioner_system_config.yml with the serials of an x, y and z stage.
* Note, the stage limits and stage min/max position are set to [0mm, 149.99mm]. This was done to prevent an error where the stage limits were not equal for the range [0mm, 150mm].
* Note, the position value at home is stored to account for a very small offset. In these tests, this offset value is added to compensate.
"""

# set the serial numbers for your stages in .positioner_system_config.yml!
ps = ThorlabsLTStage.initialize(PositionerSystem)

# set stage min/max position in hardware
for stage in ThorlabsLTStage.get_stages(ps)
    ThorlabsLTStage.set_stage_min_max_pos(stage, 0u"mm", 149.99u"mm")
end

# set stage home parameters
home(ps)
set_origin(ps)

# set stage min/max position in Julia
ThorlabsLTStage.set_limits(ps, (0u"mm", 0u"mm", 0u"mm"), (149.99u"mm", 149.99u"mm", 149.99u"mm"))


sleep_amount = 0.2

# ==========================================================================================================================

@testset "test position rounding" begin

    @testset "test case: close to beginning position" begin
        println("Move X to 1.5 mm")
        move_x_abs(ps, 1.5u"mm")
        sleep(sleep_amount)
        measured_x_pos = get_pos_x(ps)
        @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 1.5u"mm" + get_origin(ps)[1], digits=3)

        println("Move Y to 1.6 mm")
        move_y_abs(ps, 1.6u"mm")
        sleep(sleep_amount)
        measured_y_pos = get_pos_y(ps)
        @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 1.6u"mm" + get_origin(ps)[2], digits=3)

        println("Move Z to 1.8 mm")
        move_z_abs(ps, 1.8u"mm")
        sleep(sleep_amount)
        measured_z_pos = get_pos_z(ps)
        @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 1.8u"mm" + get_origin(ps)[3], digits=3)
    end

    @testset "Test Case: close to mid position" begin
        println("Move X to 75.1 mm")
        move_x_abs(ps, 75.1u"mm")
        sleep(sleep_amount)
        measured_x_pos = get_pos_x(ps)
        @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 75.1u"mm" + get_origin(ps)[1], digits=3)

        println("Move Y to 64.3 mm")
        move_y_abs(ps, 64.3u"mm")
        sleep(sleep_amount)
        measured_y_pos = get_pos_y(ps)
        @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 64.3u"mm" + get_origin(ps)[2], digits=3)

        println("Move Z to 23.3 mm")
        move_z_abs(ps, 23.3u"mm")
        sleep(sleep_amount)
        measured_z_pos = get_pos_z(ps)
        @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 23.3u"mm" + get_origin(ps)[3], digits=3)
    end


    @testset "Test Case: close to end position" begin
        println("Move X to 149.002 mm")
        move_x_abs(ps, 149.002u"mm")
        sleep(sleep_amount)
        measured_x_pos = get_pos_x(ps)
        @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 149.002u"mm" + get_origin(ps)[1], digits=3)

        println("Move Y to 149.9002 mm")
        move_y_abs(ps, 149.9002u"mm")
        sleep(sleep_amount)
        measured_y_pos = get_pos_y(ps)
        @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 149.9002u"mm" + get_origin(ps)[2], digits=3)

        println("Move Z to 149.6000009 mm")
        move_z_abs(ps, 149.6000009u"mm")
        sleep(sleep_amount)
        measured_z_pos = get_pos_z(ps)
        @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 149.6000009u"mm" + get_origin(ps)[3], digits=3)
    end

    @testset "test case: back to beginning position" begin
        println("Move X to 1 mm")
        move_x_abs(ps, 1u"mm")
        sleep(sleep_amount)
        measured_x_pos = get_pos_x(ps)
        @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 1u"mm" + get_origin(ps)[1], digits=3)

        println("Move Y to 1 mm")
        move_y_abs(ps, 1u"mm")
        sleep(sleep_amount)
        measured_y_pos = get_pos_y(ps)
        @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 1u"mm" + get_origin(ps)[2], digits=3)

        println("Move Z to 1 mm")
        move_z_abs(ps, 1u"mm")
        sleep(sleep_amount)
        measured_z_pos = get_pos_z(ps)
        @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 1u"mm" + get_origin(ps)[3], digits=3)
    end

    terminate(ps)
    @info "Terminated PS --- end of test"
end