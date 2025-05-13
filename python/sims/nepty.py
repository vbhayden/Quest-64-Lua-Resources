import rng
import time
import random
import math
import numpy as np
import os.path
import json

import seaborn
import matplotlib.pyplot as plt

from typing import Tuple, List
from numba import njit
from dataclasses import dataclass

BRIAN_START_X = np.float32(351.65)
BRIAN_START_Y = np.float32(0)
BRIAN_START_Z = np.float32(-167.22)

BRIAN_HP = 91
BRIAN_MP = 29
BRIAN_AGILITY = 24
BRIAN_DEFENSE = 25
BRIAN_FIRE = 1
BRIAN_EARTH = 36
BRIAN_WATER = 25
BRIAN_WIND = 1
BRIAN_STAFF_POWER = 16
TOTAL_ELEMENTS = BRIAN_FIRE + BRIAN_EARTH + BRIAN_WATER + BRIAN_WIND

BRIAN_RADIUS = np.float32(50.0)
BRIAN_SCALE = np.float32(0.07)
BRIAN_COLLISION_RADIUS = np.float32(BRIAN_RADIUS * BRIAN_SCALE)

ELEMENT_FIRE = 0
ELEMENT_EARTH = 1
ELEMENT_WATER = 2
ELEMENT_WIND = 3

ENEMY_HP = 880
ENEMY_DEFENSE = 65
ENEMY_AGILITY = 77
ENEMY_ATTACK = 24
ENEMY_SIZE_MODIFIER = np.float32(0.07)
ENEMY_SIZE_RAW = 70
ENEMY_HEIGHT_RAW = 260
ENEMY_SIZE = np.float32(ENEMY_SIZE_MODIFIER * ENEMY_SIZE_RAW)
ENEMY_HEIGHT = ENEMY_HEIGHT_RAW * ENEMY_SIZE_MODIFIER

SPELL_POWER_AVALANCHE = 460
SPELL_POWER_ROCK_1 = 290
SPELL_POWER_WATER_1 = 365
SPELL_POWER_WATER_2 = 374
SPELL_POWER_WATER_3 = 384

AVALANCHE_ROCK_FALL_SPEED = 0.3
AVALANCHE_ROCK_INITIAL_HEIGHT = 32.4

DECISION_BARRIER = 0
DECISION_AVALANCHE = 1
DECISION_WEAKNESS = 2
DECISION_HEALING_ITEM = 3
DECISION_CONFUSION = 4
DECISION_MANA_ITEM = 5
DECISION_MELEE = 6
DECISION_WATER_1 = 7
DECISION_ROCK_1 = 8
DECISION_PASS = 9

decision_map = {
    DECISION_BARRIER: "Barrier",
    DECISION_AVALANCHE: "Avalanche",
    DECISION_WEAKNESS: "Weakness 2",
    DECISION_HEALING_ITEM: "Healing Item",
    DECISION_CONFUSION: "Confusion",
    DECISION_MANA_ITEM: "Mana Item",
    DECISION_MELEE: "Melee",
    DECISION_WATER_1: "Water 1",
    DECISION_ROCK_1: "Rock 1",
    DECISION_PASS: "Pass",
}

def get_decision_text(decision_code):
    if decision_code in decision_map:
        return decision_map[decision_code]
    return f"Unknown: {decision_code}"

BONUS_TABLE = np.array([
    0.0240, # Level 1,  Bonus Percent: 2.4%,
    0.0281, # Level 2,  Bonus Percent: 2.8%,
    0.0324, # Level 3,  Bonus Percent: 3.2%,
    0.0367, # Level 4,  Bonus Percent: 3.7%,
    0.0412, # Level 5,  Bonus Percent: 4.1%,
    0.0459, # Level 6,  Bonus Percent: 4.6%,
    0.0506, # Level 7,  Bonus Percent: 5.1%,
    0.0556, # Level 8,  Bonus Percent: 5.6%,
    0.0606, # Level 9,  Bonus Percent: 6.1%,
    0.0659, # Level 10, Bonus Percent: 6.6%,
    0.0712, # Level 11, Bonus Percent: 7.1%,
    0.0768, # Level 12, Bonus Percent: 7.7%,
    0.0825, # Level 13, Bonus Percent: 8.2%,
    0.0883, # Level 14, Bonus Percent: 8.8%,
    0.0944, # Level 15, Bonus Percent: 9.4%,
    0.1006, # Level 16, Bonus Percent: 10.1%,
    0.1070, # Level 17, Bonus Percent: 10.7%,
    0.1137, # Level 18, Bonus Percent: 11.4%,
    0.1205, # Level 19, Bonus Percent: 12.1%,
    0.1275, # Level 20, Bonus Percent: 12.8%,
    0.1347, # Level 21, Bonus Percent: 13.5%,
    0.1421, # Level 22, Bonus Percent: 14.2%,
    0.1498, # Level 23, Bonus Percent: 15.0%,
    0.1577, # Level 24, Bonus Percent: 15.8%,
    0.1658, # Level 25, Bonus Percent: 16.6%,
    0.1742, # Level 26, Bonus Percent: 17.4%,
    0.1828, # Level 27, Bonus Percent: 18.3%,
    0.1917, # Level 28, Bonus Percent: 19.2%,
    0.2009, # Level 29, Bonus Percent: 20.1%,
    0.2103, # Level 30, Bonus Percent: 21.0%,
    0.2200, # Level 31, Bonus Percent: 22.0%,
    0.2300, # Level 32, Bonus Percent: 23.0%,
    0.2403, # Level 33, Bonus Percent: 24.0%,
    0.2509, # Level 34, Bonus Percent: 25.1%,
    0.2618, # Level 35, Bonus Percent: 26.2%,
    0.2731, # Level 36, Bonus Percent: 27.3%,
    0.2847, # Level 37, Bonus Percent: 28.5%,
    0.2966, # Level 38, Bonus Percent: 29.7%,
    0.3089, # Level 39, Bonus Percent: 30.9%,
    0.3216, # Level 40, Bonus Percent: 32.2%,
    0.3347, # Level 41, Bonus Percent: 33.5%,
    0.3481, # Level 42, Bonus Percent: 34.8%,
    0.3619, # Level 43, Bonus Percent: 36.2%,
    0.3762, # Level 44, Bonus Percent: 37.6%,
    0.3909, # Level 45, Bonus Percent: 39.1%,
    0.4060, # Level 46, Bonus Percent: 40.6%,
    0.4216, # Level 47, Bonus Percent: 42.2%,
    0.4376, # Level 48, Bonus Percent: 43.8%,
    0.4542, # Level 49, Bonus Percent: 45.4%,
    0.4712, # Level 50, Bonus Percent: 47.1%,
    0.4887, # Level 51, Bonus Percent: 48.9%,
    0.5068, # Level 52, Bonus Percent: 50.7%,
    0.5254, # Level 53, Bonus Percent: 52.5%,
    0.5445, # Level 54, Bonus Percent: 54.5%,
    0.5643, # Level 55, Bonus Percent: 56.4%,
    0.5846, # Level 56, Bonus Percent: 58.5%,
    0.6056, # Level 57, Bonus Percent: 60.6%,
    0.6271, # Level 58, Bonus Percent: 62.7%,
    0.6493, # Level 59, Bonus Percent: 64.9%,
    0.6722, # Level 60, Bonus Percent: 67.2%,
    0.6958, # Level 61, Bonus Percent: 69.6%,
    0.7201, # Level 62, Bonus Percent: 72.0%,
    0.7451, # Level 63, Bonus Percent: 74.5%,
    0.7708, # Level 64, Bonus Percent: 77.1%,
    0.7973, # Level 65, Bonus Percent: 79.7%
], dtype=np.float32)

BONUS_TOTAL = len(BONUS_TABLE)
BONUS_MAX = BONUS_TABLE[-1]
BONUS_MIN = 0.2

NEPTY_SHIELD_POWER = 500
NEPTY_SHIELD_ACCURACY = 100
NEPTY_SHIELD_RANGE = 17.50
NEPTY_SHIELD_RNG_ADVANCES = 30

