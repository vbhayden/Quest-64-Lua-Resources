local MEM_PTR_MAP_DATA_MAIN = 0x084F18
local MEM_PTR_MAP_DATA_MODELS = 0x084F20
local MEM_LOADED_MODELS_ARRAY_PTR = 0x84F24
local MEM_PTR_MAP_DATA_VEGETATION = 0x084F24
local MEM_PTR_MAP_DATA_MODEL_INFO = 0x084F28
local MEM_PTR_MAP_DATA_NAVIGATION = 0x084F2C

local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Y = 0x7BAD0
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_SPIRIT_INFO_START = 0x86A00

local MEM_CHEST_COUNT = 0X0869A0
local MEM_CHEST_INFO_START = 0X0862E0

local MEM_CURRENT_MAP_ID = 0x08536B
local MEM_CURRENT_SUBMAP_ID = 0x08536F

local MEM_GAME_STATE = 0x07B2E4
local MEM_ALLOW_BATTLES = 0x084F10

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function IsGameBusy()
    local state = memory.read_u32_be(MEM_GAME_STATE, "RDRAM")
    return state > 0
end 

local function AreBattlesAllowed()
    local flags = memory.read_u16_be(MEM_ALLOW_BATTLES, "RDRAM")
    return bit.band(flags, 0x0001) > 0
end

local function GetMapIDs()
    local mapID = memory.readbyte(MEM_CURRENT_MAP_ID, "RDRAM")
    local subMapID = memory.readbyte(MEM_CURRENT_SUBMAP_ID, "RDRAM")

    return mapID, subMapID
end

local function ToShort(first_byte, second_byte)
    local unsigned = first_byte * 256 + second_byte
    if unsigned >= 32768 then
        return unsigned - 32768 * 2
    else
        return unsigned
    end
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

local function GetEncounterPointers()

    local ptr_region_data = GetPointerFromAddress(0x08C560)
    local ptr_circle_data = GetPointerFromAddress(0x08C564)

    local data = {
        ptr_region_start = GetPointerFromAddress(ptr_region_data),
        total_regions = GetPointerFromAddress(ptr_region_data + 4),
        ptr_circle_start = GetPointerFromAddress(ptr_circle_data + 8),
        total_circles = GetPointerFromAddress(ptr_circle_data + 12)
    }

    if data.total_circles > 500 then
        console.log("Circle Count: " .. data.total_circles)
        data.total_circles = 0
    end
    
    if data.total_regions > 500 then
        console.log("Region Count: " .. data.total_regions)
        data.total_regions = 0
    end

    return data
end

