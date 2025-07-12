local MEM_PTR_MAP_DATA_MAIN = 0x084F18
local MEM_PTR_MAP_DATA_VEGETATION = 0x084F24
local MEM_PTR_MAP_DATA_NAVIGATION = 0x084F2C

local MEM_CURRENT_MAP_ID = 0x08536B
local MEM_CURRENT_SUBMAP_ID = 0x08536F

local MEM_GAME_STATE = 0x07B2E4
local MEM_ALLOW_BATTLES = 0x084F10

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

    console.log(string.format("%08X -> %s Total Regions", data.ptr_region_start, data.total_regions))
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

    console.log(string.format("%08X -> %s Total Circles", data.ptr_circle_start, data.total_circles))
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

-- local function ReadSpiritsFromMemory()

--     local spirit_count = memory.read_u32_be(MEM_SPIRIT_INFO_START, "RDRAM")
--     local spirits = {}

--     local spirit_index = 0
--     while spirit_index < spirit_count do
--         local spirit_coord_ptr = MEM_SPIRIT_INFO_START + 0x8 + 0x18 * spirit_index
        
--         spirits[#spirits+1] = {
--             x = memory.readfloat(spirit_coord_ptr + 0x0, true, "RDRAM"),
--             y = memory.readfloat(spirit_coord_ptr + 0x4, true, "RDRAM"),
--             z = memory.readfloat(spirit_coord_ptr + 0x8, true, "RDRAM")
--         }

--         spirit_index = spirit_index + 1
--     end

--     return spirits
-- end

-- local function ReadChestsFromMemory()

--     local chest_count = memory.read_u32_be(MEM_CHEST_COUNT, "RDRAM")
--     local chests = {}

--     local chest_index = 0
--     while chest_index < chest_count do
--         local chest_coord_ptr = MEM_CHEST_INFO_START + 0x6C * chest_index
        
--         chests[#chests+1] = {
--             x = memory.readfloat(chest_coord_ptr + 0x0, true, "RDRAM"),
--             y = memory.readfloat(chest_coord_ptr + 0x4, true, "RDRAM"),
--             z = memory.readfloat(chest_coord_ptr + 0x8, true, "RDRAM"),
--             angle = memory.readfloat(chest_coord_ptr + 0x10, true, "RDRAM")
--         }

--         chest_index = chest_index + 1
--     end

--     return chests
-- end

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

local function ReadNavMeshOriginal()

    local map, submap = GetMapIDs()
    local ptr_nav_data = GetPointerFromAddress(MEM_PTR_MAP_DATA_NAVIGATION)

    -- Need the submap index to read everything
    local ptr_submap_nav_data = ptr_nav_data + 0x10 * submap

    local ptr_verts = GetPointerFromAddress(ptr_submap_nav_data)
    local ptr_vert_indices = GetPointerFromAddress(ptr_submap_nav_data + 0x4)
    local ptr_vert_groups = GetPointerFromAddress(ptr_submap_nav_data + 0x8)
    local total_groups = memory.read_u32_be(ptr_submap_nav_data + 0xC, "RDRAM")

    local var_s7 = ptr_vert_groups
    local var_fp = total_groups

    if var_fp ~= 0 then
        while var_fp > 0 do
            
            local var_s1 = memory.read_u32_be(var_s7, "RDRAM")
            local var_s0 = ptr_vert_indices + memory.read_u32_be(var_s7 * 4, "RDRAM")

            if var_s1 ~= 0 then
                while var_s1 ~= 0 do
                    
                    local vert_address_root = ptr_verts

                    local vert_a = memory.read_u32_be((var_s0 + 0x0) * 8, "RDRAM") + vert_address_root
                    local az = memory.read_float(vert_a + 0x4, true, "RDRAM")

                    local vert_b = memory.read_u32_be((var_s0 + 0x4) * 8, "RDRAM") + vert_address_root
                    local bx = memory.read_float(vert_b + 0x0, true, "RDRAM")

                    local bz = memory.read_float(vert_b + 0x4, true, "RDRAM")
                    local ax = memory.read_float(vert_a + 0x0, true, "RDRAM")

                    var_s0 = var_s0 + 4
                    var_s1 = var_s1 - 1
                end
            end

            var_fp = var_fp - 1
            var_s7 = var_s7 + 8
        end
    end
end

local function WriteMapData(path, geometry_chains, circles, regions, spirits, chests)

    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

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
    
        local chains = ReadNavMesh()
        local circles = GetEncounterCirclesFromMemory()
        local regions = GetEncounterRegionsFromMemory()
        -- local spirits = ReadSpiritsFromMemory()
        -- local chests = ReadChestsFromMemory()

        local filepath = "data/us/mapdata-" .. map .. "-" .. submap .. ".json"
        WriteMapData(filepath, chains, circles, regions, {}, {})

        previous_map = map
        previous_submap = submap
    end

    was_busy = busy
    emu.frameadvance()
end
