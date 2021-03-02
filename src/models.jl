"""
# Available Functions

- `initialize_lts` 
- `move_xyz(xyz, x, y, z)` 
- `pos_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `pos_xyz(xyz)`
- `pos_x(xyz)`
- `pos_y(xyz)`
- `pos_z(xyz)`
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
- `set_limits(xyz, low, high)`
- `get_limits(xyz)`
- `get_limits_x(xyz)`
- `get_limits_y(xyz)`
- `get_limits_z(xyz)`
- `clear_limits(xyz)`

# Example
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

"""
mutable struct ThorlabsLTS150
    lts
end
