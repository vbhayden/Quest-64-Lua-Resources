-- Quest 64 Brian Mover Tool
--
-- This is a Lua script for the Bizhawk emulator
-- to move Brian around in-game.  It can also move enemies. 
--
-- The movement will be relative to the target's rotation.
--
-- To use this script, open a Quest 64 rom with a modern
-- version of the Bizhawk / Emuhawk emulator, then load this
-- file using the Lua console.
--
--
--
-- CONTROLS
--
-- The tool will listen for keyboard inputs and move things
-- in response.  These keybinds can be edited, but you may
-- want to refer to the bizhawk guides for how it wants you
-- to name specific keys etc.
--
local KB_COPY = "C"
local KB_PASTE = "V"
local KB_MOVE_UP = "Up"
local KB_MOVE_DOWN = "Down"
local KB_MOVE_LEFT = "Left"
local KB_MOVE_RIGHT = "Right"
local KB_MOVEMENT_INCREASE = "PageUp"
local KB_MOVEMENT_DECREASE = "PageDown"
local KB_TOGGLE_TARGET = "Space"
local KB_CHANGE_ENENY = "Tab"
local KB_RESET_ROTATION = "Delete"

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--                                                             --
--                                                             --
--                                                             --
--                                                             --
-- Not recommended to edit anything from here onwards etc.     --
--                                                             --
--                                                             --
--                                                             --
--                                                             --
--                                                             --
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- Memory Values
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_ENEMY_POSITION_X = 0x7C9BC
local MEM_ENEMY_POSITION_Z = 0x7C9C4
local MEM_ENEMY_ROTATION_Y = 0x7C9CC

local MEM_BATTLE_LAST_X = 0x86B18
local MEM_BATTLE_LAST_Z = 0x86B20
local MEM_BATTLE_CENTER_X = 0x880B8
local MEM_BATTLE_CENTER_Z = 0x880D8

local GUI_PADDING_RIGHT = 240 + 60

local MovementMagnitude = 1
local MoveEnemy = false
local MoveEnemyIndex = 0

local PreviousKeys = {}
local PreviousX = nil
local PreviousZ = nil

local BattleCenters = {}
local BattleDistanceMin = 9999
local BattleDistanceMax = 0
local EncounterWasActive = false

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function GetLastCombatPosition()
    local bx = memory.readfloat(MEM_BATTLE_LAST_X, true, "RDRAM")
    local bz = memory.readfloat(MEM_BATTLE_LAST_Z, true, "RDRAM")

    return bx, bz
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return brianX, brianZ
end

local function SetBrianLocation(x, z)
    
    memory.writefloat(MEM_BRIAN_POSITION_X, x, true, "RDRAM")
    memory.writefloat(MEM_BRIAN_POSITION_Z, z, true, "RDRAM")
end

local function GetBrianDirection()
    local angleRadians = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

local function SetBrianDirection(angle)
    memory.writefloat(MEM_BRIAN_ROTATION_Y, angle, true, "RDRAM")
end

local function GetEnemyLocation()
    local brianX = memory.readfloat(MEM_ENEMY_POSITION_X + MoveEnemyIndex * 296, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_ENEMY_POSITION_Z + MoveEnemyIndex * 296, true, "RDRAM")
    
    return brianX, brianZ
end

local function GetEnemyDirection()
    local angleRadians = memory.readfloat(MEM_ENEMY_ROTATION_Y + MoveEnemyIndex * 296, true, "RDRAM")
    return angleRadians
end

local function SetEnemyLocation(x, z)
    
    memory.writefloat(MEM_ENEMY_POSITION_X + MoveEnemyIndex * 296, x, true, "RDRAM")
    memory.writefloat(MEM_ENEMY_POSITION_Z + MoveEnemyIndex * 296, z, true, "RDRAM")
end

local function SetEnemyDirection(angle)
    memory.writefloat(MEM_ENEMY_ROTATION_Y + MoveEnemyIndex * 296, angle, true, "RDRAM")
end

