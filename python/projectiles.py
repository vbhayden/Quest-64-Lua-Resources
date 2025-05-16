import math
import matplotlib.pyplot as plt
import numpy as np

from dataclasses import dataclass
from typing import Tuple, List

@dataclass
class Brian:
    x: float
    y: float
    z: float
    angle: float
    size: float = 3.5
    
    def get_collision_center(self) -> Tuple[float, float, float]:
        collision_y = self.y + 5.6
        return (self.x, collision_y, self.z)
    
@dataclass
class Enemy:
    x: float
    y: float
    z: float
    collision_y: float
    size: float
    height: float
    
    def get_collision_center(self) -> Tuple[float, float, float]:
        return (self.x, self.collision_y, self.z)

@dataclass
class Projectile:
    x: float
    y: float
    z: float
    vx: float
    vy: float
    vz: float
    target: Enemy = None
    
    def get_data_row(self):
        return [self.x, self.y, self.z, self.vx, self.vy, self.vz]
    
@dataclass
class SpellDefinition:
    size: float
    steady_speed_index: int
    initial_speed_index: int
    initial_placement: int
    homing_index: int

DEF_WIND_CUTTER_1 = SpellDefinition(size=5.0, steady_speed_index=4, initial_speed_index=3, initial_placement=2, homing_index=3)

PROJECTILE_INIT_SPEEDS = [
    2,
    3,
    4,
    6,
    7
]

PROJECTILE_STEADY_SPEEDS = [
    0.4,
    0.5,
    0.7,
    1.0,
    1.2
]

PROJECTILE_HOMING_VALUES = [
    0,
    1,
    2,
    10,
    10
]

PROJECTILE_INIT_LOCAL_DIRECTIONS = [
    ( 0.0, 0.5,  1.0),
    ( 0.7, 0.5,  0.7),
    (-0.7, 0.5,  0.7),
    ( 1.0, 0.5,  0.0),
    (-1.0, 0.5,  0.0),
    ( 0.7, 0.5, -0.7),
    (-0.7, 0.5, -0.7),
    ( 0.0, 0.5, -1.0),
]

def load_test_data(data_path):
    rows = []
    with open(data_path) as fp:
        lines = fp.readlines()
        rows = [list(map(float, line.split(","))) for line in lines[1:]]
        
    return rows

def rotate_vector_with_angle(angle, vector_tuple: Tuple[float, float, float]):
    
    angle_sin = math.sin(angle);
    angle_cos = math.cos(angle);
    
    (x, y, z) = vector_tuple
    
    rotated_x = (z * angle_sin) - (x * angle_cos);
    rotated_z = (z * angle_cos) + (x * angle_sin);

    return (rotated_x, y, rotated_z)

def simulate_projectile_init(brian: Brian, enemy: Enemy, p: Projectile, spell: SpellDefinition):
    
    local_direction = PROJECTILE_INIT_LOCAL_DIRECTIONS[spell.initial_placement]
    world_direction = rotate_vector_with_angle(brian.angle, local_direction)
    
    init_speed = PROJECTILE_INIT_SPEEDS[spell.initial_speed_index]
    
    (vx, vy, vz) = world_direction
    p.vx = vx * init_speed
    p.vy = vy * init_speed
    p.vz = vz * init_speed
    
    (bx, by, bz) = brian.get_collision_center()
    
    p.x = bx
    p.y = by
    p.z = bz
    
    p.target = enemy
    
    return 

