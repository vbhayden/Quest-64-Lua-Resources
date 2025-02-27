
MEM_BRIAN_POSITION_X = 0x7AA20
MEM_BRIAN_POSITION_Y = 0x7AA24
MEM_BRIAN_POSITION_Z = 0x7AA28
MEM_BRIAN_ROTATION_Y = 0x7AA30

MEM_ENEMY_POSITION_X = 0x7C9BC
MEM_ENEMY_POSITION_Z = 0x7C9C4
MEM_ENEMY_ROTATION_Y = 0x7C9CC

MEM_BATTLE_LAST_X = 0x86B18
MEM_BATTLE_LAST_Z = 0x86B20

MEM_BATTLE_CENTER_X = 0x880B8
MEM_BATTLE_CENTER_Z = 0x880D8

MEM_ENEMY_COUNT = 0x07C993

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

MovementMagnitude = 1

MoveEnemy = false
MoveEnemyIndex = 0

local analog_x = 0
local analog_y = 0
local use_analog = false
local analog_increment = 1
local analog_decrement = -5
local analog_min = 0
local analog_max = 127

local function Clamp(value, min, max)
    if value > max then
        return max

    elseif value < min then
        return min
    end

    return value
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Ternary ( cond , T , F )
    if cond then return T else return F end
end

function GetEnemyCount()
    return memory.readbyte(MEM_ENEMY_COUNT, "RDRAM")
end

function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

function GetLastCombatPosition()
    local bx = memory.readfloat(MEM_BATTLE_LAST_X, true, "RDRAM")
    local bz = memory.readfloat(MEM_BATTLE_LAST_Z, true, "RDRAM")

    return bx, bz
end

function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianY = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return brianX, brianY, brianZ
end

function SetBrianLocation(x, z)
    
    memory.writefloat(MEM_BRIAN_POSITION_X, x, true, "RDRAM")
    memory.writefloat(MEM_BRIAN_POSITION_Z, z, true, "RDRAM")
end

function GetBrianDirection()
    local angleRadians = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

function SetBrianDirection(angle)
    memory.writefloat(MEM_BRIAN_ROTATION_Y, angle, true, "RDRAM")
end

function GetEnemyLocation()
    local brianX = memory.readfloat(MEM_ENEMY_POSITION_X + MoveEnemyIndex * 296, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_ENEMY_POSITION_Z + MoveEnemyIndex * 296, true, "RDRAM")
    
    return brianX, brianZ
end

function GetEnemyDirection()
    local angleRadians = memory.readfloat(MEM_ENEMY_ROTATION_Y + MoveEnemyIndex * 296, true, "RDRAM")
    return angleRadians
end

function SetEnemyLocation(x, z)
    
    memory.writefloat(MEM_ENEMY_POSITION_X + MoveEnemyIndex * 296, x, true, "RDRAM")
    memory.writefloat(MEM_ENEMY_POSITION_Z + MoveEnemyIndex * 296, z, true, "RDRAM")
end

function SetEnemyDirection(angle)
    memory.writefloat(MEM_ENEMY_ROTATION_Y + MoveEnemyIndex * 296, angle, true, "RDRAM")
end

function TransformDirectionForBrian(x, y, z)
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

function TransformDirectionForEnemy(x, y, z)
    local theta = GetEnemyDirection()

    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return xp, y, zp
end

function MoveBrianRelative(x, y, z)
    local dx, dy, dz = TransformDirectionForBrian(x, y, z)
    local brianX, brianY, brianZ = GetBrianLocation()

    SetBrianLocation(brianX + dx * MovementMagnitude, brianZ + dz * MovementMagnitude)
end

function MoveEnemyRelative(x, y, z)
    local dx, dy, dz = TransformDirectionForEnemy(x, y, z)
    local brianX, brianZ = GetEnemyLocation()

    SetEnemyLocation(brianX + dx * MovementMagnitude, brianZ + dz * MovementMagnitude)
end

local previous_keys = {}

local breadcrumbs = {}
local readingCrumbs = false
local wasReadingCrumbs = false

local function WriteCrumbCSV(path)
    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    for _, coord_line in pairs(breadcrumbs) do
        file:write(coord_line .. "\n")
    end

    breadcrumbs = {}

    file:close()
end