local function TransformDirectionForBrian(x, y, z)
    -- Direction Notes:
    --
    -- -X = WEST
    -- +X = EAST
    -- -Z = NORTH
    -- +Z = SOUTH
    --
    -- This gives us a traditional quadrant system aligned to
    -- World South as +Z and World East as +X.  Swapping Z and Y
    -- for notation, this aligns with the game's opinion that 
    -- due North is a -pi orientation on the vertical axis.
    --
    -- We need to make a small adjustment to account for the 
    -- symmetry issue and flip the sign of our angle below.
    --
    -- Brian himself cannot rotate along any non-vertical axis,
    -- so our Y component of the provided vector will not be 
    -- adjusted at all.
    --
    -- With that, we can use the standard 2D rotation matrix
    -- to finish the math.
    --
    local theta = GetBrianDirection()

    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return xp, y, zp
end

local function TransformDirectionForEnemy(x, y, z)
    local theta = GetEnemyDirection()

    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return xp, y, zp
end

local function MoveBrianRelative(x, y, z)
    local dx, dy, dz = TransformDirectionForBrian(x, y, z)
    local brianX, brianZ = GetBrianLocation()

    SetBrianLocation(brianX + dx * MovementMagnitude, brianZ + dz * MovementMagnitude)
end

local function MoveEnemyRelative(x, y, z)
    local dx, dy, dz = TransformDirectionForEnemy(x, y, z)
    local brianX, brianZ = GetEnemyLocation()

    SetEnemyLocation(brianX + dx * MovementMagnitude, brianZ + dz * MovementMagnitude)
end

local saved_x = 0
local saved_y = 0
local saved_z = 0
local saved_rotation = 0

local function ProcessKeyboardInput()

    local keys = input.get()

    if keys[KB_TOGGLE_TARGET] == true and PreviousKeys[KB_TOGGLE_TARGET] ~= true then
        MoveEnemy = not MoveEnemy
    end

    local movementFunc = Ternary(MoveEnemy, MoveEnemyRelative, MoveBrianRelative)
    local rotationFunc = Ternary(MoveEnemy, SetEnemyDirection, SetBrianDirection)

    if keys[KB_MOVE_UP] == true and PreviousKeys[KB_MOVE_UP] ~= true then
        movementFunc(0, 0, 1)
    end

    if keys[KB_MOVE_DOWN] == true and PreviousKeys[KB_MOVE_DOWN] ~= true then
        movementFunc(0, 0, -1)
    end

    if keys[KB_MOVE_LEFT] == true and PreviousKeys[KB_MOVE_LEFT] ~= true then
        movementFunc(1, 0, 0)
    end

    if keys[KB_MOVE_RIGHT] == true and PreviousKeys[KB_MOVE_RIGHT] ~= true then
        movementFunc(-1, 0, 0)
    end

    if keys[KB_MOVEMENT_INCREASE] == true and PreviousKeys[KB_MOVEMENT_INCREASE] ~= true then
        MovementMagnitude = MovementMagnitude * 2
    end

    if keys[KB_MOVEMENT_DECREASE] == true and PreviousKeys[KB_MOVEMENT_DECREASE] ~= true then
        MovementMagnitude = MovementMagnitude / 2
        if MovementMagnitude < 1 then
            MovementMagnitude = 1
        end
    end

    if keys[KB_COPY] == true and PreviousKeys[KB_COPY] ~= true then
        saved_x, saved_z = GetBrianLocation()
        saved_rotation = GetBrianDirection()
    end

    if keys[KB_PASTE] == true and PreviousKeys[KB_PASTE] ~= true then
        SetBrianLocation(saved_x, saved_z)
        SetBrianDirection(saved_rotation)
    end

    if keys[KB_RESET_ROTATION] == true and PreviousKeys[KB_RESET_ROTATION] ~= true then
        rotationFunc(0)
    end

    if keys[KB_CHANGE_ENENY] == true and PreviousKeys[KB_CHANGE_ENENY] ~= true then
        MoveEnemyIndex = MoveEnemyIndex + 1
        if MoveEnemyIndex >= 6 then
            MoveEnemyIndex = 0
        end
    end

    PreviousKeys = input.get()
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

