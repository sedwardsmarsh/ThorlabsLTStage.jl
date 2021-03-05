# ThorlabsLTStage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/dev)
[![Build Status](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/workflows/CI/badge.svg)](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/actions)
[![Build Status](https://travis-ci.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl.svg?branch=master)](https://travis-ci.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl)
[![Coverage](https://codecov.io/gh/orchard-ultrasound-innovation/ThorlabsLTStage.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/orchard-ultrasound-innovation/ThorlabsLTStage.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

We currently use the Kinesis Windows DLL to control the XYZ Stage.

As such this code will only work on a Windows machine that has
been properly configured.

## Prerequisites
This guide explains how to setup a clean Windows 10 install.

### Install choco
Start a new powershell as administrator.

`Set-ExecutionPolicy -Scope CurrentUser`

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

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
```
pkg> add https://github.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl
```

This project uses [InstrumentConfig.jl](https://github.com/Orchard-Ultrasound-Innovation/InstrumentConfig.jl)
for configuration. Check out the package for more information.

### Specify python location in your config file
```
julia
julia>using ThorlabsLTStage;
julia>ThorlabsLTStage.create_config()
```
```
julia>load_python()
```
The important line in the config is "backend: python"

If you wanted to add this line but the rest of the config doesn't fit your
use case you can also manually create this config file instead.
```
    echo "backend: python" > .lts_stage.yml
    julia
    julia>using ThorlabsLTStage; ThorlabsLTStage.create_config()
    julia>load_python()
```


## Using this package
As of right now the only supported device is the Thorlabs LTS150

To connect to it:
```
julia
julia>using ThorlabsLTStage; ThorlabsLTStage.load_config()
lts = initialize(ThorlabsLTS150)
```

This will print the serial numbers of all the LTS150 stages connected to the
computer and then connect to them. The first stage detected will be initialized
as the X stage followed by Y and Z.

Lets say for your setup you want to change which stage is considered X, Y and Z.

Edit your config file with your text editor or:
` ThorlabsLTStage.edit_config() `
 to look like the following:

```
# Inside .lts_stage.yml
backend: python

ThorlabsLTS150:
    X: desired-x-stage-serial-number
    Y: desired-y-stage-serial-number
    Z: desired-z-stage-serial-number

```

Now when you run 
```
lts = initialize(ThorlabsLTS150)
```
the current stages will be configured as X, Y and Z

## Controlling the XYZ Stage
Move a single axis to a certain position:
`move_x_abs(lts, .54)`

Get position of a single axis:
`pos_y(lts)`

Get position of all stages:
`pos_xyz(lts)`

If you ask a stage to move further than its available length
this package will throw an error. You can however set limits
that will prevent a stage from moving past a particular point.

Note: All positions are in meters

For all the available commands use:

`help>ThorlabsLTS150`

## Example
```
lts = initialize(ThorlabsLTS150)

move_xyz(lts, 0.1, 0.1, 0.1)

# Move 0.05 meters forwards
move_x_rel(lts, 0.05)

# Get position of x stage (0.05 here)
pos_x(lts)

# Move 0.05 meters backwards
move_x_rel(lts, -0.05)

# Moves device to home position
home(lts)

# Returns x,y,z positions
pos_xyz(lts)

# First tuple contains lower limits, second contains upper limits
# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)
# Arrays can be used instead of tuples as well []
set_limits(lts, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))

# Will return a pair of tuples with limits you just set
get_limits(lts)

# Will return lower and upper limit for x stage
lower_x, upper_x = get_limits_x(lts)

# Will stay at 0.1 (upper limit)
move_x_abs(lts, 0.2)

# Beyond device limit but will stay at 0.1 (upper limit)
move_x_abs(lts, 5)

# Will move to 0.01 (lower limit)
move_x_abs(lts, 0)

# Clear limits
clear_limits(lts)

# Moving beyond your physical device with no limits will throw an error
# Don't do this
move_x_abs(lts, 5)
```



