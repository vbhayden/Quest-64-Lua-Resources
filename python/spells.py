"""
Small script to swap out enemy spell selection for boss abilities.

The only goal here is to randomize what the enemies end up with,
and provide a sanity check for whether the game can support these
abilities being used by enemies in the denser overworld areas.
"""

AI_HOLY_PLAINS = [
    0xADBEE0,  ## Were Hare
    0xADBEF8,  ## Hell Hound
    0xADBF10,  ## Man Eater
    0xADBF28,  ## Big Mouth
    0xADBF40,  ## Bumbershoot 1st spell
    0xADBF58,  ## Bumbershoot 2nd spell
    0xADBF70,  ## Parasault 1st spell
    0xADBF88,  ## Parasault 2nd spell
    0xADBFA0,  ## Ork JR 1st spell
    0xADBFB8,  ## Ork JR 2nd spell
    0xADBFD0,  ## Gremlin 1st spell
    0xADBFE8,  ## Gremlin 2nd spell
    0xADC000,  ## Skeleton 1st spell
    0xADC018,  ## Skeleton 2nd spell
    0xADC030,  ## Ghosthound
    0xADC048,  ## Merrow 1st spell
    0xADC060,  ## Merrow 2nd spell
    0xADC078,  ## Wolfgoat 1st spell
]

AI_DESERT_BRANNOCH = [
    0xC31590,  ## Sandman 1st Spell
    0xC315A8,  ## Sandman 2nd Spell
    0xC315C0,  ## Were Cat 1st Spell
    0xC315D8,  ## Were Cat 2nd Spell
    0xC315F0,  ## Nightmare 1st Spell
    0xC31608,  ## Nightmare 2nd Spell
    0xC31620,  ## Blueman
    0xC31638,  ## Winged Sunfish 1st Spell
    0xC31650,  ## Winged Sunfish 2nd Spell
    0xC31668,  ## Gloom Wing 1st Spell
    0xC31680,  ## Gloom Wing 2nd Spell
    0xC31698,  ## Ogre 1st Spell
    0xC316B0,  ## Ogre 2nd Spell
    0xC316C8,  ## Rocky 1st Spell
    0xC316E0,  ## Rocky 2nd Spell
    0xC316F8,  ## Red Wyvern 1st Spell
    0xC31710,  ## Red Wyvern 2nd Spell
    0xC31728,  ## Flamed Mane 1st Spell
    0xC31740,  ## Flamed Mane 2nd Spell
    0xC31758,  ## Magma Fish 1st Spell
    0xC31770,  ## Magma Fish 2nd Spell
    0xC31788,  ## Red Rose Knight 1st Spell
    0xC317A0,  ## Red Rose Knight 2nd Spell
    0xC317B8,  ## White Rose Knight 1st Spe
    0xC317D0,  ## White Rose Knight 2nd Spe
]

AI_DONDORAN = [
    0xB63120,  ## Goblin
    0xB63138,  ## Frog King
    0xB63150,  ## Apophis
    0xB63168,  ## Mad Doll 1st Spell
    0xB63180,  ## Mad Doll 2nd Spell
    0xB63198,  ## Death Hugger 1st Spell
    0xB631B0,  ## Death Hugger 2nd Spell
    0xB631C8,  ## Kobold 1st Spell
    0xB631E0,  ## Kobold 2nd Spell
    0xB631F8,  ## Man Trap 1st Spell
    0xB63210,  ## Man Trap 2nd Spell
    0xB63228,  ## Bat 1st Spell
    0xB63240,  ## Bat 2nd Spell
    0xB63258,  ## Frog Knight 1st Spell
    0xB63270,  ## Frog Knight 2nd Spell
    0xB63288,  ## Marionasty 1st Spell
    0xB632A0,  ## Marionasty 2nd Spell
    0xB632B8,  ## Dark Goblin 1st Spell
    0xB632D0,  ## Dark Goblin 2nd Spell
    0xB632E8,  ## Hot Lips
    0xB63300,  ## Ghost Stalker 1st Spell
    0xB63318,  ## Ghost Stalker 2nd Spell
    0xB63330,  ## Treant
    0xB63348,  ## Cockatrice 1st Spell
    0xB63360,  ## Cockatrice 2nd Spell
]

AI_NORMOON = [
    0xC9BCD0,  ## Ork
    0xC9BCE8,  ## Ghost 1st Spell
    0xC9BD00,  ## Ghost 2nd Spell
    0xC9BD18,  ## Will-O'-Wisp
    0xC9BD30,  ## Sprite
    0xC9BD48,  ## Jack-O'-Lantern 1st Spell
    0xC9BD60,  ## Jack-O'-Lantern 2nd Spell
    0xC9BD78,  ## Arachnoid
    0xC9BD90,  ## Lamia
    0xC9BDA8,  ## Temptress 1st Spell
    0xC9BDC0,  ## Temptress 2nd Spell
    0xC9BDD8,  ## Pixie
    0xC9BDF0,  ## Grangach
    0xC9BE08,  ## Thunder Jell 1st Spell
    0xC9BE20,  ## Thunder Jell 2nd Spell
    0xC9BE38,  ## Termant
]

