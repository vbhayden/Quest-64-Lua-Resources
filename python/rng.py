import math
import time

from numba import njit
from dataclasses import dataclass

@dataclass
class HealingExpectation:
    starting_seed: int
    max_hp: int
    water_level: int
    healing_result: int
    ending_seed: int

HEALING_1_EXPECTATIONS = [
    HealingExpectation(0x00000000, 50, 7, 4, 0x642B7E60),
    HealingExpectation(0x00000000, 50, 35, 18, 0x642B7E60),
    HealingExpectation(0xCB72A799, 158, 38, 24, 0x0E87E679),
    HealingExpectation(0x0E87E679, 158, 38, 25, 0x71661559),
    HealingExpectation(0x0E87E679, 400, 48, 32, 0x71661559),
]

MIN_HEALING_LOOKUP = {}
BONUS_LVL_1_LOOKUP = {}
BONUS_LVL_2_LOOKUP = {}

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

a_30, c_30 = advance_lcg(a, c, m, 30)
a_2, c_2 = advance_lcg(a, c, m, 2)

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
def roll_rng(current_rng, value_range):
    base = current_rng >> 16
    roll = base % value_range if value_range > 0 else 0

    return roll

@njit
def simulate_healing_cast(current_rng, water_level, max_hp, bonus_percent):

    # Accuracy check always passes
    range_rng = advance_rng_2(current_rng)

    min_heal = (water_level >> 1) + math.floor(bonus_percent * max_hp)

    heal_range = min_heal >> 2
    heal_roll = roll_rng(range_rng, heal_range)
    
    ending_rng = advance_rng_30(range_rng)

    return (ending_rng, min_heal + heal_roll)

@njit
def simulate_healing_1(current_rng, water_level, max_hp):
    return simulate_healing_cast(current_rng, water_level, max_hp, 0.02)

@njit
def simulate_healing_2(current_rng, water_level, max_hp):
    return simulate_healing_cast(current_rng, water_level, max_hp, 0.08)

def test():

    for expectation in HEALING_1_EXPECTATIONS:
        healing_rng = expectation.starting_seed
        expected_rng = expectation.ending_seed
        expected_healing = expectation.healing_result
        (new_rng, healing_amount) = simulate_healing_1(current_rng=healing_rng, water_level=expectation.water_level, max_hp=expectation.max_hp)

        if new_rng != expected_rng:
            print(f"Wrong RNG Value: {new_rng:8X}, expected {expected_rng:8X}")

        elif healing_amount != expected_healing:
            print(f"Wrong Healing Value: {healing_amount}, expected {expected_healing}")

        else:
            print("Looks good!")

@njit
def find_valid_heal_seeds(heal_results, max_hp, water_level, healing_rank, scan_start=0x00000000, scan_length=0x00FFFFFF):
    
    bonus_coefficient = 0.02 
    if healing_rank == 2:
        bonus_coefficient = 0.08
    
    valid_seeds = []

    for rng in range(scan_start, scan_start + scan_length + 1):
        seed = rng

        # if seed % 0x100000 == 0:
        #     print(f"{seed=:8X} ...")

        success = True
        for expected_heal in heal_results:
            (rng, healing_amount) = simulate_healing_cast(rng, water_level, max_hp, bonus_coefficient)
            if expected_heal != healing_amount:
                success = False
                break

        if success:
            valid_seeds.append(seed)

    # print(f"Found {len(valid_seeds)} valid seeds out of {scan_size:8X}")
    return valid_seeds

def main():

    # prepare_lookups()

    start = time.time()

    # seeds = find_valid_heal_seeds([31, 36, 36, 34, 31, 33, 36], max_hp=158, water_level=38, healing_rank=2, scan_size=0x000FFFFF)
    # seeds = find_valid_heal_seeds([23, 26, 22, 25, 23, 26, 26, 23, 24, 22, 26, 25], max_hp=158, water_level=38, healing_rank=1, scan_size=0x00FFFFFF)
    # seeds = find_valid_heal_seeds([24, 23, 23, 22, 26, 26, 25, 26, 22, 22, 25, 22], max_hp=158, water_level=38, healing_rank=1, scan_size=0x00FFFFFF)
    seeds = find_valid_heal_seeds(
        heal_results=[24, 22, 24, 22, 24, 24, 25, 23, 25, 23, 25, 24], 
        max_hp=158, 
        water_level=38, 
        healing_rank=1, 
        scan_start=0x00000000,
        scan_length=0xFFFFFFFF
    )
    
    stop = time.time()

    for seed in seeds:
        print(f"- {seed:8X}")

    print(f"Elapsed: {stop - start:.2f}, Valid Seeds: {len(seeds)}")

    # # (rng, healing) = simulate_healing_1(0x00000000, water_level=38, max_hp=158)
    # # print(f"{rng:8X}, {healing}")

    # # (new_rng, value) = roll_rng(0x00000000, 10)
    # # print(f"{new_rng:8X}, {value}")

    test()
    

def call_me(arg):
    return arg + 2

if __name__=="__main__":
    main()
        