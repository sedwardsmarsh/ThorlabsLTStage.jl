include("_lts.jl")
include("lts3d.jl")

import InstrumentConfig: initialize,terminate

terminate(lts::T) where T <: LTS = close!(lts)

function LTS(serials = GetDeviceList())
    num_stages = length(serials)
    if num_stages == 0
        error("No stages detected")
    elseif num_stages == 3
        x, y, z = serials

        x_stage = Stage(x)
        println("X Stage: $(x_stage.serial) $(x_stage.info)")

        y_stage = Stage(y)
        println("Y Stage: $(y_stage.serial) $(y_stage.info)")

        z_stage = Stage(z)
        println("Z Stage: $(z_stage.serial) $(z_stage.info)")

        return LTS_3D(x_stage, y_stage, z_stage)
    else
        error("$num_stages unexpectedly found: $serials")
    end
end

function initialize(::Type{LTS})
    stages = get(get_config(), "ThorlabsLTS", Dict())
    if isempty(stages)
        return LTS()
    end

    x_stage = stages["x"]
    y_stage = stages["y"]
    z_stage = stages["z"]
    device_list = map(s->s["serial"], [x_stage, y_stage, z_stage])
    lts = LTS(device_list)

    setup(lts.x, x_stage)
    setup(lts.y, y_stage)
    setup(lts.z, z_stage)
    return lts
end

function setup(stage, stage_config)
    # Set position limits from config
    min_pos, max_pos = limits(stage)
    min_pos = get(stage_config, "min_position", min_pos)
    max_pos = get(stage_config, "max_position", max_pos)
    limits!(stage, min_pos, max_pos)

    # Set velocity limits from config
    max_vel = get(
        stage_config, "max_velocity", velocity(stage)
    )
    velocity!(stage, max_vel)

    # Set acceleration limits from config
    max_acc = get(
        stage_config, "max_acceleration", acceleration(stage)
    )
    acceleration!(stage, max_acc)
end
