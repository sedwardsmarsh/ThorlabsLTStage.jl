# initialize the python library
lts_lib = nothing
function init_python_lib()
    global lts_lib = pyimport("ThorlabsLTStage.communication")
end

# In the C backend, this method updates the device with stored settings. 
# This functionality is handeled for us in the python backend. 
LoadSettings(serial::String) = true

# This functionality is handeled for us in the python backend.
LoadNamedSettings(serial::String, stage_name::String) = true

# starts polling communication.
# This functionality is handeled for us in the python backend.
Poll(serial::String, milliseconds::Int) = true

# clears the device message queue. 
# This functionality is not available to us in the python backend.
ClearQueue(serial::String) = true