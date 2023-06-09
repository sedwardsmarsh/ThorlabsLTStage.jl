using Test
using Unitful
using ThorlabsLTStage
# ThorlabsLTStage.init_python_lib()


@testset "Testset" begin
    ps = ThorlabsLTStage.initialize(PositionerSystem)

    for i in 1:3
        println("LOOP COUNT $i >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        # set the serial numbers for your stages in .positioner_system_config.yml!
        
        # set stage min/max position in hardware
        for stage in ThorlabsLTStage.get_stages(ps)
            ThorlabsLTStage.set_stage_min_max_pos(stage, 0u"mm", 149.99u"mm")
        end

        # set stage min/max position in Julia
        ThorlabsLTStage.set_limits(ps, (0u"mm", 0u"mm", 0u"mm"), (149.99u"mm", 149.99u"mm", 149.99u"mm"))

        ThorlabsLTStage.SetVelParams(ps.x.serial, 20, 20)
        ThorlabsLTStage.SetVelParams(ps.y.serial, 20, 20)
        ThorlabsLTStage.SetVelParams(ps.z.serial, 20, 20)

        @info "STARTING TEST >>>>>>>>>>>"

        # sleep(0.5)
        # set stage home parameters
        ThorlabsLTStage.set_home_velocity(ps.x, 5)
        ThorlabsLTStage.set_home_velocity(ps.y, 5)
        ThorlabsLTStage.set_home_velocity(ps.z, 5)
        x_vel = ThorlabsLTStage.get_home_velocity(ps.x)
        y_vel = ThorlabsLTStage.get_home_velocity(ps.y)
        z_vel = ThorlabsLTStage.get_home_velocity(ps.z)

        ThorlabsLTStage.true_home(ps.x)
        println("X true_home -- > Y stage")
        ThorlabsLTStage.true_home(ps.y)
        println("Y true_home -- > Z stage")
        ThorlabsLTStage.true_home(ps.z)
        println("Z true_home -- > All Done")
        @info "Python post true_home() all stages"

        read_origin = get_origin(ps)
        println("Get_origin after Julia home(): $read_origin")

        println(ThorlabsLTStage.get_pos_x(ps))
        println(ThorlabsLTStage.get_pos_y(ps))
        println(ThorlabsLTStage.get_pos_z(ps))

        home(ps)
        @info "JULIA HOME >>>>>>>>>>>>>>>>>"

        set_origin(ps)
        read_origin = get_origin(ps)
        println("Get_origin: $read_origin")
        @info "Start moving >>>>>>>>>>>>>>>>>>>>"

        @testset "test case: close to beginning position" begin
            println("Move X to 1.5987 mm")
            move_x_abs(ps, 1.5987u"mm")
            measured_x_pos = get_pos_x(ps)
            @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 1.5987u"mm" + get_origin(ps)[1], digits=3)
    
            println("Move Y to 1.699 mm")
            move_y_abs(ps, 1.699u"mm")
            measured_y_pos = get_pos_y(ps)
            @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 1.699u"mm" + get_origin(ps)[2], digits=3)
    
            println("Move Z to 20.5 mm")
            move_z_abs(ps, 20.5u"mm")
            measured_z_pos = get_pos_z(ps)
            @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 20.5u"mm" + get_origin(ps)[3], digits=3)
        end
    
        @testset "Test Case: close to mid position" begin
            println("Move X to 75.0 mm")
            move_x_abs(ps, 75.0u"mm")
            measured_x_pos = get_pos_x(ps)
            @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 75.0u"mm" + get_origin(ps)[1], digits=3)
    
            println("Move Y to 64.378 mm")
            move_y_abs(ps, 64.378u"mm")
            measured_y_pos = get_pos_y(ps)
            @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 64.378u"mm" + get_origin(ps)[2], digits=3)
    
            println("Move Z to 23.12345 mm")
            move_z_abs(ps, 23.12345u"mm")
            measured_z_pos = get_pos_z(ps)
            @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 23.12345u"mm" + get_origin(ps)[3], digits=3)
        end
    
    
        @testset "Test Case: close to end position" begin
            println("Move X to 149.002 mm")
            move_x_abs(ps, 149.002u"mm")
            measured_x_pos = get_pos_x(ps)
            @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 149.002u"mm" + get_origin(ps)[1], digits=3)
    
            println("Move Y to 149.9002 mm")
            move_y_abs(ps, 149.9002u"mm")
            measured_y_pos = get_pos_y(ps)
            @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 149.9002u"mm" + get_origin(ps)[2], digits=3)
    
            println("Move Z to 149.6000009 mm")
            move_z_abs(ps, 149.6000009u"mm")
            measured_z_pos = get_pos_z(ps)
            @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 149.6000009u"mm" + get_origin(ps)[3], digits=3)
        end
    
        @testset "test case: back to beginning position" begin
            println("Move X to 1 mm")
            move_x_abs(ps, 1u"mm")
            measured_x_pos = get_pos_x(ps)
            @test Base.round(u"mm", measured_x_pos, digits=3) == Base.trunc(u"mm", 1u"mm" + get_origin(ps)[1], digits=3)
    
            println("Move Y to 0.5 mm")
            move_y_abs(ps, 0.5u"mm")
            measured_y_pos = get_pos_y(ps)
            @test Base.round(u"mm", measured_y_pos, digits=3) == Base.trunc(u"mm", 0.5u"mm" + get_origin(ps)[2], digits=3)
    
            println("Move Z to 0 mm")
            move_z_abs(ps, 0u"mm")
            measured_z_pos = get_pos_z(ps)
            @test Base.round(u"mm", measured_z_pos, digits=3) == Base.trunc(u"mm", 0u"mm" + get_origin(ps)[3], digits=3)
        end
    end
    terminate(ps)
    @info "Terminated PositionerSystem"
end