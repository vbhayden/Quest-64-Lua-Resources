local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_ENEMY_POSITION_X = 0x7C9BC
local MEM_ENEMY_POSITION_Z = 0x7C9C4
local MEM_ENEMY_ROTATION_Y = 0x7C9CC

local GUI_PADDING_RIGHT = 240 + 100

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function GetEnemyAtIndex(index)

    local addr_offset = 296 * index

    local id = memory.readbyte(0x07CA0D + addr_offset, "RDRAM")

    local hp = memory.read_u16_be(0x07C9A2 + addr_offset, "RDRAM")
    local hpMax = memory.read_u16_be(0x07C9A4 + addr_offset, "RDRAM")

    local attack = memory.read_u16_be(0x07CAAC + addr_offset, "RDRAM")
    local agility = memory.read_u16_be(0x07CAAE + addr_offset, "RDRAM")
    local defense = memory.read_u16_be(0x07CAB0 + addr_offset, "RDRAM")
    
    local x = memory.readfloat(0x7C9BC + addr_offset, true, "RDRAM")
    local y = memory.readfloat(0x7C9C0 + addr_offset, true, "RDRAM")
    local z = memory.readfloat(0x7C9C4 + addr_offset, true, "RDRAM")
    
    local ptr_attributes = GetPointerFromAddress(0x07CA20 + addr_offset)
    local xp = memory.read_u32_be(ptr_attributes + 0x10, "RDRAM")

    -- console.log(string.format("%08X", 0x07CA20 + addr_offset))

    return {
        id = id,
        hp = hp,
        hpMax = hpMax,
        attack = attack,
        agi = agility,
        def = defense,
        x = x,
        y = y,
        z = z,
        xp = xp,
        ptr_attributes = ptr_attributes
    }
end

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
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


local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function DrawEnemyRow(row_index, enemy_index)

    local enemy_info = GetEnemyAtIndex(enemy_index)

    GuiTextRight(row_index, string.format("%2d) %12d XP @ %8X", enemy_index + 1, enemy_info.xp, enemy_info.ptr_attributes))
end

local function ShowEncounterInfo(row_index)

    GuiTextRight(row_index + 0, "Encounter Info:  ")
    GuiTextRight(row_index + 1, "-----------------")

    for i=0,5 do
        DrawEnemyRow(row_index + i + 2, i)
    end
end

while true do

    ShowEncounterInfo(10)
    emu.frameadvance()
end
