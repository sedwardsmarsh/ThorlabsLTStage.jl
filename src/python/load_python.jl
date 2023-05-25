using Pkg

function find_python3_path()
    if Base.Sys.iswindows()
        ENV["PYTHON"] = readchomp(`where python`)
    elseif Base.Sys.islinux()
        ENV["PYTHON"] = readchomp(`which python3`)
    end
end

function load_python_venv()
    find_python3_path()
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end
