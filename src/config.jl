using InstrumentConfig
using Preferences

const positioner_system_config = InstrumentConfig.Config(".positioner_system_config.yml", @__MODULE__)

set_alias(string::String) =  @set_preferences!("alias" => string)
get_alias() =  get_pref("alias")

## Creates preference for a LTStage named "name" with the arguments given
function set_stagekw(
    name::String;
    serial_number=missing,
    min_position=missing,
    max_position=missing,
    max_velocity=missing,
    max_acceleration=missing,
    position_accuracy=missing,
)
    dict = Dict{String, Any}()
    if (!ismissing(serial_number))
        push!(dict, "serial_number" => serial_number)
    end
    if (!ismissing(min_position))
        push!(dict, "min_position" => min_position)
    end
    if (!ismissing(max_position))
        push!(dict, "max_position" => max_position)
    end
    if (!ismissing(max_velocity))
        push!(dict, "max_velocity" => max_velocity)
    end
    if (!ismissing(max_acceleration))
        push!(dict, "max_acceleration" => max_acceleration)
    end
    if (!ismissing(position_accuracy))
        push!(dict, "position_accuracy" => position_accuracy)
    end
    @set_preferences!(name => dict)
end

## Creates a preference of name "key" with Dict with entries "pairs"
set_pref(key::String, pairs...) = @set_preferences!(key => Dict(pairs))

get_pref(key::String) = @load_preference key

has_pref(key::String) = @has_preference key

del_pref(prefs...) = @delete_preferences! prefs

function load_config()
    InstrumentConfig.load_config(positioner_system_config)
    create_aliases(positioner_system_config; ignore=["backend"])
    init_python_lib()
end

function get_config()
    return InstrumentConfig.get_config(positioner_system_config)
end

function create_config(;dir=homedir())
    InstrumentConfig.create_config(positioner_system_config; dir=dir)
end

function edit_config()
    InstrumentConfig.edit_config(positioner_system_config)
end

function backend(;v=true)
    b = get(get_config(), "backend", "None")
    if b == "None" && v
        @info """
        You have no backend chosen. Please enter in your $(positioner_system_config.name) config file:
            backend: python
        """
    end
    return b
end

function create_aliases(config; ignore=[])
    for (device, data) in config.config
        if device in ignore
            continue
        end
        device_type = nothing
        try
            device_type = eval(Symbol(device))
        catch e
            error("""
            $(config.loaded_file) contains device of name:
                $device

            This is not a valid device.

            For a list of available devices use `help> Instrument`
            """)
        end
        !(data isa Dict) && continue
        alias = get(data, "alias", "")
        isempty(alias) && continue
        @eval global const $(Symbol(alias)) = $(device_type)
        @eval export $(Symbol(alias))
        alias_print("$alias = $device")
    end
end

function alias_print(msg)
    printstyled("[ Aliasing: ", color = :blue, bold = true)
    println(msg)
end
