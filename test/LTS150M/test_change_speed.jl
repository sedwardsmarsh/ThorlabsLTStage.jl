using Test
using Unitful
using ThorlabsLTStage

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"

@info "This test repeats motion on a PositionerSystem so as to validate run without erroring"

ps = ThorlabsLTStage.initialize(PositionerSystem)
stages = ThorlabsLTStage.get_stages(ps)
loops = 1:3
@testset "Chaning velocity and acceleration" begin
    for i in loops
        println("Beginning loop $i------------------")
        vel = 3
        accel = 5
        println("Setting velocity and acceleration to: $vel, $accel")
        for stage in stages
            ThorlabsLTStage.set_home_velocity(stage, vel)
            ThorlabsLTStage.SetVelParams(stage.serial, accel, vel)
        end
        println("Set velocity and acceleration to: $vel, $accel")
        println("Initial homing sequence beginning")
        ThorlabsLTStage.home(ps)
        ThorlabsLTStage.set_origin(ps)
        println("Initial homing sequence complete")
        ThorlabsLTStage.move_xyz(ps, 5u"mm", 5u"mm", 5u"mm")
        ThorlabsLTStage.home(ps)
        println("Done moving with velocity and acceleration of: $vel, $accel")

        vel = 10
        accel = 10
        println("Setting velocity and acceleration to: $vel, $accel")
        for stage in stages
            ThorlabsLTStage.set_home_velocity(stage, vel)
            ThorlabsLTStage.SetVelParams(stage.serial, accel, vel)
        end
        println("Set velocity and acceleration to: $vel, $accel")
        ThorlabsLTStage.move_xyz(ps, 10u"mm", 10u"mm", 10u"mm")
        ThorlabsLTStage.home(ps)
        println("Done moving with velocity and acceleration of: $vel, $accel")

        vel = 15
        accel = 12
        println("Setting velocity and acceleration to: $vel, $accel")
        for stage in stages
            ThorlabsLTStage.set_home_velocity(stage, vel)
            ThorlabsLTStage.SetVelParams(stage.serial, accel, vel)
        end
        println("Set velocity and acceleration to: $vel, $accel")
        ThorlabsLTStage.move_xyz(ps, 15u"mm", 15u"mm", 15u"mm")
        ThorlabsLTStage.home(ps)
        println("Done moving with velocity and acceleration of: $vel, $accel")

        vel = 20
        accel = 20
        println("Setting velocity and acceleration to: $vel, $accel")
        for stage in stages
            ThorlabsLTStage.set_home_velocity(stage, vel)
            ThorlabsLTStage.SetVelParams(stage.serial, accel, vel)
        end
        println("Set velocity and acceleration to: $vel, $accel")
        ThorlabsLTStage.move_xyz(ps, 50u"mm", 50u"mm", 50u"mm")
        ThorlabsLTStage.home(ps)
        println("Done moving with velocity and acceleration of: $vel, $accel")
        println("Finishing loop $i------------------")
    end
end

ThorlabsLTStage.terminate(ps)