mutable struct Stage
    stage
end

function move(s::Stage, pos; block=true) 
    s.stage.move(pos) 
    block && pause(s)
end

home(s::Stage) = s.stage.home()

pos(s::Stage) = s.stage.pos()

get_limits(s::Stage) = s.stage.get_limits()

set_limits(s::Stage, min, max) = s.stage.set_limits(min, max)

get_max_velocity(s::Stage) = s.stage.get_max_velocity()

set_max_velocity(s::Stage, max) = s.stage.set_max_velocity(max)

is_moving(s::Stage) = s.stage.is_moving

function pause(s)
    while is_moving(s)
        sleep(0.1)
    end
end

Stage() = Stage("lts_lib.Stage()")

function load(s::Stage, serial)
    s.stage.init(serial)
    s.stage.print_info()
end

# Begin LTS150

abstract type LTS150 end

struct LTS150_2D <: LTS150
    x
    y
end

struct LTS150_3D <: LTS150
    x
    y
    z
end

struct LTS150_5D <: LTS150
    x
    y
    z
    a
    b
end

function initialize(::Type{T}) where T <: LTS150
    !Sys.iswindows() && error("Windows is needed to connect to ThorlabsLTS150")
    lts_lib == nothing && error("Call ThorlabsLTStage.load_config()")
    stages = get(get_config(), "ThorlabsLTS150", Dict())
    if isempty(stages)
        device_list = get_connected_stages()
        return LTS150(map(serial->load(Stage(), serial), device_list)...)
    end

    x_stage = stages["x"]
    y_stage = stages["y"]
    z_stage = stages["z"]
    device_list = map(s->s["serial"], [x_stage, y_stage, z_stage])
    lts = LTS150(map(serial->load(Stage(), serial), device_list)...)

    function setup(stage, stage_config)
        # Set position limits from config
        min_pos, max_pos = get_limits(stage)
        min_pos = get(stage_config, "min_position", min_pos)
        max_pos = get(stage_config, "max_position", max_pos)
        set_limits(stage, min_pos, max_pos)

        # Set velocity limits from config
        max_vel = get(
            stage_config, "max_velocity", get_max_velocity(stage)
        )
        set_max_velocity(stage, max_vel)

        # Set acceleration limits from config
        max_acc = get(
            stage_config, "max_acceleration", get_max_acceleration(stage)
        )
        set_max_acceleration(stage, max_acc)
    end

    setup(lts.x, x_stage)
    setup(lts.y, y_stage)
    setup(lts.z, z_stage)
    return lts
end
    

is_moving(s::LTS150_3) = any(is_moving.([s.x, s.y, s.z]))
