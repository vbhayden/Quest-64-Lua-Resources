import re

special_tokens_to_bin = {
    "at":   0b00001,
    "sp": 	0b11101,
    "ra": 	0b11111,
    "zero": 0b00000,
    "s0":   0b10000,
    "s1":   0b10001,
    "s2":   0b10010,
    "s3":   0b10011,
    "t6":   0b01110,
}

operation_to_bin = {
    "lh":   0b100001,
    "lw":   0b100011,
    "lhu":  0b100101,
    "sh":   0b101001,
    "sw":   0b101011,
    "swc1": 0b111001,
    
    "addiu": 0b001001,
    "lui"  : 0b001111,
    "lwc1":  0b110001,
    "ldc1":  0b110101,
    "addu":  0b100001,
    "andi":  0b001100,
    "jr":    0b001000,
    "jal":   0b000011,
    "move":  0b100101,
    "or":    0b100101,
    
    "beqzl": 0b000100,
    "beqz":  0b000100,
    "beql":  0b010100,
    "beq":   0b000100,
    "blez":  0b000110,
    "bne":   0b000101,
    
    "sll":   0b000000,
    "slt":   0b101010,
    "subu":  0b100011,

    "mfc1":  0b010001,
}

SPECIAL_BREAKS = {
    "bgez":  0b00001,
}

FLOAT_REGISTERS = {
    # Value / return registers
    "fv0":  0b00000,  # 0  ($f0)
    "fv0f": 0b00001,  # 0  ($f1)
    "fv1":  0b00010,  # 2  ($f2)

    # Floating-point argument registers
    "fa0":  0b01100,  # 12 ($f12)
    "fa1":  0b01110,  # 14 ($f14)
    "fa2":  0b10000,  # 16 ($f16)
    "fa3":  0b10010,  # 18 ($f18)

    # Floating-point temporary registers
    "ft0":  0b00100,  # 4  ($f4)
    "ft1":  0b00110,  # 6  ($f6)
    "ft2":  0b01000,  # 8  ($f8)
    "ft2f": 0b01001,  # 9  ($f9)
    "ft3":  0b01010,  # 10 ($f10)
    "ft4":  0b10000,  # 16 ($f16)
    "ft5":  0b10010,  # 18 ($f18)
    "ft6":  0b10100,  # 20 ($f20)
    "ft7":  0b10110,  # 22 ($f22)
}

COP_FUNC_CODES = {
    "mul.s":   0b000010,
    "add.s":   0b000000,
    "sub.s":   0b000001,
    
    "cvt.s.w": 0b100000,
    "cvt.s.d": 0b100000,
    "cvt.d.s": 0b100001,
    
    "mul.d":   0b000010,
    "add.d":   0b000000,
    "sub.d":   0b000001,
}

def get_register_bin(register: str) -> int:
    if register in special_tokens_to_bin:
        return special_tokens_to_bin[register]
    
    if register.startswith("v"):
        return 0b00010 + int(register[1:])
    
    if register.startswith("a"):
        return 0b00100 + int(register[1:])
    
    if register.startswith("s"):
        return 0b10000 + int(register[1:])
    
    if register.startswith("t"):
        t_index = int(register[1:])
        if t_index == 8:
            return 0b11000
        elif t_index == 9:
            return 0b11001
        else:
            return 0b1000 + t_index
    
    if register.startswith("f"):
        return FLOAT_REGISTERS[register]

    print(f"UNKNOWN REGISTER: {register}")

def get_lo_from(mem_addr: str) -> int:
    
    # print(f"Getting lo from {mem_addr}")

    if "+" in mem_addr:
        [base_str, extra_str] = mem_addr.split("+")
        base = int(base_str[2:], 16)
        extra = int(extra_str, 16)

        return f"{(base + extra):04X}"[4:]

    return mem_addr[6:]

def get_hi_from(mem_addr: str) -> int:

    if "+" in mem_addr:
        [base_str, extra_str] = mem_addr.split("+")
        base = int(base_str[2:], 16)
        extra = int(extra_str, 16)

        addr = base + extra
        upper = addr & 0xFFFF0000 >> 16
        lower = addr & 0x0000FFFF

        if lower >= 0x8000:
            upper += 1

        return f"{upper:04X}"
    
    addr = int(mem_addr[2:], 16)
    upper = (addr & 0xFFFF0000) >> 16
    lower = addr & 0x0000FFFF

    if lower >= 0x8000:
        upper += 1

    return f"{upper:04X}"

