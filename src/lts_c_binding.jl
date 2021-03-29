using Libdl
using Pkg.Artifacts



const ISM_LIB = "Thorlabs.MotionControl.IntegratedStepperMotors.dll"
const DEFAULT_PATH = raw"C:\Program Files\Thorlabs\Kinesis"

function path()
    try
        return joinpath(artifact"kinesis", ISM_LIB) 
    catch
        @info "Cannot locate artifact"
        return joinpath(DEFAULT_PATH, ISM_LIB)
    end
end

const shared_lib = dlopen(path())

@info shared_lib

lib(x) = dlsym(shared_lib, x)

"""
Returns the number of microsteps in one milimeter for Thorlabs LTS150

"""
microsteps_per_mm() = 409600

"""
Returns the number of microsteps in one meter for Thorlabs LTS150

"""
microsteps_per_m() = microsteps_per_mm() * 1000

"""
Returns the number of microsteps in x meters for Thorlabs LTS150

"""
microsteps_per_m(x)::Int = x * microsteps_per_m()

BuildDeviceList() = ccall(lib("TLI_BuildDeviceList"), Int, ())

GetDeviceListSize() = ccall(lib("TLI_GetDeviceListSize"), Int, ())

function GetDeviceList()
    lts_identifier = 45 # Hard coded to only detect ThorlabsLTS
    BuildDeviceList()
    list_string = Ref{Cstring}()
    ccall(lib(:TLI_GetDeviceListByTypeExt), Int, (Ref{Cstring}, UInt32, Int64), list_string, 100, lts_identifier)
    serial_list = []
    p = ccall(:strtok, Cstring, (Ref{Cstring}, Cstring), list_string, ",")
    while p != C_NULL
        push!(serial_list, unsafe_string(p))
        p = ccall(:strtok, Cstring, (Cstring, Cstring), C_NULL, ",")
    end
    return serial_list
end

LoadSettings(serial::String) = ccall(lib(:ISC_LoadSettings), Bool, (Cstring,), serial)

LoadNamedSettings(serial::String, name) = ccall(lib(:ISC_LoadNamedSettings), Bool, (Cstring,Cstring), serial, name)

function OpenDevice(serial::String) 
    err = ccall(lib(:ISC_Open), Cshort, (Cstring,), serial)
    return err
end

Poll(serial, sec) = ccall(lib(:ISC_StartPolling), Int, (Cstring, Int), serial, sec)

Enable(serial) = ccall(lib(:ISC_EnableChannel), Cshort, (Cstring,), serial)

ClearQueue(serial) = ccall(lib(:ISC_ClearMessageQueue), Int, (Cstring,), serial)

MoveTo(serial::String, pos::Int) = ccall(lib(:ISC_MoveToPosition), Int, (Cstring,Int), serial, pos)

SetMoveAbs(serial::String, pos::Int) = ccall(lib(:ISC_SetMoveAbsolutePosition), Int, (Cstring,Int), serial, pos)

MoveAbs(serial::String) = ccall(lib(:ISC_MoveAbsolute), Int, (Cstring,), serial)

GetPos(serial) = ccall(lib(:ISC_GetPosition), Int, (Cstring,), serial)

const Word = UInt16
const Dword = UInt32
function GetHardwareInfo(serial)
    modelNo = Vector{UInt8}(undef, 256) # MAXHOSTNAMELEN
    sizeOfModelNo = sizeof(modelNo)

    type = Ref{Word}()
    numChannels = Ref{Word}()

    notes = Vector{UInt8}(undef, 256) # MAXHOSTNAMELEN
    sizeOfNotes = sizeof(notes)

    firmwareVersion = Ref{Dword}()
    hardwareVersion = Ref{Word}()
    modificationState = Ref{Word}()

    params= (serial, modelNo, sizeOfModelNo, type, numChannels, notes, sizeOfNotes, firmwareVersion, hardwareVersion, modificationState)

    err = ccall(
        lib(:ISC_GetHardwareInfo), Int,
        (Cstring, Ptr{UInt8}, Csize_t, Ref{Word}, Ref{Word}, Ptr{UInt8}, Csize_t, Ref{Dword}, Ref{Word}, Ref{Word},),
        serial, modelNo, sizeOfModelNo, type, numChannels, notes, sizeOfNotes, firmwareVersion, hardwareVersion, modificationState)

    modelNo[end] = 0 # ensure null-termination
    model = GC.@preserve modelNo unsafe_string(pointer(modelNo))

    notes[end] = 0 # ensure null-termination
    note = GC.@preserve notes unsafe_string(pointer(notes))

    return model, note
end

function check_conversion_type(unit_enum)
    if !(unit_enum in [0, 1, 2]) 
        error("unit_enum must be either 0 for position, 1 for speed, 2 for acceleration")
    end
end

