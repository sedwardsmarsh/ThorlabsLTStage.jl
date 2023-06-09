# ThorlabsLTStage.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://orchard-ultrasound-innovation.github.io/ThorlabsLTStage.jl/dev)
[![Build Status](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/workflows/CI/badge.svg)](https://github.com/orchard-ultrasound-innovation/ThorlabsLTStage.jl/actions)<!-- [![Build Status](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl.svg?branch=main)](https://app.travis-ci.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl) -->
[![codecov](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl/branch/main/graph/badge.svg?token=41stEIf5vZ)](https://codecov.io/gh/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


This Julia package supports Linux and Windows. There are two backend options for this package
* A Python backend that uses [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) (default)
* A C backend which implements [Thorlabs Kinesis C API](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)

## Prerequisites
Linux
* [Julia for Linux](https://www.digitalocean.com/community/tutorials/how-to-install-julia-programming-language-on-ubuntu-22-04)

Windows
* [Julia for Windows](https://julialang.org/downloads/)
* [Thorlabs Kinesis Software](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)
---
## Setup
<details open><summary>Linux</summary>

  <h4> Install Python 3.10 </h4>
  <ol>
    <li>Open terminal and check the python version: <code>python3 --version</code></li>
    <li>If the Python version returned is less than 3.10, please install 3.10
      <ul>
        <li>Run: <code>sudo apt-get install python3.10</code></li>
      </ul>
    </li>
    <li>Install Pip
      <ul>
        <li>Run: <code>sudo apt-get install python3-pip</code></li>
      </ul>
    </li>
  </ol>


</details>

<details><summary>Windows</summary>
<ul>
  <li><h4> Enable Windows VCOM ports:</h4>
    <ol>
      <li> Plug all the stages to your PC </li>
      <li> Go to <em>Device Manager</em> and for each APTDevice listed under <em>Universal Serial Bus controllers</em> do the following:
        <ol>
          <li>Right click on each APTDevice and select <strong>properties</strong></li>
          <li>On the <em>Advanced</em> tab, check the <em>Load VCP</em> box </li>
        </ol>
    </ol>
  </li>
  <li><h4> Disable Windows app execution aliases: </h4>
    <ol>
      <li> In Windows, open <em>Manage app execution aliases</em>  </li>
      <li> Unselect the options with the gray text reading <em>python.exe</em> or <em>python3.exe</em> See below for <em>python.exe</em> example:
          <img src="python_windows_example.png">
      </li>
      <li> Download <a href="https://www.python.org/downloads/release/python-31012/">Python 3.10</a> and follow the installation instructions
        <ul>
          <li>Check the box that add Python to your <code>PATH</code> variable</li>
          <li>Verify Python3 has been installed: <code>python --version</code> </li>
        <ul>
      </li>
    </ol>
  </li>
</ul>

</details>

---

### Install the ThorlabsLTStage Python Backend
* Please follow the [devpi_guide.md](devpi_guide.md) to setup a devpi server to host the python backend
    * *As the devpi server is only hosted locally, please note the following:*
        1. The devpi user must re-login every 10 hours
        2. If the devpi server is killed it must be restarted and the devpi user must re-login
* Once the server is successfully configured, use the devpi server to install the `ThorlabsLTStage.py` package with the following command:
    * For Windows:
        1. Open *Command Prompt* with administrator privledges
            * Right click and select *Run as administrator*
        2. Run: `python -m pip install thorlabsltstage --extra-index-url http://<SERVER IP>:3141/<DEVPI USERNAME>/<DEVPI INDEX>/ --trusted-host <SERVER IP>`
            * `<SERVER IP>` : the ip address of the server
            * `<DEVPI USERNAME>` : the username of the devpi server
            * `<DEVPI INDEX>` : the index of the user on the devpi server
    * For Linux:
        1. `sudo python3 -m pip install thorlabsltstage --extra-index-url http://<SERVER IP>:3141/<DEVPI USERNAME>/<DEVPI INDEX>/ --trusted-host <SERVER IP>`
          * `<SERVER IP>` : the ip address of the server
          * `<DEVPI USERNAME>` : the username of the devpi server
          * `<DEVPI INDEX>` : the index of the user on the devpi server


---

### Initialize the Python backend
#### Linux: 
1. Open a new terminal and `cd` into the *`ThorlabsLTStage.jl`* directory
2. Run ``sudo `which julia` ``**[IMPORTANT]**

#### Windows:
1. Open *VSCode* as administrator **[IMPORTANT]**
    * Right click and select *Run as administrator*
    <br><strong>OR</strong></br>
    * Use Windows Key + R, time cmd, then hit Ctrl + Shift + Enter
2. Open a new terminal within *VSCode* and start a Julia REPL

#### Remaining Steps:
3. Enter package mode by pressing '**]**'
    * Run: `pkg> activate .`
4. Exit package mode by pressing **Backspace**:
5. Use the package: 
    * Run: `julia> using ThorlabsLTStage`
6. Initialize the Python backend:
    * Run: `julia> ThorlabsLTStage.load_python_venv()`
    * This will close the Julia REPL upon successful execution

* **Proceed to the next section for usage details**

---

## Using this package

### Project Configuration
* In *VSCode* edit the configuration file *`ThorlabsLTStage/.positioner_system_config.yml`* to update the stage serial numbers appropriately
```yml
# Inside .positioner_system_config.yml

ThorlabsLTS:
  alias: positioner_system_default
  x:
    serial: 45140764 # desired serial number
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

### Running a *`.jl`* script
#### Linux:
  1. Start a Julia REPL within *VSCode*:  ``sudo `which julia` ``
#### Windows:
  1. Open *VSCode* with administrator privileges and start a new Julia REPL 

---

2. Enter package mode by pressing: **]**
    * Run: `pkg> activate .`
3. Exit package mode by pressing: **Backspace**
    * Type in the REPL: `julia> using ThorlabsLTStage`
3. Run your desired file:
    * `julia> include(<insert path to your .jl script>)`

## Example
```julia
using Unitful

ps = initialize(PositionerSystem)

pos = get_pos(ps)
move_xyz(ps, 5u"mm", 10u"mm", 10u"mm")
pos = get_pos(ps)
move_x_rel(ps, 5u"mm")
pos = get_pos(ps)

# set a new origin location for all stages
origin = get_origin(ps)
set_origin(ps) # sets the current position as origin (0mm, 0mm, 0mm)

# absolute positions are relative to the origin
move_x_abs(ps, 5u"mm")
x_pos = get_pos_x(ps)

# set the current position (5mm) to be the upper limit
set_upper_limit(ps.x, x_pos)

# this will work
move_to_origin(ps)
move_x_abs(ps, 5u"mm")

# this will error because the upper limit was set to 5 mm
move_x_abs(ps, 6u"mm")

# set a new upper limit
set_upper_limit(ps.x, get_upper_limit(ps.x)+5u"mm")

# this will now work
move_x_abs(ps, 6u"mm")

# important: terminate our stages/positionersystem
terminate(ps)

```

---



## Using the C Backend

If you are having trouble with the Python backend you can use the C Backend. ***However, it is not recommended***
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

This will print the serial numbers of all the LTS150 and LTS300 stages connected to the computer and then connect to them
The first stage detected will be initialized
as the X stage followed by Y and Z

Lets say for your setup you want to change which stage is considered X, Y and Z

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
that will prevent a stage from moving past a particular point

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