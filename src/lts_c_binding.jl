using Libdl

const ISM_LIB = "Thorlabs.MotionControl.IntegratedStepperMotors.dll"
const path = raw"C:\Program Files\Thorlabs\Kinesis"
const shared_lib = dlopen(joinpath(path, ISM_LIB))

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
    BuildDeviceList()
    list_string = Ref{Cstring}()
    ccall(lib(:TLI_GetDeviceListByTypeExt), Int, (Ref{Cstring}, UInt32, Int64), list_string, 100, 45)
    serial_list = []
    p = ccall(:strtok, Cstring, (Ref{Cstring}, Cstring), list_string, ",")
    while p != C_NULL
        push!(serial_list, unsafe_string(p))
        p = ccall(:strtok, Cstring, (Cstring, Cstring), C_NULL, ",")
    end
    return serial_list
end

OpenDevice(serial::String) = ccall(lib(:ISC_Open), Int, (Cstring,), serial)

Poll(serial, sec) = ccall(lib(:ISC_StartPolling), Int, (Cstring, Int), serial, sec)

ClearQueue(serial) = ccall(lib(:ISC_ClearMessageQueue), Int, (Cstring,), serial)
MoveTo(serial::String, pos::Int) = ccall(lib(:ISC_MoveToPosition), Int, (Cstring,Int), serial, pos)
SetMoveAbs(serial::String, pos::Int) = ccall(lib(:ISC_SetMoveAbsolutePosition), Int, (Cstring,Int), serial, pos)
MoveAbs(serial::String) = ccall(lib(:ISC_MoveAbsolute), Int, (Cstring,), serial)

GetPos(serial) = ccall(lib(:ISC_GetPosition), Int, (Cstring,), serial)


function Real2Device(serial::String, real::Float64)
    device_unit = Ref{Int}(0)
    ccall(lib(:ISC_GetDeviceUnitFromRealValue), Int, (Cstring, Float64, Ref{Int}, Int), serial, real, device_unit, 0)
    @info device_unit
    return device_unit
end


function Device2Real(serial::String, device_unit)
    real = Ref{Float64}(0)
    ccall(lib(:ISC_GetRealValueFromDeviceUnit), Int, (Cstring, Int, Ref{Float64}, Int), serial, device_unit, real, 0)
    @info real
    return real
end

function GetMotorTravelLimits(serial)
    min = Ref{Cdouble}(0)
    max = Ref{Cdouble}(0)
    @info ccall(lib(:ISC_GetMotorTravelLimits), Int, (Cstring, Ref{Cdouble}, Ref{Cdouble}), serial, min, max)
    @info (min, max)
    return min, max
end


function Close(serial)
    ccall(lib(:ISC_StopPolling), Int, (Cstring,), serial)
    ccall(lib(:ISC_Close), Int, (Cstring,), serial)
end

function test()
serials = GetDeviceList()
@info serials
x, y, z = serials
for serial in serials
    @info OpenDevice(serial)
    sleep(3)
    @info Poll(serial, 200)
    sleep(3)
    """
    @info ClearQueue(serial)
    @info SetMoveAbs(serial, 0)
    @info MoveAbs(serial)
    sleep(3)
    """
end
end
function move_to(serial, pos)
    @info ClearQueue(serial)
    @info MoveTo(serial, pos)
end
function move_abs(serial, pos)
    @info ClearQueue(serial)
    @info "Moving $serial"
    @info SetMoveAbs(serial, pos)
    @info MoveAbs(serial)
end

struct Stage
    serial::String
    function Stage(serial)
        stage = new(serial)
        init(stage)
        return stage
    end
end


function init(stage::Stage)
    OpenDevice(stage.serial)
    sleep(1)
    Poll(stage.serial, 200)
    sleep(1)
end

function move(stage::Stage, pos)
    ClearQueue(stage.serial)
    status = MoveTo(stage.serial, microsteps_per_m(pos))
    status == 0 && return
    if status == 2
        error("Error code 2: Device not found! Have you run BuildDeviceList()?")
    else
        error("Error code $status")
    end
end

function home(stage::Stage)
    move(stage, 0)
end

function pos(stage::Stage)
    return GetPos(stage.serial)
end

struct LTS
    x_stage::Stage
    y_stage::Stage
    z_stage::Stage
end

function LTS()
    serials = GetDeviceList()
    @info serials
    if length(serials) == 0
        return LTS(Stage(), Stage(), Stage())
    elseif length(serials) == 3
        x, y, z = serials
        return LTS(Stage(x), Stage(y), Stage(z))
    end
end

function move_xyz(lts::LTS, x, y, z)
    move(lts.x_stage, x)
    move(lts.y_stage, y)
    move(lts.z_stage, z)
end