local function GetMovementDelta(x, z)

    local dx = 0
    local dz = 0

    if PreviousX ~= nil then
        dx = x - PreviousX
    end
    
    if PreviousZ ~= nil then
        dz = z - PreviousZ
    end

    PreviousX = x
    PreviousZ = z

    return dx, dz
end

local function GetEnemyCount()
    return memory.readbyte(0x07C993, "RDRAM")
end

local function IsEncounterActive()
    return GetEnemyCount() > 0
end

local function GetCombatCenter()
    local cx = memory.readfloat(MEM_BATTLE_CENTER_X, true, "RDRAM")
    local cz = memory.readfloat(MEM_BATTLE_CENTER_Z, true, "RDRAM")

    return cx, cz
end

local function AddBattleCenter(x, z)
    local new_coord = { x = x, z = z }
    for k, coord in pairs(BattleCenters) do
        if coord.x == new_coord.x and coord.z == new_coord.z then
            return
        end
    end

    BattleCenters[#BattleCenters+1] = new_coord
end

while true do

    local enemies = GetEnemyCount()
    if MoveEnemyIndex > enemies - 1 then
        MoveEnemyIndex = 0

        if MoveEnemyIndex < 0 then
            MoveEnemyIndex = 0
        end
    end

    local map, submap = GetMapIDs()
    local x, z = GetBrianLocation()
    local dx, dz = GetMovementDelta(x, z)
    local angle = GetBrianDirection()
    local cx, cz = GetCombatCenter()

    local cdx = cx - x
    local cdz = cz - z
    local center_dist = math.sqrt(cdx * cdx + cdz * cdz)

    local encounter_active = IsEncounterActive()
    local just_got_encounter = encounter_active and not EncounterWasActive

    if just_got_encounter then
        if center_dist > BattleDistanceMax then
            BattleDistanceMax = center_dist
        end
        if center_dist < BattleDistanceMin then
            BattleDistanceMin = center_dist
        end

        AddBattleCenter(cx, cz)
    end

    EncounterWasActive = encounter_active

    local speed = math.sqrt(dx * dx + dz * dz)

    GuiText(0, "Brian Mover:")
    GuiText(1, "  Target:   " .. Ternary(MoveEnemy, "Enemy #" .. MoveEnemyIndex, "Brian"))
    GuiText(2, "  Movement: " .. MovementMagnitude)
    GuiText(3, "  Brian X: " .. Round(x, 1))
    GuiText(4, "  Brian Z: " .. Round(z, 1))
    GuiText(5, "  Brian Angle: " .. Round(angle, 1))
    GuiText(6,  string.format("  Map: %d, Submap: %d", map, submap))

    GuiText(8, "Controls:")
    GuiText(9, "  Move ^: " .. KB_MOVE_UP)
    GuiText(10, "  Move v: " .. KB_MOVE_DOWN)
    GuiText(11, "  Move <: " .. KB_MOVE_LEFT)
    GuiText(12, "  Move >: " .. KB_MOVE_RIGHT)
    GuiText(13, "  Move More: " .. KB_MOVEMENT_INCREASE)
    GuiText(14, "  Move Less: " .. KB_MOVEMENT_DECREASE)
    GuiText(15, "  Reset Angle: " .. KB_RESET_ROTATION)
    GuiText(16, "  Swap Target: " .. KB_TOGGLE_TARGET)
    GuiText(17, "  Next Enemy:  " .. KB_CHANGE_ENENY)

    -- local bx, bz = GetLastCombatPosition()
    -- local bdx = x - bx
    -- local bdz = z - bz
    -- GuiTextRight(8, "Battle Dist: " .. Round(center_dist, 2))
    -- GuiTextRight(9, "Battle Center X: " .. Round(cx, 5))
    -- GuiTextRight(10, "Battle Center Z: " .. Round(cz, 5))
    -- GuiTextRight(11, "Battle Delta X: " .. Round(bdx, 2))
    -- GuiTextRight(12, "Battle Delta Z: " .. Round(bdz, 2))

    ProcessKeyboardInput()

    emu.frameadvance()
end