def assemble_hex_instruction(operation: str, r1: str, r2: str, immediate: int):
    
    op_code = f"{operation_to_bin[operation]:06b}"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    im_code = f"{immediate & 0xFFFF:016b}"
    
    return f"{int(op_code + r2_code + r1_code + im_code, 2):08X}"
    

def assemble_addu_hex_instruction(operation: str, r1: str, r2: str, r3: str):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"
    
    return f"{int(lead_zeros + r2_code + r3_code + r1_code + trail_zeroes + op_code, 2):08X}"

def assemble_cop_arithmetic_hex_instruction(operation: str, r1: str, r2: str, r3: str):
    
    coprocessor = "010001"
    func_format = "10000"
    func_code = f"{COP_FUNC_CODES[operation]:06b}"

    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    
    return f"{int(coprocessor + func_format + r3_code + r2_code + r1_code + func_code, 2):08X}"


def assemble_cvt_s_w_hex_instruction(operation: str, r1: str, r2: str):
    
    # /* 9CAC 800090AC 468042A0 */   cvt.s.w   $f10, $f8
    # r1, f10: 01010
    # r2, f8 : 01000
    #            cop    fop         r2    r1    op
    # 468042A0 - 010001 10100 00000 01000 01010 100000
    
    coprocessor = "010001"
    func_format = "10100"
    zeroes = "0" * 5
    func_code = f"{COP_FUNC_CODES[operation]:06b}"

    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    
    return f"{int(coprocessor + func_format + zeroes + r2_code + r1_code + func_code, 2):08X}"



def assemble_cvt_s_d_hex_instruction(operation: str, r1: str, r2: str):
    
    # /* 9D84 80009184 46205320 */   cvt.s.d   $f12, $f10
    #            cop                $f10  $f12
    # 46205320 - 010001 10001 00000 01010 01100 100000
    
    coprocessor = "010001"
    func_format = "10001"
    zeroes = "0" * 5
    func_code = f"{COP_FUNC_CODES[operation]:06b}"

    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    
    return f"{int(coprocessor + func_format + zeroes + r2_code + r1_code + func_code, 2):08X}"


def assemble_cvt_d_s_hex_instruction(operation: str, r1: str, r2: str):
    
    # /* 9D84 80009184 46205320 */   cvt.s.d   $f12, $f10
    #            cop                $f10  $f12
    # 46205320 - 010001 10000 00000 10010 00100 100001
    
    coprocessor = "010001"
    func_format = "10000"
    zeroes = "0" * 5
    func_code = f"{COP_FUNC_CODES[operation]:06b}"

    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    
    return f"{int(coprocessor + func_format + zeroes + r2_code + r1_code + func_code, 2):08X}"



# Order: 2-3-1, rear zeroes

def assemble_special_hex_instruction(operation: str, r1: str, r2: str, r3: str):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"
    
    return f"{int(lead_zeros + r2_code + r3_code + r1_code + trail_zeroes + op_code, 2):08X}"

# Order: 2-1-3, rear zeroes

def assemble_sll_hex_instruction(operation: str, r1: str, r2: str, sa: int):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    sa_code = f"{sa:05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"

    binary = lead_zeros + trail_zeroes + r2_code + r1_code + sa_code + op_code
    
    return f"{int(binary, 2):08X}"


# Order: 2-3-1, rear zeroes

