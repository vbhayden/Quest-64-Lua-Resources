
local MEM_ENEMY_ANIMATION_START = 0x07C998  -- arg0
local MEM_ENEMY_COMBAT_START = 0x7C9BC      -- arg1

local MEM_OFFSET_ATTRIBUTES = 0x20
local MEM_OFFSET_AI_LENGTH = 0x2C
local MEM_OFFSET_AI_START = 0x30

local MEM_OFFSET_ENEMY_MOVEMENT_RADIUS = 0x10
local MEM_OFFSET_ENEMY_MOVEMENT_MODIFIER = 0x120

local MEM_PLAYER_TRANSFORM_START = 0x7BAB8
local MEM_PLAYER_POSITION_START = 0x7BACC
local MEM_PLAYER_RADIUS = 0x07BA98
local MEM_PLAYER_SCALE = 0x7BAF0

local MEM_CURRENT_RNG = 0x4D748
local MEM_BYTE_BATTLE_STATE = 0x8c593

local MEM_SPELL_NAMES_START = 0x0C3910

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 80

local SPELL_NAMES = {}

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetBattleState()
    local state = memory.readbyte(MEM_BYTE_BATTLE_STATE, "RDRAM")
    return {
        brianCanAct = state == 1,
        enemyCanAct = state == 3,
        betweenTurns = state == 7,
        battleActive = state > 0
    }
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
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

local function GetNextRNG(currentRNG)

    -- console.log(debug.traceback())

    local A1 = memory.read_u16_be(0x22FE2, "RDRAM")
    local B1 = memory.read_u16_be(0x22FE4, "RDRAM") - 1000
    local C1 = memory.read_u16_be(0x22FE6, "RDRAM")

    local R_HI1 = math.floor(currentRNG / 0x10000)
    local R_LO1 = currentRNG % 0x10000

    local R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    local R_HI2 = R_HI2 % 65536
    local R_LO2 = R_LO1 * C1 + B1 -- 16,16,16

    return (65536 * R_HI2 + R_LO2) % 0x100000000

    -- return (currentRNG * 0x41C64E6D + 0x3039) % 0x100000000
end

local function GetCurrentRNG()
    return memory.read_u32_be(MEM_CURRENT_RNG, "RDRAM")
end

local function GetFutureRNGExplicit(advances, explicit_seed)
    local future = explicit_seed
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function ReadAISpell(address)

    local spell_id = memory.read_u16_be(address, "RDRAM")
    local spell_name = SPELL_NAMES[spell_id]

    return {
        spell = spell_id,
        name = spell_name,
        max_distance = memory.readfloat(address + 0x10, true, "RDRAM")
    }
end

local function GetCollisionDistanceToBrian()
    local brian_x = memory.readfloat(MEM_PLAYER_POSITION_START + 0x0, true, "RDRAM")
    local brian_z = memory.readfloat(MEM_PLAYER_POSITION_START + 0x8, true, "RDRAM")

    local brian_radius = memory.readfloat(MEM_PLAYER_RADIUS, true, "RDRAM")
    local brian_scale = memory.readfloat(MEM_PLAYER_SCALE, true, "RDRAM")

    local enemy_x = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x0, true, "RDRAM")
    local enemy_z = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x8, true, "RDRAM")

    local dx = enemy_x - brian_x
    local dz = enemy_z - brian_z
    local distance_to_brian = math.sqrt(dx * dx + dz * dz) - brian_radius * brian_scale

    return distance_to_brian
end

local function SimulateRNGCall(rngValue, rollAgainst)
    local checkBase = math.floor(rngValue / 0x10000)
    local rollValue = checkBase % rollAgainst

    return rollValue
end

