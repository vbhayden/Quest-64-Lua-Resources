
MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Z = 0x7BAD4
MEM_BRIAN_ROTATION_Y = 0x7BADC

MEM_ENEMY_POSITION_X = 0x7C9BC
MEM_ENEMY_POSITION_Z = 0x7C9C4
MEM_ENEMY_ROTATION_Y = 0x7C9CC

MEM_ENEMY_RESTRICT_TURNS = 0x7CA2C

MEM_BATTLE_LAST_X = 0x86B18
MEM_BATTLE_LAST_Z = 0x86B20

MEM_BATTLE_CENTER_X = 0x880B8
MEM_BATTLE_CENTER_Z = 0x880D8

local MEM_CAMERA_ROTATION_Y = 0x86DE8

local MEM_CAMERA_TARGET_X = 0x86DD8
local MEM_CAMERA_TARGET_Y = 0x86DDC
local MEM_CAMERA_TARGET_Z = 0x086DE0
local MEM_CAMERA_POSITION_X = 0x086DCC
local MEM_CAMERA_POSITION_Y = 0x086DD0
local MEM_CAMERA_POSITION_Z = 0x086DD4

MEM_ENEMY_COUNT = 0x07C993

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

MovementMagnitude = 1

MoveEnemy = false
MoveEnemyIndex = 0

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetEnemyCount()
    return memory.readbyte(MEM_ENEMY_COUNT, "RDRAM")
end

local function GetEnemyRestrictTurns(index)
    local turns = memory.read_u16_be(MEM_ENEMY_RESTRICT_TURNS + index * 296, "RDRAM")

    return turns
end

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

local function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function CreateTurnString(turns)

    if turns == 0 then
        return "n/a"
    elseif turns == 1 then
        return "1 turn"
    else
        return turns .. " turns"
    end
end

while true do

    GuiText(3, "Enemy Restriction Durations: ")
    GuiText(4, "----------------------------")

    local enemies = GetEnemyCount()
    for k = 0, enemies - 1 do

        local turns = GetEnemyRestrictTurns(k)
        GuiText(5 + k, string.format("Enemy %d: " .. CreateTurnString(turns), k+1))
    end

    emu.frameadvance()
end

-- 42.7, 79.4
--