function GetDeviceUnitFromRealValue(serial::String, real, unit_enum)
    check_conversion_type(unit_enum)
    device_unit = Ref{Cint}(0)
    err = ccall(lib(:ISC_GetDeviceUnitFromRealValue), Cshort, (Cstring, Cdouble, Ref{Cint}, Cint), serial, real, device_unit, unit_enum)
    err != 0 && error("Error code: $err")
    return device_unit[]
end

function GetRealValueFromDeviceUnit(serial::String, device_unit, unit_enum)
    check_conversion_type(unit_enum)
    real = Ref{Cdouble}(0)
    err = ccall(lib(:ISC_GetRealValueFromDeviceUnit), Cshort, (Cstring, Int, Ref{Cdouble}, Int), serial, device_unit, real, unit_enum)
    err != 0 && error("Error code: $err")
    return real[]
end

function DeviceUnitToMilimeters(serial::String, device_unit)
    return GetRealValueFromDeviceUnit(serial, device_unit, 0)
end

function MilimetersToDeviceUnit(serial::String, mm)
    GetDeviceUnitFromRealValue(serial, mm, 0)
end

function MetersToDeviceUnit(serial::String, m)
    return MilimetersToDeviceUnit(serial, m * 1000)
end

function DeviceUnitToMeters(serial::String, device_unit)
    return DeviceUnitToMilimeters(serial, device_unit) / 1000
end

function VelocityToDeviceUnit(serial::String, vel)
    return GetDeviceUnitFromRealValue(serial, vel, 1)
end

function DeviceUnitToVelocity(serial::String, device_unit)
    return GetRealValueFromDeviceUnit(serial, device_unit, 1)
end

function AccelerationToDeviceUnit(serial::String, acc)
    return GetDeviceUnitFromRealValue(serial, acc, 2)
end

function DeviceUnitToAcceleration(serial::String, device_unit)
    return GetRealValueFromDeviceUnit(serial, device_unit, 2)
end

function GetMotorTravelLimits(serial)
    min = Ref{Cdouble}(0)
    max = Ref{Cdouble}(0)
    err = ccall(lib(:ISC_GetMotorTravelLimits), Cshort, (Cstring, Ref{Cdouble}, Ref{Cdouble}), serial, min, max)
    err != 0 && error("Error GetMotorTravelLimits code: $err")
    return min[], max[]
end

function GetVelParams(serial)
    acc = Ref{Cint}(0)
    vel = Ref{Cint}(0)
    err = ccall(lib(:ISC_GetVelParams), Cshort, (Cstring, Ref{Cint}, Ref{Cint}), serial, acc, vel)
    err != 0 && error("Error GetVelParams code: $err")
    return acc[], vel[]
end

function SetVelParams(serial, acc, vel)
    err = ccall(lib(:ISC_SetVelParams), Cshort, (Cstring, Cint, Cint), serial, acc, vel)
    err != 0 && error("Error code: $err")
    return true
end

function GetVelocity(serial)
    acc, vel = GetVelParams(serial)
    return DeviceUnitToVelocity(serial, vel)
end

function SetVelocity(serial, vel)
    vel = VelocityToDeviceUnit(serial, vel)
    acc, _ = GetVelParams(serial)
    SetVelParams(serial, acc, vel)
end

function GetAcceleration(serial)
    acc, vel = GetVelParams(serial)
    acc = DeviceUnitToAcceleration(serial, acc)
    return round(acc; digits=4)
end

function SetAcceleration(serial, acc)
    acc = AccelerationToDeviceUnit(serial, acc)
    _, vel = GetVelParams(serial)
    SetVelParams(serial, acc, vel)
end

function Close(serial)
    ccall(lib(:ISC_StopPolling), Int, (Cstring,), serial)
    ccall(lib(:ISC_Close), Int, (Cstring,), serial)
end

function WaitForMessage(serial)
    msgType = Ref{Cint}(2)
    msgID = Ref{Cint}(0)
    msgData = Ref{Int64}(0)
    successful = ccall(lib(:ISC_WaitForMessage), Bool, (Cstring, Ref{Cint}, Ref{Cint}, Ref{Int64}), serial, msgType, msgID, msgData)
    @info successful
    @info msgType
    @info msgID
    @info msgData
    return msgType[], msgID[]
    while (msgType[] != 2 || msgID[] != 0)
        ccall(lib(:ISC_WaitForMessage), Bool, (Cstring, Ref{Cint}, Ref{Cint}, Ref{Clong}), serial, msgType, msgID, msgData)
    end
        
end

function MoveAbsolute(serial::String, pos)
    pos = microsteps_per_m(pos)
    ClearQueue(serial)
    SetMoveAbs(serial, pos)
    MoveAbs(serial)
end



function init(stage)
    err = OpenDevice(stage.serial)
    while err != 0
        BuildDeviceList()
        sleep(1)
        err = OpenDevice(stage.serial)
    end
    model, _ = GetHardwareInfo(stage.serial)
    setting_name = if model == "LTS150"
        "HS LTS150 150mm Stage"
    elseif model == "LTS300"
        "HS LTS300 300mm Stage"
    else
        error("Model name unrecognized: $model")
    end
    Poll(stage.serial, 50)
    sleep(1.2)
    LoadNamedSettings(stage.serial, setting_name)
    LoadSettings(stage.serial)
    Enable(stage.serial)
    return setting_name
