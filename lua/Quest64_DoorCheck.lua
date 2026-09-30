local MEM_PTR_MAP_DATA_MAIN = 0x084F18
local MEM_PTR_MAP_DATA_DOORS = 0x084F1C
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
    local first_hex_block = memory.read_u32_be(data.ptr_region_start, "RDRAM")

    console.log(string.format("%08X -> %s Total Regions, start: %08X", data.ptr_region_start, data.total_regions, first_hex_block))
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

local function ReadDoorsFromMemory()

    local ptr_map_door_data = GetPointerFromAddress(MEM_PTR_MAP_DATA_DOORS)

    local ptr_door_start = GetPointerFromAddress(ptr_map_door_data + 0x4)
    local door_count = memory.read_u32_be(ptr_map_door_data + 0x8, "RDRAM")

    local door_block_size = 0x24
    local doors = {}

    -- console.log(string.format("Map Door Data: %08X", ptr_map_door_data))
    -- console.log(string.format("Map Door Count: %08X", door_count))
    -- console.log(string.format("Map First Door: %08X", ptr_door_start))

    local door_index = 0
    
    while door_index < door_count do

        local door_addr = ptr_door_start + door_index * door_block_size
        
        -- console.log(string.format("Door %d: %08X", door_index, ptr_door_start + door_index * door_block_size))

        local door = {
            x = memory.readfloat(door_addr + 0x0, true, "RDRAM"),
            z = memory.readfloat(door_addr + 0x4, true, "RDRAM"),
            angle = memory.readfloat(door_addr + 0x8, true, "RDRAM"),
            size_x = memory.readfloat(door_addr + 0xC, true, "RDRAM"),
            size_z = memory.readfloat(door_addr + 0x10, true, "RDRAM"),
            
            flags_1 = memory.read_u32_be(door_addr + 0x14, "RDRAM"),
            flags_2 = memory.read_u32_be(door_addr + 0x18, "RDRAM"),
            flags_3 = memory.read_u16_be(door_addr + 0x1C, "RDRAM"),

            to_map = memory.read_u16_be(door_addr + 0x1E, "RDRAM"),
            to_submap = memory.read_u16_be(door_addr + 0x20, "RDRAM"),
            to_door = memory.read_u16_be(door_addr + 0x22, "RDRAM"),
        }

        doors[#doors+1] = door
        door_index = door_index + 1
    end

    return doors
end


local function GetBrianLocation()
    local x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local z = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")

    return { x=x, y=y, z=z }
end


local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60


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

local busy_timeout = 60
local busy_duration = 0
local previous_map, previous_submap = -1, -1

local logged_map, logged_submap = -1, -1

while true do

    local map, submap = GetMapIDs()    
    local doors = ReadDoorsFromMemory()

    GuiTextRight(3, string.format("X       Z       W     D        "))

    for door_index, door in pairs(doors) do
        GuiTextRight(door_index + 4, string.format("%06.1f, %06.1f, %04.1f, %04.1f", door.x, door.z, door.size_x, door.size_z))
    end

    emu.frameadvance()
end