local function GetEnemySpellUsage()

    local ptr_enemy_attributes = GetPointerFromAddress(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ATTRIBUTES, "RDRAM")
    local ptr_enemy_ai_start = GetPointerFromAddress(ptr_enemy_attributes + MEM_OFFSET_AI_START)

    local enemy_ai_length = memory.read_u16_be(ptr_enemy_attributes + MEM_OFFSET_AI_LENGTH, "RDRAM")
    local enemy_scale = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x24, true, "RDRAM")

    local enemy_movement_radius_default = memory.readfloat(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ENEMY_MOVEMENT_RADIUS, true, "RDRAM")
    local enemy_movement_radius_modifier = memory.readfloat(MEM_ENEMY_ANIMATION_START + MEM_OFFSET_ENEMY_MOVEMENT_MODIFIER, true, "RDRAM")

    local enemy_movement = enemy_movement_radius_default * enemy_movement_radius_modifier
    --

    local spells = {}
    local distance_to_brian = GetCollisionDistanceToBrian()

    for k=0,enemy_ai_length-1 do
        local ai_address = ptr_enemy_ai_start + k * 0x18
        local spell = ReadAISpell(ai_address)
        
        spell.max_distance = spell.max_distance * enemy_scale
        spell.can_happen = false
        spell.will_happen = false
        spells[#spells+1] = spell
    end

    table.sort(spells, function(spell_1, spell_2) return spell_1.max_distance < spell_2.max_distance end)

    local found_spell = false
    local best_spell = nil
    local will_move = false

    for k=1, #spells do
        if found_spell == false then

            local spell = spells[k]
            local next_spell = nil
            if k+1 <= #spells then
                next_spell = spells[k+1]
            end

            if spell.max_distance > distance_to_brian then
                
                best_spell = spell
                best_spell.will_happen = true

                found_spell = true

            else 
                
                local can_reach_with_movement = distance_to_brian < (spell.max_distance + enemy_movement)
                local next_spell_exists = next_spell ~= nil
                local next_spell_already_reaches = next_spell_exists and (next_spell.max_distance > distance_to_brian)

                -- console.log(string.format("1: %s, 2: %s, 3: %s", tostring(can_reach_with_movement), tostring(next_spell_exists), tostring(next_spell_already_reaches)))

                if can_reach_with_movement and next_spell_exists and next_spell_already_reaches then
                    local rng = GetCurrentRNG()
                    local rng_next = GetNextRNG(rng)
                    local spell_roll = SimulateRNGCall(rng_next, 2)
                    
                    spell.can_happen = true
                    next_spell.can_happen = true
    
                    if spell_roll == 0 then
                        best_spell = next_spell
                    else
                        best_spell = spell
                    end
                    
                    if best_spell ~= next_spell then
                        will_move = true
                    end
                    
                    best_spell.will_happen = true
                    found_spell = true
                
                end
                
                -- GuiTextRight(k + 14, string.format("k=%s: %s, 2: %s, 3: %s", k, tostring(can_reach_with_movement), tostring(next_spell_exists), tostring(next_spell_already_reaches)))
                
            end
        end
    end

    if not found_spell then
        local last_spell = spells[#spells]

        if (last_spell.max_distance + enemy_movement) > distance_to_brian then
            last_spell.will_happen = true
        end
    end

    return spells
end

local function ShowPredictionInfo()

    local state = GetBattleState()
    if not state.battleActive then
        GuiTextRight(8, "Not in Combat")
        return
    end

    local brian_x = memory.readfloat(MEM_PLAYER_POSITION_START + 0x0, true, "RDRAM")
    local brian_z = memory.readfloat(MEM_PLAYER_POSITION_START + 0x8, true, "RDRAM")

    local brian_radius = memory.readfloat(MEM_PLAYER_RADIUS, true, "RDRAM")
    local brian_scale = memory.readfloat(MEM_PLAYER_SCALE, true, "RDRAM")

    local enemy_x = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x0, true, "RDRAM")
    local enemy_z = memory.readfloat(MEM_ENEMY_COMBAT_START + 0x8, true, "RDRAM")

    local dx = enemy_x - brian_x
    local dz = enemy_z - brian_z
    local distance_to_brian = math.sqrt(dx * dx + dz * dz) - brian_radius * brian_scale

    local spells = GetEnemySpellUsage()
    local rng = memory.read_u32_be(MEM_CURRENT_RNG, "RDRAM")

    GuiTextRight(7, string.format("Current Distance: %.2f", distance_to_brian))
    GuiTextRight(8, string.format("Current RNG: %08X", rng))


    for k=1, #spells do
        local spell = spells[k]
        local color = Ternary(spell.will_happen, "cyan", Ternary(spell.can_happen, "yellow", "white"))
        local selector = Ternary(spell.will_happen, " >", "  ")
        GuiTextRightWithColor(10 + k, string.format("%s %3.2f: [%04X] %s", selector, spell.max_distance, spell.spell, spell.name), color)
        
        -- console.log(spell)
    end
end

local function ReadSpellNamesFromMemory()

    local names = {}
    local finished = false
    
    local offset = 0
    local found_breakpoint = false

    local total_found = 0
    local spell_id = 0x8000
    local current_name = ""

    while not finished do

        local ptr_current = MEM_SPELL_NAMES_START + offset
        local byte = memory.read_u8(ptr_current, "RDRAM")

        if byte ~= 0 then

            current_name = current_name .. string.char(byte)
            offset = offset + 1

            found_breakpoint = false

        else
            if found_breakpoint then
                finished = true
            else
                offset = offset + 4 - (offset % 4)
                found_breakpoint = true

                names[spell_id] = current_name

                spell_id = spell_id + 1

                total_found = total_found + 1
                if total_found % 15 == 0 then
                    spell_id = spell_id + 0x0100
                    spell_id = bit.band(spell_id, 0xFF00)
                end

                current_name = ""
            end
        end

    end

    return names
end

SPELL_NAMES = ReadSpellNamesFromMemory()

while true do

    ShowPredictionInfo()

    emu.frameadvance()
end