end

mutable struct Stage
    serial::String
    info::String
    min_pos::Float64
    max_pos::Float64
    lower_limit::Float64
    upper_limit::Float64
    is_moving::Bool
    function Stage(serial)
        stage = new(serial)
        stage.info = init(stage)
        finalizer(s->Close(s.serial), stage)
        stage.min_pos, stage.max_pos = GetMotorTravelLimits(serial)
        stage.lower_limit = stage.min_pos
        stage.upper_limit = stage.max_pos
        stage.is_moving = false
        return stage
    end
end

lower_limit(stage::Stage) = stage.lower_limit

function lower_limit!(stage::Stage, limit) 
    if upper_limit(stage) > stage.max_pos
        error("Min Position of $(stage.min_pos). Limit $(lower_limit(stage)) cannot be set")
    end
    stage.lower_limit  = limit
end

upper_limit(stage::Stage) = stage.upper_limit

function upper_limit!(stage::Stage, limit) 
    if upper_limit(stage) > stage.max_pos
        error("Max Position of $(stage.max_pos). Limit $(upper_limit(stage)) cannot be set")
    end
    stage.upper_limit  = limit
end

function limits!(stage::Stage, lower, upper)
    if upper < lower
        error("Upper limit ($upper) is less than lower limit ($lower)")
    end
    lower_limit!(stage, lower)
    upper_limit!(stage, upper)
end

limits(stage::Stage) = lower_limit(stage), upper_limit(stage)

reset_limits(stage::Stage) = limits!(stage, stage.min_pos, stage.max_pos)

function pause(stage::Stage, position)
    while !isapprox(pos(stage), position)
        sleep(0.1)
    end
    stage.is_moving = false
end

function move(stage::Stage, position; block=true)
    if position < lower_limit(stage) || position > upper_limit(stage)
        error("Position $position is outside of the current set limits $([stage.lower_limit, stage.upper_limit])")
    end
    stage.is_moving = true
    MoveAbsolute(stage.serial, position)
    block && pause(stage, position)
    return
end

function home(stage::Stage)
    move(stage, 0)
end

function pos(stage::Stage)
    return DeviceUnitToMeters(stage.serial, GetPos(stage.serial))
end

function close(stage::Stage)
    Close(stage.serial)
end

function get_acceleration(stage::Stage)
    return GetAcceleration(stage.serial)
end

function set_acceleration(stage::Stage, acc)
    return SetAcceleration(stage.serial, acc)
end

function get_velocity(stage::Stage)
    return GetVelocity(stage.serial)
end

function set_velocity(stage::Stage, vel)
    return SetVelocity(stage.serial, vel)
end


struct LTS
    x_stage::Stage
    y_stage::Stage
    z_stage::Stage
end

function LTS()
    serials = GetDeviceList()
    num_stages = length(serials)
    if num_stages == 0
        return LTS(Stage(), Stage(), Stage())
    elseif num_stages == 3
        x, y, z = serials

        x_stage = Stage(x)
        println("X Stage: $(x_stage.serial) $(x_stage.info)")

        y_stage = Stage(y)
        println("Y Stage: $(y_stage.serial) $(y_stage.info)")

        z_stage = Stage(z)
        println("Z Stage: $(z_stage.serial) $(z_stage.info)")

        return LTS(x_stage, y_stage, z_stage)
    else
        error("$num_stages unexpectedly found: $serials")
    end
end

stages(lts::LTS) = (lts.x_stage, lts.y_stage, lts.z_stage)

function move_xyz(lts::LTS, x, y, z)
    move(lts, x, y, z)
end

function pos(lts::LTS)
    return [pos(lts.x_stage), pos(lts.y_stage), pos(lts.z_stage)]
end

function move(lts::LTS, x, y, z)
    move(lts.x_stage, x; block=false)
    move(lts.y_stage, y; block=false)
    move(lts.z_stage, z; block=false)
    pause(lts.x_stage, x)
    pause(lts.y_stage, y)
    pause(lts.z_stage, z)
end

function limits(lts::LTS)
    s = stages(lts)
    return map(lower_limit, s), map(upper_limit, s)
end

function limits!(lts::LTS, lower, upper)
    limits!(lts.x_stage, lower[1], upper[1])
    limits!(lts.y_stage, lower[2], upper[2])
    limits!(lts.z_stage, lower[3], upper[3])
end

set_limits(lts::LTS, lower, upper) = limits!(lts, lower, upper)

get_limits(lts::LTS) = limits(lts)

reset_limits(lts::LTS) = map(reset_limits, stages(lts))

function close(lts::LTS)
    close(lts.x_stage)
    close(lts.y_stage)
    close(lts.z_stage)
    return true
end

