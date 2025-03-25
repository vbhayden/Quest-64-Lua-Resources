local MEM_PTR_MAP_DATA_MAIN = 0x07C284
local MEM_PTR_MAP_DATA_VEGETATION = 0x07C290
local MEM_PTR_MAP_DATA_NAVIGATION = 0x07C298

local MEM_CURRENT_MAP_ID = 0x0842BF
local MEM_CURRENT_SUBMAP_ID = 0x0842C3

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GetMapIDs()
    local mapID = memory.readbyte(MEM_CURRENT_MAP_ID, "RDRAM")
    local subMapID = memory.readbyte(MEM_CURRENT_SUBMAP_ID, "RDRAM")

    return mapID, subMapID
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
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

        -- console.log(string.format("%08X -> %08X", ptr_index_start, ptr_index_end))
    end

    console.log(string.format("NavMesh for %s-%s: Found %s shapes!", map, submap, #chains))

    -- console.log(string.format("%08X", ptr_nav_data))
    -- console.log(string.format("%08X", ptr_submap_nav_data))

    return chains
end

local function WriteNavMesh(path, geometry_chains)

    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    for _, geometry_chain in pairs(geometry_chains) do
        for __, coord in pairs(geometry_chain) do
            file:write(string.format("%.2f,%.2f\n", coord.x, coord.z))
        end
        file:write("-\n")
    end

    file:close()
end

local previous_map, previous_submap = -1
while true do
    local map, submap = GetMapIDs()
    
    if previous_map ~= map or previous_submap ~= submap then
    
        local chains = ReadNavMesh()
        local filepath = "data/geometry-" .. map .. "-" .. submap .. ".csv"
        WriteNavMesh(filepath, chains)

        previous_map = map
        previous_submap = submap
    end

    emu.frameadvance()
end
