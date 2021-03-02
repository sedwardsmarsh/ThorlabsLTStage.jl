module ThorlabsLTStage


using TcpInstruments: Configuration#, create_aliases
#import TcpInstruments

export 

    get_config,
    load_config,
    create_config,
    edit_config,
    backend,
    load_python,

    initialize,
    initialize_lts,
    ThorlabsLTS150,
    move_x_abs,
    move_y_abs,
    move_z_abs,
    move_x_rel,
    move_y_rel,
    move_z_rel,
    move_xyz,
    pos_xyz,
    pos_x,
    pos_y,
    pos_z,
    home,
    home_x,
    home_y,
    home_z,
    set_limits,
    get_limits,
    get_limits_x,
    get_limits_y,
    get_limits_z,
    clear_limits


include("config.jl")
include("models.jl")

using PyCall
include("python.jl")
include("lts150.jl")

#include("lts_c_binding.jl")

function __init__()
    load_config()
    if backend() == "python"
        init_python_lib()
    end
end

end