def assemble_subu_hex_instruction(operation: str, r1: str, r2: str, r3_immediate: int):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{r3_immediate:05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"

    binary = lead_zeros + r2_code + r3_code + r1_code + trail_zeroes + op_code
    
    return f"{int(binary, 2):08X}"


# Order: 2-3-1, rear zeroes

def assemble_slt_hex_instruction(operation: str, r1: str, r2: str, r3: str):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"

    binary = lead_zeros + trail_zeroes + r2_code + r3_code + r1_code + op_code
    
    return f"{int(binary, 2):08X}"


# Order: 2-3-1, rear zeroes

def assemble_slt_hex_instruction(operation: str, r1: str, r2: str, r3: str):
    
    lead_zeros = "000000"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    trail_zeroes = "00000"
    op_code = f"{operation_to_bin[operation]:06b}"

    binary = lead_zeros + trail_zeroes + r2_code + r3_code + r1_code + op_code
    
    return f"{int(binary, 2):08X}"


# Order: 2-3-1, rear zeroes

def assemble_mfc1_hex_instruction(operation: str, r1: str, r2: str):
    
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    immediate_zeroes = "00000000000"
    mid_code = "00000"
    cop_code = "010001"
    
    #              r1    r2
    # mfc1         $a2,  $f2
    # 010001 00000 00110 00010 00000000000

    binary = cop_code + mid_code + r1_code + r2_code + immediate_zeroes
    
    return f"{int(binary, 2):08X}"



# Order: 2-3-1, rear zeroes

def assemble_mtc1_hex_instruction(operation: str, r1: str, r2: str):
    
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    
    immediate_zeroes = "00000000000"
    
    mid_code = "00100"
    cop_code = "010001"
    
    #              r1    r2
    # cop    mtc1  $t6,  $f8
    # 010001 00100 01110 01000 00000000000
    
    binary = cop_code + mid_code + r1_code + r2_code + immediate_zeroes
    full = f"{int(binary, 2):08X}"
    
    # print(full, "MTC1", r1, r1_code, r2, r2_code)
        
    return full


def assemble_double_arithmetic_hex(operation: str, r1: str, r2: str, r3: str):

    # add.d
    # /* 9D78 80009178 46208280 */  add.d      $f10, $f16, $f0
    # r1, f10: 01010
    # r2, f16: 10000
    # r3: f0 : 00000
    #            cop    op    r3    r2    r1
    # 46208280 - 010001 10001 00000 10000 01010 000000


    # mul.d
    # /* 9CCC 800090CC 46249182 */  mul.d      $f6, $f18, $f4

    # r1, f6 : 00110
    # r2, f18: 10010
    # r3: f4 : 00100
            
    #            cop    fop   r3    r2    r1    op
    # 46249182 - 010001 10001 00100 10010 00110 000010

    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    r3_code = f"{get_register_bin(r3):05b}"
    
    immediate = f"{COP_FUNC_CODES[operation]:06b}"
    
    cop_code = "010001"
    mid_code = "10001"
    
    binary = cop_code + mid_code + r3_code + r2_code + r1_code + immediate
    full = f"{int(binary, 2):08X}"
    
    return full



def process_load_and_store(offset ,operation, tokens) -> str:
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """

    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    # print(operation, tokens, results)   

    if "lo" in results:
        
        if len(results) == 5:
            [r1, lo, mem_addr_raw, hex_offset, at] = results
            mem_addr_resolved = get_lo_from(mem_addr_raw + "+" + hex_offset)
            
        elif len(results) == 4:
            [r1, lo, mem_addr_raw, at] = results
            mem_addr_resolved = get_lo_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, at, mem_block)

    elif "hi" in results:
        
        if len(results) == 5:
            [r1, hi, mem_addr_raw, hex_offset, at] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw + "+" + hex_offset)
            
        elif len(results) == 4:
            [r1, hi, mem_addr_raw, at] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        full = assemble_hex_instruction(operation, r1, at, mem_block)
        
        return full
    
    else:
        
        [r1, dest_offset_str, r2] = results
        dest_offset = int(dest_offset_str, 16)

        full = assemble_hex_instruction(operation, r1, r2, dest_offset)
        
        return full

def process_addiu(offset, operation, tokens) -> str:
    token_pattern = r"""
        -0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    if "lo" in results:
        
        if len(results) == 4:
            [r1, r2, lo, mem_addr_raw] = results
            mem_addr_resolved = get_lo_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, r2, mem_block)
    
    
    elif "hi" in results:
        
        if len(results) == 4:
            [r1, r2, hi, mem_addr_raw] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, r2, mem_block)
    
    else:
        [r1, r2, dest_offset_str] = results
        dest_offset = int(dest_offset_str, 16)

        full = assemble_hex_instruction(operation, r1, r2, dest_offset)
        
        return full

