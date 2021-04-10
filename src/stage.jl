include("_stage.jl")

get_limits(s::Stage) = limits(s) .* m

function set_limits(s::Stage, min::Unitful.Length, max::Unitful.Length)
    limits!(s, raw_meters(min), raw_meters(max))
end

home(s::Stage) = home!(s)

pos(s::Stage) = position(s)

get_max_velocity(st::Stage) = velocity(st) * mm/s

set_max_velocity(st::Stage, max::Unitful.Velocity) = velocity!(st, ustrip(max --> mm/s))

get_max_acceleration(st::Stage) = acceleration(st) * mm/s^2

set_max_acceleration(st::Stage, max::Unitful.Acceleration) = acceleration!(st, ustrip(max --> mm/s^2))

move_abs(s::Stage, position::Unitful.Length) = move_abs!(s, raw_meters(position))

move_rel(s::Stage, position::Unitful.Length) = move_rel!(s, raw_meters(position))

reset_limits(stage::Stage) = limits!(stage, stage.min_pos, stage.max_pos)