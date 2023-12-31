# ThorlabsLTStage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/dev)
[![Build Status](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/workflows/CI/badge.svg)](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/actions)
[![Build Status](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl.svg?branch=main)](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
[![codecov](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl/branch/main/graph/badge.svg?token=41stEIf5vZ)](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

We currently use the Kinesis Windows DLL to control the XYZ Stage.

As such this code will only work on a Windows machine that has
been properly configured. (A Linux interface will hopefully be released by Thorlabs soon)

There are two different backends to this package. 

One is a Julia implementation that directly calls the C API to the device.

The other uses Pycall to call the Dot Net API.

The C API is preferred however at the moment it may be a bit buggier.

## Using the C Backend (default behavior)
As of right now the only supported device are Thorlabs LTS150 or LTS300 stages

To connect to them:
```julia
julia> using ThorlabsLTStage
julia> ps = initialize(PositionerSystem)
```

This will print the serial numbers of all the LTS150 and LTS300 stages connected to the computer and then connect to them. 
The first stage detected will be initialized
as the X stage followed by Y and Z.

Lets say for your setup you want to change which stage is considered X, Y and Z.

Create/edit a `.positioner_system_config.yml` file in the local directory to look like the
following:

```yml
ThorlabsLTS:
  alias: bigStage # This is an optional alias
  x:  
    serial: 45140764 # or whatever your desired serial number is
    min_position: 0       # [mm]
    max_position: 150     # [mm]
    max_velocity: 20      # [mm s^-1]
    max_acceleration: 20  # [mm s^-2]
  y:
    serial: 45146974
    max_velocity: 3       # [mm s^-1]
    max_acceleration: 5   # [mm s^-2]
  z:
    serial: 45141924

    # If no limits specified physical device limits will be used
```

Now when you run 
```julia
julia> ps = initialize(PositionerSystem)
```
the current stages will be configured as X, Y and Z

## Controlling the XYZ Stage
Move a single axis to a certain position:
`move_x_abs(ps, .54u"m")`

Get position of a single axis:
`get_pos_y(ps)`

Get position of all stages:
`get_pos(ps)`

If you ask a stage to move further than its available length
this package will throw an error. You can however set limits
that will prevent a stage from moving past a particular point.

For all the available commands use:

`help> PS_3D`

## Example
```julia
using Unitful

ps = initialize(PositionerSystem)

get_pos(ps)
move_xyz(ps, 5u"mm", 10u"mm", 10u"mm")
get_pos(ps)
move_x_rel(ps, 5u"mm")
get_pos(ps)

# set a new origin location for all stages
get_origin(ps)
set_origin(ps) # sets the current position as origin (0mm, 0mm, 0mm)

# absolute positions are relative to the origin
move_x_abs(ps, 5u"mm")
get_pos_x(ps)

# set the current position to be the upper limit
set_upper_limit(ps.x, get_pos(ps.x))

# this will work
move_to_origin(ps)
move_x_abs(ps, 5u"mm")

# this will error because the upper limit was set to 5 mm
move_x_abs(ps, 6u"mm")

# set a new upper limit
set_upper_limit(ps.x, get_upper_limit(ps.x)+5u"mm")

# this will now work
move_x_abs(ps, 6u"mm")
```





## Using the Python Backend
<details>
<summary>If you are having trouble with the C backend you can use the Python Backend. However, it may be deprecated in the future.</summary>

## Prerequisites
This guide explains how to setup a clean Windows 10 install.

### Install choco
Start a new powershell as administrator.

```
Set-ExecutionPolicy -Scope CurrentUser

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

### Install git
`choco install git`

### Install python
`choco install python --version=3.6.3`

As of this document any version of python above 3.6.3 will not work

`pip install --upgrade pip`

`pip install wheel`

`pip install pythonnet`

### Install julia
`choco install julia`

### Install kinesis
Download & Install [Kinesis](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)

### Install ThorlabsLTSStage
```julia
pkg> add ThorlabsLTStage
```

This project uses [InstrumentConfig.jl](https://github.com/Orchard-Ultrasound-Innovation/InstrumentConfig.jl)
for configuration. Check out the package for more information.

### Specify python location in your config file
```julia
julia
julia> using ThorlabsLTStage;
julia> ThorlabsLTStage.create_config()
```
```julia
julia> load_python()
```
The important line in the config is "backend: python"

If you wanted to add this line but the rest of the config doesn't fit your
use case you can also manually create this config file instead.

```julia
echo "backend: python" > .positioner_system_config.yml
julia
julia> using ThorlabsLTStage; ThorlabsLTStage.create_config()
julia> load_python()
```


## Using this package
As of right now the only supported device is the Thorlabs LTS150

To connect to it:
```julia
julia
julia> using ThorlabsLTStage; ThorlabsLTStage.load_config()
ps = initialize(ThorlabsLTS150)
```

This will print the serial numbers of all the LTS150 stages connected to the
computer and then connect to them. The first stage detected will be initialized
as the X stage followed by Y and Z.

Lets say for your setup you want to change which stage is considered X, Y and Z.

Edit your config file with your text editor or:
` ThorlabsLTStage.edit_config() `
 to look like the following:

```yml
# Inside .positioner_system_config.yml
backend: python

ThorlabsLTS:
  alias: positioner_system_default
  x:  
    serial: 45140764 # or whatever your desired serial number is
    min_position: 0
    max_position: .15 # in meters
    max_velocity: 20
    max_acceleration: 20
  y:
    serial: 45146974
    max_velocity: 3
    max_acceleration: 5
  z:
    serial: 45141924
    # If no limits specified physical device limits will be used
```

Now when you run 
```julia
ps = initialize(ThorlabsLTS150)
```
the correct stages will be configured as X, Y and Z

## Controlling the XYZ Stage
Move a single axis to a certain position:
`move_x_abs(ps, .54)`

Get position of a single axis:
`get_pos_y(ps)`

Get position of all stages:
`get_pos(ps)`

If you ask a stage to move further than its available length
this package will throw an error. You can however set limits
that will prevent a stage from moving past a particular point.

Note: All positions are in meters

For all the available commands use:

`help> ThorlabsLTS150`

## Example
```julia
ps = initialize(ThorlabsLTS150)

move_xyz(ps, 0.1, 0.1, 0.1)

# Move 0.05 meters forwards
move_x_rel(ps, 0.05)

# Get position of x stage (0.05 here)
get_pos_x(ps)

# Move 0.05 meters backwards
move_x_rel(ps, -0.05)

# Moves device to home position
home(ps)

# Returns x,y,z positions
get_pos(ps)

# First tuple contains lower limits, second contains upper limits
# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)
# Arrays can be used instead of tuples as well []
set_limits(ps, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))

# Will return a pair of tuples with limits you just set
get_limits(ps)

# Will return lower and upper limit for x stage
lower_x, upper_x = get_limits_x(ps)

# Will stay at 0.1 (upper limit)
move_x_abs(ps, 0.2)

# Beyond device limit but will stay at 0.1 (upper limit)
move_x_abs(ps, 5)

# Will move to 0.01 (lower limit)
move_x_abs(ps, 0)

# Clear limits
clear_limits(ps)

# Moving beyond your physical device with no limits will throw an error
# Don't do this
move_x_abs(ps, 5)
```
</details>
