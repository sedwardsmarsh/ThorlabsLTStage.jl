# initialize the python library
lts_lib = nothing
function init_python_lib()
    global lts_lib = pyimport("ThorlabsLTStage.communication")
end