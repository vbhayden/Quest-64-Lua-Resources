
MEMORY_PLAYER_COMBAT_EXPERIENCE = 0x07BA90
MEMORY_PLAYER_COMBAT_LEVEL = 0x07BAB4

function SetCombatLevel(value)
    memory.writebyte(MEMORY_PLAYER_COMBAT_LEVEL, value,"RDRAM")
end

function GetCombatLevel()
    return memory.readbyte(MEMORY_PLAYER_COMBAT_LEVEL, "RDRAM")
end

function SetExperience(value)
    memory.write_u32_be(MEMORY_PLAYER_COMBAT_EXPERIENCE, value,"RDRAM")
end

function GetExperience()
    return memory.read_u32_be(MEMORY_PLAYER_COMBAT_EXPERIENCE, "RDRAM")
end

-- SetCombatLevel(0)
SetExperience(200)

-- SetExperience(9000)
-- console.log("Level: " .. GetCombatLevel())
-- console.log("XP:    " .. GetExperience())

