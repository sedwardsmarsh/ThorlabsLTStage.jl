using Test
using Unitful
using ThorlabsLTStage

@info "these tests will only pass if .positioner_system_config.yml contains the serials of the connected stages"
#testing variables
run_true_home = true
printPositionAndExit = false
num_iterations = 5

# initialize python backend
# ThorlabsLTStage.init_python_lib()

ps = ThorlabsLTStage.initialize(PositionerSystem)
println("PositionerSystem initialized.")

if printPositionAndExit
    print(ThorlabsLTStage.get_pos(ps))
    ThorlabsLTStage.terminate(ps)
    exit()
end

stages = ThorlabsLTStage.get_stages(ps)
if run_true_home
    home_function, hf = ThorlabsLTStage.true_home, "true/python home" 
else
    home_function, hf = ThorlabsLTStage.home, "julia home"
end
println(hf)

for i in range(1, num_iterations)
    @testset "Rehome test, Iteration $i" begin
        home_vel = 5
        vel = 18
        accel = 10
        println("Setting velocity and acceleration to: $vel, $accel")
        for stage in stages
            ThorlabsLTStage.set_home_velocity(stage, home_vel)
            ThorlabsLTStage.SetVelParams(stage.serial, accel, vel)
        end
        println("Set velocity and acceleration to: $vel, $accel")

        println("Initial homing sequence beginning")
        home_function(ps)
        ThorlabsLTStage.set_origin(ps)
        pos = ThorlabsLTStage.get_pos(ps)
        origin = [0, 0, 0]u"mm"
        println("Done moving to: $pos, expected: $origin")
        @test pos == origin

        new_origin = [10, 10, 10]u"mm"
        # offset = 10u"mm"
        println("Moving to new origin location at $new_origin")
        ThorlabsLTStage.move_xyz(ps, new_origin[1], new_origin[2], new_origin[3])
        # ThorlabsLTStage.move_xyz(ps, offset, offset, offset)
        pos = ThorlabsLTStage.get_pos(ps)
        println("Done moving to: $pos, expected: $new_origin")
        @test pos == new_origin

        println("Setting origin to $new_origin")
        ThorlabsLTStage.set_origin(ps)
        println("Origin set")

        new_pos = [30, 30, 30]u"mm"
        # offset = 30u"mm"
        println("Moving to another position at $new_pos")
        ThorlabsLTStage.move_xyz(ps, new_pos[1], new_pos[2], new_pos[3])
        # ThorlabsLTStage.move_xyz(ps, offset, offset, offset)
        pos = ThorlabsLTStage.get_pos(ps)
        println("Done moving to: $pos, expected: $new_pos")

        println("Homing to new home position located at $new_origin")
        home_function(ps)

        pos = ThorlabsLTStage.get_pos(ps)
        println("Done moving to: $pos, expected: $new_origin")
    end
end
println("PositionerSystem terminating...")
ThorlabsLTStage.terminate(ps)
println("PositionerSystem terminated.")