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
local MEM_PTR_MAP_DATA_VEGETATION = 0x084F24
local MEM_PTR_MAP_DATA_NAVIGATION = 0x084F2C

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

    -- console.log(string.format("NavMesh for %s-%s: Found %s shapes!", map, submap, #chains))

    return chains
end



local cached_regions = {}

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GetBlockIndices(sample_x, sample_z)
    return Round(sample_x / CACHED_BLOCK_WIDTH, 0), Round(sample_z / CACHED_BLOCK_WIDTH, 0)
end

local function TransformDirectionForAngle(x, y, z, theta)
    
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
    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return {
        x = xp,
        y = y,
        z = zp
    }
end

local function GetCameraAngle()
    return Round(memory.readfloat(MEM_CAMERA_ROTATION_Y, true, "RDRAM"), 4)
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function IsGameBusy()
    local state = memory.read_u32_be(MEM_GAME_STATE, "RDRAM")
    return state ~= 0
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

local function AreBattlesAllowed()
    local flags = memory.read_u16_be(MEM_ALLOW_BATTLES, "RDRAM")
    return bit.band(flags, 0x0001) > 0
end

local function GetEncounterPointers()

    local ptr_region_data = GetPointerFromAddress(0x08C560)
    local ptr_circle_data = GetPointerFromAddress(0x08C564)

    return {
        ptr_region_start = GetPointerFromAddress(ptr_region_data),
        total_regions = GetPointerFromAddress(ptr_region_data + 4),
        ptr_circle_start = GetPointerFromAddress(ptr_circle_data + 8),
        total_circles = GetPointerFromAddress(ptr_circle_data + 12)
    }
end

local function ReadEncountersFromMemory()
    local data = GetEncounterPointers()

    local encounter_centers = {}

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

local function GetEncounterRegionsFromMemory()

    local battles_allowed = AreBattlesAllowed()
    if not battles_allowed then
        return {}
    end

    local regions = {}

    local data = GetEncounterPointers()
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

local function CheckAABBExplicit(x, z, region)
    if region == nil then
        return false
    end
    
    local above_min_x = x > region.x
    local below_max_x = x < (region.x + region.w)
    local above_min_z = z > region.z
    local below_max_z = z < (region.z + region.d)

    return above_min_x and above_min_z and below_max_x and below_max_z
end

local function GetRegionOverlapIndex(sample_x, sample_z)
    if cached_regions == nil or #cached_regions == 0 then
        return -1
    end

    for k, region in pairs(cached_regions) do
        local overlaps = CheckAABBExplicit(sample_x, sample_z, region)
        if overlaps then
            return k
        end
    end

    return -1
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return {
        x = brianX,
        z = brianZ   
    }
end

local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GuiCharRightWithColor(row_index, char_index, char, color)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset + char_index * GUI_CHAR_WIDTH, 20 + row_index * 15, char, color)
end

local function GuiCharRightWithColorExplicit(row_index, char_index, char, color, border_width, screen_width)
    
    local resolvedOffset = screen_width - border_width - GUI_PADDING_RIGHT

    gui.text(resolvedOffset + char_index * GUI_CHAR_WIDTH, 20 + row_index * 15, char, color)
end

local function GuiRowRightWithColorExplicit(row_index, char_index, text, color, border_width, screen_width)
    
    local resolvedOffset = screen_width - border_width - GUI_PADDING_RIGHT

    gui.text(resolvedOffset + char_index * GUI_CHAR_WIDTH, 20 + row_index * 15, text, color)
end

local function GetMovementRadius()
    local agility = memory.readbyte(0x7BA8D, "RDRAM")
    return agility * 0.2857 + 17
end

local function GetEncounterCenters() 

    local battles_allowed = AreBattlesAllowed()
    if battles_allowed then
        return ReadEncountersFromMemory()
    else
        return {}
    end
end

local function BuildBlocksFromCenters(centers)

    local regional_blocks = {}

    for _, coord in pairs(centers) do
        local block_i, block_j = GetBlockIndices(coord.x, coord.z)
        
        if regional_blocks[block_i] == nil then
            regional_blocks[block_i] = {}
        end

        if regional_blocks[block_i][block_j] == nil then
            regional_blocks[block_i][block_j] = {}
        end

        -- console.log("Adding Coord to block " .. block_i .. ", " .. block_j)

        block_centers = regional_blocks[block_i][block_j]
        block_centers[#block_centers + 1] = coord

        regional_blocks[block_i][block_j] = block_centers
    end

    -- console.log(regional_blocks[90][110][1])

    return regional_blocks
end 

local function MergeTables(t1, t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local cached_grid_x = -9999
local cached_grid_z = -9999
local cached_neighbor_return = {}

local function GetNeighboringCenters(sample_x, sample_z, regional_blocks)
    local grid_x, grid_z = GetBlockIndices(sample_x, sample_z)


    if grid_x == cached_grid_x and grid_z == cached_grid_z then
        return cached_neighbor_return
    end

    console.log("Rebuilding Neighbors for: " .. grid_x .. ", " .. grid_z)
    -- console.log("Cached Grid: " .. cached_grid_x .. ", " .. cached_grid_z)
    -- console.log("Actual Grid: " .. grid_x .. ", " .. grid_z)
    local nearby = {}

    for i=-1, 1 do
        for j=-1,1 do
            if regional_blocks[grid_x+i] ~= nil then
                if regional_blocks[grid_x+i][grid_z+j] ~= nil then
                    local neighboring_centers = regional_blocks[grid_x+i][grid_z+j]
                    nearby = MergeTables(nearby, neighboring_centers)
                end
            end
        end
    end

    -- console.log(regional_blocks[90][110][1])

    cached_grid_x = grid_x
    cached_grid_z = grid_z

    cached_neighbor_return = nearby

    return nearby
end

local check_for_regions = true

local function GetLocalEnounterInfo()
    local map, submap = GetMapIDs()

    local game_busy = IsGameBusy()
    if game_busy then
        return current_encounter_centers
    end

    if map ~= current_map or submap ~= current_submap then

        current_encounter_centers = GetEncounterCenters()
        cached_regional_blocks = BuildBlocksFromCenters(current_encounter_centers)
        
        local extra_print = ""
        if current_encounter_centers ~= nil then
            extra_print = ", " .. #current_encounter_centers .. " found."
        end

        console.log("Loading data for Map: " .. map .. ", Sub-Map: " .. submap .. extra_print)

        check_for_regions = true
    end

    if check_for_regions and not game_busy then

        cached_regions = GetEncounterRegionsFromMemory()
        check_for_regions = false
    end

    current_map = map
    current_submap = submap

    return current_encounter_centers
end

local function GetTrimmedCenters(regional_blocks, brian, width, height)


    local neighboring = GetNeighboringCenters(brian.x, brian.z, regional_blocks)

    -- local trimmed = {}

    -- local visible_width = width + 80
    -- local visible_height = height + 80

    -- local visible_width_sqr = visible_width * visible_width
    -- local visible_height_sqr = visible_height * visible_height

    -- for _, coord in pairs(neighboring) do
    --     local dx = brian.x - coord.x
    --     local dz = brian.z - coord.z

    --     local within_width = dx * dx < visible_width_sqr
    --     local within_height = dz * dz < visible_height_sqr

    --     if within_width and within_height then
    --         trimmed[#trimmed+1] = coord
    --     end
    -- end

    return neighboring
end

EMPTY_RESULT = {
    colliding = {},
    too_close = 0,
    too_far = 0,
    one_turns = 0,
    two_turns = 0,
    three_turns = 0,
    region_index = -1,
    overlaps = 0
}

local function GetCollidingEncounters(centers, sample_x, sample_z, movement_radius)

    local nothing_here = false
    local region_index = -1
    
    region_index = GetRegionOverlapIndex(sample_x, sample_z)
    if region_index < 0 then
        nothing_here = true
    -- elseif centers == nil or #centers == 0 then
    --     nothing_here = true
    end

    if nothing_here then
        return EMPTY_RESULT
    end

    local too_close = 0
    local too_far = 0
    local one_turns = 0
    local two_turns = 0
    local three_turns = 0
    -- local colliding = {}

    local min_distance_sqr = 50 * 50
    local max_distance_sqr = 90 * 90
    local one_turn_distance_sqr = (100 - movement_radius) * (100 - movement_radius)
    local two_turn_distance_sqr = (100 - 2 * movement_radius) * (100 - 2 * movement_radius)

    local color = "white"

    for _, coord in pairs(centers) do

        local dx = sample_x - coord.x
        local dz = sample_z - coord.z
        local distance_sqr = dx * dx + dz * dz

        if distance_sqr < min_distance_sqr then
            too_close = too_close + 1

        elseif distance_sqr < max_distance_sqr and distance_sqr >= min_distance_sqr then

            if distance_sqr > one_turn_distance_sqr then
                one_turns = one_turns + 1
            elseif distance_sqr > two_turn_distance_sqr then
                two_turns = two_turns + 1
            else
                three_turns = three_turns + 1
            end
            
            -- colliding[#colliding + 1] = coord
        end
    end

    if three_turns > 0 then
        color = "red"
    elseif two_turns > 0 then
        color = "orange"
    elseif one_turns > 0 then
        color = "yellow"
    else
        color = "white"
    end

    return {
        color = color,
        too_close = too_close,
        too_far = too_far,
        one_turns = one_turns,
        two_turns = two_turns,
        three_turns = three_turns,
        region_index = region_index,
        overlaps = one_turns + two_turns + three_turns
    }
end

local function GetOverlapColor(one_turns, two_turns, three_turns, region_index)

    if three_turns > 0 then
        return MAP_COLOR_3_TURNS
    elseif two_turns > 0 then
        return MAP_COLOR_2_TURNS
    elseif one_turns > 0 then
        return MAP_COLOR_1_TURNS
    else
        return MAP_COLOR_NO_ENCOUNTERS
    end
end

local function PrintEncounterGrid(centers, grid_width, grid_height, unit_spacing, starting_row, column_offset)

    local brian = GetBrianLocation()
    local output = {}

    local camera_theta = GetCameraAngle()
    local trimmed_centers = GetTrimmedCenters(cached_regional_blocks, brian, grid_width * unit_spacing, grid_height * unit_spacing)

    local camera_right = TransformDirectionForAngle(1, 0, 0, camera_theta)
    local camera_forward = TransformDirectionForAngle(0, 0, 1, camera_theta)

    local movement_radius = GetMovementRadius()

    local brian_x = brian.x
    local brian_z = brian.z

    -- local camera_right_x = camera_right.x
    -- local camera_right_z = camera_right.z
    -- local camera_forward_x = camera_forward.x
    -- local camera_forward_z = camera_forward.z
        
    local border_width = client.borderwidth();
    local border_height = client.borderheight();
    local screen_width = client.screenwidth();
    local screen_height = client.screenheight();

    -- local center_x = screen_width / 2
    -- local center_z = screen_height / 2

    local center_x = 240
    local center_z = 140

    -- console.log(screen_width)

    local UNITS_TO_PIXELS = 0.2
    local BRIAN_MAP_SIZE = 10

    local navmesh = ReadNavMesh()

    gui.drawEllipse(center_x - BRIAN_MAP_SIZE * UNITS_TO_PIXELS, center_z - BRIAN_MAP_SIZE * UNITS_TO_PIXELS, 10, 10, 0xFF00FFFF)

    for c, circle in pairs(trimmed_centers) do

        local cx = (circle.x - brian_x - 50) * UNITS_TO_PIXELS + center_x
        local cz = (circle.z - brian_z - 50) * UNITS_TO_PIXELS + center_z

        gui.drawEllipse(cx, cz, 100 * UNITS_TO_PIXELS, 100 * UNITS_TO_PIXELS, 0xFFFF0000)
    end

    for k, wall_chain in pairs(navmesh) do

        for vertex = 2, #wall_chain do
            local a_world = wall_chain[vertex - 1]
            local b_world = wall_chain[vertex - 0]
            
            local ax = ((a_world.x - brian_x)) * UNITS_TO_PIXELS + center_x
            local az = ((a_world.z - brian_z)) * UNITS_TO_PIXELS + center_z
            local bx = ((b_world.x - brian_x)) * UNITS_TO_PIXELS + center_x
            local bz = ((b_world.z - brian_z)) * UNITS_TO_PIXELS + center_z

            gui.drawLine(ax, az, bx, bz, 0xFFFFFFFF)
        end
    end

end

local function PrintOverlapFeedback(index)

    local currentTime = os.time()
    local messageDelta = os.difftime(currentTime, encounter_checked_at)
    if (messageDelta * 1000) < ENCOUNTER_FEEDBACK_DURATION_MS then
        
        local result = last_encounter_check_result
        if result ~= nil then
            local feedback = "Checked: " .. Ternary(result.overlaps == 0, "Clear!", result.overlaps .. " Overlaps!")
            local color = GetOverlapColor(result.one_turns, result.two_turns, result.three_turns)
            
            GuiTextCenterWithColor(index, feedback, color)
        end
    end
end

local function WriteCircleCSV(path, data_table)
    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    console.clear()

    for k = 1, #data_table do
        local data = data_table[k]
        if k == 1 then
            console.log(data)
        end
        local line = data.x .. "," .. data.z
        file:write(line .. "\n")
    end

    file:close()
    
    console.log("Wrote data to: " .. path)
end

local function WriteRegionCSV(path, data_table)
    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    for k = 1, #data_table do
        local data = data_table[k]
        console.log(data)
        local line = data.x .. "," .. data.z .. "," .. data.w .. "," .. data.d
        file:write(line .. "\n")
    end

    file:close()
    
    console.log("Wrote data to: " .. path)
end

local function WriteEncounterInfoToCSVs(circles, regions)
    local map, submap = GetMapIDs()

    local path_circles = "data/" .. map .. "-" .. submap .. "-circles"
    local path_regions = "data/" .. map .. "-" .. submap .. "-regions"

    WriteCircleCSV(path_circles, circles)
    WriteRegionCSV(path_regions, regions)
end


local previous_keys = {}
local function ProcessKeyboardInput()

    local keys = input.get()

    if keys["Space"] == true and previous_keys["Space"] ~= true then
        WriteEncounterInfoToCSVs(current_encounter_centers, cached_regions)
    end

    previous_keys = input.get()
end

while true do

    local centers = GetLocalEnounterInfo()

    if centers ~= nil then
        if ENCOUNTER_FEEDBACK_ENABLED then
            PrintOverlapFeedback(ENCOUNTER_FEEDBACK_ANCHOR_Y)
        end
        PrintEncounterGrid(centers, MAP_GRID_WIDTH, MAP_GRID_HEIGHT, MAP_GRID_UNIT_SPACING, MAP_ANCHOR_Y, MAP_ANCHOR_X)
    end

    ProcessKeyboardInput()
    gui.drawLine(20, 40, 28, 48, 0xFFFF0000) -- RED
    -- Test 4: Diagonal line (45deg angle), width of 1px
    gui.drawLine(48, 40, 40, 48, 0xFFFFFFFF) -- RED

    emu.frameadvance()
end
