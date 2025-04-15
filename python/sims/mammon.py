import rng
import random
import math

from numba import njit
from dataclasses import dataclass

BRIAN_X = 78.32734
BRIAN_Z = -326.8355

BRIAN_HP = 208
BRIAN_MP = 25
BRIAN_AGILITY = 26
BRIAN_DEFENSE = 26
BRIAN_FIRE = 1
BRIAN_EARTH = 50
BRIAN_WATER = 44
BRIAN_WIND = 1
TOTAL_ELEMENTS = BRIAN_FIRE + BRIAN_EARTH + BRIAN_WATER + BRIAN_WIND

ELEMENT_FIRE = 0
ELEMENT_EARTH = 1
ELEMENT_WATER = 2
ELEMENT_WIND = 3

MAMMON_X = -20.16924
MAMMON_Z = -349.5814

MAMMON_DEFENSE = 100
MAMMON_AGILITY = 150
MAMMON_ATTACK = 41
MAMMON_SIZE_MODIFIER = 0.21
MAMMON_SIZE_RAW = 450
MAMMON_SIZE = MAMMON_SIZE_MODIFIER * MAMMON_SIZE_RAW

SPELL_POWER_AVALANCHE = 460
SPELL_POWER_ROCK_1 = 290
SPELL_POWER_WATER_1 = 365
SPELL_POWER_WATER_2 = 374
SPELL_POWER_WATER_3 = 384

BONUS_TABLE = [
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
]

@njit
def next_rng(current_rng) -> int:
    return (current_rng * 0x41C64E6D + 0x3039) & 0xFFFFFFFF

@njit
def roll_rng(current_rng, value_range):
    if value_range == 0:
        return 0

    base = current_rng >> 16
    roll = base % value_range

    return roll

def roll(max_value):
    return random.randint(1, max_value)

def coinflip():
    return roll(2) == 1

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

def get_spell_bonus(attack_power):
    
    if attack_power >= len(BONUS_TABLE):
        return BONUS_TABLE[-1]

    if attack_power < 0:
        return 0.2

    return BONUS_TABLE[attack_power]

def calculate_hit_chance(attacker_agi, defender_agi):
    
    top = attacker_agi * 100.0
    bottom = attacker_agi + math.floor((defender_agi + 7.0) / 8.0)

    hit_chance = math.floor(top / bottom)
    return hit_chance

def calculate_brian_min_damage(element, spell_power):
    
    elementLevel = get_brian_element_power(element)
    bonusPercent = get_spell_bonus(elementLevel - 1)

    resultingPower = spell_power * bonusPercent

    affinityCoefficient = 0.5
    rawDamage = resultingPower * affinityCoefficient

    defenseCoefficient = TOTAL_ELEMENTS / (TOTAL_ELEMENTS + MAMMON_DEFENSE)
    minDamage = math.floor(math.floor(rawDamage) * defenseCoefficient)

    return minDamage

def does_rock_overlap_mammon(rock_x, rock_z):
    dx = rock_x - MAMMON_X
    dz = rock_z - MAMMON_Z

    size = MAMMON_SIZE
    skin_width = 0
    enemy_bounds = size + size * skin_width
    distance = math.sqrt(dx * dx + dz * dz)

    rock_radius = 10.0

    overlaps = distance <= (rock_radius + enemy_bounds)
    return overlaps

def simulate_avalanche_rock_hit(seed):
    
    accuracy_seed = next_rng(seed)    
    agility_seed = next_rng(accuracy_seed)
    
    hit_chance = calculate_hit_chance(BRIAN_AGILITY, MAMMON_AGILITY)
    hit_roll = roll_rng(agility_seed, 100)
    
    if hit_roll >= hit_chance:
        return False, 0, agility_seed
    
    damage_seed = next_rng(agility_seed)
    damage_min = calculate_brian_min_damage(ELEMENT_EARTH, SPELL_POWER_AVALANCHE)
    damage_range = math.floor(math.sqrt(damage_min))
    damage_roll = roll_rng(damage_seed, damage_range + 1)
    
    damage = damage_min + damage_roll
    
    return True, damage, damage_seed