NEPTY_BUBBLE_POWER = 200
NEPTY_BUBBLE_ACCURACY = 90
NEPTY_BUBBLE_RANGE = 56.00
NEPTY_BUBBLE_PROJECTILES = 3
NEPTY_BUBBLE_RNG_ADVANCES = 30

NEPTY_MOVEMENT_CYCLE_DISTANCE = 12.04

NEPTY_START_POSITION_X = np.float32(419.8)
NEPTY_START_POSITION_Y = np.float32(0)
NEPTY_START_POSITION_Z = np.float32(-172.95)

def advance_lcg(a, c, m, steps):
    a_n = pow(a, steps, m)

    sum_ = 0
    cur = 1
    for _ in range(steps):
        sum_ = (sum_ + cur) % m
        cur = (cur * a) % m

    c_n = (c * sum_) % m
    return a_n, c_n

# Constants
a = 0x41C64E6D
c = 0x3039
m = 2**32

a_240=0x3BE331C1
c_240=0xDEA2B5D0
a_90=0x9E7E03C9
c_90=0x948784C6
a_32=0x8B2E1481
c_32=0x642B7E60
a_31=0xF53981E5
c_31=0x0202A263
a_30=0x4E6A7659
c_30=0x961D9892
a_2=0xC2A29A69
c_2=0xD3DC167E

# a_240, c_240 = advance_lcg(a, c, m, 240)
# a_90, c_90 = advance_lcg(a, c, m, 90)
# a_32, c_32 = advance_lcg(a, c, m, 32)
# a_31, c_31 = advance_lcg(a, c, m, 31)
# a_30, c_30 = advance_lcg(a, c, m, 30)
# a_2, c_2 = advance_lcg(a, c, m, 2)

# print(f"{a_240=:8X}, {c_240=:8X}")
# print(f"{a_90=:8X}, {c_90=:8X}")
# print(f"{a_32=:8X}, {c_32=:8X}")
# print(f"{a_31=:8X}, {c_31=:8X}")
# print(f"{a_30=:8X}, {c_30=:8X}")
# print(f"{a_2=:8X}, {c_2=:8X}")

@njit
def get_movement_radius(actor_agility) -> float:
    return 17 + actor_agility * 0.2857

BRIAN_MOVEMENT_RADIUS = get_movement_radius(BRIAN_AGILITY)
NEPTY_MOVEMENT_RADIUS = get_movement_radius(ENEMY_AGILITY)

# exit(0)

@njit
def advance_rng_240(current_rng) -> int:
    return (current_rng * a_240 + c_240) & 0xFFFFFFFF

@njit
def advance_rng_90(current_rng) -> int:
    return (current_rng * a_90 + c_90) & 0xFFFFFFFF

@njit
def advance_rng_32(current_rng) -> int:
    return (current_rng * a_32 + c_32) & 0xFFFFFFFF

@njit
def advance_rng_31(current_rng) -> int:
    return (current_rng * a_31 + c_31) & 0xFFFFFFFF

@njit
def advance_rng_30(current_rng) -> int:
    return (current_rng * a_30 + c_30) & 0xFFFFFFFF

@njit
def advance_rng_2(current_rng) -> int:
    return (current_rng * a_2 + c_2) & 0xFFFFFFFF

@njit
def next_rng(current_rng) -> int:
    return (current_rng * 0x41C64E6D + 0x3039) & 0xFFFFFFFF

@njit
def roll_rng(current_rng: int, value_range: int):
    if value_range == 0:
        return 0

    base = current_rng >> 16
    roll = base % value_range

    return roll

@njit()
def roll_for_variation(max_value):
    return random.randint(1, max_value)

@njit()
def coinflip():
    return roll_for_variation(2) == 1

@njit()
def get_bonus_table():
    return BONUS_TABLE

@njit()
def get_coord_distance(ax, az, bx, bz):
    dx = ax - bx
    dz = az - bz
    
    return math.sqrt(dx*dx + dz*dz)

@njit()
def get_array_distance(a, b):
    dx = a[0] - b[0]
    dz = a[1] - b[1]
    
    return math.sqrt(dx*dx + dz*dz)

@njit()
def get_coord_direction(from_x, from_z, to_x, to_z):
    dx = to_x - from_x
    dz = to_z - from_z
    d = math.sqrt(dx*dx + dz*dz)
    
    return dx / d, dz / d

@njit()
def get_array_direction(point_from, point_to):
    dx = point_to[0] - point_from[0]
    dz = point_to[1] - point_from[1]
    d = math.sqrt(dx*dx + dz*dz)
    
    return dx / d, dz / d

@njit()
def get_collision_distance_to_brian(brian_x, brian_z, enemy_x, enemy_z):
    
    dx = enemy_x - brian_x
    dz = enemy_z - brian_z
    distance_to_brian = math.sqrt(dx * dx + dz * dz) - BRIAN_COLLISION_RADIUS

    return distance_to_brian

@njit()
def get_brian_element_power(element):

    fire_factor = BRIAN_FIRE >> 3
    earth_factor = BRIAN_EARTH >> 3
    water_factor = BRIAN_WATER >> 3
    wind_factor = BRIAN_WIND >> 3

    if element == ELEMENT_FIRE:
        fire_factor = BRIAN_FIRE
        water_factor = BRIAN_WATER >> 4
    
    if element == ELEMENT_EARTH:
        earth_factor = BRIAN_EARTH
        wind_factor = BRIAN_WIND >> 4
    
    if element == ELEMENT_WATER:
        water_factor = BRIAN_WATER
        fire_factor = BRIAN_FIRE >> 4
    
    if element == ELEMENT_WIND:
        wind_factor = BRIAN_WIND
        earth_factor = BRIAN_EARTH >> 4
    
    return fire_factor + earth_factor + water_factor + wind_factor

@njit()
def get_spell_bonus(attack_power: int) -> float:
        
    if attack_power >= BONUS_TOTAL:
        return BONUS_MAX

    if attack_power < 0:
        return BONUS_MIN
    
    table = get_bonus_table()
    return table[attack_power]

@njit()
def calculate_hit_chance(attacker_agi, defender_agi):
    
    top = attacker_agi * 100.0
    bottom = attacker_agi + math.floor((defender_agi + 7.0) / 8.0)
    # top = attacker_agi * 100
    # bottom = attacker_agi + (defender_agi + 7) >> 3

    hit_chance = math.floor(top / bottom)
    return hit_chance

@njit()
def calculate_brian_min_damage(element: int, spell_power: int, weakness_active: bool):
    
    element_level = get_brian_element_power(element)
    spell_bonus = get_spell_bonus(element_level - 1)

    resulting_power = spell_power * spell_bonus

    affinity = 1
    raw_damage = resulting_power * affinity

    enemy_defense = ENEMY_DEFENSE
    if weakness_active:
        enemy_defense *= 0.5
    
    defense_coefficient = TOTAL_ELEMENTS / (TOTAL_ELEMENTS + enemy_defense)
    damage_min = math.floor(math.floor(raw_damage) * defense_coefficient)

    return damage_min

@njit()
def calculate_enemy_min_damage(attack_power, spell_power) -> int:

    bonus_percent = get_spell_bonus(attack_power - 1)
    resulting_power = spell_power * bonus_percent
    
    raw_damage = resulting_power
    
    defense_coefficient = attack_power / (attack_power + BRIAN_DEFENSE)
    damage_min = math.floor(math.floor(raw_damage) * defense_coefficient)
    
    return damage_min

@njit()
def does_rock_overlap_nepty(rock_x, rock_y, rock_z, nepty_x, nepty_z):
    
    cx = nepty_x
    cy = 0
    cz = nepty_z
    
    collision_radius = ENEMY_SIZE
    collision_height = ENEMY_HEIGHT

    dx = cx - rock_x
    dz = cz - rock_z
    
    dy = (cy + collision_height * 0.5 - rock_y) * 0.5

    radial_sum = 10.0 + collision_radius
    elliptical_distance = math.sqrt(dx*dx + dy*dy + dz*dz)

    return radial_sum > elliptical_distance

