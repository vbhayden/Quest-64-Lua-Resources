"""
CRC Repair tool, copied from the C# Merrow repo which was converted from C++
"""

import struct
import sys

# Constants
N64_HEADER_SIZE = 0x40
N64_BC_SIZE = 0x1000 - N64_HEADER_SIZE

N64_CRC1 = 0x10
N64_CRC2 = 0x14

CHECKSUM_START = 0x00001000
CHECKSUM_LENGTH = 0x00100000
CHECKSUM_CIC6102 = 0xF8CA4DDC
CHECKSUM_CIC6103 = 0xA3886759
CHECKSUM_CIC6105 = 0xDF26F436
CHECKSUM_CIC6106 = 0x1FEA617A

# CRC table - will be generated
crc_table = []


def rol(value, bits):
    """Rotate left"""
    value &= 0xFFFFFFFF
    return ((value << bits) | (value >> (32 - bits))) & 0xFFFFFFFF


def bytes_to_uint32(buffer, offset):
    """Convert 4 bytes (big-endian) to uint32"""
    return struct.unpack('>I', bytes(buffer[offset:offset + 4]))[0]


def write_uint32(buffer, offset, value):
    """Write uint32 as big-endian bytes"""
    struct.pack_into('>I', buffer, offset, value & 0xFFFFFFFF)


def gen_crc_table():
    """Generate CRC32 lookup table"""
    global crc_table
    crc_table = [0] * 256
    poly = 0xEDB88320
    
    for i in range(256):
        crc = i
        for _ in range(8):
            if crc & 1:
                crc = (crc >> 1) ^ poly
            else:
                crc = crc >> 1
        crc_table[i] = crc & 0xFFFFFFFF
    
    return crc_table


def crc32(data, offset, length):
    """Calculate CRC32"""
    crc = 0xFFFFFFFF
    for i in range(offset, offset + length):
        crc = (crc >> 8) ^ crc_table[(crc ^ data[i]) & 0xFF]
    return ~crc & 0xFFFFFFFF


def n64_get_cic(data):
    """Detect CIC chip from boot code"""
    crc = crc32(data, N64_HEADER_SIZE, N64_BC_SIZE)
    
    cic_map = {
        0x6170A4A1: 6101,
        0x90BB6CB5: 6102,
        0x0B050EE0: 6103,
        0x98BC2C86: 6105,
        0xACC8580A: 6106,
    }
    
    return cic_map.get(crc, 6105)


def seed_from_bootcode(bootcode):
    """Get seed value from bootcode"""
    seed_map = {
        6101: CHECKSUM_CIC6102,
        6102: CHECKSUM_CIC6102,
        6103: CHECKSUM_CIC6103,
        6105: CHECKSUM_CIC6105,
        6106: CHECKSUM_CIC6106,
    }
    return seed_map.get(bootcode, 0)


def n64_calc_crc(data):
    """Calculate N64 CRC values. Returns (crc1, crc2) or None on error"""
    bootcode = n64_get_cic(data)
    seed = seed_from_bootcode(bootcode)
    
    if seed == 0:
        return None
    
    t1 = seed
    t2 = seed
    t3 = seed
    t4 = seed
    t5 = seed
    t6 = seed
    
    for i in range(CHECKSUM_START, CHECKSUM_START + CHECKSUM_LENGTH, 4):
        d = bytes_to_uint32(data, i)
        
        # Check for overflow before wrapping
        if (t6 + d) > 0xFFFFFFFF:
            t4 = (t4 + 1) & 0xFFFFFFFF
        t6 = (t6 + d) & 0xFFFFFFFF
        t3 ^= d
        
        r = rol(d, d & 0x1F)
        t5 = (t5 + r) & 0xFFFFFFFF
        t2 ^= (r if t2 > d else t6 ^ d)
        
        if bootcode == 6105:
            idx = N64_HEADER_SIZE + 0x0710 + (i & 0xFF)
            ref_val = bytes_to_uint32(data, idx)
            t1 = (t1 + (ref_val ^ d)) & 0xFFFFFFFF
        else:
            t1 = (t1 + (t5 ^ d)) & 0xFFFFFFFF
    
    if bootcode == 6103:
        crc1 = ((t6 ^ t4) + t3) & 0xFFFFFFFF
        crc2 = ((t5 ^ t2) + t1) & 0xFFFFFFFF
    elif bootcode == 6106:
        crc1 = ((t6 * t4) + t3) & 0xFFFFFFFF
        crc2 = ((t5 * t2) + t1) & 0xFFFFFFFF
    else:
        crc1 = (t6 ^ t4 ^ t3) & 0xFFFFFFFF
        crc2 = (t5 ^ t2 ^ t1) & 0xFFFFFFFF
    
    return (crc1, crc2)


def fix_crc(file_path):
    """Fix CRC in N64 ROM file"""
    gen_crc_table()
    
    try:
        with open(file_path, 'rb') as f:
            buffer = bytearray(f.read())
    except IOError as ex:
        print(f'Unable to open "{file_path}": {ex}')
        return 1
    
    if len(buffer) < CHECKSUM_START + CHECKSUM_LENGTH:
        print("File too small or invalid N64 image.")
        return 1
    
    cic = n64_get_cic(buffer)
    cic_name = f"CIC-NUS-{cic}" if cic != 0 else "Unknown"
    print(f"BootChip: {cic_name}")
    
    crc_values = n64_calc_crc(buffer)
    if crc_values is None:
        print("Unable to calculate CRC")
        return 1
    
    crc1_calc, crc2_calc = crc_values
    
    crc1_read = bytes_to_uint32(buffer, N64_CRC1)
    crc2_read = bytes_to_uint32(buffer, N64_CRC2)
    
    crc1_status = "(Good)" if crc1_calc == crc1_read else "(Bad, fixed)"
    print(f"CRC 1: 0x{crc1_read:08X}  Calculated: 0x{crc1_calc:08X} {crc1_status}")
    if crc1_calc != crc1_read:
        write_uint32(buffer, N64_CRC1, crc1_calc)
    
    crc2_status = "(Good)" if crc2_calc == crc2_read else "(Bad, fixed)"
    print(f"CRC 2: 0x{crc2_read:08X}  Calculated: 0x{crc2_calc:08X} {crc2_status}")
    if crc2_calc != crc2_read:
        write_uint32(buffer, N64_CRC2, crc2_calc)
    
    try:
        with open(file_path, 'wb') as f:
            f.write(buffer)
    except IOError as ex:
        print(f"Failed to write file: {ex}")
        return 1
    
    return 0


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python n64_crc.py <rom_file>")
        sys.exit(1)
    
    sys.exit(fix_crc(sys.argv[1]))
