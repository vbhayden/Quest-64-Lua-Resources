
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Y = 0x7BAD0
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_CAMERA_POSITION_X = 0x86DCC
local MEM_CAMERA_POSITION_Y = 0x86DD0
local MEM_CAMERA_POSITION_Z = 0x86DD4

local MEM_CAMERA_TARGET_POSITION_X = 0x86DD8
local MEM_CAMERA_TARGET_POSITION_Y = 0x86DDC
local MEM_CAMERA_TARGET_POSITION_Z = 0x86DE0

local MEM_CAMERA_ROTATION_X = 0x86DE4
local MEM_CAMERA_ROTATION_Y = 0x86DE8
local MEM_CAMERA_ROTATION_Z = 0x86DEC

local MEM_BATTLE_LAST_X = 0x86B18
local MEM_BATTLE_LAST_Z = 0x86B20

local MEM_BATTLE_CENTER_X = 0x880B8
local MEM_BATTLE_CENTER_Z = 0x880D8

local MEM_CURRENT_MAP_ID = 0x08536B
local MEM_CURRENT_SUBMAP_ID = 0x08536F

local MEM_ENEMY_COUNT = 0x07C993
local MEM_SIZE_ENEMY_BLOCK = 0x128

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local MovementMagnitude = 1

local MoveEnemy = false
local MoveEnemyIndex = 0

local analog_x = 0
local analog_y = 0
local use_analog = false

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetEnemyCount()
    return memory.read_u16_be(MEM_ENEMY_COUNT, "RDRAM")
end

local function GetMapIDs()
    local mapID = memory.readbyte(MEM_CURRENT_MAP_ID, "RDRAM")
    local subMapID = memory.readbyte(MEM_CURRENT_SUBMAP_ID, "RDRAM")

    return mapID, subMapID
end

local function GetLastCombatPosition()
    local bx = memory.readfloat(MEM_BATTLE_LAST_X, true, "RDRAM")
    local bz = memory.readfloat(MEM_BATTLE_LAST_Z, true, "RDRAM")

    return bx, bz
end

local function GetCameraTransform()

    local x = memory.readfloat(MEM_CAMERA_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_CAMERA_POSITION_Y, true, "RDRAM")
    local z = memory.readfloat(MEM_CAMERA_POSITION_Z, true, "RDRAM")

    local tx = memory.readfloat(MEM_CAMERA_TARGET_POSITION_X, true, "RDRAM")
    local ty = memory.readfloat(MEM_CAMERA_TARGET_POSITION_Y, true, "RDRAM")
    local tz = memory.readfloat(MEM_CAMERA_TARGET_POSITION_Z, true, "RDRAM")
    
    local rx = memory.readfloat(MEM_CAMERA_ROTATION_X, true, "RDRAM")
    local ry = memory.readfloat(MEM_CAMERA_ROTATION_Y, true, "RDRAM")
    local rz = memory.readfloat(MEM_CAMERA_ROTATION_Z, true, "RDRAM")

    return { x=x, y=y, z=z, rx=rx, ry=ry, rz=rz, tx=tx, ty=ty, tz=tz }
end

local function GetBrianLocation()
    local x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local z = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")

    return { x=x, y=y, z=z }
end

local previous_keys = {}

local function ProcessKeyboardInput()

    local keys = input.get()

    if keys["Space"] == true and previous_keys["Space"] ~= true then
        MoveEnemy = not MoveEnemy
    end

    local movementFunc = Ternary(MoveEnemy, MoveEnemyRelative, MoveBrianRelative)
    local rotationFunc = Ternary(MoveEnemy, SetEnemyDirection, SetBrianDirection)

    if keys["Delete"] == true and previous_keys["Delete"] ~= true then
        ClearAnalog()
    end

    if use_analog then
        joypad.setanalog({ ['X Axis'] = analog_x, ['Y Axis'] = analog_y, }, 1)
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
        local total_enemies = GetEnemyCount()
        MoveEnemyIndex = MoveEnemyIndex + 1
        if MoveEnemyIndex >= total_enemies then
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

local function DistanceBetweenCoords(c1, c2)

    local dx = c1.x - c2.x
    local dz = c1.z - c2.z

    return math.sqrt(dx * dx + dz * dz)
end

while true do

    local camera_transform = GetCameraTransform()
    local camera_target_coord = {
        x = camera_transform.tx,
        y = camera_transform.ty,
        z = camera_transform.tz,
    }

    local brian_transform = GetBrianLocation()
    local camera_distance = DistanceBetweenCoords(camera_transform, brian_transform)
    local focus_distance = DistanceBetweenCoords(camera_transform, camera_target_coord)

    local angle_x = math.deg(camera_transform.rx)
    local angle_y = math.deg(camera_transform.ry)
    local angle_z = math.deg(camera_transform.rz)

    GuiTextRight(6, "Camera Info: ")
    GuiTextRight(7, "X: " .. Round(camera_transform.x, 2))
    GuiTextRight(8, "Y: " .. Round(camera_transform.y, 2))
    GuiTextRight(9, "X: " .. Round(camera_transform.z, 2))

    GuiTextRight(11, "Radians X: " .. Round(camera_transform.rx, 3))
    GuiTextRight(12, "Radians Y: " .. Round(camera_transform.ry, 3))
    GuiTextRight(13, "Radians Z: " .. Round(camera_transform.rz, 3))
    
    GuiTextRight(15, "Angle X: " .. Round(angle_x, 3))
    GuiTextRight(16, "Angle Y: " .. Round(angle_y, 3))
    GuiTextRight(17, "Angle Z: " .. Round(angle_z, 3))
    
    GuiTextRight(19, "Brian Dist: " .. Round(camera_distance, 3))
    GuiTextRight(20, "Focus Dist: " .. Round(focus_distance, 3))

    ProcessKeyboardInput()

    emu.frameadvance()
end

-- 42.7, 79.4
--