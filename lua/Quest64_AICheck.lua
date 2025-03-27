
local MEM_ENEMY_ANIMATION_START = 0x07C998  -- arg0
local MEM_ENEMY_COMBAT_START = 0x7C9BC      -- arg1

local MEM_OFFSET_ATTRIBUTES = 0x20
local MEM_OFFSET_AI_LENGTH = 0x2C
local MEM_OFFSET_AI_START = 0x30

local MEM_OFFSET_ENEMY_RADIUS = 0x24
local MEM_OFFSET_ENEMY_SCALE = 0x30
local MEM_OFFSET_ENEMY_MOVEMENT_RADIUS = 0x10
local MEM_OFFSET_ENEMY_MOVEMENT_MODIFIER = 0x120


local MEM_PLAYER_TRANSFORM_START = 0x7BAB8
local MEM_PLAYER_RADIUS = 0x07BA98
local MEM_PLAYER_SCALE = 0x7BAF0

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 80

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function ReadAISpell(address)
    return {
        spell = memory.read_u32_be(address, "RDRAM"),
        max_distance = memory.readfloat(address + 0x20, true, "RDRAM")
    }
end

local function GetValidEnemySpells()

    local ptr_enemy_attributes = GetPointerFromAddress(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ATTRIBUTES, "RDRAM")
    local ptr_enemy_ai_start = GetPointerFromAddress(ptr_enemy_attributes + MEM_OFFSET_AI_START)

    local enemy_ai_length = memory.read_u16_be(ptr_enemy_attributes + MEM_OFFSET_AI_LENGTH, "RDRAM")

    local brian_x = memory.readfloat(MEM_PLAYER_TRANSFORM_START + 0x0, true, "RDRAM")
    local brian_z = memory.readfloat(MEM_PLAYER_TRANSFORM_START + 0x8, true, "RDRAM")

    local brian_radius = memory.readfloat(MEM_PLAYER_RADIUS, true, "RDRAM")
    local brian_scale = memory.readfloat(MEM_PLAYER_SCALE, true, "RDRAM")

    local enemy_x = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x0, true, "RDRAM")
    local enemy_z = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x8, true, "RDRAM")

    local enemy_collision_radius = memory.readfloat(MEM_ENEMY_COMBAT_START + MEM_OFFSET_ENEMY_RADIUS, true, "RDRAM")

    local enemy_movement_radius_default = memory.readfloat(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ENEMY_MOVEMENT_RADIUS, true, "RDRAM")
    local enemy_movement_radius_modifier = memory.readfloat(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ENEMY_MOVEMENT_MODIFIER, true, "RDRAM")

    --

    local dx = enemy_x - brian_x
    local dz = enemy_z - brian_z
    local distance_to_brian = math.sqrt(dx * dx + dz * dz) - brian_radius * brian_scale

    local spells = {}

    for k=0,enemy_ai_length-1 do
        local ai_address = ptr_enemy_ai_start + k * 0x18
        local spell = ReadAISpell(ai_address)
        
        spells[#spells+1] = spell
    end

    table.sort(spells, function(spell_1, spell_2) return spell_1.max_distance < spell_2.max_distance end)

    return spells
end


local function GuiTextRightWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text, color)
end

local function GuiTextRight(row_index, text)
    GuiTextRightWithColor(row_index, text, "white")
end

local function ShowPredictionInfo()

    local spells = GetValidEnemySpells()
    
    for k=1, #spells do
        local spell = spells[k]
        GuiTextRight(10 + k, string.format("%s: %08X  @ ", k, spell.spell))
    end

end

while true do

    ShowPredictionInfo()

    emu.frameadvance()
end