@njit()
def simulate_avalanche_rock_hit(seed: int, weakness_active) -> Tuple[bool, int, int]:
    
    accuracy_seed = next_rng(seed)    
    agility_seed = next_rng(accuracy_seed)
    
    hit_chance = calculate_hit_chance(BRIAN_AGILITY, ENEMY_AGILITY)
    hit_roll = roll_rng(agility_seed, 100)
    
    if hit_roll >= hit_chance:
        return False, 0, agility_seed
    
    damage_seed = next_rng(agility_seed)
    damage_min = calculate_brian_min_damage(ELEMENT_EARTH, SPELL_POWER_AVALANCHE, weakness_active)
    damage_range = math.floor(math.sqrt(damage_min))
    damage_roll = roll_rng(damage_seed, damage_range + 1)
    
    damage = damage_min + damage_roll
    
    return True, damage, damage_seed

@njit()
def simulate_avalanche(seed: int, brian_x, brian_z, nepty_x, nepty_z, weakness_active=False, debug=False):
    rock_overlaps = 0
    rock_hits = 0
    total_damage = 0

    rock_delay = 5
    next_rock_at = 0
    harmless_duration = 4
    max_rocks = 10

    rock_coords = np.zeros((10, 3), dtype=np.float32)
    rock_properties = np.zeros((10, 2), dtype=np.uint8)
    
    rocks_released = 0
    collisions_observed = 0
    collisions_processed = 0
    
    COLLISION_DISABLED = 0
    COLLISION_QUEUED = 1
    COLLISION_PROCESSED = 2
    
    # if debug:
    #     print(f"[{seed:08X}] == START ==")

    for current_frame in range(1, rock_delay * 10 + harmless_duration * 2 + 1):
        for rock_index in range(rocks_released):

            (x, y, z) = rock_coords[rock_index]
            (frames_active, collision_state) = rock_properties[rock_index]

            collision_enabled = frames_active >= harmless_duration
            rock_can_damage = collision_enabled and collision_state != COLLISION_PROCESSED
            
            if rock_can_damage:
                
                falling_frames = frames_active - harmless_duration + 1
                y -= AVALANCHE_ROCK_FALL_SPEED * falling_frames
                
                rock_coords[rock_index] = [x, y, z]
                
                # recently_activated = frames_active == harmless_duration
                # if recently_activated:
                #     if debug:
                #         print(f"[{seed:08X}] PRE-COLLISION, Rock {rock_index}")
                
                overlaps_enemy = does_rock_overlap_nepty(x, y, z, nepty_x, nepty_z)
                if overlaps_enemy:
                    rock_properties[rock_index, 1] = COLLISION_QUEUED
                    collisions_observed += 1
            
            rock_properties[rock_index, 0] += 1
        
        allow_more_rocks = rocks_released < max_rocks
        if allow_more_rocks and (current_frame >= next_rock_at):
            
            next_rock_at = next_rock_at + rock_delay
            
            offset_seed = next_rng(seed)
            angle_seed = next_rng(offset_seed)
            
            offset_roll = roll_rng(offset_seed, 20)
            angle_roll = roll_rng(angle_seed, 16)

            seed = angle_seed

            angle = angle_roll * 22.5 * math.pi / 180.0
            offset = 20 + offset_roll

            rock_x = brian_x - offset * math.sin(angle)
            rock_y = AVALANCHE_ROCK_INITIAL_HEIGHT
            rock_z = brian_z - offset * math.cos(angle)
            
            rock_coords[rocks_released] = [rock_x, rock_y, rock_z]
            rocks_released += 1

        if collisions_processed < collisions_observed:
            for rock_index in range(10):
                
                collision_state = rock_properties[rock_index, 1]
                if collision_state == COLLISION_QUEUED:
                    rock_overlaps += 1
                    
                    hit, damage, final_seed = simulate_avalanche_rock_hit(seed, weakness_active)
                    if hit:
                        rock_hits += 1
                        total_damage += damage
                        
                    seed = final_seed
                
                    # if debug:
                    #     (rock_x, rock_y, rock_z) = rock_coords[rock_index]
                    #     print(f"[{seed:8X}] POST-COLLISION, Rock {rock_index} - {hit}: {damage}")
                    #     print(f"[{seed:8X}] POST-COLLISION, Rock {rock_index} - {rock_x:.1f}, {rock_y:.1f}, {rock_z:.1f}")
                        
                    collisions_processed += 1
                    rock_properties[rock_index, 1] = COLLISION_PROCESSED
    
        # if debug:
        #     print(f"[{seed:08X}] Frame {current_frame}")
    
    return rock_hits, total_damage, seed

