
MEMORY_PLAYER_COMBAT_EXPERIENCE = 0x07BA90

function GetCombatExperience()
    return memory.read_u32_be(MEMORY_PLAYER_COMBAT_EXPERIENCE, "RDRAM")
end

function SetCombatExperience(val)
    memory.write_u32_be(MEMORY_PLAYER_COMBAT_EXPERIENCE, val, "RDRAM")
end

function SetSpirits(f, e, wa, wi)
    memory.writebyte(0x7BAA4, f, "RDRAM")
    memory.writebyte(0x7BAA5, e, "RDRAM")
    memory.writebyte(0x7BAA6, wa, "RDRAM")
    memory.writebyte(0x7BAA7, wi, "RDRAM")
end

function SetOtherStats(hp, mp, defense, agility, mapHp, maxMana)
    
    memory.write_u16_be(0x7BA84, hp, "RDRAM")
    memory.write_u16_be(0x7BA86, mapHp, "RDRAM")
    memory.write_u16_be(0x7BA88, mp, "RDRAM")
    memory.write_u16_be(0x7BA8A, maxMana, "RDRAM")
    memory.writebyte(0x7BA8F, defense, "RDRAM")
    memory.writebyte(0x7BA8D, agility, "RDRAM")
end

function GetExperience()
    return memory.read_u32_be(0x07BA90, "RDRAM")
end

-- SetCombatExperience(28000)

-- SetSpirits(1, 1, 1, 16)
-- SetOtherStats(1, 48, 100, 500, 150, 48)


while true do 
    -- SetSpirits(20, 50, 48, 1)
    -- SetOtherStats(115, 18, 4, 95, 115, 18)
    
    -- SetSpirits(49, 49, 49, 49)
    -- SetOtherStats(1, 48, 100, 89, 150, 48)
    
    -- SetSpirits(1, 25, 23, 1)
    -- SetOtherStats(82, 20, 16, 16, 82, 20)
    
    -- SetSpirits(1, 1, 1, 1)
    -- SetOtherStats(50, 15, 40, 40, 82, 20)
    
    -- SetSpirits(1, 1, 7, 1)
    -- SetOtherStats(50, 15, 40, 40, 82, 20)
    
    -- SetSpirits(1, 1, 8, 1)
    -- SetOtherStats(50, 15, 40, 40, 82, 20)
    
    -- SetSpirits(1, 34, 1, 1)
    -- SetOtherStats(1, 15, 40, 40, 82, 20)
    
    SetSpirits(1, 1, 7, 1)
    SetOtherStats(50, 15, 4, 10, 50, 15)
    
    -- SetSpirits(1, 1, 23, 1)
    -- SetOtherStats(1, 15, 6, 6, 50, 15)

    emu.frameadvance()
end

console.log(GetExperience())
