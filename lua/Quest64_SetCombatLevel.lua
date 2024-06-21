
MEMORY_PLAYER_COMBAT_LEVEL = 0x7BAB4
MEMORY_PLAYER_COMBAT_EXPERIENCE = 0x07BA90

function SetExperience(value)
    memory.write_u32_be(0x07BA90, value,"RDRAM")
end

function GetExperience()
    return memory.read_u32_be(0x07BA90, "RDRAM")
end

function SetCombatLevel(level)
    memory.writebyte(MEMORY_PLAYER_COMBAT_LEVEL, level, "RDRAM")
end

while true do 
    SetCombatLevel(2)
    SetExperience(0)
    emu.frameadvance()
end
