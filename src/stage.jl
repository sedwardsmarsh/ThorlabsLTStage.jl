include("_stage.jl")

const Speed = Union{typeof(mm/s), typeof(m/s)}

get_limits(s::Stage) = limits(s)

function set_limits(s::Stage, min::Unitful.Length, max::Unitful.Length) 
    limits!(s, raw_meters(min), raw_meters(max))
end

home(s::Stage) = home!(s)

pos(s::Stage) = position(s)

get_max_velocity(s::Stage) = velocity(s) * mm/s

set_max_velocity(s::Stage, max::Speed) = velocity!(s, ustrip(max --> mm/s))

get_max_acceleration(s::Stage) = velocity(s) * mm/s

set_max_acceleration(s::Stage, max::typeof(mm/s^2)) = acceleration!(s, ustrip(max))

move_abs(s::Stage, position::Unitful.Length) = move_abs!(s, raw_meters(position))

move_rel(s::Stage, position::Unitful.Length) = move_rel!(s, raw_meters(position))

reset_limits(stage::Stage) = limits!(stage, stage.min_pos, stage.max_pos)
