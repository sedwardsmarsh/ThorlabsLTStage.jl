import InstrumentConfig: initialize, terminate

function initialize(::Type{FakePS_3D}) 
    return FakePS_3D(map(FakeStage, ["1", "2", "3"])...)
end