# ThorlabsLTStage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/dev)
[![Build Status](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/workflows/CI/badge.svg)](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/actions)
[![Build Status](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl.svg?branch=main)](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
[![codecov](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl/branch/main/graph/badge.svg?token=41stEIf5vZ)](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


There are two different backends for this julia package.
* A Python backend that uses [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).
* A Julia implementation that directly calls the [Thorlabs Kinesis C API](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)..

As the Kinesis C API is unreliable, the Python backend is used by default.



---


## Installing the Python Backend
* Instructions include Linux and Windows.
### Windows Setup
#### Enable Windows VCOM ports:
  1. Install Kinesis Software from Thorlabs at [this link](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0).
  2. Plug all of the stages into your computer.
  3. Go to Device Manager and for each APTdevice listed under Universal Serial Bus controllers do the following:
      1. Right click on each APTdevice and select **properties**
      2. On the *Advanced* tab, check the *Load VCP* box.
#### Disable Windows app execution aliases:
  1. In Windows, use the search bar to find *Manage app execution aliases*. 
  2. Unselect the options with the gray text reading *python.exe* or *python3.exe*. See below for *python.exe* example:
      * ![](Python_windows_example.png)
  3. Uninstall Python3 by searching *Add or remove a program* in the Windows search bar.
        * right click and select uninstall and following the remaining instructions.
  3. Download [Python 3.10](python.org/downloads/release/python-3100/) and follow the installation instructions. 
        * Check the box that add Python to your `PATH` variable. 
        * Verify Python3 has been installed by running:
            * `python --version`

### Linux Setup
#### Install Python 3.10 
* Open terminal and check the python version: 
    * Run: `python3 --version`
* If the Python version returned is not 3.10, please install 3.10
    * Run: `sudo apt-get install python3.10`
#### Install pip
* Open terminal and check if you have pip installed:
    * Run: `python3 -m pip --version`
        * If pip is installed, proceed to the next section
        * If pip is not found, run: `sudo apt-get install python3-pip`

### Install the ThorlabsLTStage Python backend
* Please follow the [devpi_guide.md](devpi_guide.md) to setup a devpi server to host the python backend. 
    * *As the devpi server is only hosted locally, please note the following:*
        1. The devpi user must re-login every 10 hours.
        2. If the devpi server is killed it must be restarted and the devpi user must re-login.
* Once the server is successfully configured, use the devpi server to install the `ThorlabsLTStage.py` package with the following command:
    * For Windows:
        1. Open *Command Prompt* with administrator privledges.
            * Right click and select *Run as administrator*.
        2. Run: `python -m pip install thorlabsltstage --extra-index-url http://<SERVER IP>:3141/<DEVPI USERNAME>/<DEVPI INDEX>/ --trusted-host <SERVER IP>`
            * `<SERVER IP>` : the ip address of the server
            * `<DEVPI USERNAME>` : the username of the devpi server
            * `<DEVPI INDEX>` : the index of the user on the devpi server
    * For Linux: `sudo python3 -m pip install thorlabsltstage --extra-index-url http://<SERVER IP>:3141/<DEVPI USERNAME>/<DEVPI INDEX>/ --trusted-host <SERVER IP>`
        * `<SERVER IP>` : the ip address of the server
        * `<DEVPI USERNAME>` : the username of the devpi server
        * `<DEVPI INDEX>` : the index of the user on the devpi server



## Setup Julia
### Install Julia
* [Julia for Linux](https://www.digitalocean.com/community/tutorials/how-to-install-julia-programming-language-on-ubuntu-22-04).
* [Julia for Windows](https://julialang.org/downloads/).

### Initialize the Python backend
#### Windows:
1. Open *VSCode* as administrator
    * Right click and select *Run as administrator*.
2. Open a new terminal within *VSCode*
    * *Terminal > New Terminal*
3. `cd` into the *`ThorlabsLTStage.jl`* directory
4. Start a julia REPL:
    * press **ctrl+shift+p** and type: *>Julia: Start REPL*

#### Linux: 
1. Open a new terminal and `cd` into the *`ThorlabsLTStage.jl`* directory.
2. run ``sudo `which julia` ``

#### Remaining Steps:
1. Enter package mode, press **]**
    * Run: `pkg> activate .`
2. Exit package mode, press **ctrl+c**:
3. Use the package: 
    * Run: `julia> using ThorlabsLTStage`
4. Initialize the Python backend:
    * Run: `julia> ThorlabsLTStage.load_python_venv()`
    * This will close the Julia REPL upon successful execution.

* The Python backend has been setup successfully. Please proceed to the next section for usage details.



---



## Using this package

### Project Configuration
* In *VSCode* edit the configuration file *`ThorlabsLTStage/.positioner_system_config.yml`* to update the stage serial numbers appropriately. 
```yml
# Inside .positioner_system_config.yml

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

### Using this package in Linux
1. Start a Julia REPL within *VSCode*:
    1. press **ctrl+shift+p** and type: *>Julia: Start REPL*
    2. Run: ``sudo `which julia` ``. Then proceed to the next section.

### Using this package in Windows
1. In *VSCode*, with administrator privledges, open a terminal.
1. Start new Julia REPL and proceed to the next section.

### Running a *`.jl`* script
1. Enter package mode, press **]**
    * Run: `pkg> activate .`
2. Exit package mode, press **ctrl+c**:
3. `julia> using ThorlabsLTStage`
4. `julia> include(<path to your .jl script>)`



---



## Using the C Backend
<details>
<summary>If you are having trouble with the Python backend you can use the C Backend. However, it is unrecommended.</summary>
```julia
pkg> add ThorlabsLTStage
julia> using ThorlabsLTStage
julia> ps = initialize(PositionerSystem)
```
### Using this package
The C Backend now uses units from Unitful.jl

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

Edit/Create a config file with your text editor or:
` ThorlabsLTStage.edit_config() `
 to look like the following:

```yml
# Inside .positioner_system_config.yml
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
</details>