def process_lui(offset, operation, tokens) -> str:
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    if "lo" in results:
        
        if len(results) == 3:
            [r1, lo, mem_addr_raw] = results
            mem_addr_resolved = get_lo_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, "zero", mem_block)
    
    
    elif "hi" in results:
        
        if len(results) == 3:
            [r1, hi, mem_addr_raw] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, "zero", mem_block)
    
    else:
        
        [r1, dest_offset_str] = results
        dest_offset = int(dest_offset_str, 16)

        full = assemble_hex_instruction(operation, r1, "zero", dest_offset)
        
        return full
    
    
def process_load_into_cop(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    if "lo" in results:
        
        if len(results) == 4:
            [r1, lo, mem_addr_raw, at] = results
            mem_addr_resolved = get_lo_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, at, mem_block)
    
    
    elif "hi" in results:
        
        if len(results) == 4:
            [r1, hi, mem_addr_raw, at] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, r1, at, mem_block)
    
    else:
        
        [r1, dest_offset_str, r2] = results
        dest_offset = int(dest_offset_str, 16)

        full = assemble_hex_instruction(operation, r1, r2, dest_offset)
        return full
    
    
    
def process_addu(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, r3] = results

    full = assemble_addu_hex_instruction(operation, r1, r2, r3)
    return full

def process_andi(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, immediate] = results

    full = assemble_hex_instruction(operation, r1, r2, int(immediate, 16))
    
    return full
   
def process_cop_arithmetic(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, r3] = results

    full = assemble_cop_arithmetic_hex_instruction(operation, r1, r2, r3)
    return full


def process_cvt_s_d(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results

    full = assemble_cvt_s_d_hex_instruction(operation, r1, r2)
    return full


def process_cvt_s_w(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results

    full = assemble_cvt_s_w_hex_instruction(operation, r1, r2)
    return full


def process_cvt_d_s(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results

    full = assemble_cvt_d_s_hex_instruction(operation, r1, r2)
    return full

def process_double_arithmetic(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, r3] = results

    full = assemble_double_arithmetic_hex(operation, r1, r2, r3)
    return full

def process_jr(offset, operation, tokens) -> str:
    
    special = "0" * 6
    mid_zeroes = "0" * 15
    ra = f"{get_register_bin(tokens):05b}"
    jr = f"{operation_to_bin[operation]:06b}"
    
    return f"{int(special + ra + mid_zeroes + jr, 2):08X}"

def process_jal(offset, operation, tokens) -> str:
    
    func_addr = int(tokens[6:], 16)
    jal_addr = func_addr // 4
    
    target = f"{jal_addr:026b}"
    special = f"{operation_to_bin[operation]:06b}"
    
    return f"{int(special + target, 2):08X}"


def process_or(offset, operation, tokens) -> str:
     
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    if len(results) == 3:
        [r1, r2, r3] = results
        
    elif len(results) == 2:
        [r1, r2] = results
        r3 = "zero"

    full = assemble_special_hex_instruction(operation, r1, r2, r3)
    return full


def process_sll(offset, operation, tokens) -> str:
     
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, shift_str] = results
    shift_amount = int(shift_str, 16)

    full = assemble_sll_hex_instruction(operation, r1, r2, shift_amount)
    return full


def process_slt(offset, operation, tokens) -> str:
     
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, r3] = results

    full = assemble_slt_hex_instruction(operation, r1, r2, r3)
    return full


def process_li(offset, operation, tokens) -> str:
     
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results

    return process_addiu(offset, "addiu", f"{r1},zero,{r2}")


def process_mfc1(offset, operation, tokens) -> str:

    # cop    mfc1  $a2,  $f2
    # 010001 00000 00110 00010 00000000000

    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results
    
    full = assemble_mfc1_hex_instruction(operation, r1, r2)
    return full


def process_mtc1(offset, operation, tokens) -> str:

    # cop    mtc1  $a2,  $f2
    # 010001 00100 01110 01000 00000000000
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2] = results
    
    full = assemble_mtc1_hex_instruction(operation, r1, r2)
    return full


