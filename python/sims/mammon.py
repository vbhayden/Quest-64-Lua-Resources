import rng
import time
import random
import math
import numpy as np

from typing import Tuple, List
from numba import njit, longlong
from dataclasses import dataclass

BRIAN_X = 78.32734
BRIAN_Y = 109.8082
BRIAN_Z = -326.8355

BRIAN_HP = 208
BRIAN_MP = 25
BRIAN_AGILITY = 26
BRIAN_DEFENSE = 26
BRIAN_FIRE = 1
BRIAN_EARTH = 50
BRIAN_WATER = 44
BRIAN_WIND = 1
BRIAN_STAFF_POWER = 16
TOTAL_ELEMENTS = BRIAN_FIRE + BRIAN_EARTH + BRIAN_WATER + BRIAN_WIND

ELEMENT_FIRE = 0
ELEMENT_EARTH = 1
ELEMENT_WATER = 2
ELEMENT_WIND = 3

MAMMON_X = -20.16924
MAMMON_Y = 75.2183
MAMMON_Z = -349.5814

MAMMON_HP = 2300
MAMMON_DEFENSE = 100
MAMMON_AGILITY = 150
MAMMON_ATTACK = 41
MAMMON_SIZE_MODIFIER = 0.21
MAMMON_SIZE_RAW = 450
MAMMON_SIZE = MAMMON_SIZE_MODIFIER * MAMMON_SIZE_RAW
MAMMOM_HEIGHT_RAW = 1000
MAMMON_HEIGHT = MAMMOM_HEIGHT_RAW * MAMMON_SIZE_MODIFIER

AVALANCHE_ROCK_FALL_SPEED = 0.3
AVALANCHE_ROCK_INITIAL_HEIGHT = 32.4

SPELL_POWER_AVALANCHE = 460
SPELL_POWER_ROCK_1 = 290
SPELL_POWER_WATER_1 = 365
SPELL_POWER_WATER_2 = 374
SPELL_POWER_WATER_3 = 384

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

MAMMON_LIGHT_POWER = 320
MAMMON_LIGHT_ACCURACY = 85
MAMMON_WAVE_POWER = 480
MAMMON_WAVE_ACCURACY = 100
MAMMON_ARROWS_POWER = 50
MAMMON_ARROWS_ACCURACY = 100

MAMMON_SPELLS = np.array([
    # rng   acc%    count   power   dispels
    [ 0,    MAMMON_LIGHT_ACCURACY,  1, MAMMON_LIGHT_POWER,  1 ],    # Light
    [ 90,   MAMMON_WAVE_ACCURACY,   1, MAMMON_WAVE_POWER,   0 ],    # Waves
    [ 240,  MAMMON_ARROWS_ACCURACY, 8, MAMMON_ARROWS_POWER, 0 ]     # Arrows
], dtype=np.int32)

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
a_31=0xF53981E5
c_31=0x0202A263
a_30=0x4E6A7659
c_30=0x961D9892
a_2=0xC2A29A69
c_2=0xD3DC167E

# a_240, c_240 = advance_lcg(a, c, m, 240)
# a_90, c_90 = advance_lcg(a, c, m, 90)
# a_31, c_31 = advance_lcg(a, c, m, 31)
# a_30, c_30 = advance_lcg(a, c, m, 30)
# a_2, c_2 = advance_lcg(a, c, m, 2)

# print(f"{a_240=:8X}, {c_240=:8X}")
# print(f"{a_90=:8X}, {c_90=:8X}")
# print(f"{a_31=:8X}, {c_31=:8X}")
# print(f"{a_30=:8X}, {c_30=:8X}")
# print(f"{a_2=:8X}, {c_2=:8X}")

@njit
def advance_rng_240(current_rng) -> int:
    return (current_rng * a_240 + c_240) & 0xFFFFFFFF

@njit
def advance_rng_90(current_rng) -> int:
    return (current_rng * a_90 + c_90) & 0xFFFFFFFF

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

@njit
def get_mammon_spells():
    return MAMMON_SPELLS

@njit()
def get_bonus_table():
    return BONUS_TABLE

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

    hit_chance = math.floor(top / bottom)
    return hit_chance

