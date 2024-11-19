local PrevRNG = 0
local PrevRNG2 = 0
local PrevRNG3 = 0
local RNGTableGlobal = {}

local MEM_AGI_XP = 0x7BAAD
local MEM_AGI_TOWN = 0x7BC1C
local MEM_AGI_FIELD = 0x7BC18
local MEM_AGI_BATTLE = 0x7BCA0

local MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
local MEM_ENCOUNTER_ACCUMULATION = 0x8C578
local MEM_CAMERA_ROTATION_Y = 0x86DE8
local MEM_GAME_STATE = 0x7B2E4
local MEM_ALLOW_BATTLES = 0x084F10
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4

local MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
local MEM_ENCOUNTER_ACCUMULATION = 0x8C578

local COLOR_FOR_NEXT_ENCOUNTER = true

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 160 + 100

-- Working Variables
local current_map = -1
local current_submap = -1
local current_encounter_centers = {}
local cached_regional_blocks = {}

local encounter_checked_at = 0
local last_step_distance = 0
local last_encounter_check_result = nil

local keep_checking_for = 5
local cached_regions = {}
local cached_encounter_presets = {}

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

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

local function GetEncounterRegionsFromMemory()

    local battles_allowed = AreBattlesAllowed()
    if not battles_allowed then
        return {}, {}
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

    -- The region start pointer will have an address after 12 bytes,
    -- which is the thing we want.
    --
    local ptr_region_data = GetPointerFromAddress(0x08C560)
    local ptr_preset_definitions = ptr_region_data + 12

    local ptr_preset_metadata_start = GetPointerFromAddress(ptr_preset_definitions)
    local ptr_preset_metadata_start_raw = memory.read_u32_be(ptr_preset_definitions, "RDRAM")
    local presets = {}

    local ptr_preset_metadata_index = ptr_preset_metadata_start
    local ptr_preset_metadata_index_raw = ptr_preset_metadata_start_raw

    local total_found = 0
    local found_next_pack = true
    while found_next_pack do
        local ptr_preset_start = GetPointerFromAddress(ptr_preset_metadata_index)
        local unique_enemy_count = memory.read_u16_be(ptr_preset_metadata_index + 4, "RDRAM")
        
        total_found = total_found + 1

        local pack_info = {}
        local ptr_unique_enemy_block = ptr_preset_start

        for k = 1, unique_enemy_count do
            
            local enemy_index = memory.read_u32_be(ptr_unique_enemy_block, "RDRAM")
            local min_amount = memory.read_u32_be(ptr_unique_enemy_block + 4, "RDRAM")
            local extra_amount = memory.read_u32_be(ptr_unique_enemy_block + 8, "RDRAM")

            console.log("[" .. k .. "]: " .. enemy_index .. ", " .. min_amount .. ", " .. extra_amount)

            local pack = {
                enemy_index = memory.read_u32_be(ptr_unique_enemy_block, "RDRAM"),
                min_amount = memory.read_u32_be(ptr_unique_enemy_block + 4, "RDRAM"),
                extra_amount = memory.read_u32_be(ptr_unique_enemy_block + 8, "RDRAM"),
            }

            ptr_unique_enemy_block = ptr_unique_enemy_block + 12
            pack_info[#pack_info+1] = pack

            -- console.log(pack)
        end

        presets[#presets+1] = {
            enemy_count = unique_enemy_count,
            pack_info = pack_info
        }

        ptr_preset_metadata_index = ptr_preset_metadata_index + 8
        ptr_preset_metadata_index_raw = memory.read_u32_be(ptr_preset_metadata_index, "RDRAM")
        local next_unique_count = memory.read_u16_be(ptr_preset_metadata_index + 4, "RDRAM")

        if ptr_preset_metadata_index_raw < 0x80000000 or next_unique_count > 13 then
            found_next_pack = false
        end
    end

    return regions, presets
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

local function IsGameBusy()
    local state = memory.read_u32_be(MEM_GAME_STATE, "RDRAM")
    return state ~= 0
end 


local check_for_regions = true

local function GetLocalEnounterRegions()
    local map, submap = GetMapIDs()
    
    local game_busy = IsGameBusy()
    if game_busy then
        return cached_regions, cached_encounter_presets
    end

    if map ~= current_map or submap ~= current_submap then
        check_for_regions = true
    end

    if check_for_regions and not game_busy then

        cached_regions, cached_encounter_presets = GetEncounterRegionsFromMemory()
        check_for_regions = false
    end

    current_map = map
    current_submap = submap

    return cached_regions, cached_encounter_presets
end


local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

local function GuiTextColor(row_index, text, color)
    GuiTextWithColor(row_index, text, color)
end

local function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

local function GuiTextRightColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text, color)
end


