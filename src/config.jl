using InstrumentConfig

const positioner_system_config = InstrumentConfig.Config(".positioner_system_config.yml", @__MODULE__)

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