def process_beq(offset, operation, tokens) -> str:
    
    print(tokens)
    [r1, r2, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    op_code = f"{operation_to_bin[operation]:06b}"
    r1_code = f"{get_register_bin(r1):05b}"
    zero_code = "0" * 5
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + zero_code + delta_code, 2):08X}"


def process_beql(offset, operation, tokens) -> str:
    
    [r1, r2, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    op_code = f"{operation_to_bin[operation]:06b}"
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    zero_code = "0" * 5
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + zero_code + delta_code, 2):08X}"
    
def process_beqzl(offset, operation, tokens) -> str:
    [r1, jump] = tokens.split(",")
    return process_beql(offset, "beql", ",".join([r1, "zero", jump]))  

def process_beqz(offset, operation, tokens) -> str:
     
    [r1, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    op_code = f"{operation_to_bin[operation]:06b}"
    r1_code = f"{get_register_bin(r1):05b}"
    zero_code = "0" * 5
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + zero_code + delta_code, 2):08X}"


def process_bgez(offset, operation, tokens) -> str:
     
    [r1, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    regimm = "000001"
    r1_code = f"{get_register_bin(r1):05b}"
    op_code = f"{SPECIAL_BREAKS[operation]:05b}"
    delta_code = f"{int(op_delta):016b}"

    return f"{int(regimm + r1_code + op_code + delta_code, 2):08X}"



def process_blez(offset, operation, tokens) -> str:
     
    [r1, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    r1_code = f"{get_register_bin(r1):05b}"
    op_code = f"{operation_to_bin[operation]:06b}"
    zeroes = "0" * 5
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + zeroes + delta_code, 2):08X}"



def process_bnez(offset, operation, tokens) -> str:
     
    [r1, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
        
    return process_bne(offset, "bne", ",".join([r1, "zero", jump]))


def process_bne(offset, operation, tokens) -> str:
     
    [r1, r2, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4 - 1
    
    r1_code = f"{get_register_bin(r1):05b}"
    r2_code = f"{get_register_bin(r2):05b}"
    op_code = f"{operation_to_bin[operation]:06b}"
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + r2_code + delta_code, 2):08X}"




def process_break(offset, operation, tokens) -> str:
     return process_beqz(offset, "beqz", f"zero,{tokens}")


def process_subu(offset, operation, tokens) -> str:
     
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
    [r1, r2, r3] = results

    if "x" in r3:
        r3_immediate = int(r3, 16)
    else:
        r3_immediate = get_register_bin(r3)

    full = assemble_subu_hex_instruction(operation, r1, r2, r3_immediate)
    return full


def interpret_as_hex(offset, operation, tokens) -> str:
    
    if operation in ["sw", "sh", "swc1", "lhu", "lh", "lw"]:
        return process_load_and_store(offset, operation, tokens)
    
    elif operation in ["addiu"]:
        return process_addiu(offset, operation, tokens)
    
    elif operation in ["lui"]:
        return process_lui(offset, operation, tokens)
    
    elif operation in ["lwc1", "ldc1"]:
        return process_load_into_cop(offset, operation, tokens)    
    
    elif operation in ["addu"]:
        return process_addu(offset, operation, tokens)
    
    elif operation in ["addu"]:
        return process_addu(offset, operation, tokens)
    
    elif operation in ["add.s", "sub.s", "mul.s"]:
        return process_cop_arithmetic(offset, operation, tokens)
    
    elif operation in ["andi"]:
        return process_andi(offset, operation, tokens)
    
    elif operation in ["jr"]:
        return process_jr(offset, operation, tokens)
    
    elif operation in ["jal"]:
        return process_jal(offset, operation, tokens)
    
    elif operation in ["or", "move"]:
        return process_or(offset, operation, tokens)
    
    elif operation in ["beql", "beq"]:
        return process_beq(offset, operation, tokens)
    
    elif operation in ["beqzl"]:
        return process_beqzl(offset, operation, tokens)
    
    elif operation in ["beqz"]:
        return process_beqz(offset, operation, tokens)
    
    elif operation in ["bgez"]:
        return process_bgez(offset, operation, tokens)
    
    elif operation in ["blez"]:
        return process_blez(offset, operation, tokens)
    
    elif operation in ["bnez"]:
        return process_bnez(offset, operation, tokens)
        
    elif operation in ["b"]:
        return process_break(offset, operation, tokens)
        
    elif operation in ["sll"]:
        return process_sll(offset, operation, tokens)
    
    elif operation in ["slt"]:
        return process_slt(offset, operation, tokens)
    
    elif operation in ["li"]:
        return process_li(offset, operation, tokens)
    
    elif operation in ["mfc1"]:
        return process_mfc1(offset, operation, tokens)
    
    elif operation in ["mtc1"]:
        return process_mtc1(offset, operation, tokens)

    elif operation in ["cvt.s.w"]:
        return process_cvt_s_w(offset, operation, tokens)
    
    elif operation in ["cvt.s.d"]:
        return process_cvt_s_d(offset, operation, tokens)
    
    elif operation in ["cvt.d.s"]:
        return process_cvt_d_s(offset, operation, tokens)
    
    elif operation in ["add.d", "mul.d"]:
        return process_double_arithmetic(offset, operation, tokens)

    elif operation in ["nop"]:
        return "00000000"

    elif operation in ["subu"]:
        return process_subu(offset, operation, tokens)
    
    return ""



