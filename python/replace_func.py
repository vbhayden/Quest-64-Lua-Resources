block = """
i 288:    addiu   sp,sp,-0x78
28c:    sw      ra,0x34(sp)
290:    sw      s1,0x30(sp)
294:    sw      s0,0x2c(sp)
r 298:    lui     a0,%hi(D_8007D0C4)
r 29c:    lw      a0,%lo(D_8007D0C4)(a0)
r 2a0:    lui     v0,%hi(D_8007D0C0)
> 2a4:    addiu   v0,v0,%lo(D_8007D0C0)
r 2a8:    beqzl   a0,494 ~>
2ac:    lw      ra,0x34(sp)
r 2b0:    lhu     t6,0(v0)
r 2b4:    lui     a2,%hi(D_8007BACC)
| 2b8:    addiu   a2,a2,%lo(D_8007BACC)
r 2bc:    addiu   t7,t6,1
r 2c0:    sh      t7,0(v0)
r 2c4:    lhu     t8,0(a0)
r 2c8:    andi    t9,t7,0xffff
r 2cc:    move    s1,a0
r 2d0:    slt     at,t8,t9
2d4:    beqz    at,490 ~>
| 2d8:    lui     t4,%hi(D_80054690)
r 2dc:    lhu     t2,2(a0)
r 2e0:    lui     t8,%hi(D_8008C598)
> 2e4:    lhu     t8,%lo(D_8008C598)(t8)
r 2e8:    addiu   t4,t4,%lo(D_80054690)
r 2ec:    sll     t3,t2,0x4
r 2f0:    addu    t0,t3,t4
r 2f4:    lh      t5,0(t0)
r 2f8:    lui     t2,%hi(D_8007D0B0)
> 2fc:    sll     t9,t8,0x1
> 300:    addu    t2,t2,t9
> 304:    lhu     t2,%lo(D_8007D0B0)(t2)
> 308:    sll     t6,t5,0x2
> 30c:    lui     t7,%hi(D_800C1B90)
> 310:    addu    t6,t6,t5
> 314:    sll     t6,t6,0x1
318:    addiu   t7,t7,%lo(D_800C1B90)
r 31c:    sll     t3,t2,0x3
r 320:    addu    t1,t6,t7
> 324:    addu    t3,t3,t2
r 328:    sll     t3,t3,0x2
> 32c:    lui     t6,%hi(D_8008C592)
> 330:    lhu     t6,%lo(D_8008C592)(t6)
r 334:    addu    t3,t3,t2
> 338:    sll     t3,t3,0x3
> 33c:    lui     t5,%hi(D_8007C998)
> 340:    addiu   t5,t5,%lo(D_8007C998)
> 344:    addiu   t4,t3,0x24
> 348:    addu    a1,t4,t5
> 34c:    andi    t7,t6,0x2
> 350:    move    v1,a1
> 354:    beqz    t7,364 ~>
> 358:    move    v0,a2
> 35c:    move    v0,a1
| 360:    move    v1,a2
364: ~> lwc1    ft0,8(s1)
r 368:    lui     s0,%hi(D_8007D0D0)
| 36c:    addiu   s0,s0,%lo(D_8007D0D0)
370:    swc1    ft0,0(s0)
374:    lwc1    ft1,0x10(s1)
378:    move    a1,s0
37c:    swc1    ft1,4(s0)
r 380:    lwc1    fa0,0x10(v0)
| 384:    sw      t1,0x48(sp)
r 388:    sw      t0,0x4c(sp)
r 38c:    sw      v1,0x54(sp)
> 390:    sw      v0,0x58(sp)
394:    jal     func_800232F4
| 398:    swc1    fa0,0x38(sp)
39c:    lhu     t8,4(s1)
s 3a0:    lw      v0,0x58(sp)
s 3a4:    lw      v1,0x54(sp)
3a8:    andi    t9,t8,0x2
> 3ac:    lw      t0,0x4c(sp)
3b0:    beqz    t9,3c8 ~>
| 3b4:    lw      t1,0x48(sp)
r 3b8:    lwc1    fv1,0(v1)
< 
r 3bc:    lwc1    fa0,4(v1)
< 
3c0:    b       3d4 ~>
r 3c4:    lwc1    fa1,8(v1)
3c8: ~> lwc1    fv1,0(v0)
3cc:    lwc1    fa0,4(v0)
3d0:    lwc1    fa1,8(v0)
r 3d4: ~> lwc1    ft5,0x24(v0)
3d8:    lwc1    ft4,0(s0)
r 3dc:    lwc1    ft3,0xc(s1)
3e0:    lwc1    ft2,4(s0)
r 3e4:    mul.s   ft4,ft4,ft5
r 3e8:    lwc1    ft1,8(t0)
r 3ec:    lui     at,%hi(D_8007D0D0)
r 3f0:    mul.s   ft3,ft3,ft5
r 3f4:    swc1    ft1,%lo(D_8007D0D0)(at)
| 3f8:    lwc1    ft1,0xc(t0)
r 3fc:    mul.s   ft5,ft2,ft5
| 400:    lui     at,%hi(D_8007D0D0)
< 
r 404:    add.s   fv1,fv1,ft4
r 408:    swc1    ft1,%lo(D_8007D0D0+0x4)(at)
| 40c:    lwc1    ft1,0x28(v0)
r 410:    add.s   fa0,fa0,ft3
| 414:    lwc1    ft3,0x38(sp)
| 418:    mfc1    a2,fv1
| 41c:    add.s   fa1,fa1,ft5
| 420:    mfc1    a3,fa0
| 424:    lui     at,%hi(D_8007D0D0)
< 
< 
< 
< 
< 
< 
< 
< 
< 
< 
< 
r 428:    swc1    ft1,%lo(D_8007D0D0+0x8)(at)
< 
< 
r 42c:    lhu     a0,2(t0)
r 430:    lhu     a1,4(t0)
434:    swc1    fa1,0x10(sp)
| 438:    swc1    ft3,0x14(sp)
< 
< 
< 
< 
< 
r 43c:    sw      t1,0x18(sp)
440:    sw      s0,0x1c(sp)
< 
444:    jal     func_800177F8
r 448:    sw      v0,0x20(sp)
44c:    lhu     v0,4(s1)
r 450:    andi    t2,v0,0x4
r 454:    beqzl   t2,46c ~>
r 458:    andi    t3,v0,0x1
45c:    jal     func_80013F20
460:    li      a0,1
464:    lhu     v0,4(s1)
r 468:    andi    t3,v0,0x1
r 46c: ~> beqz    t3,480 ~>
r 470:    lui     v0,%hi(D_8007D0C4)
474:    lui     at,%hi(D_8007D0C4)
478:    b       490 ~>
47c:    sw      zero,%lo(D_8007D0C4)(at)
> 480: ~> addiu   v0,v0,%lo(D_8007D0C4)
r 484:    lw      t4,0(v0)
< 
r 488:    addiu   t5,t4,0x18
r 48c:    sw      t5,0(v0)
490: ~> lw      ra,0x34(sp)
494: ~> lw      s0,0x2c(sp)
498:    lw      s1,0x30(sp)
49c:    jr      ra
i 4a0:    addiu   sp,sp,0x78
"""

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
    "addu":  0b100001,
    "andi":  0b001100,
    "jr":    0b001000,
    "jal":   0b000011,
    "move":  0b100101,
    "or":    0b100101,
    "beqzl": 0b000100,
    "beqz":  0b000100,
    "beql":  0b010100,
    "sll":   0b000000,
    "slt":   0b101010,
    "mfc1":  0b010001,
}

