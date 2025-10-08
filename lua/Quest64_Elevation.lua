-- Quest 64 Area Map Tool
--
-- This is a Lua script for the Bizhawk emulator
-- to display the encounter areas in-game.  It does this
-- by reading the game's memory, so no other resources or
-- CSV files should be required.
--
-- To use this script, open a Quest 64 rom with a modern
-- version of the Bizhawk / Emuhawk emulator, then load this
-- file using the Lua console.  A crude ASCII map should
-- appear on the right of your screen.
--
--
-- 
-- Encounter Map Config Values
--
-- These values will adjust how the map appears 
-- and can be edited without issue, although some
-- values will require a specific type etc.
--
local MAP_GRID_WIDTH = 14
local MAP_GRID_HEIGHT = 11
local MAP_GRID_UNIT_SPACING = 5
local MAP_ANCHOR_X = 2
local MAP_ANCHOR_Y = 20

-- Color Config
--
-- Colors can be provided with either the english name
-- or a corresponding hex code, accepting both 6 and 8 digits.
--
local MAP_COLOR_PLAYER = "cyan"
local MAP_COLOR_3_TURNS = "red"
local MAP_COLOR_2_TURNS = "orange"
local MAP_COLOR_1_TURNS = "yellow"
local MAP_COLOR_NO_ENCOUNTERS = 0xFFAAAAAA
local MAP_COLOR_NO_REGION = 0x50808080

local MAP_CHARACTER_NO_REGION = "+"
local MAP_CHARACTER_NO_ENCOUNTERS = "."

-- Encounter Feedback Config Values
--
-- These values control whether and where the feedback
-- for triggering an encounter will appear.  This is the
-- little popup that informs you of when the game would have
-- rolled for an encounter.
--
local ENCOUNTER_FEEDBACK_ENABLED = true
local ENCOUNTER_FEEDBACK_ANCHOR_Y = -2
local ENCOUNTER_FEEDBACK_DURATION_MS = 1000
local CACHED_BLOCK_WIDTH = 200

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
local MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
local MEM_ENCOUNTER_ACCUMULATION = 0x8C578
local MEM_CAMERA_ROTATION_Y = 0x86DE8
local MEM_GAME_STATE = 0x7B2E4
local MEM_ALLOW_BATTLES = 0x084F10
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4

-- GUI Constants
local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 80

-- Working Variables
local current_map = -1
local current_submap = -1
local current_encounter_centers = {}
local cached_regional_blocks = {}

local encounter_checked_at = 0
local last_step_distance = 0
local last_encounter_check_result = nil

local MEM_PTR_MAP_DATA_MAIN = 0x084F18
local MEM_PTR_MAP_DATA_NAVIGATION = 0x084F2C

local MEM_PTR_MAP_DATA_MODELS = 0x084F20
local MEM_PTR_MAP_DATA_VEGETATION = 0x084F24
local MEM_PTR_MAP_DATA_MODEL_INFO = 0x084F28

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
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

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return {
        x = brianX,
        z = brianZ   
    }
end

local function GetMapModelData()
    local ptr_map_models = GetPointerFromAddress(MEM_PTR_MAP_DATA_MODELS)

    return {
        unk0 = memory.read_u16_be(ptr_map_models + 0x0, "RDRAM"),
        unk2 = memory.read_u16_be(ptr_map_models + 0x2, "RDRAM"),
        unk4 = memory.read_u16_be(ptr_map_models + 0x4, "RDRAM"),
        unk6 = memory.read_u16_be(ptr_map_models + 0x6, "RDRAM"),
        unk8 = memory.readfloat(ptr_map_models + 0x8, true, "RDRAM"),
        unkC = memory.readfloat(ptr_map_models + 0xC, true, "RDRAM"),
        unk10 = memory.readfloat(ptr_map_models + 0x10, true, "RDRAM"),
        unk14 = memory.readfloat(ptr_map_models + 0x14, true, "RDRAM"),
        unk18 = GetPointerFromAddress(ptr_map_models + 0x18),
        unk1C = GetPointerFromAddress(ptr_map_models + 0x1C),
        unk20 = GetPointerFromAddress(ptr_map_models + 0x20),
        unk24 = memory.read_u16_be(ptr_map_models + 0x24, "RDRAM"),
        unk26 = memory.read_u16_be(ptr_map_models + 0x26, "RDRAM"),
        unk28 = memory.read_u16_be(ptr_map_models + 0x28, "RDRAM"),
    }
