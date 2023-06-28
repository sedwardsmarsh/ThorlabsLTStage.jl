using Pkg

function find_python3_path()
    if Base.Sys.iswindows()
        ENV["PYTHON"] = _get_latest_python_path(`where python`)
    elseif Base.Sys.islinux()
        ENV["PYTHON"] = _get_latest_python_path(`which python3`)
    end
end

function _get_latest_python_path(python_command::Cmd)
    all_python_paths = _get_all_python_paths(python_command)
    filter!(path -> _is_valid_python_path(path) , all_python_paths)
    sort!(all_python_paths, lt=_compare_paths_by_version)
    return all_python_paths[1]
end

_get_all_python_paths(python_command::Cmd) = split(readchomp(python_command), "\r\n")
_is_valid_python_path(path::Any) = occursin(r"(.*Python\d+\\+python\.exe)|(.*\/python(\d)?)", path)

function _compare_paths_by_version(path_a::SubString{String}, path_b::SubString{String})
    a_version_number = parse(Int, match(r"(?<=Python)\d+", path_a).match)
    b_version_number = parse(Int, match(r"(?<=Python)\d+", path_b).match)
    return a_version_number > b_version_number
end

function load_python()
    find_python3_path()
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end