@njit()
def calculate_brian_min_damage(element: int, spell_power: int, weakness_active: bool):
    
    element_level = get_brian_element_power(element)
    spell_bonus = get_spell_bonus(element_level - 1)

    resulting_power = spell_power * spell_bonus

    affinity = 0.5
    raw_damage = resulting_power * affinity

    enemy_defense = MAMMON_DEFENSE
    if weakness_active:
        enemy_defense *= 0.5
    
    defense_coefficient = TOTAL_ELEMENTS / (TOTAL_ELEMENTS + enemy_defense)
    damage_min = math.floor(math.floor(raw_damage) * defense_coefficient)

    return damage_min

@njit()
def calculate_enemy_min_damage(attack_power, spell_power):

    bonus_percent = get_spell_bonus(attack_power - 1)
    resulting_power = spell_power * bonus_percent
    
    raw_damage = resulting_power
    
    defense_coefficient = attack_power / (attack_power + BRIAN_DEFENSE)
    damage_min = math.floor(math.floor(raw_damage) * defense_coefficient)
    
    return damage_min

@njit()
def does_capsule_overlap_sphere(c_radius, c_height, cx, cy, cz, s_radius, sx, sy, sz):
    planar_dx = cx - sx
    planar_dz = cz - sz
    planar_distance = math.sqrt(planar_dx**2 + planar_dz**2)
    
    skin_width = 3.5
    
    if planar_distance > (s_radius + c_radius):
        return False

    if cy <= sy <= cy + c_height:
        return True
    
    top_dy = (cy + c_height) - sy
    top_distance = math.sqrt(planar_distance**2 + top_dy**2)
    
    if top_distance < (s_radius + c_radius + skin_width):
        return True

    return False


@njit()
def does_rock_overlap_mammon(rock_x, rock_y, rock_z, mammon_x, mammon_z):
   
    mammon_radius = MAMMON_SIZE
    mammon_height = MAMMON_HEIGHT - mammon_radius
    mammon_y = MAMMON_Y
        
    overlaps = does_capsule_overlap_sphere(mammon_radius, mammon_height, mammon_x, mammon_y, mammon_z, 10.0, rock_x, rock_y, rock_z)
    
    return overlaps

