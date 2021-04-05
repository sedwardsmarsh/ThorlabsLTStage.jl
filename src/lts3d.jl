"""
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
- `reset_limits(xyz)`
"""

get_limits(lts) = limits(lts)
set_limits(lts, lower, upper) = limits!(lts, raw_meters.(lower), raw_meters.(upper))

get_limits_x(lts) = get_limits(lts.x)
get_limits_y(lts) = get_limits(lts.y)
get_limits_z(lts) = get_limits(lts.z)

set_limits_x(lts, l, u) = set_limits(lts.x, l, u)
set_limits_y(lts, l, u) = set_limits(lts.y, l, u)
set_limits_z(lts, l, u) = set_limits(lts.z, l, u)

move_xyz(lts, x, y, z) = move(lts, x, y, z)

move_x_abs(lts, x) = move_abs(lts.x, x)
move_y_abs(lts, y) = move_abs(lts.y, y)
move_z_abs(lts, z) = move_abs(lts.z, z)

move_x_rel(lts, x) = move_rel(lts.x, x)
move_y_rel(lts, y) = move_rel(lts.y, y)
move_z_rel(lts, z) = move_rel(lts.z, z)

pos_xyz(lts) = pos(lts)
pos_x(lts) = pos(lts.x)
pos_y(lts) = pos(lts.y)
pos_z(lts) = pos(lts.z)

home(lts) = home_xyz(lts)
home_x(lts) = home(lts.x)
home_y(lts) = home(lts.y)
home_z(lts) = home(lts.z)

get_max_velocity(lts) = map(get_max_velocity, stages(lts))
get_max_acceleration(lts) = map(get_max_acceleration, stages(lts))