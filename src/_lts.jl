stages(lts::LTS_3D) = (lts.x, lts.y, lts.z)

function close!(lts::T) where T <: LTS
    s = stages(lts)
    map(close!, s)

    return nothing
end

function limits(lts::T) where T <: LTS
    s = stages(lts)
    return map(x->lower_limit(x)*m, s), map(x->upper_limit(x)*m, s)
end


function limits!(lts::T, lower, upper) where T <: LTS
    s = stages(lts)
    num_stages = length(s)
    length(lower) != num_stages && error("Expected $(num_stages) elements in $lower")
    length(upper) != num_stages && error("Expected $(num_stages) elements in $upper")
    for i in 1:num_stages
        set_limits(s[i], lower[i], upper[i])
    end

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

function Base.show(io::IO, ::MIME"text/plain", lts::T) where T <: LTS
   println(io, "Thorlabs LTS")
   function p_stage(io, s)
       print(io, " ")
       Base.show(io, s)
       println() 
   end
   p_stage(io, lts.x)
   p_stage(io, lts.y)
   p_stage(io, lts.z)
end

function set_origin(lts::LTS_3D)
    map(set_origin, stages(lts))
    return nothing
end

function get_origin(lts::LTS_3D)
    return [map(get_origin, stages(lts))...]
end
