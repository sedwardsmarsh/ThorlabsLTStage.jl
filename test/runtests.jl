using Test
using TestSetExtensions
using Logging

using ThorlabsLTStage

@testset ExtendedTestSet "ThorlabsLTStage.jl" begin
    log_level_threshold = Logging.Warn
    log_output = stderr
    mylogger = ConsoleLogger(log_output, log_level_threshold)
    global_logger(mylogger)

    @includetests ARGS
end
