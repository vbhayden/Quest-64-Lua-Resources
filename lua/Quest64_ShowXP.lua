MEMORY_PLAYER_COMBAT_EXPERIENCE = 0x07BA90
MEMORY_PLAYER_COMBAT_LEVEL = 0x07BAB2

MEMORY_PLAYER_XP_HEALTH = 0x07BA90
MEMORY_PLAYER_XP_MANA = 0x07BA90
MEMORY_PLAYER_XP_DEFENSE = 0x07BA90
MEMORY_PLAYER_XP_AGILITY = 0x07BA90

function SetCombatLevel(value)
    memory.write_u32_be(0x07BA90, value,"RDRAM")
end

function GetCombatLevel()
    return memory.read_u32_be(0x07BA90, "RDRAM")
end

function SetCombatXP(value)
    memory.write_u32_be(0x07BA90, value,"RDRAM")
end

function GetCombatXP()
    return memory.read_u32_be(0x07BA90, "RDRAM")
end

function SetHealthXP(value)
    memory.write_u16_be(MEMORY_PLAYER_XP_HEALTH, value, "RDRAM")
end

function SetDefenseXP(value)
    memory.write_u16_be(MEMORY_PLAYER_XP_DEFENSE, value, "RDRAM")
end

function SetSpirits(f, e, wa, wi)
    memory.writebyte(0x7BAA4, f, "RDRAM")
    memory.writebyte(0x7BAA5, e, "RDRAM")
    memory.writebyte(0x7BAA6, wa, "RDRAM")
    memory.writebyte(0x7BAA7, wi, "RDRAM")
end

SetSpirits(3, 3, 3, 3)

SetHealthXP(10)
SetDefenseXP(20)
SetCombatXP(500)