@njit()
def simulate_avalanche_rock_hit(seed: int, weakness_active) -> Tuple[bool, int, int]:
    
    accuracy_seed = next_rng(seed)    
    agility_seed = next_rng(accuracy_seed)
    
    hit_chance = calculate_hit_chance(BRIAN_AGILITY, MAMMON_AGILITY)
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
def simulate_avalanche(seed: int, mammon_x, mammon_z, weakness_active=False, debug=False):
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
    
    # debug=True
    
    # if debug:
    #     print(f"[{seed:08X}] == START ==")

    for current_frame in range(1, rock_delay * 10 + harmless_duration * 2 + 1):
        for rock_index in range(rocks_released):

            (x, y, z) = rock_coords[rock_index]
            (frames_active, collision_state) = rock_properties[rock_index]

            collision_enabled = frames_active >= harmless_duration
            rock_can_damage = collision_enabled and collision_state != COLLISION_PROCESSED
            
            if rock_can_damage:
                
                movement_frames = frames_active - harmless_duration
                
                y -= AVALANCHE_ROCK_FALL_SPEED * (movement_frames)
                rock_coords[rock_index] = [x, y, z]
                
                # recently_activated = frames_active == harmless_duration
                # if recently_activated:
                #     if debug:
                #         print(f"[{seed:08X}] PRE-COLLISION, Rock {rock_index}")
                
                overlaps_enemy = does_rock_overlap_mammon(x, y, z, mammon_x, mammon_z)
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

            rock_x = BRIAN_X - offset * math.sin(angle)
            rock_y = BRIAN_Y + AVALANCHE_ROCK_INITIAL_HEIGHT
            rock_z = BRIAN_Z - offset * math.cos(angle)
            
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
def simulate_barrier(seed):
    
    hit_seed = advance_rng_31(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= 90:
        return False, hit_roll, 0, hit_seed
    
    turn_seed = next_rng(hit_seed)
    turns = 2 + roll_rng(turn_seed, 2)
    
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
    agility_chance = calculate_hit_chance(BRIAN_AGILITY, MAMMON_AGILITY)
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
    hit_chance = calculate_hit_chance(BRIAN_AGILITY, MAMMON_AGILITY)
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
    seed = advance_rng_30(seed)
    return simulate_generic_damaging_spell(seed, ELEMENT_WATER, SPELL_POWER_WATER_1, weakness_active)

@njit()
def simulate_rock_1(seed, weakness_active=False):
    return simulate_generic_damaging_spell(seed, ELEMENT_EARTH, SPELL_POWER_ROCK_1, weakness_active)

@njit()
def simulate_brian_melee(seed, weakness_active=False):
    agility_seed = next_rng(seed)
    agility_chance = calculate_hit_chance(BRIAN_AGILITY, MAMMON_AGILITY)
    agility_roll = roll_rng(agility_seed, 100)

    if agility_roll >= agility_chance:
        return False, 0, agility_seed

    total_elements = TOTAL_ELEMENTS
    influence = math.floor(total_elements * 1.5)
    
    reduction_threshold = total_elements >> 2
    attack_reduction = 0

    if ELEMENT_FIRE > reduction_threshold:
        attack_reduction += ELEMENT_FIRE - reduction_threshold
    
    if ELEMENT_EARTH > reduction_threshold:
        attack_reduction += ELEMENT_EARTH - reduction_threshold
    
    if ELEMENT_WATER > reduction_threshold:
        attack_reduction += ELEMENT_WATER - reduction_threshold
    
    if ELEMENT_WIND > reduction_threshold:
        attack_reduction += ELEMENT_WIND - reduction_threshold

    spirit_influence = influence - attack_reduction
    attack_power = (spirit_influence * BRIAN_STAFF_POWER) >> 4
    enemy_defense = MAMMON_DEFENSE
    if weakness_active:
        enemy_defense = enemy_defense >> 1
    defense_coefficient = attack_power / (attack_power + enemy_defense)

    damage_seed = next_rng(agility_seed)
    damage_min = math.floor(attack_power * defense_coefficient)
    damage_range = math.floor(math.sqrt(damage_min) + 1)
    damage = damage_min + roll_rng(damage_seed, damage_range)

    return True, damage, damage_seed

@njit()
def simulate_brian_turn(seed, can_attack, brian_stats, brian_buffs, mammon_stats, mammon_debuffs) -> Tuple[int, int]:
    cannot_attack = not can_attack
    
    can_afford_spells = brian_stats[1] >= 3
    # can_afford_cheap_spells = brian_stats[1] >= 1
    
    weakness_currently_active = mammon_debuffs[0] > 0
    
    rock_hits, avalanche_damage, avalanche_seed = simulate_avalanche(seed, MAMMON_X, MAMMON_Z, weakness_currently_active)
    melee_hit, melee_damage, melee_seed = simulate_brian_melee(seed, weakness_currently_active)
    # water_hit, water_damage, water_seed = simulate_water_1(seed, weakness_currently_active)
    # rock_hit, rock_damage, rock_seed = simulate_rock_1(seed, weakness_currently_active)

    ## Can we kill Mammon right now
    ##
    ## Check the damaging spells + melee to see if any will
    ## end the fight right now.
    ##
    if can_afford_spells and avalanche_damage >= mammon_stats[0]:
        brian_stats[1] -= 3
        mammon_stats[0] -= avalanche_damage
        return DECISION_AVALANCHE, avalanche_seed
    
    # if can_afford_cheap_spells:
    #     if water_damage >= mammon_stats[0]:
    #         brian_stats[1] -= 1
    #         mammon_stats[0] -= water_damage
    #         return DECISION_WATER_1, water_seed
        
    #     if rock_damage >= mammon_stats[0]:
    #         brian_stats[1] -= 1
    #         mammon_stats[0] -= rock_damage
    #         return DECISION_ROCK_1, rock_seed
        
    if melee_damage >= mammon_stats[0]:
        brian_stats[1] += 1
        mammon_stats[0] -= melee_damage
        return DECISION_MELEE, melee_seed
    
    ## Check for Weakness and Barrier options
    ##
    ## These are always wildcards, as we don't use Weakness in normal playthroughs
    ## but manips use it pretty heavily.  Barrier is also different here, as we
    ## will sometimes 
    ##
    weakness_bias = cannot_attack or (roll_for_variation(3) == 1)
    weakness_not_strong = mammon_debuffs[0] <= 2
    weakness_hit, weakness_roll, weakness_turns, weakness_seed = simulate_weakness(seed)
    
    if can_afford_spells and weakness_not_strong and weakness_bias and weakness_hit and weakness_turns >= 3:
        brian_stats[1] -= 3
        mammon_debuffs[0] = weakness_turns

        return DECISION_WEAKNESS, weakness_seed
    
    barrier_bias = cannot_attack or coinflip()
    barrier_unreliable = brian_buffs[0] <= 1
    barrier_hit, barrier_roll, barrier_turns, barrier_seed = simulate_barrier(seed)
    
    if can_afford_spells and barrier_unreliable and barrier_hit and barrier_bias:
        brian_stats[1] -= 3
        brian_buffs[0] = barrier_turns + 1

        return DECISION_BARRIER, barrier_seed
    
    if brian_stats[0] <= 99 and coinflip():
        brian_stats[0] = BRIAN_HP
        return DECISION_HEALING_ITEM, seed
    
    ## Confusion Check
    ##
    ## Prioritize the confusion roll bias when we're low on mana,
    ## with much lower odds when we're comfy.
    ##
    confusion_bias = (brian_stats[1] <= 9 and roll_for_variation(3) == 1) or (roll_for_variation(6) == 1)
    confusion_not_strong = brian_buffs[1] <= 1
    confusion_hit, _, confusion_turns, confusion_seed = simulate_confusion(seed)
    
    if can_afford_spells and confusion_not_strong and confusion_bias and confusion_hit and confusion_turns >= 2:
        brian_stats[1] -= 3
        brian_buffs[1] = confusion_turns
        return DECISION_CONFUSION, confusion_seed
    
    
    if can_attack and can_afford_spells and coinflip() and avalanche_damage >= 200:
        brian_stats[1] -= 3
        mammon_stats[0] -= avalanche_damage
        return DECISION_AVALANCHE, avalanche_seed
    
    melee_bias = ((not can_afford_spells) and coinflip()) or (roll_for_variation(4) == 1)
    if melee_hit and melee_bias:
        brian_stats[1] += 1
        mammon_stats[0] -= melee_damage
        return DECISION_MELEE, melee_seed
    
    if can_attack and can_afford_spells and avalanche_damage >= 100:
        brian_stats[1] -= 3
        mammon_stats[0] -= avalanche_damage
        return DECISION_AVALANCHE, avalanche_seed
    
    ## Check for mana
    ##
    ## We could've rolled confusion earlier, but getting here and still needing mana
    ## may pose a risk.
    ##
    if brian_stats[1] <= 20 and roll_for_variation(2) <= 2:
        brian_stats[1] = BRIAN_MP
        return DECISION_MANA_ITEM, seed

    ## Prefer to heal here, but allow for variance
    ##
    elif brian_stats[1] < 3 and roll_for_variation(10) >= 2:
        brian_stats[1] = BRIAN_MP
        return DECISION_MANA_ITEM, seed
    
    
    ## Last Options for randomness 
    ##
    ## We didn't roll for any of the major spells, so these will add some variance
    ## to the process overall, with Water 1 giving 30+ advances alone and the other 
    ## two options giving much smaller amounts than the normal spells.
    ##
    if melee_hit and roll_for_variation(4) == 1:
        brian_stats[1] += 1
        mammon_stats[0] -= melee_damage
        return DECISION_MELEE, melee_seed

    # elif can_attack and can_afford_cheap_spells and water_hit and roll_for_variation(3) == 1:
    #     brian_stats[1] -= 1
    #     mammon_stats[0] -= water_damage
    #     return DECISION_WATER_1, water_seed

    # elif rock_hit and can_afford_cheap_spells and roll_for_variation(2) == 1:
    #     brian_stats[1] -= 1
    #     mammon_stats[0] -= rock_damage
    #     return DECISION_ROCK_1, rock_seed

    elif can_attack and can_afford_spells and coinflip():
        brian_stats[1] -= 3
        mammon_stats[0] -= avalanche_damage
        return DECISION_AVALANCHE, avalanche_seed
    
    return DECISION_PASS, seed

attack_decisions = np.array([DECISION_AVALANCHE, DECISION_MELEE, DECISION_ROCK_1, DECISION_WATER_1], dtype=int)
expensive_decisions = np.array([DECISION_AVALANCHE, DECISION_BARRIER, DECISION_CONFUSION], dtype=int)

@njit()
def simulate_brian_turn_explicit(seed, decision_code, can_attack, brian_stats, brian_buffs, mammon_stats, mammon_debuffs) -> int:

    if not can_attack and decision_code in attack_decisions:
        return seed

    can_afford_spells = brian_stats[1] > 3

    if not can_afford_spells and decision_code in expensive_decisions:
        return seed

    weakness_currently_active = mammon_debuffs[0] > 0

    if decision_code == DECISION_AVALANCHE:
        rock_hits, avalanche_damage, avalanche_seed = simulate_avalanche(seed, MAMMON_X, MAMMON_Z, weakness_currently_active)
        brian_stats[1] -= 3
        mammon_stats[0] -= avalanche_damage
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
            mammon_debuffs[0] = weakness_turns
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
        mammon_stats[0] -= melee_damage
        return melee_seed

    elif decision_code == DECISION_MANA_ITEM:
        brian_stats[1] = BRIAN_MP
        return seed
    
    elif decision_code == DECISION_HEALING_ITEM:
        brian_stats[0] = BRIAN_HP
        return seed

    return seed

@njit()
def simulate_mammon_attack_roll(seed, spell_accuracy, spell_power):
    
    hit_seed = next_rng(seed)
    hit_roll = roll_rng(hit_seed, 100)
    if hit_roll >= spell_accuracy:
        return False, 0, hit_seed
    
    agi_seed = next_rng(hit_seed)
    agi_roll = roll_rng(agi_seed, 100)
    agi_chance = calculate_hit_chance(MAMMON_AGILITY, BRIAN_AGILITY)
    if agi_roll >= agi_chance:
        return False, 0, agi_seed
    
    damage_seed = next_rng(agi_seed)
    damage_min = calculate_enemy_min_damage(MAMMON_ATTACK, spell_power)
    damage_range = math.floor(math.sqrt(damage_min))
    
    damage_roll = roll_rng(damage_seed, damage_range + 1)
    damage = damage_min + damage_roll
    
    return True, damage, damage_seed

@njit()
def simulate_mammon_turn(seed, brian_stats, brian_buffs, barrier_turns):
    
    # print(f"MAMMON 1: {seed:8X}")
    
    ai_seed = next_rng(seed)
    ai_roll = roll_rng(ai_seed, 3)
    
    spells = get_mammon_spells()
    spell = spells[ai_roll]
    
    if spell[0] == 90:
        ai_seed = advance_rng_90(ai_seed)
    elif spell[0] == 240:
        ai_seed = advance_rng_240(ai_seed)
    
    if barrier_turns > 0:
        # print(f"MAMMON X: {ai_seed:8X}")
        return ai_seed, 0
    
    total_damage = 0
    
    spell_accuracy = spell[1]
    spell_hits = spell[2]
    spell_power = spell[3]
    will_remove_buffs = spell[4] > 0
    
    for k in range(spell_hits):
        
        hit_brian, damage, ai_seed = simulate_mammon_attack_roll(ai_seed, spell_accuracy, spell_power)
        
        if hit_brian:
            
            brian_has_confusion = brian_buffs[1] > 0
            if brian_has_confusion:
                brian_stats[1] += damage
                if brian_stats[1] > BRIAN_MP:
                    brian_stats[1] = BRIAN_MP
            
            if will_remove_buffs:
                brian_buffs[1] = 0
                
            brian_stats[0] -= damage
            total_damage += damage
    
    return ai_seed, total_damage

@njit()
def end_brian_turn(buffs):
    k = 0
    while k < len(buffs):
        if buffs[k] > 0:
            buffs[k] -= 1
        k += 1 

@njit()
def sim_mammon_randomly(seed, max_turns):

    brian_stats = [BRIAN_HP, BRIAN_MP]
    brian_buffs = [
        0, # Barrier
        0  # Confusion
    ]
    mammon_stats = [2300]
    mammon_debuffs = [0]
    
    decision_result = np.longlong(0)
    
    turns = 0
    CANNOT_ATTACK_UNTIL = 2

    combat_seed = seed
        
    while brian_stats[0] > 0 and mammon_stats[0] > 0 and turns < max_turns:
        
        decision, iter_seed = simulate_brian_turn(
            seed=combat_seed, 
            can_attack=turns >= CANNOT_ATTACK_UNTIL, 
            brian_stats=brian_stats, 
            brian_buffs=brian_buffs, 
            mammon_stats=mammon_stats, 
            mammon_debuffs=mammon_debuffs
        )
        
        decision_result += decision << (turns * 4)
        
        # print(f"{combat_seed:8X}->{iter_seed:8X}", decision, get_decision_text(decision), brian_stats, brian_buffs, mammon_stats)
        
        if mammon_stats[0] <= 0:
            return True, turns + 1, decision_result
        
        end_brian_turn(brian_buffs)
        
        if mammon_stats[0] > 0:
            iter_seed, damage = simulate_mammon_turn(
                seed=iter_seed, 
                brian_stats=brian_stats, 
                brian_buffs=brian_buffs, 
                barrier_turns=brian_buffs[0]
            )
            
        if brian_stats[0] <= 0:
            return False, turns + 1, decision_result
        
        turns += 1
        combat_seed = iter_seed

    return False, turns, decision_result

@njit()
def sim_bulk(starting_seed, exits, heals, sim_count, max_turns=16):
    
    best_turns = 1000
    decision_result = np.longlong(0)
    
    seed = starting_seed
    
    for exit_casts in range(exits):
        seed = advance_rng_30(seed)
        
    for exit_casts in range(heals):
        seed = advance_rng_31(seed)
        
    for k in range(sim_count):
        
        success, turns, decisions = sim_mammon_randomly(seed, max_turns)
        
        if success and (best_turns > turns):
            best_turns = turns
            decision_result = decisions
            # print("New best!", best_turns)

    return best_turns, decision_result

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

@njit()
def sim_mammon_brute_force(seed: int, decision_codes: np.longlong, max_turns=16):
    
    brian_stats = [BRIAN_HP, BRIAN_MP]
    brian_buffs = [0, 0]
    mammon_stats = [MAMMON_HP]
    mammon_debuffs = [0]

    turns = 0
    CANNOT_ATTACK_UNTIL = 2

    combat_seed = seed
        
    while brian_stats[0] > 0 and mammon_stats[0] > 0 and turns < max_turns:
        
        decision_code = (decision_codes >> turns * 4) % 16
        iter_seed = simulate_brian_turn_explicit(combat_seed, decision_code, turns >= CANNOT_ATTACK_UNTIL, brian_stats, brian_buffs, mammon_stats, mammon_debuffs)
        
        # print(f"{combat_seed:8X}->{iter_seed:8X}", decision_code, get_decision_text(decision_code), brian_stats, brian_buffs, mammon_stats)
        
        if mammon_stats[0] < 0:
            mammon_stats[0] = 0
        
        if brian_buffs[0] > 0:
            brian_buffs[0] -= 1
        if brian_buffs[1] > 0:
            brian_buffs[1] -= 1
        
        if mammon_stats[0] > 0:
            iter_seed, damage = simulate_mammon_turn(iter_seed, brian_stats, brian_buffs, brian_buffs[0])
        
        turns += 1
        combat_seed = iter_seed

    if brian_stats[0] > 0 and mammon_stats[0] > 0:
        return False, turns, decision_codes
    
    if brian_stats[0] > 0:
        return True, turns, decision_codes
        
    return False, turns, decision_codes

@njit()
def sim_bulk_brute_force(starting_seed: int, decision_cap: np.longlong, max_turns=16) -> Tuple[int, np.longlong]:
    
    best_decisions = np.longlong(0xFFFF)
    best_turns = 999
    decision_code = np.longlong(0)
    
    while decision_code < decision_cap:
        
        # print (f"{decision_code=:3X} ...")
        
        # if decision_code % 0x8000000 == 0:
        #     print (f"{decision_code=:12X} ...")

        success, turns, _ = sim_mammon_brute_force(starting_seed, decision_code, max_turns)
        if success and turns < best_turns:
            # print(f"New Best!  {turns} turns with {decision_code:16X}")
            best_decisions = decision_code
            best_turns = turns

        decision_code = increment_against_hex_cap(decision_code, decision_cap)

    return best_turns, best_decisions

@njit()
def run_sim(starting_seed, sim_count, heal_variance, exit_variance, max_turns=16):
    
    heal_count = 0
    exit_count = 0
    best_turns = 1000
    decision_result = np.longlong(0)
    
    for heals in range(heal_variance+1):
        for exits in range(exit_variance+1):
            turns, decisions = sim_bulk(starting_seed, exits, heals, sim_count, max_turns)
            if turns < best_turns:
                best_turns = turns
                decision_result = decisions
                heal_count = heals
                exit_count = exits
                # print("New best! ", turns)
    
    return heal_count, exit_count, best_turns, decision_result

@njit()
def run_sim_brute_force(starting_seed, decision_cap, heal_variance, exit_variance, max_turns=12):
    heal_count = 0
    exit_count = 0
    best_turns = 1000
    decision_result = np.longlong(0)
    
    for heals in range(heal_variance+1):
        for exits in range(exit_variance+1):
            
            advanced_seed = starting_seed
            for _ in range(heals):
                advanced_seed = advance_rng_31(advanced_seed)
            for _ in range(exits):
                advanced_seed = advance_rng_30(advanced_seed)
            
            turns, decisions = sim_bulk_brute_force(advanced_seed, decision_cap, max_turns)
            if turns < best_turns:
                best_turns = turns
                decision_result = decisions
                heal_count = heals
                exit_count = exits
                print("New best! ", turns)
    
    return heal_count, exit_count, best_turns, decision_result

@dataclass
class DamageExpectation:
    start_seed: int
    final_seed: int
    hits: int
    damage: int
    weakness_active: bool = False
    
@dataclass
class MammonExpectation:
    start_seed: int
    final_seed: int
    damage: int

ROCK_1_EXPECTATIONS = [
    DamageExpectation(start_seed=0xA9DA80E6, final_seed=0x2578327D, hits=1, damage=41)
]
AVALANCHE_EXPECTATIONS = [
    DamageExpectation(start_seed=0x7CD824BA, final_seed=0x7F34193C, hits=2, damage=139),
    DamageExpectation(start_seed=0x22A21E98, final_seed=0x12857CA4, hits=4, damage=273),
    DamageExpectation(start_seed=0x027659D4, final_seed=0x7F76085D, hits=3, damage=256, weakness_active=True),
    DamageExpectation(start_seed=0x20C7EE06, final_seed=0x8FA5CAA7, hits=1, damage=93, weakness_active=True),
]
MAMMON_TURN_EXPECTATIONS = [
    MammonExpectation(start_seed=0x2B825F46, final_seed=0x4BDED0A8, damage=99),
    MammonExpectation(start_seed=0x4BDED0A8, final_seed=0x0ACFC9BA, damage=104),
    MammonExpectation(start_seed=0x0ACFC9BA, final_seed=0x2E0EBEFC, damage=97),
    MammonExpectation(start_seed=0x2E0EBEFC, final_seed=0x6C7CB0EE, damage=99),
]

def test_mammon_turn():
    print("-- Mammon Turn Testing --")
    for k, expectation in enumerate(MAMMON_TURN_EXPECTATIONS):
        print(f"  -- Case {k}:")
        sim_seed, sim_damage = simulate_mammon_turn(expectation.start_seed, brian_stats=[BRIAN_HP, BRIAN_MP], brian_buffs=[0, 0], barrier_turns=0)
        
        if (sim_damage, sim_seed) == (expectation.damage, expectation.final_seed):
            print("    -- passed!")
        else:
            print("    -- Failed!")
            print(f"     -- Damage: {sim_damage}, expected {expectation.damage}")
            print(f"     -- Seed: {sim_seed:8X}, expected {expectation.final_seed:8X}")

def test_rock_1():
    print("-- Rock 1 Testing --")
    for k, expectation in enumerate(ROCK_1_EXPECTATIONS):
        print(f"  -- Case {k}:")
        (sim_hit, sim_damage, sim_seed) = simulate_rock_1(expectation.start_seed, weakness_active=expectation.weakness_active)
        sim_hits = 1 if sim_hit else 0
        
        if (sim_hits, sim_damage, sim_seed) == (expectation.hits, expectation.damage, expectation.final_seed):
            print("    -- passed!")
        else:
            print("    -- Failed!")
            print(f"     -- Hits: {sim_hits}, expected {expectation.hits}")
            print(f"     -- Damage: {sim_damage}, expected {expectation.damage}")
            print(f"     -- Seed: {sim_seed:8X}, expected {expectation.final_seed:8X}")

def test_avalanche():
    print("-- Avalanche Testing --")
    for k, expectation in enumerate(AVALANCHE_EXPECTATIONS):
        print(f"  -- Case {k}:")
        (sim_hits, sim_damage, sim_seed) = simulate_avalanche(expectation.start_seed, MAMMON_X, MAMMON_Z, weakness_active=expectation.weakness_active)
        
        if (sim_hits, sim_damage, sim_seed) == (expectation.hits, expectation.damage, expectation.final_seed):
            print("    -- passed!")
        else:
            print("    -- Failed!")
            print(f"     -- Hits: {sim_hits}, expected {expectation.hits}")
            print(f"     -- Damage: {sim_damage}, expected {expectation.damage}")
            print(f"     -- Seed: {sim_seed:8X}, expected {expectation.final_seed:8X}")

def test():
    test_rock_1()
    test_avalanche()
    test_mammon_turn()
    
def main():
    test()
    return
    
    from multiprocessing import Pool
    
    # test()
    start = time.time()
    
    seed = 0x084C487C
    
    # success, turns, decisions = sim_mammon_randomly(seed, 20)
    # print(f"{seed:8X}--------") 
    # print(f"{success=} {turns=}")
    # for turn in range(turns):
    #     decision_code = (decisions >> turn * 4) % 16
    #     print(decision_code, get_decision_text(decision_code))
    
    heal_range = 13
    exit_range = 13
    sim_count = 100
    max_turns = 12
    
    # (heals, exits, turns, decisions) = run_sim(seed, sim_count, heal_range, exit_range, max_turns=16)
        
    pool = Pool(processes=8)
    args = [
        [
            seed,
            sim_count,
            heal_range,
            exit_range,
            max_turns
        ]
        for _ in range(8)
    ]
    results = pool.starmap(run_sim, args)
    pool.close()
            
    end = time.time()
    
    turns = 99
    decisions = 0xF
    exits = 0
    heals = 0
    
    for [iter_heals, iter_exits, iter_turns, iter_decisions] in results:
        if iter_turns < turns:
            decisions = iter_decisions
            heals = iter_heals
            exits = iter_exits
            turns = iter_turns
    
    for turn in range(turns):
        decision_code = (decisions >> turn * 4) % 16
        print(decision_code, get_decision_text(decision_code))

    advanced_seed = seed
    for _ in range(heals):
        advanced_seed = advance_rng_31(advanced_seed)
    for _ in range(exits):
        advanced_seed = advance_rng_30(advanced_seed)
        
    print(f"{seed:8X} -> {advanced_seed:8X}")
    print(f"{turns=} {heals=} {exits=}")
    print(f"Elapsed: {end-start:.2f}, Total Sims: {heal_range * exit_range * sim_count}")
    print(f"Decision Code: {decisions:16X}")

    print("---------------")
    print("Recreating with Brute Force sim...")
    
    bf_success, bf_turns, decisions = sim_mammon_brute_force(advanced_seed, decisions)
    print(f"{advanced_seed:8X}--------") 
    print(f"{bf_success=} {bf_turns=}")
    for turn in range(turns):
        decision_code = (decisions >> turn * 4) % 16
        print(decision_code, get_decision_text(decision_code))

    if bf_success:
        print(f"Fight success! {bf_turns} turns with {decisions:16X}")

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
