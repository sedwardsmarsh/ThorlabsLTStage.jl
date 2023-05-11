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

# builds an internal collection of all devices found on 
# the USB that are not currently open. Return zero for now,
# since all connected devices are always available. 
# TODO: mark devices as closed or open
function BuildDeviceList()
    return []
end

# returns the length of the device list.
function GetDeviceListSize()
    return length(GetDeviceList())
end

# returns a vector of strings of the connected device serials.
function GetDeviceList()
    return lts_lib.get_available_stage_serials()
end

# this function returns true if the device is connected, false if it is not 
# connected. We can verify this by requesting the serial numbers of all 
# connected devices.
# TODO: change python backend to allow checking which stages are connected
check_is_connected(serial::String) = lts_lib.is_stage_connected(serial)

# this function connects to the stage with the corresponding serial number.
connect_device(serial::String) = 0

# this function disconnects from the stage with the corresponding serial number.
disconnect_device(serial::String) = 0

# In the C backend, this function enables the channel corresponding to the 
# serial number. However, this is handeled by the python backend for us.
Enable(serial::String) = 0