def simulate_projectile_update(brian: Brian, enemy: Enemy, p: Projectile, spell: SpellDefinition):
    
    homing_value = PROJECTILE_HOMING_VALUES[spell.homing_index]
    steady_speed = PROJECTILE_STEADY_SPEEDS[spell.steady_speed_index]
    
    (ax, ay, az) = enemy.get_collision_center()
    
    dx = ax - p.x
    dy = ay - p.y
    dz = az - p.z
    
    target_distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    
    aligned_speed_x = homing_value * dx / target_distance
    aligned_speed_y = homing_value * dy / target_distance
    aligned_speed_z = homing_value * dz / target_distance
    
    prev_vx = p.vx
    prev_vy = p.vy
    prev_vz = p.vz
    
    previous_speed = math.sqrt(prev_vx**2 + prev_vy**2 + prev_vz**2)
    
    if previous_speed > 0.001:
        
        aligned_speed_x += prev_vx / previous_speed
        aligned_speed_y += prev_vy / previous_speed
        aligned_speed_z += prev_vz / previous_speed
    
    aligned_speed = math.sqrt(aligned_speed_x**2 + aligned_speed_y**2 + aligned_speed_z**2)
    
    p.vx = 0.9 * prev_vx + steady_speed * aligned_speed_x / aligned_speed
    p.vy = 0.9 * prev_vy + steady_speed * aligned_speed_y / aligned_speed
    p.vz = 0.9 * prev_vz + steady_speed * aligned_speed_z / aligned_speed
    
    p.x += p.vx
    p.y += p.vy
    p.z += p.vz
    
    # print(p)
    # exit(1)
    
    # print(p.x, p.y, p.z)

def is_sim_row_accurate(sim_row, real_row, threshold=0.1):
    for k, (simmed, recorded) in enumerate(zip(sim_row, real_row)):
        diff = abs(simmed - recorded)
        if diff > threshold:
            print("Values Inaccurate: ", k, diff)
            print("  - Sim:  ", simmed)
            print("  - Real: ", recorded)
            return False
        
    return True

def is_sim_data_accurate(sim_data, real_data, threshold=0.1):
    for k, (sim_row, real_row) in enumerate(zip(sim_data, real_data)):
        accurate = is_sim_row_accurate(sim_row, real_row, threshold=threshold)
        if not accurate:
            print("Row Inaccurate: ", k)
            print("  - Sim:  ", sim_row)
            print("  - Real: ", real_row)
            return False

    return True

def test_wind_1_case(data_path, show_plot=False):
    
    test_data_wind_1 = load_test_data(data_path)
    init_data = test_data_wind_1[0]
    
    [bx, by, bz, angle] = init_data[0:4]
    [ex, ey, ez, ecy, e_size, e_height] = init_data[4:10]
    [px, py, pz, pvx, pvy, pvz] = init_data[10:]
    
    brian = Brian(x=bx, y=by, z=bz, angle=angle)
    enemy = Enemy(x=ex, y=ey, z=ez, size=e_size, height=e_height, collision_y=ecy)
    projectile = Projectile(x=px, y=py, z=pz, vx=pvx, vy=pvy, vz=pvz)
    
    rows = []
    rows.append(projectile.get_data_row())
    
    simulate_projectile_init(brian=brian, enemy=enemy, p=projectile, spell=DEF_WIND_CUTTER_1)
    
    for _ in range(len(test_data_wind_1) - 1):
        simulate_projectile_update(brian=brian, enemy=enemy, p=projectile, spell=DEF_WIND_CUTTER_1)
        rows.append(projectile.get_data_row())
    
    recorded_projectile_rows = [row[10:] for row in test_data_wind_1]
    seems_accurate = is_sim_data_accurate(rows, recorded_projectile_rows, threshold=0.1)
    
    if seems_accurate:
        print(" - Accurate!", data_path)
    
    if not show_plot:
        return
    
    reals = list(zip(*recorded_projectile_rows))
    sims = list(zip(*rows))
    
    fig = plt.figure()
    ax = fig.add_subplot(projection='3d')

    ax.plot(reals[0], reals[2], reals[1], color="green")
    ax.scatter(sims[0], sims[2], sims[1], color="red")

    ax.set_xlabel('X Label')
    ax.set_ylabel('Z Label')
    ax.set_zlabel('Y Label')

    plt.show()

def test_wind_1():
    # test_wind_1_case("./test_data/wind1.pinhead.1.csv", show_plot=False)
    test_wind_1_case("./test_data/wind1.pinhead.2.csv", show_plot=False)
    # test_wind_1_case("./test_data/wind1.pinhead.3.csv", show_plot=False)
    # test_wind_1_case("./test_data/wind1.kobold.1.csv", show_plot=False)

def main():
    
    test_wind_1()
    
    
    pass

if __name__=="__main__":
    main()
