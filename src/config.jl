const lts_config = Configuration.Config(".lts_stage.yml")

function load_config()
    Configuration.load_config(lts_config)
    create_aliases(lts_config; ignore=["backend"])
end

function get_config()
    return Configuration.get_config(lts_config)
end

function create_config(;dir=homedir())
    Configuration.create_config(lts_config; dir=dir)
end

function edit_config()
    Configuration.edit_config(lts_config)
end

function backend(;v=true) 
    b = get(get_config(), "backend", "None")
    if b == "None" && v
        @info """
        You have no backend chosen. Please enter in your $(lts_config.name) config file:
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