end

local function GetVertexData(address)
    return {
        unk0 = memory.read_s16_be(address + 0x0, "RDRAM"),
        unk2 = memory.read_s16_be(address + 0x2, "RDRAM"),
        unk4 = memory.read_s16_be(address + 0x4, "RDRAM"),
        unk6 = memory.read_s16_be(address + 0x6, "RDRAM"),
    }
end

local function GetFaceData(address)
    return {
        unk0 = memory.read_s16_be(address + 0x0, "RDRAM"),
        unk2 = memory.read_s16_be(address + 0x2, "RDRAM"),
        unk4 = memory.read_s16_be(address + 0x4, "RDRAM"),
        unk6 = memory.read_u16_be(address + 0x6, "RDRAM"),
        unk8 = memory.readfloat(address + 0x8, true, "RDRAM"),
        unkC = memory.readfloat(address + 0xC, true, "RDRAM"),
        unk10 = memory.readfloat(address + 0x10, true, "RDRAM"),
    }
end

local function GetModelTriangles(x, z, scale, flags, arg4_address, arg5)

    local arg4 = {
        unk0 = memory.read_u16_be(arg4_address + 0x0, "RDRAM"),
        unk2 = memory.read_u16_be(arg4_address + 0x2, "RDRAM"),
        unk4 = memory.read_u32_be(arg4_address + 0x4, "RDRAM"),
        unk8 = memory.read_s16_be(arg4_address + 0x8, "RDRAM"),
        unkA = memory.read_s16_be(arg4_address + 0xA, "RDRAM"),
        unkC = memory.read_u32_be(arg4_address + 0xC, "RDRAM"),
        unk10 = memory.read_u32_be(arg4_address + 0x10, "RDRAM"),
        unk14 = GetPointerFromAddress(arg4_address + 0x14),
        unk18 = memory.read_u16_be(arg4_address + 0x18, "RDRAM"),
        unk1A = memory.read_u16_be(arg4_address + 0x1A, "RDRAM"),
        unk1C = GetPointerFromAddress(arg4_address + 0x1C)
    }

    local face_data_length = 0x14
    local vertex_data_length = 0x8

    local triangle_count = arg4.unk18
    local triangles = {}

    if triangle_count ~= 0 then
        
        for triangle_index = 0,triangle_count - 1 do
            
            local var_s1 = GetFaceData(arg4.unk14 + face_data_length * triangle_index)
            if bit.band(var_s1.unk6, flags) then
                
                local vert_a = GetVertexData(arg4.unk1C + var_s1.unk0 * vertex_data_length)
                local vert_b = GetVertexData(arg4.unk1C + var_s1.unk2 * vertex_data_length)
                local vert_c = GetVertexData(arg4.unk1C + var_s1.unk4 * vertex_data_length)

                triangles[#triangles+1] = {
                    { x = vert_a.unk0, y = vert_a.unk2, z = vert_a.unk4 },
                    { x = vert_b.unk0, y = vert_b.unk2, z = vert_b.unk4 },
                    { x = vert_c.unk0, y = vert_c.unk2, z = vert_c.unk4 },
                }
            end
        end
    end

    return triangles
end

