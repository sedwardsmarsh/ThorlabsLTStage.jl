# initialize the python library
lts_lib = nothing
function init_python_lib()
    global lts_lib = pyimport("ThorlabsLTStage.communication")
end

# builds an internal collection of all devices found on 
# the USB that are not currently open. Return zero for now,
# since all connected devices are always available. 
function BuildDeviceList()
    return []
end

# returns the length of the device list. Return zero for now,
# since all connected devices are always available. 
function GetDeviceListSize()
    return length(GetDeviceList())
end

# returns a vector of strings of the connected device serials.
function GetDeviceList()
    return lts_lib.get_available_stage_serials()
end