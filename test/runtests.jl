using Test
using TestSetExtensions
using Logging

using ThorlabsLTStage

@testset ExtendedTestSet "ThorlabsLTStage.jl" begin
    # log_level_threshold = Logging.Warn
    # log_output = stderr
    # mylogger = ConsoleLogger(log_output, log_level_threshold)
    # global_logger(mylogger)

    # @includetests ARGS
    include("LTS150M/test_change_speed.jl")
    include("LTS150M/test_device_list_methods.jl")
    include("LTS150M/test_home.jl")
    include("LTS150M/test_home_no_reinit.jl")
    include("LTS150M/test_homing_commands.jl")
    include("LTS150M/test_messaging_configuration.jl")
    include("LTS150M/test_position_commands.jl")
    include("LTS150M/test_position_rounding.jl")
    include("LTS150M/test_python_connection.jl")
    include("LTS150M/test_utility_functions.jl")
end