def parse_decomp_me_hex(decomp_asm_path):

    lines = []
    with open(decomp_asm_path) as fp:
        lines = fp.readlines()
    
    line_count = 0
    match_count = 0
    missing_ops = []
    hex_blocks = []
    operations = []

    print(f"Parsing decomp file with {len(lines)} lines")

    for line in lines:
        line = line.strip()

        if ":" not in line:
            continue

        [header, instruction] = line.split(":")
        instruction = instruction[4:]

        offset = int(header[-3:], 16)
        operation = instruction[:8].strip()
        tokens = instruction[8:]

        hex = interpret_as_hex(offset=offset, operation=operation, tokens=tokens)
        
        line_count += 1
        hex_blocks.append(hex if hex != "" else "00000000")
        operations.append(operation)
        
        if hex != "":
            match_count += 1
        elif operation not in missing_ops:
            missing_ops.append(operation)
        
    print(f"{match_count} of {line_count} matched, {round(100 * match_count / line_count, 1)} %")
    print(f"Missing ops: {missing_ops}")

    return hex_blocks, operations


def parse_actual_me_hex(actual_asm_path):

    lines = []
    with open(actual_asm_path) as fp:
        lines = fp.readlines()

    hex_blocks = []
    operations = []

    for line in lines:
        line = line.strip()

        if not line.startswith("/"):
            continue

        chunks = line.split(" ")
        hex = chunks[3]
        hex_blocks.append(hex)

        operations.append(line[30:38].strip())
        
    return hex_blocks, operations


def validate_decomp_me_asm(decomp_path, actual_path):
    decomp_hex, decomp_instructions = parse_decomp_me_hex(decomp_path)
    actual_hex, actual_instructions = parse_actual_me_hex(actual_path)

    if len(decomp_hex) != len(actual_hex):
        print(f"Diff sizes:: decomp: {len(decomp_hex)}, actual: {len(actual_hex)}")

    bad_decomp_instructions = []

    for (decomp, actual, decomp_instruction, actual_instruction) in zip(decomp_hex, actual_hex, decomp_instructions, actual_instructions):

        if decomp == actual:
            print(f"{decomp} == {actual} ✅, {decomp_instruction} vs. {actual_instruction}")
        else:
            print(f"{decomp} != {actual} ❌, {decomp_instruction} vs. {actual_instruction}")

            if decomp_instruction not in bad_decomp_instructions:
                bad_decomp_instructions.append(decomp_instruction)

    print("mismatched instructions: ", bad_decomp_instructions)

def main():
    func_name = "func_80008FE0"
    decomp_path = f"decomp/{func_name}.decomp"
    actual_path = f"decomp/{func_name}.actual"

    validate_decomp_me_asm(decomp_path, actual_path)



if __name__ == "__main__":
    main()