@njit()
def simulate_barrier(seed, is_jp=False):
    
    hit_seed = advance_rng_31(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= 90:
        return False, hit_roll, 0, hit_seed
    
    turn_seed = next_rng(hit_seed)
    turns = 2 + roll_rng(turn_seed, 5 if is_jp else 2)
    
    return True, hit_roll, turns, turn_seed

@njit()
def simulate_confusion(seed):

    hit_seed = next_rng(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= 90:
        return False, hit_roll, 0, advance_rng_30(hit_seed)
    
    turn_seed = next_rng(hit_seed)
    turns = 2 + roll_rng(turn_seed, 5)
    
    return True, hit_roll, turns, advance_rng_30(turn_seed)

@njit()
def simulate_weakness(seed):
    
    hit_seed = next_rng(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= 90:
        return False, hit_roll, 0, advance_rng_30(hit_seed)
    
    agility_seed = next_rng(hit_seed)
    agility_chance = calculate_hit_chance(BRIAN_AGILITY, ENEMY_AGILITY)
    agility_roll = roll_rng(agility_seed, 100)
    
    if agility_roll >= agility_chance:
        return False, agility_roll, 0, advance_rng_30(agility_seed)
    
    status_seed = next_rng(agility_seed)
    status_chance = 20
    status_roll = roll_rng(status_seed, 32)
    
    if status_roll >= status_chance:
        return False, status_roll, 0, advance_rng_30(status_seed)
    
    turn_seed = next_rng(status_seed)
    turns = 2 + roll_rng(turn_seed, 5)
    
    return True, status_roll, turns, advance_rng_30(turn_seed)

@njit()
def simulate_generic_damaging_spell(seed, element, spell_power, weakness_active=False):
    
    accuracy_seed = next_rng(seed)
    accuracy_roll = roll_rng(accuracy_seed, 100)
    if accuracy_roll >= 100:
        return False, 0, accuracy_seed
    
    hit_seed = next_rng(accuracy_seed)
    hit_chance = calculate_hit_chance(BRIAN_AGILITY, ENEMY_AGILITY)
    hit_roll = roll_rng(hit_seed, 100)

    if hit_roll >= hit_chance:
        return False, 0, hit_seed

    damage_seed = next_rng(hit_seed)
    damage_min = calculate_brian_min_damage(element, spell_power, weakness_active)
    damage_range = math.floor(math.sqrt(damage_min))

    damage_roll = roll_rng(damage_seed, damage_range + 1)
    damage = damage_min + damage_roll

    return True, damage, damage_seed

@njit()
def simulate_water_1(seed, weakness_active=False):
    particle_seed = advance_rng_30(seed)
    return simulate_generic_damaging_spell(particle_seed, ELEMENT_WATER, SPELL_POWER_WATER_1, weakness_active)

@njit()
def simulate_rock_1(seed, weakness_active=False):
    return simulate_generic_damaging_spell(seed, ELEMENT_EARTH, SPELL_POWER_ROCK_1, weakness_active)

@njit()
def simulate_brian_melee(seed, weakness_active=False, back_attack=False, is_combo=False, can_crit=False):
    
    if is_combo and ALLOW_MISTAKES and coinflip():
        return False, 0, seed
    
    agility_seed = next_rng(seed)
    agility_chance = calculate_hit_chance(BRIAN_AGILITY, ENEMY_AGILITY)
    agility_roll = roll_rng(agility_seed, 100)

    if agility_roll >= agility_chance:
        return False, 0, agility_seed

    total_elements = TOTAL_ELEMENTS
    power = math.floor(total_elements * 1.5)
    
    reduction_threshold = total_elements >> 2
    total_penalty = 0

    if ELEMENT_FIRE > reduction_threshold:
        total_penalty += ELEMENT_FIRE - reduction_threshold
    
    if ELEMENT_EARTH > reduction_threshold:
        total_penalty += ELEMENT_EARTH - reduction_threshold
    
    if ELEMENT_WATER > reduction_threshold:
        total_penalty += ELEMENT_WATER - reduction_threshold
    
    if ELEMENT_WIND > reduction_threshold:
        total_penalty += ELEMENT_WIND - reduction_threshold

    element_damage = power - total_penalty
    back_attack_bonus = 0.5 if back_attack else 0.0
    raw_damage = (element_damage * math.floor(BRIAN_STAFF_POWER * (1 + back_attack_bonus))) >> 4

    enemy_defense = ENEMY_DEFENSE
    
    if weakness_active:
        enemy_defense = enemy_defense >> 1
    if is_combo:
        raw_damage = raw_damage >> 1
    
    defense_coefficient = total_elements / (total_elements + enemy_defense)

    damage_seed = next_rng(agility_seed)
    damage_min = math.floor(raw_damage * defense_coefficient)
    
    if can_crit:
        damage_seed = next_rng(damage_seed)
        crit_roll = roll_rng(damage_seed, 0x20)
        if crit_roll == 0:
            damage_min = (damage_min + ((damage_min + 1) >> 1)) & 0xFFFF

    damage_range = math.floor(math.sqrt(damage_min) + 1)
    damage = damage_min + roll_rng(damage_seed, damage_range)

    return True, damage, damage_seed

@njit()
def simulate_brian_avalanche_turn(seed, can_attack, brian_stats, brian_buffs, turns_since_barrier, brian_coords, nepty_coords, enemy_stats, enemy_debuffs, is_jp=False, healing_items=2, mana_items=2, turns_between_barriers=3) -> Tuple[int, int, bool]:
    cannot_attack = not can_attack
    
    can_afford_spells = brian_stats[1] >= 3
    can_afford_cheap_spells = brian_stats[1] >= 1
    
    weakness_currently_active = enemy_debuffs[0] > 0
    
    # Coords
    #
    brian_x = brian_coords[0]
    brian_z = brian_coords[1]
    nepty_x = nepty_coords[0]
    nepty_z = nepty_coords[1]

    if brian_stats[0] <= 50 and (healing_items > 0):
        brian_stats[0] = BRIAN_HP
        return DECISION_HEALING_ITEM, seed, True
    
    # We play Nepty a little differently in JP
    #
    should_barrier = (turns_since_barrier >= turns_between_barriers) or brian_buffs[0] == 0

    if can_afford_spells and should_barrier:
        
        # For Barrier, we want to stay away so that Nepty ideally
        # rolls for Bubble -- in case we miss.
        #
        nepty_to_brian_x, nepty_to_brian_z = get_array_direction(nepty_coords, brian_coords)
        random_distance = NEPTY_BUBBLE_RANGE + 5.0

        ideal_x = nepty_to_brian_x * random_distance + nepty_coords[0]
        ideal_z = nepty_to_brian_z * random_distance + nepty_coords[1]
        
        distance_to_ideal = get_coord_distance(brian_x, brian_z, ideal_x, ideal_z)
        if distance_to_ideal > BRIAN_MOVEMENT_RADIUS:
            distance_to_ideal = BRIAN_MOVEMENT_RADIUS

        brian_to_ideal_x, brian_to_ideal_z = get_coord_direction(brian_x, brian_z, ideal_x, ideal_z)

        brian_coords[0] += brian_to_ideal_x * distance_to_ideal
        brian_coords[1] += brian_to_ideal_z * distance_to_ideal

        barrier_hit, barrier_roll, barrier_turns, barrier_seed = simulate_barrier(seed, is_jp=is_jp)

        brian_stats[1] -= 3
        brian_buffs[0] = barrier_turns + 1

        return DECISION_BARRIER, barrier_seed, barrier_hit
    
    # Prefer to use a mana item, but use Confusion if we are out
    #
    elif (brian_stats[1] <= 3):
        if mana_items > 0:
            brian_stats[1] = BRIAN_MP
            return DECISION_MANA_ITEM, seed, True
        
        elif can_afford_spells:
            
            # For Confusion, we want to stay away so that Nepty ideally
            # rolls for Bubble
            #
            nepty_to_brian_x, nepty_to_brian_z = get_array_direction(nepty_coords, brian_coords)
            random_distance = NEPTY_BUBBLE_RANGE + 5.0

            ideal_x = nepty_to_brian_x * random_distance + nepty_coords[0]
            ideal_z = nepty_to_brian_z * random_distance + nepty_coords[1]
            
            distance_to_ideal = get_coord_distance(brian_x, brian_z, ideal_x, ideal_z)
            if distance_to_ideal > BRIAN_MOVEMENT_RADIUS:
                distance_to_ideal = BRIAN_MOVEMENT_RADIUS

            brian_to_ideal_x, brian_to_ideal_z = get_coord_direction(brian_x, brian_z, ideal_x, ideal_z)

            brian_coords[0] += brian_to_ideal_x * distance_to_ideal
            brian_coords[1] += brian_to_ideal_z * distance_to_ideal
            
            confusion_hit, _, confusion_turns, confusion_seed = simulate_confusion(seed)

            if confusion_hit:
                brian_buffs[1] = confusion_turns + 1
            
            return DECISION_CONFUSION, confusion_seed, confusion_hit

    if can_attack and can_afford_spells:

        # Move Brian to roughly 25 units away from Nepty based on
        # the current direction to her
        #
        nepty_to_brian_x, nepty_to_brian_z = get_array_direction(nepty_coords, brian_coords)

        # print("")
        # print(f"Nepty to Brian: {nepty_to_brian_x:.4f}, {nepty_to_brian_z:.4f}")

        random_distance = 25.0 + 4 - random.random() * 2

        ideal_x = nepty_to_brian_x * random_distance + nepty_coords[0]
        ideal_z = nepty_to_brian_z * random_distance + nepty_coords[1]
        
        distance_to_ideal = get_coord_distance(brian_x, brian_z, ideal_x, ideal_z)

        if distance_to_ideal > BRIAN_MOVEMENT_RADIUS:
            distance_to_ideal = BRIAN_MOVEMENT_RADIUS

        direction_to_ideal_x, direction_to_ideal_z = get_coord_direction(brian_x, brian_z, ideal_x, ideal_z)
        
        # print(f"Brian to Ideal: {direction_to_ideal_x:.4f}, {direction_to_ideal_z:.4f}")
        # print("")
        # print(f"Brian: {brian_x:.4f}, {brian_z:.4f}")
        # print(f"Ideal: {ideal_x:.4f}, {ideal_z:.4f}")
        # print(f"Nepty: {nepty_x:.4f}, {nepty_z:.4f}")
        # print("")

        brian_coords[0] += direction_to_ideal_x * distance_to_ideal
        brian_coords[1] += direction_to_ideal_z * distance_to_ideal

        # print(brian_coords, nepty_coords, get_array_distance(brian_coords, nepty_coords))

        avalanche_hits, avalanche_damage, avalanche_seed = simulate_avalanche(seed, brian_coords[0], brian_coords[1], nepty_x, nepty_z, weakness_currently_active)

        brian_stats[1] -= 3
        enemy_stats[0] -= avalanche_damage
        return DECISION_AVALANCHE, avalanche_seed, True
    
    elif cannot_attack and can_afford_cheap_spells:
        # For Rock, we want to stay away so that Nepty ideally
        # rolls for Bubble
        #
        nepty_to_brian_x, nepty_to_brian_z = get_array_direction(nepty_coords, brian_coords)
        random_distance = NEPTY_BUBBLE_RANGE + 5.0

        ideal_x = nepty_to_brian_x * random_distance + nepty_coords[0]
        ideal_z = nepty_to_brian_z * random_distance + nepty_coords[1]
        
        distance_to_ideal = get_coord_distance(brian_x, brian_z, ideal_x, ideal_z)
        if distance_to_ideal > BRIAN_MOVEMENT_RADIUS:
            distance_to_ideal = BRIAN_MOVEMENT_RADIUS

        brian_to_ideal_x, brian_to_ideal_z = get_coord_direction(brian_x, brian_z, ideal_x, ideal_z)

        brian_coords[0] += brian_to_ideal_x * distance_to_ideal
        brian_coords[1] += brian_to_ideal_z * distance_to_ideal

        rock_hit, rock_damage, rock_seed = simulate_rock_1(seed, weakness_currently_active)

        brian_stats[1] -= 1
        enemy_stats[0] -= rock_damage
        return DECISION_ROCK_1, rock_seed, True

    else:
        # For Melee, we will need to get close
        #
        distance_to_melee = get_coord_distance(brian_x, brian_z, nepty_x, nepty_z) - 3.5 - ENEMY_SIZE
        if distance_to_melee <= BRIAN_MOVEMENT_RADIUS:

            brian_to_ideal_x, brian_to_ideal_z = get_array_direction(nepty_coords, brian_coords)

            brian_coords[0] = brian_to_ideal_x * (3.5 + ENEMY_SIZE) + nepty_coords[0]
            brian_coords[1] = brian_to_ideal_z * (3.5 + ENEMY_SIZE) + nepty_coords[1]

            melee_hit, melee_damage, melee_seed = simulate_brian_melee(seed, weakness_currently_active, back_attack=True, can_crit=is_jp)
            combo_hit, combo_damage, combo_seed = simulate_brian_melee(melee_seed, weakness_currently_active, back_attack=True, is_combo=True, can_crit=is_jp)

            melee_hit_count = 0
            if melee_hit:
                melee_hit_count += 1
            if combo_hit:
                melee_hit_count += 1
            
            melee_damage = melee_damage + combo_damage
            melee_seed = combo_seed
            
            brian_stats[1] += melee_hit_count
            enemy_stats[0] -= melee_damage
            return DECISION_MELEE, melee_seed, True
        
        else:
            return DECISION_PASS, seed, False


@njit()
def simulate_brian_melee_turn(seed, can_attack, brian_stats, brian_buffs, turns_since_barrier, enemy_stats, enemy_debuffs, is_jp=False, healing_items=2, mana_items=2) -> Tuple[int, int, bool]:
    cannot_attack = not can_attack
    
    can_afford_spells = brian_stats[1] >= 3
    can_afford_cheap_spells = brian_stats[1] >= 1
    
    weakness_currently_active = enemy_debuffs[0] > 0
    
    # avalanche_hits, avalanche_damage, avalanche_seed = simulate_avalanche(seed, nepty_x, nepty_z, weakness_currently_active)
    melee_hit, melee_damage, melee_seed = simulate_brian_melee(seed, weakness_currently_active, back_attack=True, can_crit=is_jp)
    combo_hit, combo_damage, combo_seed = simulate_brian_melee(melee_seed, weakness_currently_active, back_attack=True, is_combo=True, can_crit=is_jp)
    # water_hit, water_damage, water_seed = simulate_water_1(seed, weakness_currently_active)
    rock_hit, rock_damage, rock_seed = simulate_rock_1(seed, weakness_currently_active)

    melee_hit_count = 0
    if melee_hit:
        melee_hit_count += 1
    if combo_hit:
        melee_hit_count += 1
    
    melee_damage = melee_damage + combo_damage
    melee_seed = combo_seed

    # if can_attack and melee_damage >= enemy_stats[0]:
    #     brian_stats[1] += melee_hit_count
    #     enemy_stats[0] -= melee_damage
    #     return DECISION_MELEE, melee_seed

    ## Unlike Mammon, Nepty will be in 2-shot range for the entire fight,
    ## making it much more dangerous to play around without barrier.
    ##
    ## We will weight this much more heavily here.
    ##
    should_barrier = (turns_since_barrier >= 2) or brian_buffs[0] == 0
    barrier_hit, barrier_roll, barrier_turns, barrier_seed = simulate_barrier(seed, is_jp=is_jp)
    
    if can_afford_spells and should_barrier:
        brian_stats[1] -= 3
        brian_buffs[0] = barrier_turns + 1

        return DECISION_BARRIER, barrier_seed, barrier_hit
    
    if brian_stats[0] <= 50 and (healing_items > 0):
        brian_stats[0] = BRIAN_HP
        return DECISION_HEALING_ITEM, seed, True
    
    # ## Confusion Check
    # ##
    # ## Prioritize the confusion roll bias when we're low on mana,
    # ## with much lower odds when we're comfy.
    # ##
    # confusion_bias = (brian_stats[1] <= 9 and roll_for_variation(5) == 1) or (roll_for_variation(12) == 1)
    # confusion_not_strong = brian_buffs[1] <= 1
    # confusion_hit, _, confusion_turns, confusion_seed = simulate_confusion(seed)
    
    # if can_afford_spells and confusion_not_strong and confusion_bias and confusion_hit and confusion_turns >= 2:
    #     brian_stats[1] -= 3
    #     brian_buffs[1] = confusion_turns
    #     return DECISION_CONFUSION, confusion_seed
    
    
    # # if can_attack and can_afford_spells and avalanche_damage >= 140:
    # #     brian_stats[1] -= 3
    # #     enemy_stats[0] -= avalanche_damage
    # #     return DECISION_AVALANCHE, avalanche_seed
    
    # melee_bias = ((not can_afford_spells) and coinflip()) or (roll_for_variation(4) == 1)
    # if can_attack and melee_hit and melee_bias:
    #     brian_stats[1] += 1
    #     enemy_stats[0] -= melee_damage
    #     return DECISION_MELEE, melee_seed
    
    # if can_attack and can_afford_spells and avalanche_hits >= 1:
    #     brian_stats[1] -= 3
    #     enemy_stats[0] -= avalanche_damage
    #     return DECISION_AVALANCHE, avalanche_seed
    
    ## Prefer to heal here, but allow for variance
    ##
    elif (brian_stats[1] <= 3) and (mana_items > 0):
        brian_stats[1] = BRIAN_MP
        return DECISION_MANA_ITEM, seed, True

    elif cannot_attack and can_afford_cheap_spells:
        brian_stats[1] -= 1
        enemy_stats[0] -= rock_damage
        return DECISION_ROCK_1, rock_seed, True

    else:
        brian_stats[1] += melee_hit_count
        enemy_stats[0] -= melee_damage
        return DECISION_MELEE, melee_seed, True

attack_decisions = np.array([DECISION_AVALANCHE, DECISION_MELEE, DECISION_ROCK_1, DECISION_WATER_1], dtype=int)
expensive_decisions = np.array([DECISION_AVALANCHE, DECISION_BARRIER, DECISION_CONFUSION], dtype=int)

@njit()
def simulate_brian_turn_explicit(seed, decision_code, can_attack, brian_stats, brian_buffs, ENEMY_stats, ENEMY_debuffs, nepty_position) -> int:

    if not can_attack and decision_code in attack_decisions:
        return seed

    can_afford_spells = brian_stats[1] >= 3

    if not can_afford_spells and decision_code in expensive_decisions:
        return seed

    weakness_currently_active = ENEMY_debuffs[0] > 0

    if decision_code == DECISION_AVALANCHE:
        rock_hits, avalanche_damage, avalanche_seed = simulate_avalanche(seed, nepty_position[0], nepty_position[1], weakness_currently_active)
        brian_stats[1] -= 3
        ENEMY_stats[0] -= avalanche_damage
        return avalanche_seed
    
    if decision_code == DECISION_BARRIER:
        barrier_hit, barrier_roll, barrier_turns, barrier_seed = simulate_barrier(seed)
        brian_stats[1] -= 3
        if barrier_hit:
            brian_buffs[0] = barrier_turns + 1
        return barrier_seed
    
    if decision_code == DECISION_WEAKNESS:
        weakness_hit, weakness_roll, weakness_turns, weakness_seed = simulate_weakness(seed)
        brian_stats[1] -= 3
        if weakness_hit:
            ENEMY_debuffs[0] = weakness_turns
        return weakness_seed
    
    if decision_code == DECISION_CONFUSION:
        confusion_hit, _, confusion_turns, confusion_seed = simulate_confusion(seed)
        brian_stats[1] -= 3
        if confusion_hit:
            brian_buffs[1] = confusion_turns + 1
        return confusion_seed
    
    elif decision_code == DECISION_MELEE:
        melee_hit, melee_damage, melee_seed = simulate_brian_melee(seed, weakness_currently_active)
        brian_stats[1] += 1
        ENEMY_stats[0] -= melee_damage
        return melee_seed

    elif decision_code == DECISION_MANA_ITEM:
        brian_stats[1] = BRIAN_MP
        return seed
    
    elif decision_code == DECISION_HEALING_ITEM:
        brian_stats[0] = BRIAN_HP
        return seed

    can_afford_cheap_spells = brian_stats[1] >= 1
    
    if decision_code == DECISION_ROCK_1:
        rock_hit, rock_damage, rock_seed = simulate_rock_1(seed, weakness_currently_active)
        brian_stats[1] -= 1
        if rock_hit:
            ENEMY_stats[0] -= rock_damage
        return rock_seed
    
    elif decision_code == DECISION_WATER_1:
        water_hit, water_damage, water_seed = simulate_water_1(seed, weakness_currently_active)
        brian_stats[1] -= 1
        if water_hit:
            ENEMY_stats[0] -= water_damage
        return water_seed

    return seed

@njit()
def simulate_nepty_damage(seed, spell_accuracy, spell_power, can_crit=False):
    hit_seed = next_rng(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= spell_accuracy:
        return False, 0, hit_seed
    
    agi_seed = next_rng(hit_seed)
    agi_roll = roll_rng(agi_seed, 100)
    agi_chance = calculate_hit_chance(ENEMY_AGILITY, BRIAN_AGILITY)
    if agi_roll >= agi_chance:
        return False, 0, agi_seed
    
    damage_seed = next_rng(agi_seed)
    damage_min = calculate_enemy_min_damage(ENEMY_ATTACK, spell_power)
    
    if can_crit:
        damage_seed = next_rng(damage_seed)
        crit_roll = roll_rng(damage_seed, 0x20)
        if crit_roll == 0:
            damage_min = (damage_min + ((damage_min + 1) >> 1)) & 0xFFFF
    
    damage_range = math.floor(math.sqrt(damage_min))
    
    damage_roll = roll_rng(damage_seed, damage_range + 1)
    damage = damage_min + damage_roll
    
    return True, damage, damage_seed

@njit()
def simulate_nepty_shield(seed: int, is_jp=False):
    hit, damage, attack_seed = simulate_nepty_damage(seed, NEPTY_SHIELD_ACCURACY, NEPTY_SHIELD_POWER, can_crit=is_jp)
    particle_seed = advance_rng_30(attack_seed)
    
    return hit, damage, particle_seed

@njit()
def simulate_nepty_bubble_hit(seed: int, is_jp=False):
    hit, damage, attack_seed = simulate_nepty_damage(seed, NEPTY_BUBBLE_ACCURACY, NEPTY_BUBBLE_POWER, can_crit=is_jp)
    return hit, damage, attack_seed

@njit()
def apply_damage_to_brian(damage: int, brian_stats: List[int], brian_buffs: List[int], remove_buffs: bool) -> None:
    
    brian_has_confusion = brian_buffs[1] > 0
    if brian_has_confusion:
        brian_stats[1] += damage
        if brian_stats[1] > BRIAN_MP:
            brian_stats[1] = BRIAN_MP
    
    if remove_buffs:
        brian_buffs[1] = 0
        
    brian_stats[0] -= damage

@njit()
def simulate_nepty_turn_simple(seed: int, brian_stats, brian_buffs, barrier_turns, is_jp=False) -> Tuple[int, int]:
    
    if barrier_turns > 0:
        return advance_rng_30(seed), 0
    
    hit, damage, resulting_seed = simulate_nepty_shield(seed, is_jp=is_jp)

    if hit:
        apply_damage_to_brian(damage, brian_stats, brian_buffs, True)

    return resulting_seed, damage

@njit()
def simulate_nepty_turn_realistic(seed: int, brian_coords, nepty_coords, brian_stats, brian_buffs, barrier_turns, is_jp=False) -> Tuple[int, int]:
    
    [bx, bz] = brian_coords
    [nx, nz] = nepty_coords
    ai_distance = get_collision_distance_to_brian(bx, bz, nx, nz)
    
    # Brian is within Shield range and Nepty will cast it instantly
    # without rolling for any decisions
    #
    if ai_distance < NEPTY_SHIELD_RANGE:
        
        if barrier_turns > 0:
            return advance_rng_30(seed), 0
        
        hit, damage, resulting_seed = simulate_nepty_shield(seed, is_jp=is_jp)

        if hit:
            apply_damage_to_brian(damage, brian_stats, brian_buffs, True)

        return resulting_seed, damage
    
    # Nepty will approach Brian due to him being too far away
    #
    if ai_distance > NEPTY_BUBBLE_RANGE:
        
        # The enemy seems to move until they are just within the maximum range
        # for the spell
        #
        distance_outside_of_range = ai_distance - NEPTY_BUBBLE_RANGE
        movement_cycles = int(math.ceil(distance_outside_of_range / NEPTY_MOVEMENT_CYCLE_DISTANCE))
        movement_distance = movement_cycles * NEPTY_MOVEMENT_CYCLE_DISTANCE
        
        direction_x, direction_z = get_array_direction(nepty_coords, brian_coords)
        movement_x = direction_x * movement_distance
        movement_z = direction_z * movement_distance

        nepty_coords[0] += movement_x
        nepty_coords[1] += movement_z
        
        # print("Nepty Approach + Bubble:", nepty_coords, movement_x, movement_z, math.sqrt(movement_x**2 + movement_z**2), distance_outside_of_range)
        

        # Consider these as being too far away to actually hit Brian,
        # so we'll just advance the RNG and assume that the player
        # will dodge the shots
        #
        # Each shot advances the RNG by 30, so we'll do 90 total.
        #
        bubble_seed = advance_rng_90(seed)
        return bubble_seed, 0
    
    # If we're still here, then Brian's distance is inside of Bubble range,
    # but outside of Shield range.  In this case, Nepty will roll for what to do.
    #
    ai_seed = next_rng(seed)
    ai_roll = roll_rng(ai_seed, 2)
    
    will_approach_and_shield = ai_roll == 1
    
    if will_approach_and_shield:
        
        # Similar to the Bubble case above, move until Nepty is in shield range.
        #
        distance_outside_of_range = ai_distance - NEPTY_SHIELD_RANGE
        movement_cycles = int(math.ceil(distance_outside_of_range / NEPTY_MOVEMENT_CYCLE_DISTANCE))
        movement_distance = movement_cycles * NEPTY_MOVEMENT_CYCLE_DISTANCE
        
        direction_x, direction_z = get_array_direction(nepty_coords, brian_coords)
        movement_x = direction_x * movement_distance
        movement_z = direction_z * movement_distance
        
        nepty_coords[0] += movement_x
        nepty_coords[1] += movement_z

        # print("Nepty Approach + Shield:", nepty_coords, movement_x, movement_z, math.sqrt(movement_x**2 + movement_z**2), distance_outside_of_range)
        
        # Unlike the Bubble case, Shield is definitely going to hit Brian.
        #
        if barrier_turns > 0:
            return advance_rng_30(ai_seed), 0
        
        hit, damage, resulting_seed = simulate_nepty_shield(ai_seed, is_jp=is_jp)

        if hit:
            apply_damage_to_brian(damage, brian_stats, brian_buffs, True)

        return resulting_seed, damage

    else:
        
        # If she casts it in-place, then we will usually be hit by
        # the first one and nothing else.
        #
        bubble_seed = advance_rng_30(ai_seed)
        hit, damage, resulting_seed = simulate_nepty_bubble_hit(bubble_seed, is_jp=is_jp)
        
        particle_seed = advance_rng_30(resulting_seed)
        particle_seed = advance_rng_30(particle_seed)
        
        return particle_seed, damage

@njit()
def end_brian_turn(buffs):
    k = 0
    while k < len(buffs):
        if buffs[k] > 0:
            buffs[k] -= 1
        k += 1 

@njit()
def sim_nepty_with_melee(seed: int, max_turns: int) -> Tuple[bool, int, Tuple[np.longlong, np.longlong]]:

    brian_stats = [BRIAN_HP, BRIAN_MP]
    brian_buffs = [
        0, # Barrier
        0  # Confusion
    ]
    nepty_stats = [ENEMY_HP]
    nepty_debuffs = [0]
    
    decision_hi = np.longlong(0)
    decision_lo = np.longlong(0)
    
    healing_items = 1
    mana_items = 2
    
    turns = 0
    turns_since_barrier = 100

    combat_seed = seed
        
    while brian_stats[0] > 0 and nepty_stats[0] > 0 and turns < max_turns:
        
        can_attack = turns >= 2

        decision, iter_seed, didnt_miss = simulate_brian_melee_turn(
            seed=combat_seed, 
            turns_since_barrier=turns_since_barrier,
            can_attack=can_attack, 
            brian_stats=brian_stats, 
            brian_buffs=brian_buffs, 
            enemy_stats=nepty_stats, 
            enemy_debuffs=nepty_debuffs,
            is_jp=True,
            healing_items=healing_items,
            mana_items=mana_items,
        )
        
        if decision == DECISION_HEALING_ITEM:
            healing_items -= 1
            
        if decision == DECISION_MANA_ITEM:
            mana_items -= 1

        if decision == DECISION_BARRIER and didnt_miss:
            turns_since_barrier = 0
        else:
            turns_since_barrier += 1
        
        big_decision = np.longlong(decision)
        
        if turns >= 16:
            decision_hi += big_decision << ((turns - 16) * 4)
        else:
            decision_lo += big_decision << (turns * 4)
        
        end_brian_turn(brian_buffs)
        
        # print(f"{combat_seed:8X}->{iter_seed:8X}", decision, f"{get_decision_text(decision):10}", brian_stats, brian_buffs, nepty_stats)
        
        if nepty_stats[0] <= 0:
            return True, turns + 1, (decision_hi, decision_lo)
        
        
        if nepty_stats[0] > 0:
            iter_seed, damage = simulate_nepty_turn_simple(
                seed=iter_seed, 
                brian_stats=brian_stats, 
                brian_buffs=brian_buffs, 
                barrier_turns=brian_buffs[0],
                is_jp=True
            )
            
        if nepty_debuffs[0] > 0:
            nepty_debuffs[0] -= 1
            
        if brian_stats[0] <= 0:
            return False, turns + 1, (decision_hi, decision_lo)
        
        turns += 1
        combat_seed = iter_seed

    return False, turns, (decision_hi, decision_lo)


@njit()
def sim_nepty_with_avalanche(seed: int, max_turns: int, turns_between_barriers: int) -> Tuple[bool, int, Tuple[np.longlong, np.longlong]]:

    brian_stats = [BRIAN_HP, BRIAN_MP]
    brian_buffs = [
        0, # Barrier
        0  # Confusion
    ]
    nepty_stats = [ENEMY_HP]
    nepty_debuffs = [0]
    
    decision_hi = np.longlong(0)
    decision_lo = np.longlong(0)
    
    brian_coords = [BRIAN_START_X, BRIAN_START_Z]
    nepty_coords = [NEPTY_START_POSITION_X, NEPTY_START_POSITION_Z]
    
    healing_items = 1
    mana_items = 2
    
    turns = 0
    turns_since_barrier = 100
    barrier_has_hit = False

    combat_seed = seed
        
    while brian_stats[0] > 0 and nepty_stats[0] > 0 and turns < max_turns:
        
        can_attack = barrier_has_hit

        decision, iter_seed, didnt_miss = simulate_brian_avalanche_turn(
            seed=combat_seed, 
            turns_since_barrier=turns_since_barrier,
            turns_between_barriers=turns_between_barriers,
            can_attack=can_attack, 
            brian_coords=brian_coords,
            nepty_coords=nepty_coords,
            brian_stats=brian_stats, 
            brian_buffs=brian_buffs, 
            enemy_stats=nepty_stats, 
            enemy_debuffs=nepty_debuffs,
            is_jp=True,
            healing_items=healing_items,
            mana_items=mana_items,
        )

        if not barrier_has_hit and (decision == DECISION_BARRIER) and (brian_buffs[0] > 0):
            barrier_has_hit = True
        
        if decision == DECISION_HEALING_ITEM:
            healing_items -= 1
            
        if decision == DECISION_MANA_ITEM:
            mana_items -= 1

        if decision == DECISION_BARRIER and didnt_miss:
            turns_since_barrier = 0
        else:
            turns_since_barrier += 1
        
        big_decision = np.longlong(decision)
        
        if turns >= 16:
            decision_hi += big_decision << ((turns - 16) * 4)
        else:
            decision_lo += big_decision << (turns * 4)
        
        end_brian_turn(brian_buffs)
        
        # print(f"{combat_seed:8X}->{iter_seed:8X}", decision, f"{get_decision_text(decision):10}", brian_stats, brian_buffs, nepty_stats)
        # print(f"{combat_seed:8X}->Brian: {brian_coords[0]:.2f}, {brian_coords[1]:.2f}, Nepty: {nepty_coords[0]:.2f}, {nepty_coords[1]:.2f}, Dist: {get_array_distance(brian_coords, nepty_coords)}")
        
        if nepty_stats[0] <= 0:
            return True, turns + 1, (decision_hi, decision_lo)
        
        if nepty_stats[0] > 0:
            iter_seed, damage = simulate_nepty_turn_realistic(
                seed=iter_seed, 
                brian_stats=brian_stats, 
                brian_buffs=brian_buffs, 
                barrier_turns=brian_buffs[0],
                brian_coords=brian_coords,
                nepty_coords=nepty_coords,
                is_jp=True
            )
            
        if nepty_debuffs[0] > 0:
            nepty_debuffs[0] -= 1
            
        if brian_stats[0] <= 0:
            return False, turns + 1, (decision_hi, decision_lo)
        
        turns += 1
        combat_seed = iter_seed

    return False, turns, (decision_hi, decision_lo)

@njit()
def run_sim_avalanche(starting_seed, sim_count, max_turns=32, turns_between_barriers=3):
    
    num_success = 0
    num_defeats = 0
    turn_array = np.zeros((max_turns), dtype=np.int32)
    
    for k in range(sim_count):
        
        success, turns, (decisions_hi, decisions_lo) = sim_nepty_with_avalanche(starting_seed + k, max_turns, turns_between_barriers)

        if success:
            num_success += 1
            turn_array[turns-1] += 1
        else:
            num_defeats += 1

    return num_success, num_defeats, turn_array

@njit()
def run_sim_melee(starting_seed, sim_count, max_turns=32):
    
    num_success = 0
    num_defeats = 0
    turn_array = np.zeros((max_turns), dtype=np.int32)
    
    for k in range(sim_count):
        
        success, turns, (decisions_hi, decisions_lo) = sim_nepty_with_melee(starting_seed + k, max_turns)

        if success:
            num_success += 1
            turn_array[turns-1] += 1
        else:
            num_defeats += 1

    return num_success, num_defeats, turn_array

@njit()
def increment_against_hex_cap(current: np.longlong, hex_cap: np.longlong) -> np.longlong:

    if current == hex_cap:
        return current
    
    digit_current = current & 0xF
    digit_cap = hex_cap & 0xf
    
    if digit_current < digit_cap:
        return current + 1
    
    digit_index = 0
    while digit_current == digit_cap and digit_index < 16:
        
        current &= (0xFFFFFFFFFFFFFFFF - 0xF << (digit_index * 4))
        digit_index += 1
        digit_current = current & (0xF << (4 * digit_index))
        digit_cap = hex_cap & (0xF << (4 * digit_index))
    
    increment = 1 << 4 * digit_index
    
    return current + increment


def get_sim_data(seed, count, barriers):
    expected_path = f"data/nepty.{seed:08X}.{count}.{barriers}.json"
    exists = os.path.isfile(expected_path)

    if exists:
        with open(expected_path) as fp:
            data = json.load(fp)
            return data
        

    return None

def save_sim_data(seed, count, barriers, data):
    expected_path = f"data/nepty.{seed:08X}.{count}.{barriers}.json"
    with open(expected_path, "w+") as fp:
        json.dump(data, fp)

# ALLOW_MISTAKES=False
ALLOW_MISTAKES=True
 
def main():
    # test()
    # return
    
    from multiprocessing import Pool
    
    # # test()
    start = time.time()
    
    seed = 0xCB72A799
    
    
    # success, turns, (decisions_hi, decisions_lo) = sim_nepty_with_avalanche(seed, 32)
    # print(f"{seed:8X}--------") 
    # print(f"{success=} {turns=}")
    # for turn in range(turns):
        
    #     if turn >= 16:
    #         decision_code = (decisions_hi >> ((turn - 16) * 4)) % 16
    #     else:
    #         decision_code = (decisions_lo >> (turn * 4)) % 16
        
    #     print(f"{decision_code:8X}", get_decision_text(decision_code))
    
    # return
    
    
    # hit_chance = calculate_hit_chance(BRIAN_AGILITY, ENEMY_AGILITY)
    
    # print(hit_chance)
    # return



    # process_count = 8
    # sim_count = 0x4000
    # max_turns_allowed = 32
    
    # print(f"Starting Nepty Sim, {sim_count * process_count} runs over {process_count} processes ...")
        
    # pool = Pool(processes=process_count)
    # args = [
    #     [
    #         seed + k * sim_count,
    #         sim_count,
    #         max_turns_allowed
    #     ]
    #     for k in range(8)
    # ]
    # results = pool.starmap(run_sim_melee, args)
    # pool.close()
            
    # end = time.time()
    
    # total_wins = 0
    # total_losses = 0
    # total_turn_array = [0 for _ in range(max_turns_allowed)]

    # for [wins, losses, turn_array] in results:
    #     total_wins += wins
    #     total_losses += losses
        
    #     for k in range(max_turns_allowed):
    #         total_turn_array[k] += int(turn_array[k])

    # min_turns = min(total_turn_array)
    # max_turns = max(total_turn_array)
    # success_rate = total_wins / (total_wins + total_losses)

    # print(total_wins, total_losses, min_turns, max_turns)
    # print(f"Elapsed: {end-start:.2f}")

    # x = [f"{k+1}" for k in range(max_turns_allowed)]
    # y = [turns for turns in total_turn_array]
    
    # colors = plt.cm.hsv(np.linspace(0.5, 0.0, max_turns_allowed))
    
    # plt.bar(x, y, color=colors, edgecolor='black', width=1)
    
    # plt.xlabel("Number of Turns")
    # plt.ylabel("Frequency")
    
    # plt.xticks(range(1, max_turns_allowed+1))
    
    # plt.grid(axis='x', which='both', linestyle='--', linewidth=0.5)
    # plt.grid(axis='y', which='both', linestyle='--', linewidth=0.5)

    # # seaborn.barplot(total_turn_array)

    # mistake_text = "Perfect Inputs" if not ALLOW_MISTAKES else "Non-Perfect Inputs"
    # plt.title(f"JP Nepty with Melee - {success_rate:.2f} Success Rate, {sim_count * process_count} seeds, {mistake_text}")
    # plt.show()







    process_count = 8
    sim_count = 0x20000
    max_turns_allowed = 32
    
    print(f"Starting Nepty Sim, {sim_count * process_count} runs over {process_count} processes ...")
    
    fig, axes = plt.subplots(3, 2, sharex=True, sharey=True)

    
    # fig.suptitle(f"JP Nepty with Avalanche - {success_rate:.2f} Success Rate, {sim_count * process_count} seeds")
    
    # plt.grid(axis='x', which='both', linestyle='--', linewidth=0.5)
    # plt.grid(axis='y', which='both', linestyle='--', linewidth=0.5)
        
    plt.xticks(range(1, max_turns_allowed+1))
    
    fig.align_labels(axes)

    # fig.subplots_adjust(top=0.88)
    # fig.tight_layout()

    for turns_between_barriers in range(1, 6 + 1):

        sim_data = get_sim_data(seed, sim_count, turns_between_barriers)
        if sim_data is None:
                
            pool = Pool(processes=process_count)
            args = [
                [
                    seed + k * sim_count,
                    sim_count,
                    max_turns_allowed,
                    turns_between_barriers,
                ]
                for k in range(8)
            ]
            results = pool.starmap(run_sim_avalanche, args)
            pool.close()

            total_wins = 0
            total_losses = 0
            total_turn_array = [0 for _ in range(max_turns_allowed)]

            for [wins, losses, turn_array] in results:
                total_wins += wins
                total_losses += losses
                
                for k in range(max_turns_allowed):
                    total_turn_array[k] += int(turn_array[k])
            
            sim_data = [total_wins, total_losses, total_turn_array]
            save_sim_data(seed, sim_count, turns_between_barriers, [total_wins, total_losses, total_turn_array])

        # Use this to plot everything
        #
        [total_wins, total_losses, total_turn_array] = sim_data

        end = time.time()

        min_turns = min(total_turn_array)
        max_turns = max(total_turn_array)
        success_rate = total_wins / (total_wins + total_losses)

        print(total_wins, total_losses, min_turns, max_turns)
        print(f"Elapsed: {end-start:.2f}")

        x = [f"{k+1}" for k in range(max_turns_allowed)]
        y = [turns for turns in total_turn_array]
        
        colors = plt.cm.hsv(np.linspace(0.5, 0.0, max_turns_allowed))

        sub_x = (turns_between_barriers-1) % 3
        sub_y = (turns_between_barriers-1) // 3

        subplot = axes[sub_x, sub_y]
        
        subplot.bar(x, y, color=colors, edgecolor='black', width=1)
        
        subplot.grid(axis='x', which='both', linestyle='--', linewidth=0.5)
        subplot.grid(axis='y', which='both', linestyle='--', linewidth=0.5)

        # seaborn.barplot(total_turn_array)



        if turns_between_barriers == 1:
            subplot.set_title(f"Every Other Turn, {100*success_rate:.2f} % Wins")
        else:
            subplot.set_title(f"Every {turns_between_barriers} Turns, {100*success_rate:.2f} % Wins")

    plt.suptitle(f"JP Nepty with Simulated Barrier Strategies -- {sim_count * process_count} runs each")
    plt.show()










    # heal_range = 1
    # exit_range = 1
    # decision_cap = 0x3333333333
    
    # best_code = run_sim_brute_force(seed, decision_cap, heal_range, exit_range)
    # print(f"Done!  Best Code: {best_code:10X}")
    
    # end = time.time()
    # print(f"Elapsed: {end-start:.2f}")
    
    # turns, decisions = sim_bulk_brute_force(seed, 0x33333333333333, max_turns=14)
    # print(turns, decisions)

# 0x2B825F46
# turns=9 heals=7 exits=6
# Elapsed: 8.92, Total Sims: 144000
# Decision Code:        111311102

if __name__=="__main__":
    main()
