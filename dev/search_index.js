var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ThorlabsLTStage","category":"page"},{"location":"#ThorlabsLTStage","page":"Home","title":"ThorlabsLTStage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ThorlabsLTStage]","category":"page"},{"location":"#ThorlabsLTStage.ThorlabsLTS150","page":"Home","title":"ThorlabsLTStage.ThorlabsLTS150","text":"Available Functions\n\ninitialize_lts \nmove_xyz(xyz, x, y, z) \npos_xyz(xyz, x, y, z) \nmove_x_abs(xyz, x)\nmove_y_abs(xyz, y)\nmove_z_abs(xyz, z)\nmove_x_rel(xyz, x)\nmove_y_rel(xyz, y)\nmove_z_rel(xyz, z)\npos_xyz(xyz)\npos_x(xyz)\npos_y(xyz)\npos_z(xyz)\nhome(xyz)\nhome_x(xyz)\nhome_y(xyz)\nhome_z(xyz)\nset_limits(xyz, low, high)\nget_limits(xyz)\nget_limits_x(xyz)\nget_limits_y(xyz)\nget_limits_z(xyz)\nclear_limits(xyz)\n\nExample\n\nlts = initialize(ThorlabsLTS150)\n\nmove_xyz(lts, 0.1, 0.1, 0.1)\n\n# Move 0.05 meters forwards\nmove_x_rel(lts, 0.05)\n\n# Get position of x stage (0.05 here)\npos_x(lts)\n\n# Move 0.05 meters backwards\nmove_x_rel(lts, -0.05)\n\n# Moves device to home position\nhome(lts)\n\n# Returns x,y,z positions\npos_xyz(lts)\n\n# First tuple contains lower limits, second contains upper limits\n# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)\n# Arrays can be used instead of tuples as well []\nset_limits(lts, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))\n\n# Will return a pair of tuples with limits you just set\nget_limits(lts)\n\n# Will return lower and upper limit for x stage\nlower_x, upper_x = get_limits_x(lts)\n\n# Will stay at 0.1 (upper limit)\nmove_x_abs(lts, 0.2)\n\n# Beyond device limit but will stay at 0.1 (upper limit)\nmove_x_abs(lts, 5)\n\n# Will move to 0.01 (lower limit)\nmove_x_abs(lts, 0)\n\n# Clear limits\nclear_limits(lts)\n\n# Moving beyond your physical device with no limits will throw an error\n# Don't do this\nmove_x_abs(lts, 5)\n\n\n\n\n\n","category":"type"},{"location":"#ThorlabsLTStage.get_limits-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.get_limits","text":"Returns\n\n(lts.x_low_limit, lts.y_low_limit, lts.z_low_limit),\n   (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.get_limits_x-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.get_limits_x","text":"Returns\n\n(x_low_limit, x_high_limit)\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.get_limits_y-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.get_limits_y","text":"Returns\n\n(y_low_limit, y_high_limit)\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.get_limits_z-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.get_limits_z","text":"Returns\n\n(z_low_limit, z_high_limit)\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.home-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.home","text":"home(xyz)\n\nThis will home the x, y and z stages at the same time\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.home_x-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.home_x","text":"home_x(xyz)\n\nThis will home the x stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.home_y-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.home_y","text":"home_y(xyz)\n\nThis will home the y stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.home_z-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.home_z","text":"home_z(xyz)\n\nThis will home the z stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.initialize-Tuple{Type{ThorlabsLTS150}}","page":"Home","title":"ThorlabsLTStage.initialize","text":"xyz = initialize(ThorlabsLTS150)\n\nConnect to Thorlabs LTS\n\nReturns:\n\nThorlabsLTS150: Device Handle \n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_x_abs-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_x_abs","text":"move_x(xyz, x)\n\nMoves x stage to desired absolute location\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_x_rel-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_x_rel","text":"move_x(xyz, x)\n\nMoves x stage forward or backwards.\n\nA positive number will move it forwards along the x axis while a negative number will move it backwards.\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_xyz-NTuple{4,Any}","page":"Home","title":"ThorlabsLTStage.move_xyz","text":"move_xyz(xyz, x, y, z)\n\nSimulatenously moves x, y and z stage to desired location\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_y_abs-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_y_abs","text":"move_y(xyz, y)\n\nMoves y stage to desired absolute location\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_y_rel-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_y_rel","text":"move_y(xyz, y)\n\nMoves y stage forward or backwards.\n\nA positive number will move it forwards along the y axis while a negative number will move it backwards.\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_z_abs-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_z_abs","text":"move_z(xyz, z)\n\nMoves z stage to desired absolute location\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.move_z_rel-Tuple{Any,Any}","page":"Home","title":"ThorlabsLTStage.move_z_rel","text":"move_z(xyz, z)\n\nMoves z stage forward or backwards.\n\nA positive number will move it forwards along the z axis while a negative number will move it backwards.\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.pos_x-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.pos_x","text":"pos_x(xyz)\n\nReturns the current position of x stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.pos_xyz-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.pos_xyz","text":"pos_xyz(xyz)\n\nReturns location of x, y and z stages in the form of a Array: [x, y, z]\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.pos_y-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.pos_y","text":"pos_y(xyz)\n\nReturns the current position of y stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.pos_z-Tuple{Any}","page":"Home","title":"ThorlabsLTStage.pos_z","text":"pos_z(xyz)\n\nReturns the current position of z stage\n\n\n\n\n\n","category":"method"},{"location":"#ThorlabsLTStage.set_limits-Tuple{Any,Any,Any}","page":"Home","title":"ThorlabsLTStage.set_limits","text":"set_limits(xyz, (x_low_lim, y_low_lim, z_low_lim), (x_high_lim, y_high_lim, z_high_lim))\n\nArguments\n\nlow: A Pair or an Array of three positions: (lts.xlowlimit, lts.ylowlimit, lts.zlowlimit)\nhigh: A Pair or an Array of three positions: (lts.xhighlimit, lts.yhighlimit, lts.zhighlimit)\n\n\n\n\n\n","category":"method"}]
}