FLOAT_REGISTERS = {
    # Value / return registers
    "fv0":  0b00000,  # 0  ($f0)
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
    "ft3":  0b01010,  # 10 ($f10)
    "ft4":  0b10000,  # 16 ($f16)
    "ft5":  0b10010,  # 18 ($f18)
    "ft6":  0b10100,  # 20 ($f20)
    "ft7":  0b10110,  # 22 ($f22)
}

COP_FUNC_CODES = {
    "mul.s": 0b000010,
    "add.s": 0b000000,
    "sub.s": 0b000001,
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
        return 0b01000 + int(register[1:])
    
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

        return f"{base + extra:X}"[:4]
    
    return mem_addr[2:6]

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
    
    # print(operation, r1, r2, r3)
    
    return f"{int(coprocessor + func_format + r2_code + r1_code + r3_code + func_code, 2):08X}"


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
    trail_zeroes = "00000"
    immediate_zeroes = "00000000000"
    op_code = f"{operation_to_bin[operation]:06b}"
    
    #              r1    r2
    # mfc1         $a2,  $f2
    # 010001 00000 00110 00010 00000000000

    binary = op_code + trail_zeroes + r1_code + r2_code + immediate_zeroes
    
    return f"{int(binary, 2):08X}"



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

        return assemble_hex_instruction(operation, "zero", r1, mem_block)
    
    
    elif "hi" in results:
        
        if len(results) == 3:
            [r1, hi, mem_addr_raw] = results
            mem_addr_resolved = get_hi_from(mem_addr_raw)
            
        else:
            print("weird results:", results)

        mem_block = int(mem_addr_resolved, 16)

        return assemble_hex_instruction(operation, "zero", r1, mem_block)
    
    else:
        
        [r1, dest_offset_str] = results
        dest_offset = int(dest_offset_str, 16)

        full = assemble_hex_instruction(operation, "zero", r1, dest_offset)
        
        return full
    
    
def process_lwc1(offset, operation, tokens) -> str:
    
    token_pattern = r"""
        0x[0-9A-Fa-f]+   # hexadecimal number, e.g. 0x34
        |
        \d+              # decimal number, e.g. 0 or 12
        |
        [A-Za-z_]\w*     # identifier, e.g. t6 or v0
    """
    results = re.findall(token_pattern, tokens, re.VERBOSE)
    
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

    # mfc1         $a2,  $f2
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


def process_break_if_equals_zero(offset, operation, tokens) -> str:
     
    [r1, jump] = tokens.split(",")
    
    if " " in jump:
        jump = jump.split(" ")[0]
    
    call_offset = offset
    jump_offset = int(jump, 16)
    op_delta = (jump_offset - call_offset) // 4
    
    op_code = f"{operation_to_bin[operation]:06b}"
    r1_code = f"{get_register_bin(r1):05b}"
    zero_code = "0" * 5
    delta_code = f"{int(op_delta):016b}"

    return f"{int(op_code + r1_code + zero_code + delta_code, 2):08X}"



def process_break(offset, operation, tokens) -> str:
     return process_break_if_equals_zero(offset, "beqz", f"zero,{tokens}")


def interpret_as_hex(offset, operation, tokens) -> str:
    
    if operation in ["sw", "sh", "swc1", "lhu", "lh", "lw"]:
        return process_load_and_store(offset, operation, tokens)
    
    elif operation in ["addiu"]:
        return process_addiu(offset, operation, tokens)
    
    elif operation in ["lui"]:
        return process_lui(offset, operation, tokens)
    
    elif operation in ["lwc1"]:
        return process_lwc1(offset, operation, tokens)    
    
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
    
    elif operation in ["beqzl", "beqz"]:
        return process_break_if_equals_zero(offset, operation, tokens)
    
    elif operation in ["sll"]:
        return process_sll(offset, operation, tokens)
    
    elif operation in ["slt"]:
        return process_slt(offset, operation, tokens)
    
    elif operation in ["li"]:
        return process_li(offset, operation, tokens)
    
    elif operation in ["mfc1"]:
        return process_mfc1(offset, operation, tokens)
    
    elif operation in ["b"]:
        return process_break(offset, operation, tokens)
    
    return ""

line_count = 0
match_count = 0
missing_ops = []

hex_blocks = []

for line in block.split("\n"):

    # print(line)

    if ":" not in line:
        continue

    [header, instruction] = line.split(":")
    instruction = instruction[4:]

    offset = int(header[-3:], 16)
    operation = instruction[:8].strip()
    tokens = instruction[8:]

    hex = interpret_as_hex(offset=offset, operation=operation, tokens=tokens)
    
    print(f" {hex:08s} :: {offset:4X} {operation:8s} {tokens:20s}")

    # print(operation, tokens, hex_block)
    
    line_count += 1
    hex_blocks.append(hex)
    
    if hex != "":
        match_count += 1
    elif operation not in missing_ops:
        missing_ops.append(operation)
    
print(f"{match_count} of {line_count} matched, {round(100 * match_count / line_count, 1)} %")
print(f"Missing ops: {missing_ops}")