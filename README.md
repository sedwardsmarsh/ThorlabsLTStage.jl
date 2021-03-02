# ThorlabsLTStage

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mofii.github.io/ThorlabsLTStage.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mofii.github.io/ThorlabsLTStage.jl/dev)
[![Build Status](https://github.com/mofii/ThorlabsLTStage.jl/workflows/CI/badge.svg)](https://github.com/mofii/ThorlabsLTStage.jl/actions)
[![Build Status](https://travis-ci.com/mofii/ThorlabsLTStage.jl.svg?branch=master)](https://travis-ci.com/mofii/ThorlabsLTStage.jl)
[![Coverage](https://codecov.io/gh/mofii/ThorlabsLTStage.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mofii/ThorlabsLTStage.jl)
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

## Install git
`choco install git`

## Install python
`choco install python --version=3.6.3`

As of this document any version of python above 3.6.3 will not work

`pip install --upgrade pip`

`pip install wheel`

`pip install pythonnet`

## Install julia
`choco install julia`

## Install kinesis
Download & Install [Kinesis](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)

## Install ThorlabsLTSStage
```
pkg> add https://github.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl
```

Add python: "python" to `.lts_stage.yml`:
```
create_config()
edit_config()
```

Load python
```
load_python()
```

