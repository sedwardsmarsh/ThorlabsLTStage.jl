using Pkg

function load_python_venv()
    ENV["PYTHON"] = "/usr/bin/python3"
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end