local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GetEncounterAccumulation()
    return memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM")
end

local function GetNextRNG(currentRNG)
    local A1 = memory.read_u16_be(0x22FE2, "RDRAM")
    local B1 = memory.read_u16_be(0x22FE4, "RDRAM") - 1000
    local C1 = memory.read_u16_be(0x22FE6, "RDRAM")

    local R_HI1 = math.floor(currentRNG / 0x10000)
    local R_LO1 = currentRNG % 0x10000

    local R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    local R_HI2 = R_HI2 % 65536
    local R_LO2 = R_LO1 * C1 + B1 -- 16,16,16

    return (65536 * R_HI2 + R_LO2) % 0x100000000

    -- return (currentRNG * 0x41C64E6D + 0x3039) % 0x100000000
end

local function GetFutureRNG(seed, advances)
    local future = seed
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function SimulateRNGCall(rng, bound)
    local checkBase = math.floor(rng / 0x10000)
    local rollValue = checkBase % bound

    return rollValue
end

local function SimulateSingleRNGCall(rng, bound)
    local checkBase = math.floor(rng / 0x10000)
    local rollValue = checkBase % bound

    local next_seed = GetFutureRNG(rng, 1)

    return rollValue, next_seed
end

local function SimulateEncounterRoll(seed)
   
    local brian = GetBrianLocation()
    local region_data, encounter_presets = GetLocalEnounterRegions()
    local region_index = GetRegionOverlapIndex(brian.x, brian.z)
    
    if region_index == -1 then
        return {
            total_enemies = 0,
            enemy_ids = {},
            pack = {}
        }
    end

    -- We roll for the encounter distance and a circle
    -- prior to checking for a an encounter preset
    --
    -- Distance Check
    -- Circle Check
    -- AABB Check
    -- Encounter Index Check
    --
    local encounter_preset_seed = GetFutureRNG(seed, 2)
    -- local encounter_preset_seed = seed

    local encounter_indices = region_data[region_index].encounters
    local total_encounter_presets = #encounter_indices
    local random_encounter_index = SimulateRNGCall(encounter_preset_seed, total_encounter_presets)

    local encounter_preset_index = encounter_indices[random_encounter_index + 1]
    local encounter_preset = encounter_presets[encounter_preset_index + 1]

    -- console.log(region_index)
    -- console.log(encounter_indices)
    -- console.log("Presets:")
    -- console.log(encounter_presets)
    -- console.log("Preset Index:")
    -- console.log(encounter_preset_index)

    if encounter_preset == nil then
        return {
            total_enemies = 0,
            enemy_ids = {},
            pack = {}
        }
    end

    local pack_seed = GetFutureRNG(encounter_preset_seed, 1)
    local pack_info = encounter_preset.pack_info

    -- console.log("Pack Info:")
    -- console.log(pack_info[1])

    local total_enemies = 0
    local enemy_ids = {}

    for k = 1, encounter_preset.enemy_count do

        local pack = pack_info[k]
        local amount = pack.min_amount
        local variance = pack.extra_amount

        if variance > 0 then
            local extra, pack_seed = SimulateSingleRNGCall(pack_seed, variance + 1)
            amount = amount + extra
        end

        for _ = 1, amount do
            enemy_ids[#enemy_ids + 1] = pack.enemy_index
        end

        total_enemies = total_enemies + amount
    end 

    local result = {
        total_enemies = total_enemies,
        enemy_ids = enemy_ids,
        pack = pack_info
    }

    return result
end

local function CheckIfEncounterWillTriggerForSeed(seed, futureIndex)

    local rng = GetFutureRNG(seed, futureIndex)

    local currentAccumulation = GetEncounterAccumulation() + 50 * futureIndex
    local encounterRoll = SimulateRNGCall(rng, 2000)

    return rng, encounterRoll < currentAccumulation, encounterRoll, currentAccumulation
end

local function CheckSeedRollFrom100(seed, futureIndex)

    local rng = GetFutureRNG(seed, futureIndex)
    local roll = SimulateRNGCall(rng, 100)

    return rng, roll
end

local function GetCurrentRNG()
    return memory.read_u32_be(0x04D748, "RDRAM")
end

local function PrintRNG(rng, duration)
    return string.format("%08X ", rng) .. "- " .. duration
end

cacheTable = {}

local function appendHistory(table, newValue, historyLength)
    
    for key, value in pairs(table) do

        if key <= historyLength then
            cacheTable[key+1] = value
        end
    end
    
    for key, value in pairs(cacheTable) do
        table[key] = cacheTable[key]
    end

    table[0] = newValue

    return table
end

local function PrintPreviewSeedInfo(row, previewIndex, seed, GuiFunction)

    local rng, willTrigger, roll, accumulation = CheckIfEncounterWillTriggerForSeed(seed, previewIndex)

    local color = "white"
    if COLOR_FOR_NEXT_ENCOUNTER then
        local accumulation = memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION)
        if roll < GetEncounterAccumulation() + 50 then
            color = "cyan" 
        else
            color = "gray"
        end

    end

    local rngString = string.format("%08X ", rng)
    local indexString = string.format("%02d", previewIndex)

    local future_seed = GetFutureRNG(seed, previewIndex)
    local result = SimulateEncounterRoll(future_seed)
    -- local battleString = table.concat(result.enemy_ids, ",")
    local battleString = Ternary(AreBattlesAllowed() and willTrigger, table.concat(result.enemy_ids, ","), " ")

    -- GuiFunction(row, string.format("%s: %s-> %04s %s", indexString, rngString, roll, battleString), color)
    GuiFunction(row, string.format("%s: %s-> %s", indexString, rngString, battleString), color)