local function GetModelInfo(arg0, arg1, flags, model_index, motion_data)

    local block_length = 0x18
    local ptr_model_info = GetPointerFromAddress(0x84F24) + block_length * model_index

    local var_a0 = {
        unk0 = memory.readfloat(ptr_model_info + 0x0, true, "RDRAM"),   -- X
        unk4 = memory.readfloat(ptr_model_info + 0x4, true, "RDRAM"),   -- Y
        unk8 = memory.readfloat(ptr_model_info + 0x8, true, "RDRAM"),   -- Z
        unkC = memory.readfloat(ptr_model_info + 0xC, true, "RDRAM"),   -- Angle
        unk10 = memory.readfloat(ptr_model_info + 0x10, true, "RDRAM"), -- Scale
        unk14 = memory.read_u16_be(ptr_model_info + 0x14, "RDRAM"),     -- ?
        unk16 = memory.read_u16_be(ptr_model_info + 0x16, "RDRAM"),     -- ?
    }

    local model_x = var_a0.unk0
    local model_y = var_a0.unk4
    local model_z = var_a0.unk8

    local local_x = arg0 - var_a0.unk0
    local local_z = arg1 - var_a0.unk8
    local model_scale = var_a0.unk10

    local var_v0 = bit.lshift(var_a0.unk14, 5) + GetPointerFromAddress(0x84F28)

    local terrain_has_collision = bit.band(var_a0.unk16, 0xFF) < 0x10

    local triangles = GetModelTriangles(local_x, local_z, model_scale, flags, var_v0, motion_data)
    if #triangles ~= 0 then
        GuiText(5 + model_index, string.format("%02d: %s - %05.2f, %05.2f, Angle: %0.2f, Triangles: %d", model_index, Ternary(terrain_has_collision, "True", "False"), model_x, model_z, var_a0.unkC, #triangles))
    end

    return {
        triangles = triangles,
        scale = var_a0.unk10,
        angle = var_a0.unkC,
        x = model_x,
        y = model_y,
        z = model_z
    }
end

local function ReadModelData()

    local temp_v0 = GetMapModelData()
    local brian = GetBrianLocation()

    local v1 = 0
    local a1 = 0
    local s1 = 0

    if temp_v0.unk28 == 0 then
        s1 = temp_v0.unk20
    else
        v1 = math.floor((brian.x - temp_v0.unk8) / temp_v0.unk10)
        a1 = math.floor((brian.z - temp_v0.unkC) / temp_v0.unk14)
        s1 = ((temp_v0.unk1C + (((temp_v0.unk4 * a1) + v1) * 2)) * 2) + temp_v0.unk20
    end

    local s0 = memory.read_u16_be(s1, "RDRAM")
    local s1_2 = s1 + 2

    local model_count = 0

    local elevation_models = {}

    if  v1 >= 0 
    and v1 < temp_v0.unk4 
    and a1 >= 0 
    and a1 < temp_v0.unk6 then

        -- ::loop_17::
        s0 = memory.read_u16_be(s1, "RDRAM")
        s1_2 = s1 + 2

        while s0 ~= 0 do
            local a3 = memory.read_u16_be(s1_2, "RDRAM")
            s1_2 = s1_2 + 2
            s0 = s0 - 1

            model_count = model_count + 1

            local model_info = GetModelInfo(brian.x, brian.z, 0xFFFF, a3, {})

            if #model_info.triangles > 0 then
                elevation_models[#elevation_models+1] = model_info
            end
        end
    end

    local var_s0_2 = temp_v0.unk2
    local var_s1_3 = temp_v0.unk24

    while s0 ~= 0 do

        local temp_a3_2 = memory.read_u16_be(var_s1_3, "RDRAM")
        var_s1_3 = var_s1_3 + 2
        var_s0_2 = var_s0_2 - 1

        local model_triangles = GetModelInfo(brian.x, brian.z, 0xFFFF, temp_a3_2, {})
    
        if #model_triangles > 0 then
            elevation_models[#elevation_models+1] = model_triangles
        end
    end
    
    return elevation_models
end

console.clear()


while true do

    ReadModelData()

    emu.frameadvance()
end