def simulate_avalanche(seed, debug=False):
    rock_overlaps = 0
    rock_hits = 0
    total_damage = 0

    rock_delay = 5
    next_rock_at = 0
    harmless_duration = 4
    max_rocks = 10

    active_rocks = []
    collision_queue = []
    
    if debug:
        print(f"[{seed:08X}] == START ==")

    for current_frame in range(1, rock_delay * 10 + harmless_duration * 2 + 1):
        for i, rock in enumerate(active_rocks):

            collision_enabled = rock["frames_active"] >= harmless_duration
            rock_can_damage = collision_enabled and not rock["already_collided"]
            
            if rock_can_damage:
                
                recently_activated = rock["frames_active"] == harmless_duration
                if recently_activated:
                    if debug:
                        print(f"[{seed:08X}] PRE-COLLISION, Rock {i+1}")
                
                overlaps_enemy = does_rock_overlap_mammon(rock["x"], rock["z"])
                if overlaps_enemy:
                    collision_queue.append(rock)
                
            rock["frames_active"] += 1
        
        allow_more_rocks = len(active_rocks) < max_rocks
        if allow_more_rocks and (current_frame >= next_rock_at):
            
            next_rock_at = next_rock_at + rock_delay
            
            offset_seed = next_rng(seed)
            angle_seed = next_rng(offset_seed)
            
            offset_roll = roll_rng(offset_seed, 20)
            angle_roll = roll_rng(angle_seed, 16)

            seed = angle_seed

            angle = angle_roll * 22.5 * math.pi / 180
            offset = 20 + offset_roll

            rock_x = BRIAN_X - offset * math.sin(angle)
            rock_z = BRIAN_Z - offset * math.cos(angle)
            
            if debug:
                print(f"[{seed:08X}] {len(active_rocks)+1}: {rock_x:.1f}, {rock_z:.1f}")
            
            rock = {
                "frames_active": 0,
                "already_collided": False,
                "x": rock_x,
                "z": rock_z
            }
            
            active_rocks.append(rock)

        if len(collision_queue) > 0:
            for rock in collision_queue:
                
                rock["already_collided"] = True
                rock_overlaps += 1
                
                hit, damage, final_seed = simulate_avalanche_rock_hit(seed)
                if hit:
                    rock_hits += 1
                    total_damage += damage
                    
                seed = final_seed
                
                if debug:
                    print(f"[{seed:8X}] POST-COLLISION, Rock {i+1} - {hit}: {damage}")
                    print(f"[{seed:8X}] POST-COLLISION, Rock {i+1} - {rock["x"]:.1f}, {rock["z"]:.1f}")
                
            collision_queue.clear()
    
        if debug:
            print(f"[{seed:08X}] Frame {current_frame}")
    
    return rock_hits, total_damage, seed

def simulate_barrier(seed, buffs):
    pass

def simulate_confusion(seed, buffs):
    pass

def simulate_weakness(seed):
    pass

def simulate_brian_turn(seed, can_attack, brian_hp, brian_mp, buffs, mammon_debuffs):
    cannot_attack = not can_attack
    
    can_afford_spells = brian_mp >= 3
    
    # rockHits, avalancheDamage, avalancheSeed = simulate_avalanche(seed, brian_info, mammon_info)

    # if can_afford_spells and avalancheDamage >= mammon_info.hp then
    #     SpendBrianMana(brian_info, 3)
    #     return ProcessBrianTurn(avalancheSeed, brian_info, mammon_info, "Avalanche", avalancheDamage)
    # end
    
    weakness_bias = cannot_attack or roll(3) == 1
    weakness_expiring_soon = mammon_debuffs[0] <= 2
    
    
    barrier_bias = cannot_attack or coinflip()
    barrier_unreliable = buffs[0] <= 1
    
    # local weakness_bias = cannot_attack or roll(3) == 1
    # local weakness_expiring_soon = mammon_info.weaknessTurns <= 2
    # local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(seed, brian_info, mammon_info)

    # local barrier_bias = Coinflip() or cannot_attack
    # local barrier_unreliable = brian_info.barrierTurns <= 1
    # local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier(seed, brian_info)

    # if can_afford_spells and weakness_expiring_soon and weakness_bias and weaknessHit and weaknessTurns >= 3 then
    #     SpendBrianMana(brian_info, 3)
    #     mammon_info.weaknessTurns = weaknessTurns

    #     return ProcessBrianTurn(weaknessSeed, brian_info, mammon_info, "Weakness", 0)
    # end
    
    return seed, "Passed"

def end_brian_turn(buffs):
    k = 0
    while k < len(buffs):
        if buffs[k] > 0:
            buffs[k] -= 1
        k += 1 

def sim_mammon_randomly(seed, stop_after):

    brian_hp = BRIAN_HP
    brian_mp = BRIAN_HP
    brian_barrier_turns = 0
    brian_confusion_turns = 0
    
    brian_buffs = [0, 0]
    mammon_debuffs = [0]
    
    mammon_hp = 2300
    
    decisions = []
    turns = 0
    CANNOT_ATTACK_UNTIL = 2

    while brian_hp > 0 and mammon_hp > 0 and turns < stop_after:
        
        seed, decision = simulate_brian_turn(seed, turns >= CANNOT_ATTACK_UNTIL, brian_buffs, mammon_debuffs)
        end_brian_turn(brian_buffs)
        
#         summaryLine = summaryLine .. decision

#         seed = brianSeed

#         EndBrianTurn(brian_info)
        
#         if mammon_info.hp > 0 then
#             local mammonSeed, brianDamage, mammonSpell = SimulateMammonMove(seed, mammon_info, brian_info)
#             seed = mammonSeed

#             EndMammonTurn(mammon_info)

#             summaryLine = summaryLine .. ", " .. mammonSpell.name
#         end
        
#         summaryLine = summaryLine .. ", " .. brian_info.hp
#         summaryLine = summaryLine .. ", " .. mammon_info.hp

#         decisions[#decisions+1] = summaryLine
        
#         turns = turns + 1
#     end

#     if brian_info.hp > 0 and mammon_info.hp > 0 then
#         return false, turns, decisions
#     end

#     if brian_info.hp > 0 then
#         return true, turns, decisions
#     end

#     if mammon_info.hp > 0 then
#         return false, turns, decisions
#     end
# end

def test():
    (hits, damage, seed) = simulate_avalanche(0x6E79DE97, debug=True)
    print(f"{hits=} {damage=} {seed=:8X}")

def main():
    test()

if __name__=="__main__":
    main()
