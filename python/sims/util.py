from dataclasses import dataclass
from numba import njit

@dataclass
class IncrementExpectation:
    cap: int
    value: int
    expected_value: int

EXPECTATIONS = [
    IncrementExpectation(cap=0x4444, value=0x4443, expected_value=0x4444),
    IncrementExpectation(cap=0x4424, value=0x4324, expected_value=0x4400),
    IncrementExpectation(cap=0x4444, value=0x4444, expected_value=0x4444),
    IncrementExpectation(cap=0x0011, value=0x0001, expected_value=0x0010),
    IncrementExpectation(cap=0x333333333333, value=0x333333333323, expected_value=0x333333333330)
]

@njit()
def increment_against_hex_cap(current, hex_cap):

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
    
    increment = 1 << (4 * digit_index)
    
    return current + increment


def test():
    failures = 0
    for expectation in EXPECTATIONS:
        actual_value = increment_against_hex_cap(expectation.value, expectation.cap)
        if actual_value != expectation.expected_value:
            failures += 1
            print(f"{actual_value:04X} != {expectation.expected_value:04X}")
            
    print("Total Failures:", failures)

def main():
    pass

if __name__=="__main__":
    test()
    main()
