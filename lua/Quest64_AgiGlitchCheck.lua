
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_ENEMY_POSITION_X = 0x7C9BC
local MEM_ENEMY_POSITION_Z = 0x7C9C4
local MEM_ENEMY_ROTATION_Y = 0x7C9CC

local MEM_AGILITY_XP = 0x07BAAD

local MEM_COMBAT_AGI_LAST_X = 0x8C5A4
local MEM_COMBAT_AGI_LAST_Z = 0x8C430

local MEM_COMBAT_AGI_DISTANCE = 0x7BCA0

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local MovementMagnitude = 1

local MoveEnemy = false
local MoveEnemyIndex = 0

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

local function Distance(x1, x2, z1, z2)
    local dx = x1 - x2
    local dz = z1 - z2

    return math.sqrt(dx*dx + dz*dz)
end

local function GetExpectedCombatAgiXP(possible_last_x_addr, possible_last_z_addr)

    local possible_last_x = memory.readfloat(possible_last_x_addr, true, "RDRAM")
    local possible_last_z = memory.readfloat(possible_last_z_addr, true, "RDRAM")

    local brian_x, brian_z = GetBrianLocation()

    return Distance(brian_x, possible_last_x, brian_z, possible_last_z)
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

    local bx, bz = GetBrianLocation()

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


local function ProcessKeyboardInput()

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
            local filename = "crumbs-" .. map .. "-" .. submap .. "-" .. os.time()
            WriteCrumbCSV(filename .. ".csv")
        end

        readingCrumbs = not readingCrumbs
    end

    previous_keys = input.get()
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

local PreviousX = nil
local PreviousZ = nil

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

local function PrintCombatValues(index)

    local start = 0x88188 - 20 * 16

    for k = 0, 40 do
        local iter_address = start + k * 16
        local combat_value = memory.readfloat(iter_address, true, "RDRAM")

        GuiTextRight(k + index, "Combat " .. string.format("%x", iter_address) .. ": " .. combat_value)
    end
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

BattleCenters = {}

local function AddBattleCenter(x, z)
    local new_coord = { x = x, z = z }
    for k, coord in pairs(BattleCenters) do
        if coord.x == new_coord.x and coord.z == new_coord.z then
            return
        end
    end

    BattleCenters[#BattleCenters+1] = new_coord
end

local function CountUniqueBattleCenters()
    return #BattleCenters
end

local BattleDistanceMin = 9999
local BattleDistanceMax = 0
local EncounterWasActive = false

while true do

    local brian_x, brian_z = GetBrianLocation()
    
    local agi_xp = memory.readbyte(MEM_AGILITY_XP, "RDRAM")
    local current_agi_distance = memory.readfloat(MEM_COMBAT_AGI_DISTANCE, true, "RDRAM")

    local combat_last_x = memory.readfloat(MEM_COMBAT_AGI_LAST_X, true, "RDRAM")
    local combat_last_z = memory.readfloat(MEM_COMBAT_AGI_LAST_Z, true, "RDRAM")

    local current_combat_agi_distance = Distance(brian_x, combat_last_x, brian_z, combat_last_z)
    local resulting_distance = current_agi_distance + current_combat_agi_distance
    local resulting_xp = math.floor((current_agi_distance + current_combat_agi_distance) / 50)

    GuiText(16, "Agi Glitch Distances:  ")
    GuiText(17, "-------------------------:  ")
    GuiText(18, "Current AGI XP: " .. agi_xp)
    GuiText(19, "Current AGI Progress: " .. Round(current_agi_distance, 2))
    GuiText(20, "Combat AGI Distance:  " .. Round(current_combat_agi_distance, 2))
    GuiText(21, "Converted XP:         " .. Round(current_combat_agi_distance / 50, 2))
    
    GuiTextWithColor(23, "Resulting AGI Distance: " .. Round(resulting_distance, 2), "cyan")
    GuiTextWithColor(24, "Resulting AGI XP Bonus: " .. resulting_xp, "cyan")

    GuiTextWithColor(25, "Leftover AGI Distance: " .. Round(resulting_distance % 50, 2), "yellow")
    GuiTextWithColor(26, "Updated AGI XP: " .. (agi_xp + resulting_xp), "yellow")

    emu.frameadvance()
end

-- 42.7, 79.4
--