local function GetEncounterRegionsFromMemory()

    local battles_allowed = AreBattlesAllowed()
    if not battles_allowed then
        return {}
    end

    local regions = {}

    local data = GetEncounterPointers()

    -- console.log(string.format("%08X -> %s Total Regions", data.ptr_region_start, data.total_regions))
    -- return {}

    local region_size = 4 * 6
    local bytes = memory.read_bytes_as_array(data.ptr_region_start, data.total_regions * region_size, "RDRAM")

    for k=1,#bytes/region_size do
        
        local index = (k - 1) * region_size

        local x = ToShort(bytes[index + 1], bytes[index + 2])
        local z = ToShort(bytes[index + 3], bytes[index + 4])
        local w = ToShort(bytes[index + 5], bytes[index + 6])
        local d = ToShort(bytes[index + 7], bytes[index + 8])

        local encounters = {}
        local encounter_count = bytes[index + 10]

        for i = 1,encounter_count do
            local entry_index = index + 10 + 2 * i
            encounters[#encounters+1] = bytes[entry_index]
        end

        local region = {
            x = x,
            z = z,
            w = w,
            d = d,
            encounters = encounters
        }

        regions[#regions + 1] = region
    end

    return regions
end

local function GetEncounterCirclesFromMemory()
    
    local battles_allowed = AreBattlesAllowed()
    if not battles_allowed then
        return {}
    end

    local data = GetEncounterPointers()
    local encounter_centers = {}

    -- console.log(string.format("%08X -> %s Total Circles", data.ptr_circle_start, data.total_circles))
    -- return {}

    local bytes = memory.read_bytes_as_array(data.ptr_circle_start, data.total_circles * 4, "RDRAM")
    for k=1,#bytes/4 do
        
        local index = (k - 1) * 4
        local center = {
            x = ToShort(bytes[index + 1], bytes[index + 2]),
            z = ToShort(bytes[index + 3], bytes[index + 4])
        }

        encounter_centers[#encounter_centers + 1] = center
    end

    return encounter_centers
end

local function ReadSpiritsFromMemory()

    local spirit_count = memory.read_u32_be(MEM_SPIRIT_INFO_START, "RDRAM")
    local spirits = {}

    local spirit_index = 0
    while spirit_index < spirit_count do
        local spirit_coord_ptr = MEM_SPIRIT_INFO_START + 0x8 + 0x18 * spirit_index
        
        spirits[#spirits+1] = {
            x = memory.readfloat(spirit_coord_ptr + 0x0, true, "RDRAM"),
            y = memory.readfloat(spirit_coord_ptr + 0x4, true, "RDRAM"),
            z = memory.readfloat(spirit_coord_ptr + 0x8, true, "RDRAM")
        }

        spirit_index = spirit_index + 1
    end

    return spirits
end

local function ReadChestsFromMemory()

    local chest_count = memory.read_u32_be(MEM_CHEST_COUNT, "RDRAM")
    local chests = {}

    local chest_index = 0
    while chest_index < chest_count do
        local chest_coord_ptr = MEM_CHEST_INFO_START + 0x6C * chest_index
        
        chests[#chests+1] = {
            x = memory.readfloat(chest_coord_ptr + 0x0, true, "RDRAM"),
            y = memory.readfloat(chest_coord_ptr + 0x4, true, "RDRAM"),
            z = memory.readfloat(chest_coord_ptr + 0x8, true, "RDRAM"),
            angle = memory.readfloat(chest_coord_ptr + 0x10, true, "RDRAM")
        }

        chest_index = chest_index + 1
    end

    return chests
end

local function ReadNavMesh()

    local map, submap = GetMapIDs()
    local ptr_nav_data = GetPointerFromAddress(MEM_PTR_MAP_DATA_NAVIGATION)

    -- Need the submap index to read everything
    local ptr_submap_nav_data = ptr_nav_data + 0x10 * submap

    local ptr_verts = GetPointerFromAddress(ptr_submap_nav_data)
    local ptr_vert_indices = GetPointerFromAddress(ptr_submap_nav_data + 0x4)
    local ptr_vert_groups = GetPointerFromAddress(ptr_submap_nav_data + 0x8)
    local total_groups = memory.read_u32_be(ptr_submap_nav_data + 0xC, "RDRAM")

    local groups = {}

    -- console.clear()

    for k=0,total_groups-1 do
        local index = ptr_vert_groups + k * 0x8
        local a = memory.read_u32_be(index + 0x0, "RDRAM")
        local b = memory.read_u32_be(index + 0x4, "RDRAM")

        -- console.log(string.format("Index: %s, Length %s", a, b))

        groups[#groups+1] = {a=a, b=b}
    end

    local chains = {}

    for k=1, #groups do
        local pair = groups[k]

        local ptr_index_start = ptr_vert_indices + 0x4 * pair.a
        local ptr_index_end = ptr_vert_indices + 0x4 * (pair.a + pair.b)

        local chain = {}

        for ptr_index = ptr_index_start, ptr_index_end, 0x4 do
            local index = memory.read_u32_be(ptr_index, "RDRAM")

            -- console.log(string.format("%08X", index))

            local ptr_vert = ptr_verts + index * 0x8
            local coord = {
                x = memory.readfloat(ptr_vert + 0x0, true, "RDRAM"),
                z = memory.readfloat(ptr_vert + 0x4, true, "RDRAM")
            }

            chain[#chain+1] = coord
        end

        chains[#chains+1] = chain
    end

    console.log(string.format("NavMesh for %s-%s: Found %s shapes!", map, submap, #chains))

    return chains
end

local function IsTree(model)
    if model == 0x8010 then
        return true
    end

    return false
end

local function IsShrub(model)
    if model == 0x8000 then
        return true
    end

    return false
end

local function GetModelInfoAtAddress(addr)

    return {
        x = memory.readfloat(addr, true, "RDRAM"),
        y = memory.readfloat(addr + 4, true, "RDRAM"),
        z = memory.readfloat(addr + 8, true, "RDRAM"),
        angle = memory.readfloat(addr + 12, true, "RDRAM"),
        size = memory.readfloat(addr + 16, true, "RDRAM"),
        anim = memory.read_u16_be(addr + 20, "RDRAM"),
        model = memory.read_u16_be(addr + 22, "RDRAM")
    }
end

local function GetMapVegetationData()

    local vegetation = {}

    local ptr_1 = memory.read_u32_be(MEM_PTR_MAP_DATA_MODELS, "RDRAM")
    local ptr_2 = memory.read_u32_be(MEM_LOADED_MODELS_ARRAY_PTR, "RDRAM")
    local ptr_models_count = GetPointerFromAddress(MEM_PTR_MAP_DATA_MODELS)
    local ptr_models_array = GetPointerFromAddress(MEM_LOADED_MODELS_ARRAY_PTR)

    if bit.band(ptr_1, 0X80000000) == 0x80000000 then

        local models_count = memory.read_u16_be(ptr_models_count, "RDRAM")
        for k = 0, models_count - 1 do
            
            local addr = ptr_models_array + k * 24
            local model_info = GetModelInfoAtAddress(addr)

            local is_tree = IsTree(model_info.model)
            local is_shrub = IsShrub(model_info.model)
            if is_tree or is_shrub then
                vegetation[#vegetation+1] = model_info
            end
        end
    end

    return vegetation
end

local function GetMapModelData()
    local ptr_map_models = GetPointerFromAddress(MEM_PTR_MAP_DATA_MODELS)

    return {
        unk0 = memory.read_u16_be(ptr_map_models + 0x0, "RDRAM"),       -- ?
        unk2 = memory.read_u16_be(ptr_map_models + 0x2, "RDRAM"),       -- Non-Tile Model Count?
        unk4 = memory.read_u16_be(ptr_map_models + 0x4, "RDRAM"),       -- Columns
        unk6 = memory.read_u16_be(ptr_map_models + 0x6, "RDRAM"),       -- Rows
        unk8 = memory.readfloat(ptr_map_models + 0x8, true, "RDRAM"),   -- Min X Bound
        unkC = memory.readfloat(ptr_map_models + 0xC, true, "RDRAM"),   -- Min Z Bound
        unk10 = memory.readfloat(ptr_map_models + 0x10, true, "RDRAM"), -- Map Tile Width (X-axis)
        unk14 = memory.readfloat(ptr_map_models + 0x14, true, "RDRAM"), -- Map Tile Depth (Z-axis)
        unk18 = GetPointerFromAddress(ptr_map_models + 0x18),           -- ?
        unk1C = GetPointerFromAddress(ptr_map_models + 0x1C),           -- PTR - Tile Start Address
        unk20 = GetPointerFromAddress(ptr_map_models + 0x20),           -- PTR - Terrain Start Address?
        unk24 = GetPointerFromAddress(ptr_map_models + 0x24),           -- PTR - Non-Tile Start Address
        unk28 = memory.read_u16_be(ptr_map_models + 0x28, "RDRAM"),     -- Is Map Tiled?
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
        unk14 = memory.read_u16_be(ptr_model_info + 0x14, "RDRAM"),     -- Animation?
        unk16 = memory.read_u16_be(ptr_model_info + 0x16, "RDRAM"),     -- Model
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

    -- console.log(model_index .. ": " .. #triangles)

    return {
        triangles = triangles,
        scale = var_a0.unk10,
        angle = var_a0.unkC,
        x = model_x,
        y = model_y,
        z = model_z
    }
end

local function GetBrianLocation()
    local x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local z = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")

    return { x=x, y=y, z=z }
end

local function ToInt(number)
    if number >= 0 then
        return math.floor(number)
    else
        return math.ceil(number)
    end
end

local function ReadElevationData()

    local temp_v0 = GetMapModelData()
    local brian = GetBrianLocation()

    local v1 = 0
    local a1 = 0
    local var_s1 = 0

    if temp_v0.unk28 == 0 then
        var_s1 = temp_v0.unk20
        console.log(string.format("var_s1: %08X", var_s1))
    else
        -- var_v1 = (s32) ((var_f20 - temp_v0->unk8) / temp_v0->unk10);
        -- var_a1 = (s32) ((var_f22 - temp_v0->unkC) / temp_v0->unk14);
        -- var_s1 = (  *(temp_v0->unk1C + (((temp_v0->unk4 * var_a1) + var_v1) * 2)) * 2  ) + temp_v0->unk20;
        -- v1 = math.floor((brian.x - temp_v0.unk8) / temp_v0.unk10)
        -- a1 = math.floor((brian.z - temp_v0.unkC) / temp_v0.unk14)
        -- var_s1 = ((temp_v0.unk1C + (((temp_v0.unk4 * a1) + v1) * 2)) * 2) + temp_v0.unk20
        var_s1 = (memory.read_u16_be(temp_v0.unk1C, "RDRAM") * 2) + temp_v0.unk20
        
        local tile_x = ToInt((brian.x - temp_v0.unk8) / temp_v0.unk10)
        local tile_z = ToInt((brian.z - temp_v0.unkC) / temp_v0.unk14)
        local tile_start = temp_v0.unk1C
        local tile_columns = temp_v0.unk4
        local tile_index = tile_columns * tile_z + tile_x
        local tile_address = tile_start + tile_index * 2
        local model_offset = memory.read_u16_be(tile_address, "RDRAM") * 2
        local model_address = model_offset + temp_v0.unk20

        console.log("X: " .. tile_x)
        console.log("Z: " .. tile_z)
        console.log("Start: " .. tile_start)
        console.log("Rows: " .. temp_v0.unk6)
        console.log("Columns: " .. tile_columns)
        console.log("Index: " .. tile_index)
        console.log(string.format("Tile Address: %08X", tile_address))
        console.log("Model Offset: " .. model_offset)
        console.log(string.format("Model Address: %08X", model_address))

        var_s1 = model_address
    end

    local model_count = 0
    local elevation_models = {}


    if  v1 >= 0 
    and v1 < temp_v0.unk4 
    and a1 >= 0 
    and a1 < temp_v0.unk6 then

        -- ::loop_17::
        local var_s0 = memory.read_u16_be(var_s1, "RDRAM")
        local var_s1_2 = var_s1 + 2

        console.log(string.format("%08X", var_s1))
        console.log(var_s0)

        while var_s0 ~= 0 do
            local temp_a3 = memory.read_u16_be(var_s1_2, "RDRAM")
            var_s1_2 = var_s1_2 + 2
            var_s0 = var_s0 - 1

            model_count = model_count + 1

            local model_info = GetModelInfo(brian.x, brian.z, 0xFFFF, temp_a3, {})

            if #model_info.triangles > 0 then
                elevation_models[#elevation_models+1] = model_info
                console.log("found! " .. #model_info.triangles .. " triangles!")
            end
        end
    end

    local var_s0_2 = temp_v0.unk2
    local var_s1_3 = temp_v0.unk24

    console.log(var_s0_2)

    while var_s0_2 ~= 0 do

        local temp_a3_2 = memory.read_u16_be(var_s1_3, "RDRAM")
        var_s1_3 = var_s1_3 + 2
        var_s0_2 = var_s0_2 - 1

        local model_info = GetModelInfo(brian.x, brian.z, 0xFFFF, temp_a3_2, {})
    
        if #model_info.triangles > 0 then
            elevation_models[#elevation_models+1] = model_info
            console.log("found! " .. #model_info.triangles)
        end
    end
    
    return elevation_models
end

local function WriteMapData(path)

    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end
    
    local geometry_chains = ReadNavMesh()
    local circles = GetEncounterCirclesFromMemory()
    local regions = GetEncounterRegionsFromMemory()
    local spirits = ReadSpiritsFromMemory()
    local chests = ReadChestsFromMemory()
    local vegetation = GetMapVegetationData()
    local elevation_triangles = ReadElevationData()

    file:write("{\n")

    local last_char = ""

    
    file:write('\t"walls": [\n')
    for chain_index, geometry_chain in pairs(geometry_chains) do
        file:write('\t\t[\n')
        for k, coord in pairs(geometry_chain) do
            if k == #geometry_chain then last_char = "" else last_char = "," end
            file:write(string.format('\t\t\t{"x": %.4f, "z": %.4f}%s\n', coord.x, coord.z, last_char))
        end
        if chain_index == #geometry_chains then last_char = "" else last_char = "," end
        file:write(string.format('\t\t]%s\n', last_char))
    end
    file:write('\t],\n')

    
    file:write('\t"circles": [\n')
    for circle_index, circle in pairs(circles) do
        local last_char = ","
        if circle_index == #circles then last_char = "" else last_char = "," end
        file:write(string.format('\t\t{"x": %.4f, "z": %.4f}%s\n', circle.x, circle.z, last_char))
    end
    file:write('\t],\n')
    

    file:write('\t"regions": [\n')
    for region_index, region in pairs(regions) do
        local last_char = ","
        if region_index == #regions then last_char = "" else last_char = "," end
        file:write(string.format('\t\t{"x": %.4f, "z": %.4f, "width": %.4f, "depth": %.4f}%s\n', region.x, region.z, region.w, region.d, last_char))
    end    
    file:write('\t],\n')
    

    file:write('\t"spirits": [\n')
    for spirit_index, spirit in pairs(spirits) do
        local last_char = ","
        if spirit_index == #spirits then last_char = "" else last_char = "," end
        file:write(string.format('\t\t{"x": %.4f, "z": %.4f}%s\n', spirit.x, spirit.z, last_char))
    end    
    file:write('\t],\n')
    

    file:write('\t"chests": [\n')
    for chest_index, chest in pairs(chests) do
        local last_char = ","
        if chest_index == #chests then last_char = "" else last_char = "," end
        file:write(string.format('\t\t{"x": %.4f, "z": %.4f, "angle": %.4f}%s\n', chest.x, chest.z, chest.angle, last_char))
    end    
    file:write('\t],\n')
    

    file:write('\t"vegetation": [\n')
    for v_index, model in pairs(vegetation) do
        local last_char = ","
        if v_index == #vegetation then last_char = "" else last_char = "," end
        -- x = memory.readfloat(addr, true, "RDRAM"),
        -- y = memory.readfloat(addr + 4, true, "RDRAM"),
        -- z = memory.readfloat(addr + 8, true, "RDRAM"),
        -- angle = memory.readfloat(addr + 12, true, "RDRAM"),
        -- size = memory.readfloat(addr + 16, true, "RDRAM"),
        -- anim = memory.read_u16_be(addr + 20, "RDRAM"),
        -- model = memory.read_u16_be(addr + 22, "RDRAM")
        file:write(string.format('\t\t{"x": %.4f, "y": %.4f, "z": %.4f, "angle": %.4f, "scale": %.2f, "anim": %d, "model": %d}%s\n', 
            model.x, model.y, model.z, model.angle, model.size, model.anim, model.model, last_char))
    end    
    file:write('\t],\n')

    file:write('\t"elevation": [\n')

    for v_index, model in pairs(elevation_triangles) do
        local last_char = ","
        if v_index == #elevation_triangles then last_char = "" else last_char = "," end
        -- Model Format:
        ---- triangles = triangles,
        ---- scale = var_a0.unk10,
        ---- angle = var_a0.unkC,
        ---- x = model_x,
        ---- y = model_y,
        ---- z = model_z
        -- Triangles Format:
        ---- Array of 3-element arrays of x/y/z tables
        file:write(string.format('\t\t{"x": %.4f, "y": %.4f, "z": %.4f, "angle": %.4f, "scale": %.2f, "triangles": [\n', 
            model.x, model.y, model.z, model.angle, model.scale))
        
        for e_index, triangle in pairs(model.triangles) do

            local inner_last_char = ","
            if e_index == #model.triangles then inner_last_char = "" else inner_last_char = "," end
            file:write("\t\t\t[\n")
            file:write(string.format('\t\t\t\t{"x": %.4f, "y": %.4f, "z": %.4f},\n', triangle[1].x, triangle[1].y, triangle[1].z))
            file:write(string.format('\t\t\t\t{"x": %.4f, "y": %.4f, "z": %.4f},\n', triangle[2].x, triangle[2].y, triangle[2].z))
            file:write(string.format('\t\t\t\t{"x": %.4f, "y": %.4f, "z": %.4f}\n',  triangle[3].x, triangle[3].y, triangle[3].z))
            file:write(string.format('\t\t\t]%s\n', inner_last_char))
        end

        file:write(string.format("\t\t]}%s\n", last_char))

    end
    file:write('\t]\n')

    file:write("}\n")

    file:close()
end

local busy_timeout = 30
local busy_duration = 0
local previous_map, previous_submap = -1, -1
while true do
    local map, submap = GetMapIDs()
    
    local busy = IsGameBusy()
    if busy then
        busy_duration = busy_timeout
    elseif busy_duration > 0 then
        busy_duration = busy_duration - 1
    end

    if (busy_duration == 0) and (previous_map ~= map or previous_submap ~= submap) then

        local filepath = "data/us/mapdata-" .. map .. "-" .. submap .. ".json"
        WriteMapData(filepath)

        previous_map = map
        previous_submap = submap
    end

    was_busy = busy
    emu.frameadvance()
end
