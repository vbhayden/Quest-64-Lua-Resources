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
    if value_range == 0:
        return 0

    base = current_rng >> 16
    roll = base % value_range

    return roll

@njit
def simulate_healing_cast_faster(current_rng, min_heal, heal_range):

    # Accuracy check always passes
    range_rng = advance_rng_2(current_rng)
    heal_roll = roll_rng(range_rng, heal_range)
    ending_rng = advance_rng_30(range_rng)

    return (ending_rng, min_heal + heal_roll)

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
    bonus_healing = math.floor(bonus_coefficient * max_hp)
    water_influence = water_level >> 1
    
    min_heal = water_influence + bonus_healing
    heal_range = min_heal >> 2

    for rng in range(scan_start, scan_start + scan_length):
        seed = rng

        # if seed % 0x100000 == 0:
        #     print(f"{seed=:8X} ...")

        success = True
        for expected_heal in heal_results:
            # (rng, healing_amount) = simulate_healing_cast_faster(rng, min_heal, heal_range)

            range_rng = advance_rng_2(rng)
            heal_roll = roll_rng(range_rng, heal_range)
            rng = advance_rng_30(range_rng)

            healing_amount = min_heal + heal_roll

            if expected_heal != healing_amount:
                success = False
                break

        if success:
            valid_seeds.append((seed, rng))

    # print(f"Found {len(valid_seeds)} valid seeds out of {scan_size:8X}")
    return valid_seeds

def main():

    start = time.time()
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
    test()

def main_multi():
    from multiprocessing import Process, Pool

    pool = Pool(processes=8)

    # heal_results = [24, 22, 24, 22, 24, 24, 25, 23, 25, 23, 25, 24]
    # max_hp = 158
    # water_level = 38 
    # healing_rank = 1 
    
    heal_results = [32, 34, 37, 31, 33, 37, 34, 35, 32, 31, 33, 32, 37, 37, 34, 34]
    max_hp = 158
    water_level = 38 
    healing_rank = 2
    scan_length = 0x20000000

    args = [
        [
            heal_results,
            max_hp,
            water_level,
            healing_rank,
            scan_length * k,
            scan_length
        ]
        for k in range(8)
    ]

    results = pool.starmap(find_valid_heal_seeds, args)
    pool.close()

    seeds = []
    for result in results:
        seeds = seeds + result
            
    for (start_seed, current_seed) in seeds:
        print(f"- {start_seed:8X} -> {current_seed:8X}")

    print(f"Valid Seeds: {len(seeds)}")

if __name__=="__main__":
    start = time.time()
    main_multi()
    # main()
    print(f"Elapsed: {time.time() - start:.2f}")
        