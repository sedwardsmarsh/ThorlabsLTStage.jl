using Libdl
using Pkg.Artifacts

const ISM_LIB = "Thorlabs.MotionControl.IntegratedStepperMotors.dll"
const DEFAULT_PATH = raw"C:\Program Files\Thorlabs\Kinesis"

function path()
    # TODO: Make artifacts work
    if false
    try
        art_path = joinpath(artifact"kinesis", ISM_LIB) 
        kinesis_dll = dlopen(path())
        dlsym(kinesis_dll, :ISC_Open)
        return art_path
    catch
        @info "Cannot locate artifact"
        return joinpath(DEFAULT_PATH, ISM_LIB)
    end
    end
    return joinpath(DEFAULT_PATH, ISM_LIB)
end

const shared_lib = Ref{Ptr{Nothing}}()

function lib(x)
    !Sys.iswindows() && error("Non Windows Machine Detected")
    global shared_lib
    if shared_lib[] == C_NULL
        kinesis_dll = dlopen(path())
        shared_lib[] = kinesis_dll
    end
    return dlsym(shared_lib[], x)
end

BuildDeviceList() = ccall(lib("TLI_BuildDeviceList"), Int, ())

GetDeviceListSize() = ccall(lib("TLI_GetDeviceListSize"), Int, ())

function GetDeviceList()
    lts_identifier = 45 # Hard coded to only detect ThorlabsLTS
    BuildDeviceList()
    GetDeviceListSize()
    list_string = Vector{UInt8}(undef, 256) # MAXHOSTNAMELEN
    size_list_string = sizeof(list_string)
    err = ccall(lib(:TLI_GetDeviceListByTypeExt), Int, (Ptr{UInt8}, Csize_t, Int64), list_string, size_list_string, lts_identifier)
    if err != 0
        @info "GetDeviceError: $err"
        return err
    end
    list_string[end] = 0 # ensure null-termination
    serials = GC.@preserve list_string unsafe_string(pointer(list_string))
    return [filter(!isempty, split(serials, ','))...]
end

LoadSettings(serial::String) = ccall(lib(:ISC_LoadSettings), Bool, (Cstring,), serial)

LoadNamedSettings(serial::String, name) = ccall(lib(:ISC_LoadNamedSettings), Bool, (Cstring,Cstring), serial, name)

function OpenDevice(serial::String) 
    err = ccall(lib(:ISC_Open), Cshort, (Cstring,), serial)
    return err
end

Poll(serial, sec) = ccall(lib(:ISC_StartPolling), Bool, (Cstring, Int), serial, sec)

Enable(serial) = ccall(lib(:ISC_EnableChannel), Cshort, (Cstring,), serial)

ClearQueue(serial) = ccall(lib(:ISC_ClearMessageQueue), Int, (Cstring,), serial)

MoveTo(serial::String, pos::Int) = ccall(lib(:ISC_MoveToPosition), Int, (Cstring,Int), serial, pos)

SetMoveAbsolutePosition(serial::String, pos::Int) = ccall(lib(:ISC_SetMoveAbsolutePosition), Int, (Cstring,Int), serial, pos)

MoveAbsolute(serial::String) = ccall(lib(:ISC_MoveAbsolute), Int, (Cstring,), serial)

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

function MoveAbs(serial::String, pos)
    pos = MetersToDeviceUnit(serial, pos)
    ClearQueue(serial)
    SetMoveAbsolutePosition(serial, pos)
    MoveAbsolute(serial)
end


