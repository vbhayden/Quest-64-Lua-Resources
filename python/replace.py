from pathlib import Path

ROM_PATH = "./roms/quest.clean.boss.anim.z64"
OUTPUT_PATH = "./quest.boss.anims.z64"


PATCHES = {    
    # # Adjust the queue call to assign the caster's transform after being called
    # 0xAFA8: 0x3C098007,     # Load address for writing caster transform HI -> t0
    # 0xAFAC: 0x2529D0CC,     # Load address for writing caster transform LO
    # 0xAFB0: 0x17200001,     # Jump one less since we moved this down some
    # 0xAFB8: 0x8FA40000,     # Write caster transform ptr to anim variable memory
    
    # Leave directly from Starting Room -> into Holy Plains
    0x43619C: 0x00000002, 
    0x4361A0: 0x00000000, 
    
    # Fixing spell anim update to use caster from projectiles
    0xBF88: 0x3C028008,
    0xBF8C: 0x8C426F3C,
    
    # Fixing queue flag to queue animations for any encounter in func_8000A284
    0xAFBC: 0x308A0400,
    
    # Fixing queue flag to update animations for any encounter in func_80008C20
    0x98C0: 0x318D0101,
    
    # Adding Nepty Spin to Were Hare
    0xADBEE0: 0x84050003,
    
    # Adding Beigis Laser to Hell Hound
    0xADBEF8: 0x840D000A,
    
    # Adding Solvaring Spikes to Big Mouth
    0xADBF28: 0x84010002,
}

with open(ROM_PATH, "rb") as f:
    rom = bytearray(f.read())

for offset, instruction in PATCHES.items():
    rom[offset:offset + 4] = instruction.to_bytes(4, byteorder="big")
    print(f"Patched 0x{offset:08X} -> 0x{instruction:08X}")

with open(OUTPUT_PATH, "wb") as f:
    f.write(rom)

print(f"Saved patched ROM to {OUTPUT_PATH}")
