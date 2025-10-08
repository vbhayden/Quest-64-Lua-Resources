
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

local MEM_CAMERA_VERTICAL_OFFSET = 0x86E1C
local MEM_CAMERA_LOCAL_ELEVATION = 0x86E18
local MEM_CAMERA_FOCUS_DISTANCE = 0x86E0C
local MEM_CAMERA_FOV_DEGREES = 0x86EC8
local MEM_CAMERA_NEAR_CLIP_DISTANCE = 0x86ECC
local MEM_CAMERA_FAR_CLIP_DISTANCE = 0x86ED0

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

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    -- if bit.band(address, 0x80000000) ~= 0x80000000 then
    --     console.log(string.format("BAD POINTER RECEIVED: %08X", address))
    -- end

    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
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

local function GetRuntimeCameraData()

    local addr_base = 0X86DC0

    return {
        mode = memory.read_u32_be(addr_base + 0x0, "RDRAM"),
        camera_x = memory.readfloat(addr_base + 0xC, true, "RDRAM"),
        camera_y = memory.readfloat(addr_base + 0x10, true, "RDRAM"),
        camera_z = memory.readfloat(addr_base + 0x14, true, "RDRAM"),
        look_x = memory.readfloat(addr_base + 0x18, true, "RDRAM"),
        look_y = memory.readfloat(addr_base + 0x1C, true, "RDRAM"),
        look_z = memory.readfloat(addr_base + 0x20, true, "RDRAM"),
        camera_angle_x = memory.readfloat(addr_base + 0x24, true, "RDRAM"),
        camera_angle_y = memory.readfloat(addr_base + 0x28, true, "RDRAM"),
        camera_angle_z = memory.readfloat(addr_base + 0x2C, true, "RDRAM"),
        min_angle_x = memory.readfloat(addr_base + 0x60, true, "RDRAM"),
        max_angle_x = memory.readfloat(addr_base + 0x64, true, "RDRAM"),
        min_angle_y = memory.readfloat(addr_base + 0x68, true, "RDRAM"),
        max_angle_y = memory.readfloat(addr_base + 0x6C, true, "RDRAM"),
    }
end







local data = GetRuntimeCameraData()

console.log("new QuestRuntimeCameraData")
console.log("{")
console.log("   mode = " .. data.mode .. ",")
console.log("   camX = " .. data.camera_x .. "f,")
console.log("   camY = " .. data.camera_y .. "f,")
console.log("   camZ = " .. data.camera_z .. "f,")
console.log("   targetBaseX = " .. data.look_x .. "f,")
console.log("   targetBaseY = " .. data.look_y .. "f,")
console.log("   targetBaseZ = " .. data.look_z .. "f,")
console.log("   cameraAngleX = " .. data.camera_angle_x .. "f,")
console.log("   cameraAngleY = " .. data.camera_angle_y .. "f,")
console.log("   cameraAngleZ = " .. data.camera_angle_z .. "f,")
console.log("   minAngleX = " .. data.min_angle_x .. "f,")
console.log("   maxAngleX = " .. data.max_angle_x .. "f,")
console.log("   minAngleY = " .. data.min_angle_y .. "f,")
console.log("   maxAngleY = " .. data.max_angle_y .. "f,")
console.log("}")


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
    
    GuiTextRight(11, "Focus Info: ")
    GuiTextRight(12, "X: " .. Round(camera_transform.tx, 2))
    GuiTextRight(13, "Y: " .. Round(camera_transform.ty, 2))
    GuiTextRight(14, "X: " .. Round(camera_transform.tz, 2))

    GuiTextRight(16, "Radians X: " .. Round(camera_transform.rx, 3))
    GuiTextRight(17, "Radians Y: " .. Round(camera_transform.ry, 3))
    GuiTextRight(18, "Radians Z: " .. Round(camera_transform.rz, 3))
    
    GuiTextRight(20, "Angle X: " .. Round(angle_x, 3))
    GuiTextRight(21, "Angle Y: " .. Round(angle_y, 3))
    GuiTextRight(22, "Angle Z: " .. Round(angle_z, 3))
    
    GuiTextRight(24, "Brian Dist: " .. Round(camera_distance, 3))
    GuiTextRight(25, "Focus Dist: " .. Round(focus_distance, 3))
    
    local vertical_offset = memory.readfloat(MEM_CAMERA_VERTICAL_OFFSET, true, "RDRAM")
    local local_elevation = memory.readfloat(MEM_CAMERA_LOCAL_ELEVATION, true, "RDRAM")
    local focus_distance = memory.readfloat(MEM_CAMERA_FOCUS_DISTANCE, true, "RDRAM")
    local fov_degrees = memory.readfloat(MEM_CAMERA_FOV_DEGREES, true, "RDRAM")
    local near_clip = memory.readfloat(MEM_CAMERA_NEAR_CLIP_DISTANCE, true, "RDRAM")
    local far_clip = memory.readfloat(MEM_CAMERA_FAR_CLIP_DISTANCE, true, "RDRAM")

    GuiTextRight(27, "Unity Settings: ")
    GuiTextRight(28, " - Focus Height: " .. Round(vertical_offset, 2))
    GuiTextRight(29, " - Local Elevation: " .. Round(local_elevation, 2))
    GuiTextRight(30, " - Focus Distance: " .. Round(focus_distance, 2))
    GuiTextRight(31, " - FOV Degrees: " .. Round(fov_degrees, 2))
    GuiTextRight(32, " - Near Clip: " .. Round(near_clip, 2))
    GuiTextRight(33, " - Far Clip: " .. Round(far_clip, 2))


    emu.frameadvance()
end


-- 42.7, 79.4
--