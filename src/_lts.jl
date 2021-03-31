stages(lts::LTS_3D) = (lts.x, lts.y, lts.z)

function close!(lts::T) where T <: LTS
    s = stages(lts)
    map(close!, s)

    return nothing
end

function limits(lts::T) where T <: LTS
    s = stages(lts)
    return map(lower_limit, s), map(upper_limit, s)
end

function limits!(lts::LTS_2D, lower, upper)
    limits!(lts.x_stage, lower[1], upper[1])
    limits!(lts.y_stage, lower[2], upper[2])

    return nothing
end

function limits!(lts::LTS_3D, lower, upper)
    limits!(lts.x_stage, lower[1], upper[1])
    limits!(lts.y_stage, lower[2], upper[2])
    limits!(lts.z_stage, lower[3], upper[3])

    return nothing
end

function move(lts::LTS_3D, x, y, z; move_func=move_abs!)
    move_func(lts.x, x; block=false)
    move_func(lts.y, y; block=false)
    move_func(lts.z, z; block=false)
    pause(lts.x, x)
    pause(lts.y, y)
    pause(lts.z, z)

    return nothing
end

home_xyz(lts::LTS_3D) = move(lts, 0, 0, 0)

pos(lts::T) where T <:  LTS = [map(pos, stages(lts))...]

reset_limits(lts::T) where T <: LTS = map(reset_limits, stages(lts))