local last_bx = 0
local last_bx = 0
local min_crumb_distance = 5

local function ReadCrumbs()

    local bx, by, bz = GetBrianLocation()

    if not wasReadingCrumbs then
        last_bx = bx
        last_bz = bz
    end

    local dbx = last_bx - bx
    local dbz = last_bz - bz

    local distance = math.sqrt(dbx * dbx + dbz * dbz)
    if distance > min_crumb_distance then
        breadcrumbs[#breadcrumbs+1] = string.format("%f,%f", bx, bz)

        last_bx = bx
        last_bz = bz
    end
end

local function ToggleAnalog()
    use_analog = not use_analog

    if not use_analog then
        joypad.setanalog({ ['X Axis'] = '', ['Y Axis'] = '', }, 1)
    end
end

local function UpdateAnalog(dx, dy)
    analog_x = analog_x + dx
    analog_x = Clamp(analog_x, analog_min, analog_max)
    
    analog_y = analog_y + dy
    analog_y = Clamp(analog_y, analog_min, analog_max)
end

local function ClearAnalog()
    analog_x = 0
    analog_y = 0
    
    joypad.setanalog({ ['X Axis'] = analog_x, ['Y Axis'] = analog_y, }, 1)
end


function ProcessKeyboardInput()

    local keys = input.get()

    if keys["Space"] == true and previous_keys["Space"] ~= true then
        MoveEnemy = not MoveEnemy
    end

    local movementFunc = Ternary(MoveEnemy, MoveEnemyRelative, MoveBrianRelative)
    local rotationFunc = Ternary(MoveEnemy, SetEnemyDirection, SetBrianDirection)

    if keys["Backspace"] == true and previous_keys["Backspace"] ~= true then
        ToggleAnalog()
    end

    if keys["Up"] == true and previous_keys["Up"] ~= true then
        if use_analog then
            UpdateAnalog(0, analog_increment)
        else
            movementFunc(0, 0, 1)
        end
    end

    if keys["Down"] == true and previous_keys["Down"] ~= true then
        if use_analog then
            UpdateAnalog(0, analog_decrement)
        else
            movementFunc(0, 0, -1)
        end
    end

    if keys["Delete"] == true and previous_keys["Delete"] ~= true then
        ClearAnalog()
    end

    if use_analog then
        joypad.setanalog({ ['X Axis'] = analog_x, ['Y Axis'] = analog_y, }, 1)
    end

    if not use_analog then
        if keys["Left"] == true and previous_keys["Left"] ~= true then
            movementFunc(1, 0, 0)
        end
    
        if keys["Right"] == true and previous_keys["Right"] ~= true then
            movementFunc(-1, 0, 0)
        end
    end

    if keys["PageUp"] == true and previous_keys["PageUp"] ~= true then
        MovementMagnitude = MovementMagnitude * 2
    end

    if keys["PageDown"] == true and previous_keys["PageDown"] ~= true then
        MovementMagnitude = MovementMagnitude / 2
    end

    if keys["Delete"] == true and previous_keys["Delete"] ~= true then
        rotationFunc(3.14159678)
    end

    if keys["Tab"] == true and previous_keys["Tab"] ~= true then
        MoveEnemyIndex = MoveEnemyIndex + 1
        if MoveEnemyIndex >= 6 then
            MoveEnemyIndex = 0
        end
    end
    
    if keys["Enter"] == true and previous_keys["Enter"] ~= true then
        if readingCrumbs then
            local map, submap = GetMapIDs()
            local filename = "data/crumbs-" .. map .. "-" .. submap .. "-" .. os.time()
            WriteCrumbCSV(filename .. ".csv")
        end

        readingCrumbs = not readingCrumbs
    end

    previous_keys = input.get()
end

function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

PreviousX = nil
PreviousZ = nil

function GetMovementDelta(x, z)

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

function PrintCombatValues(index)

    local start = 0x88188 - 20 * 16

    for k = 0, 40 do
        local iter_address = start + k * 16
        local combat_value = memory.readfloat(iter_address, true, "RDRAM")

        GuiTextRight(k + index, "Combat " .. string.format("%x", iter_address) .. ": " .. combat_value)
    end
end

function GetEnemyCount()
    return memory.readbyte(0x07C993, "RDRAM")
end

function IsEncounterActive()
    return GetEnemyCount() > 0
end

function GetCombatCenter()
    local cx = memory.readfloat(MEM_BATTLE_CENTER_X, true, "RDRAM")
    local cz = memory.readfloat(MEM_BATTLE_CENTER_Z, true, "RDRAM")

    return cx, cz
end

BattleCenters = {}

function AddBattleCenter(x, z)
    local new_coord = { x = x, z = z }
    for k, coord in pairs(BattleCenters) do
        if coord.x == new_coord.x and coord.z == new_coord.z then
            return
        end
    end

    BattleCenters[#BattleCenters+1] = new_coord
end

function CountUniqueBattleCenters()
    return #BattleCenters
end

BattleDistanceMin = 9999
BattleDistanceMax = 0
EncounterWasActive = false

while true do

    local enemies = GetEnemyCount()
    if MoveEnemyIndex > enemies - 1 then
        MoveEnemyIndex = 0

        if MoveEnemyIndex < 0 then
            MoveEnemyIndex = 0
        end
    end

    local map, submap = GetMapIDs()
    local x, y, z = GetBrianLocation()
    local dx, dz = GetMovementDelta(x, z)
    local bx, bz = GetLastCombatPosition()
    local angle = GetBrianDirection()
    local cx, cz = GetCombatCenter()

    local cdx = cx - x
    local cdz = cz - z
    local center_dist = math.sqrt(cdx * cdx + cdz * cdz)
    
    local ldx = bx - x
    local ldz = bz - z
    local combat_dist = math.sqrt(ldx * ldx + ldz * ldz)

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

    local bdx = x - bx
    local bdz = z - bz
    local speed = math.sqrt(dx * dx + dz * dz)

    if use_analog then
        GuiTextWithColor(4, "Mode:     Precison", "cyan")
        GuiText(5, "Target:   Brian (Walking)")
        GuiText(6, "Analog:  " ..analog_y)
        GuiText(7, "Brian X: " .. Round(x, 1))
        GuiText(8, "Brian Y: " .. Round(y, 1))
        GuiText(9, "Brian Z: " .. Round(z, 1))
        GuiText(10, "Brian Angle: " .. Round(angle, 1))
        GuiText(11, "Brian Speed: " .. Round(speed, 2))
    else
        GuiTextWithColor(4, "Mode:     Default", "gray")
        GuiText(5, "Target:   " .. Ternary(MoveEnemy, "Enemy #" .. MoveEnemyIndex, "Brian"))
        GuiText(6, "Movement: " .. MovementMagnitude)
        GuiText(7, "Brian X: " .. Round(x, 1))
        GuiText(8, "Brian Y: " .. Round(y, 1))
        GuiText(9, "Brian Z: " .. Round(z, 1))
        GuiText(10, "Brian Angle: " .. Round(angle, 1))
        GuiText(11, "Brian Speed: " .. Round(speed, 2))

        analog_y = 0
    end

    GuiText(13, "Agi Dist:  " .. Round(combat_dist, 2))

    GuiText(15, "Map ID:  " .. map)
    GuiText(16, "Sub Map: " .. submap)

    -- GuiTextRight(5, "Unique Centers: " .. CountUniqueBattleCenters())
    -- GuiTextRight(6, "Battle Dist: " .. Round(center_dist, 2))
    -- GuiTextRight(7, "Battle Dist (Min): " .. Round(BattleDistanceMin, 2))
    -- GuiTextRight(8, "Battle Dist (Max): " .. Round(BattleDistanceMax, 2))
        

    -- GuiTextRight(9, "Battle Center X: " .. Round(cx, 5))
    -- GuiTextRight(10, "Battle Center Z: " .. Round(cz, 5))
    -- GuiTextRight(11, "Battle Delta X: " .. Round(bdx, 2))
    -- GuiTextRight(12, "Battle Delta Z: " .. Round(bdz, 2))

    -- PrintCombatValues(5)

    if readingCrumbs then
        ReadCrumbs()
    end
    wasReadingCrumbs = readingCrumbs

    GuiTextWithColor(18, "Reading Movement: " .. Ternary(readingCrumbs, "RECORDING", "No"), Ternary(readingCrumbs, "red", "grey"))

    ProcessKeyboardInput()

    emu.frameadvance()
end

-- 42.7, 79.4
--