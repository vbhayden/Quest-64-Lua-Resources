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


def rotate_vector_with_angle(angle, vector_tuple: Tuple[float, float, float]):
    
    angle_sin = math.sin(angle);
    angle_cos = math.cos(angle);
    
    (x, y, z) = vector_tuple
    
    rotated_x = (z * angle_sin) - (x * angle_cos);
    rotated_z = (z * angle_cos) + (x * angle_sin);

    return (rotated_x, y, rotated_z)

def simulate_projectile_with_dt(fps: int):
    
    results = []

    time_scaling = 30 / fps
    
    ## Init
    ##
    local_direction = (-0.7, 0.5,  0.7)
    world_direction = rotate_vector_with_angle(3.1416, local_direction)
    
    brian = Brian(0, 60, 0, 3.1416)
    enemy = Enemy(0, 60, -90, 74.0, 17.5, 28.0)
    p = Projectile(0, 0, 0, 0, 0, 0)
    
    init_speed = 6
    
    (vx, vy, vz) = world_direction
    p.vx = vx * init_speed
    p.vy = vy * init_speed
    p.vz = vz * init_speed
    
    (bx, by, bz) = brian.get_collision_center()
    
    p.x = bx
    p.y = by
    p.z = bz
    
    p.target = enemy
    
    ## Update
    ##
    homing_value = 10 
    steady_speed = 1.2
    
    # print(init_speed, homing_value, steady_speed)
    
    for _ in range(11):
     
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
        
        results.append((p.x, p.y, p.z))
        
        print(p.x, p.y, p.z)

    return results



def simulate_projectile_update(brian: Brian, enemy: Enemy, p: Projectile):
    
    homing_value = 10 
    steady_speed = 1.2
    
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


def lerp(a, b, t):
    return a * (1 - t) + b * t

def lerp_vector(a, b, t):

    (a1, a2, a3, *other) = a
    (b1, b2, b3, *other) = b

    return (lerp(a1, b1, t), lerp(a2, b2, t), lerp(a3, b3, t))

def interpolate_from_array(arr, dt_spacing, t):

    a = arr[0]
    b = arr[1]
    next_index = 2

    while t > dt_spacing:
        a = arr[next_index-1]
        b = arr[next_index]
        t -= dt_spacing
        next_index += 1

    t_normalized = t / dt_spacing

    print("A:", a)
    print("B:", b)
    print("T:", t)

    result = lerp_vector(a, b, t_normalized)
    return result

def simulate_projectile_with_constellation(fps: int):
    
    results = []

    time_scaling = 30 / fps
    
    ## Init
    ##
    local_direction = (-0.7, 0.5,  0.7)
    world_direction = rotate_vector_with_angle(3.1416, local_direction)
    
    brian = Brian(0, 60, 0, 3.1416)
    enemy = Enemy(0, 60, -90, 74.0, 17.5, 28.0)
    p = Projectile(0, 0, 0, 0, 0, 0)
    
    init_speed = 6
    
    (vx, vy, vz) = world_direction
    p.vx = vx * init_speed
    p.vy = vy * init_speed
    p.vz = vz * init_speed
    
    (bx, by, bz) = brian.get_collision_center()
    
    p.x = bx
    p.y = by
    p.z = bz
    
    p.target = enemy
    
    ## Update
    ##
    homing_value = 10 
    steady_speed = 1.2
    
    ## Interpolation Setup
    ##
    quest_dt = 1.0 / 30
    quest_next = 0
    quest_duration = 11 * quest_dt

    quest_coords = [p.get_data_row()]

    elapsed = 0.0
    actual_dt = 1.0 / fps

    while elapsed < quest_duration:

        while elapsed >= quest_next:
            simulate_projectile_update(brian, enemy, p)
            quest_coords.append(p.get_data_row())
            quest_next += quest_dt

            print(p.get_data_row()[:3])

        interpolated_coord = interpolate_from_array(quest_coords, quest_dt, elapsed)
        results.append(interpolated_coord)

        elapsed += actual_dt
    
    return results


def test():

    arr = [
        (0, 10, 20),
        (10, 20, 30),
        (20, 30, 40),
        (30, 40, 50)
    ]

    result = interpolate_from_array(arr, 0.5, 0.75)

    print("Received:", result)
    print("Expected:", (15, 25, 35))


def main():

    # test()
    # return
    
    recorded_points = [
        (-3.8508,68.4548,-4.9678),
        (-7.3285,71.1430,-10.6329),
        (-10.4100,73.6440,-16.9278),
        (-13.0727,75.9376,-23.7873),
        (-15.2926,78.0031,-31.1477),
        (-17.0432,79.8179,-38.9456),
        (-18.2933,81.3566,-47.1148),
        (-19.0048,82.5888,-55.5831),
        (-19.1293,83.4764,-64.2653),
        (-18.6044,83.9703,-73.0493),
        (-17.3524,84.0070,-81.7711),
    ]
    
    # simulated_points = simulate_projectile_with_dt(15)
    # simulated_points = simulate_projectile_with_dt(120)
    # simulated_points = simulate_projectile_with_dt(120)
    
    simulated_points = simulate_projectile_with_constellation(120)

    
    reals = list(zip(*recorded_points))
    sims = list(zip(*simulated_points))
    
    fig = plt.figure()
    axes = fig.subplots(1, 3)

    axes[0].plot(reals[0], reals[2], color="green")
    axes[0].scatter(sims[0], sims[2], color="red")
    axes[0].set_xlabel('X Axis')
    axes[0].set_ylabel('Z Axis')

    axes[1].plot(reals[0], reals[1], color="green")
    axes[1].scatter(sims[0], sims[1], color="red")
    axes[1].set_xlabel('X Axis')
    axes[1].set_ylabel('Y Axis')
    
    axes[2].plot(reals[2], reals[1], color="green")
    axes[2].scatter(sims[2], sims[1], color="red")
    axes[2].set_xlabel('Z Axis')
    axes[2].set_ylabel('Y Axis')

    plt.show()

if __name__=="__main__":
    main()