AI_CULL_HAZARD_BLUE_CAVE = [
    0xBBDD00,  ## Multi Optics 1st Spell
    0xBBDD18,  ## Multi Optics 2nd Spell
    0xBBDD30,  ## Mimic 1st Spell
    0xBBDD48,  ## Mimic 2nd Spell
    0xBBDD60,  ## Crawler 1st Spell
    0xBBDD78,  ## Crawler 2nd Spell
    0xBBDD90,  ## Scorpion 1st Spell
    0xBBDDA8,  ## Scorpion 2nd Spell
    0xBBDDC0,  ## Scare Crow
    0xBBDDD8,  ## Wyvern 1st Spell
    0xBBDDF0,  ## Wyvern 2nd Spell
    0xBBDE08,  ## Skelebat
    0xBBDE20,  ## Cryshell
    0xBBDE38,  ## Blood Jell
    0xBBDE50,  ## Caterpillar 1st Spell
    0xBBDE68,  ## Caterpillar 2nd Spell
    0xBBDE80,  ## Fish Man
]

AI_MAMMONS_WORLD = [
    0xCC4360,  ## Judgement 1st Spell
    0xCC4378,  ## Judgement 2nd Spell
    0xCC4390,  ## Judgement 3rd Spell
    0xCC43A8,  ## Pale Rider 1st Spell
    0xCC43C0,  ## Pale Rider 2nd Spell
    0xCC43D8,  ## Pin Head 1st Spell
    0xCC43F0,  ## Pin Head 2nd Spell
    0xCC4408,  ## Spriggan 1st Spell
    0xCC4420,  ## Spriggan 2nd Spell
]

ALL_AI = [
    AI_HOLY_PLAINS,
    AI_DONDORAN,
    AI_CULL_HAZARD_BLUE_CAVE,
    AI_NORMOON,
    AI_DESERT_BRANNOCH,
    AI_MAMMONS_WORLD
]

BOSS_SPELLS = [
    # 0x8400, ## Solvaring Beam
    # 0x8401, ## Solvaring Pound
    0x8402, ## Zelse Razors
    0x8403, ## Zelse Zipper
    # 0x8306, ## Large Cutter
    0x8404, ## Nepty Bubbles
    # 0x8405, ## Nepty AOE
    # 0x8408, ## Shilf Laser
    0x8409, ## Shilf Doves
    0x8406, ## Fargo Ball
    0x8407, ## Fargo AOE
    # 0x840A, ## Guilty Claws
    # 0x840B, ## Guilty AOE
    0x840C, ## Beigis Sword
    # 0x840D, ## Beigis Beam
    # 0x840E, ## Mammon Globe
    0x840F, ## Mammon Waves
    0x8410, ## Mammon Arrows
]

BOSS_SPELL_ANIMS_TO_UNFLICKER = [
    0xD4E850, ## Mammon Waves
]
 
def swap_spell_code(spell_hex):
    swap_index = spell_hex % len(BOSS_SPELLS)
    return BOSS_SPELLS[swap_index]

def replace_trail_with_solid(rom_data: bytearray, spell_anim_addr: int):
    anim_block_length = 0x10
    trail_block_start = spell_anim_addr
    
    ## Each animation block is 0x10 long, with 4 blocks total and another
    ## sound effect block at the end at 0x8 long.
    ##
    trail_block = rom_data[trail_block_start:trail_block_start + 32]
    
    print(trail_block.__repr__())

if __name__ == "__main__":
    
    # check = 0x8406.to_bytes(2, byteorder="big")
    # print(check)
    
    # exit(0)
    
    import sys

    if len(sys.argv) < 2:
        print("You must pass a valid rom path")
        exit(1)

    rom_path = sys.argv[1]
    
    with open(rom_path, "rb") as fp:
        rom_data = bytearray(fp.read())
    
    for ai_group in ALL_AI:
        for ai_address in ai_group:
            spell_addr = ai_address + 0
            spell_code_raw = rom_data[spell_addr:spell_addr+2]
            spell_code = int.from_bytes(spell_code_raw)
            if spell_code == 0x0000:
                continue
            
            replaced_code = swap_spell_code(spell_code)
            rom_data[spell_addr:spell_addr+2] = replaced_code.to_bytes(2, byteorder="big")
            
            print(f"[{ai_address:8X}] {spell_code:4X} -> {replaced_code:4X}")
    
    # for addr_spell_anim in BOSS_SPELL_ANIMS_TO_UNFLICKER:
    #     addr_spell_anim_type = addr_spell_anim + 16
        
    #     print(f"{addr_spell_anim:8X} -> {addr_spell_anim_type:8X}")
        
    #     current_type = rom_data[addr_spell_anim_type:addr_spell_anim_type + 4]
    #     desired_type = 0x0001
        
    #     print(f"{current_type=} -> {desired_type=}")
    #     print(f"{type(addr_spell_anim_type)}, {type(current_type)}, {type(desired_type)}")
        
    #     rom_data[addr_spell_anim_type:addr_spell_anim_type + 4] = desired_type.to_bytes(2, byteorder="big")
    
    for anim_addr in BOSS_SPELL_ANIMS_TO_UNFLICKER:
        replace_trail_with_solid(rom_data, anim_addr)
    
    with open(rom_path + ".modded", "wb+") as fp:
        fp.write(rom_data)
        
    print("... done!")