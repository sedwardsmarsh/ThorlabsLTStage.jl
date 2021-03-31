function LTS()
    serials = GetDeviceList()
    num_stages = length(serials)
    if num_stages == 0
        return LTS(Stage(), Stage(), Stage())
    elseif num_stages == 3
        x, y, z = serials

        x_stage = Stage(x)
        println("X Stage: $(x_stage.serial) $(x_stage.info)")

        y_stage = Stage(y)
        println("Y Stage: $(y_stage.serial) $(y_stage.info)")

        z_stage = Stage(z)
        println("Z Stage: $(z_stage.serial) $(z_stage.info)")

        return LTS(x_stage, y_stage, z_stage)
    else
        error("$num_stages unexpectedly found: $serials")
    end
end

function move(lts::LTS, x, y, z)
    move(lts.x_stage, x; block=false)
    move(lts.y_stage, y; block=false)
    move(lts.z_stage, z; block=false)
    pause(lts.x_stage, x)
    pause(lts.y_stage, y)
    pause(lts.z_stage, z)
end

function limits(lts::LTS)
    s = stages(lts)
    return map(lower_limit, s), map(upper_limit, s)
end

function limits!(lts::LTS, lower, upper)
    limits!(lts.x_stage, lower[1], upper[1])
    limits!(lts.y_stage, lower[2], upper[2])
    limits!(lts.z_stage, lower[3], upper[3])
end

set_limits(lts::LTS, lower, upper) = limits!(lts, lower, upper)

get_limits(lts::LTS) = limits(lts)

reset_limits(lts::LTS) = map(reset_limits, stages(lts))

function close(lts::LTS)
    close(lts.x_stage)
    close(lts.y_stage)
    close(lts.z_stage)
    return true
end

function move_xyz(lts::LTS, x, y, z)
    move(lts, x, y, z)
end