end

local function PrintRNGStream(index, historyLength, previewLength, onLeft)

    local duration = 0
    local previousRNG = GetCurrentRNG()

    local nextRNG = GetFutureRNG(previousRNG, 1)

    console.clear()

    local result = SimulateEncounterRoll(previousRNG)

    console.log(result)
    console.log(table.concat(result.enemy_ids, ","))

    local table = {}
    local GuiFunction = Ternary(onLeft, GuiTextColor, GuiTextRightColor)

    while true do

        local currentRNG = memory.read_u32_be(0x04D748, "RDRAM")
        
        if currentRNG == previousRNG then 
            duration = duration + 1
        else
            
            local entry = PrintRNG(previousRNG, duration)
            table = appendHistory(table, entry, historyLength)

            duration = 1
        end

        GuiFunction(index, PrintRNG(currentRNG, duration))

        for key, value in pairs(table) do
            GuiFunction(index + key + 1 + 1, "" .. value)
        end
        
        for previewIndex=1, previewLength do
            PrintPreviewSeedInfo(index - previewIndex - 1, previewIndex, currentRNG, GuiFunction)   
        end        
        
        emu.frameadvance()

        previousRNG = currentRNG
    end
end

local function main()
    PrintRNGStream(40, 5, 35, false)
    -- PrintRNGStream(20, 5, 5, false)
    -- PrintRNGStream(28, 5, 30, true)
end

main()
