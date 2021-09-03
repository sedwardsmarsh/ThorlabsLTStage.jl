import InstrumentConfig: initialize, terminate

function initialize(::Type{FakePS_3D}) 
    return FakePS_3D(map(FakeStage, ["1", "2", "3"])...)
end

stages(positioner_system::FakePS_3D) = (positioner_system.x, positioner_system.y, positioner_system.z)

function move(positioner_system::FakePS_3D, x, y, z; move_func=false)
    move_abs!(positioner_system.x, x)
    move_abs!(positioner_system.y, y)
    move_abs!(positioner_system.z, z)
end

home_xyz(positioner_system::FakePS_3D) = move(positioner_system, raw_meters(0m), raw_meters(0m), raw_meters(0m))
