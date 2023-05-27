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


# returns the stage's current position in device units. 
function GetPos(serial::String)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.get_stage_position_in_device_units(stage)
end

# set the move absolute position. this function does nothing because the python 
# backend handles this for us
SetMoveAbsolutePosition(serial::String, pos::Int64) = 0

# Moves the stage to the position defined in the SetMoveAbsolute command. 
MoveAbsolute(serial::String) = 0

# move the stage to the specified absolute position.
function MoveAbs(serial::String, pos::Int64)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.move_stage_absolute(stage, pos)
end

# move the stage to the specified position, pos (in device units). There is no
# difference between this method and and absolute movement.
MoveTo(serial::String, pos::Int64) = MoveAbs(serial, pos)

# Gets the absolute minimum and maximum travel range constants for the current 
# stage. This functionality is not available in python currently.
GetMotorTravelLimits(serial::String) = (0u"mm", 150u"mm")

# Gets the minimum position for the stage, in device units
get_stage_axis_min_pos(serial::String) = 0

# Gets the maxiumum position for the stage, in device units. This functionality 
# is not supported by the python backend, so we return 150mm in device units.
# The value returned # is derived from 1mm == 409,600 device units (encoder 
# counts). 
get_stage_axis_max_pos(serial::String) = 150 * 409600

# Sets the minimum and maximum position limits for the stage. This functionality # is not available through the python backend, so 0 is returned.
set_stage_axis_min_max_pos(serial::String, min_pos::Int, max_pos::Int) = 0

# Gets the move velocity parameters.
function GetVelParams(serial::String)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    acc = lts_lib.get_stage_velocity(stage)
    vel = lts_lib.get_stage_acceleration(stage)
    return acc[], vel[]
end

# Sets the move velocity parameters, in device units
function SetVelParams(serial::String, acc::Int, vel::Int)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    lts_lib.set_stage_acceleration(stage, acc)
    lts_lib.set_stage_velocity(stage, vel)
end

# Get the move velocity.
function GetVelocity(serial::String)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.get_stage_velocity(stage)
end

# Set the move velocity.
function SetVelocity(serial::String, vel::Int)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.set_stage_velocity(stage, vel)
end

# Get the move acceleration.
function GetAcceleration(serial::String)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.get_stage_acceleration(stage)
end

# Set the move acceleration.
function SetAcceleration(serial::String, acc::Int)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.set_stage_acceleration(stage, acc)
end

# Gets the hardware information from the device. The python backend doesn't 
# support this functionality, so we return zero.
GetHardwareInfo(serial::String) = 0

# verify the conversion type.
check_conversion_type(unit_enum::Int) = 0

# converts a device unit to a real world unit.
function GetDeviceUnitFromRealValue(serial::String, real::Float64, unit_enum::Int)
    global lts_lib
    if unit_enum == 0
        return lts_lib.convert_mm_to_device_units(real)
    elseif unit_enum == 1
        return lts_lib.convert_velocity_in_mm_to_device_units(real)
    elseif unit_enum == 2
        return lts_lib.convert_acceleration_in_mm_to_device_units(real)
    else
        error("unit_enum must be either 0 for position, 1 for speed, 2 for acceleration")
    end
end

# converts a real world to a device unit unit.
function GetRealValueFromDeviceUnit(serial::String, device_unit::Int, unit_enum::Int)
    global lts_lib
    if unit_enum == 0
        return lts_lib.convert_device_units_to_mm(device_unit)
    elseif unit_enum == 1
        return lts_lib.convert_velocity_in_device_units_to_mm(device_unit)
    elseif unit_enum == 2
        return lts_lib.convert_acceleration_in_device_units_to_mm(device_unit)
    else
        error("unit_enum must be either 0 for position, 1 for speed, 2 for acceleration")
    end
end

# converts device units to mm for position
function DeviceUnitToMillimeters(serial::String, device_unit::Int)
    return GetRealValueFromDeviceUnit(serial, device_unit, 0)
end

# converts mm to device units for position
function MillimetersToDeviceUnit(serial::String, mm::Float64)
    GetDeviceUnitFromRealValue(serial, mm, 0)
end

# converts m to device units for position
function MetersToDeviceUnit(serial::String, m::Float64)
    return MillimetersToDeviceUnit(serial, m * 1000)
end

# converts device units to m for position
function DeviceUnitToMeters(serial::String, device_unit::Int)
    return DeviceUnitToMillimeters(serial, device_unit) / 1000
end

# converts mm/s to device units/s
function VelocityToDeviceUnit(serial::String, vel::Float64)
    return GetDeviceUnitFromRealValue(serial, vel, 1)
end

# converts device units/s to mm/s
function DeviceUnitToVelocity(serial::String, device_unit::Int)
    return GetRealValueFromDeviceUnit(serial, device_unit, 1)
end

# converts mm/s/s to device units/s/s
function AccelerationToDeviceUnit(serial::String, acc::Float64)
    return GetDeviceUnitFromRealValue(serial, acc, 2)
end

# converts device units/s/s to mm/s/s
function DeviceUnitToAcceleration(serial::String, device_unit::Int)
    return GetRealValueFromDeviceUnit(serial, device_unit, 2)
end

# blocks waiting for a message to return from the stage. this is not 
# implemented in the python backend, so we return 0.
WaitForMessage(serial::String) = 0

# resets the stage's home to be 0 at the minimum limit switch
function ResetHomePosition(serial::String)
    global lts_lib
    stage = lts_lib.STAGE_SERIAL_MAP[serial]
    return lts_lib.find_stage_home(stage)
end