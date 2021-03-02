using Pkg

function load_python()
    ENV["PYTHON"] = backend()
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end
