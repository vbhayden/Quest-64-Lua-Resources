local MEM_PTR_MAP_DATA_DOORS = 0x084F1C
local MEM_PTR_MAP_DATA_DOORS = 0x084F1C

local MEM_CURRENT_MAP_ID = 0x084EE4
local MEM_CURRENT_SUBMAP_ID = 0x084EE8

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local EncounterCheckedAt = 0
local LastStepDistance = 0

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
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

local function Trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GuiTextCenter(row_index, text, color)
    return GuiTextCenterWithColor(row_index, text, "white")
end

local function GetMapIDs()
    local mapID = memory.read_u32_be(MEM_CURRENT_MAP_ID, "RDRAM")
    local subMapID = memory.read_u32_be(MEM_CURRENT_SUBMAP_ID, "RDRAM")

    return mapID, subMapID
end

local last_log = ""
local function PrintMerrowValues(index)

    local ptr_data = GetPointerFromAddress(MEM_PTR_MAP_DATA_DOORS)
    local nearby_ptr = memory.read_u32_be(ptr_data + 0xC, "RDRAM")
    local monster_table_index = memory.read_u16_be(ptr_data + 0x12, "RDRAM")

    local unk0 = memory.read_u32_be(ptr_data + 0x0, "RDRAM")
    local unk4 = memory.read_u32_be(ptr_data + 0x4, "RDRAM")
    local unk8 = memory.read_u32_be(ptr_data + 0x8, "RDRAM")
    local unkC = memory.read_u32_be(ptr_data + 0xC, "RDRAM")
    local unk10 = memory.read_u16_be(ptr_data + 0x10, "RDRAM")
    local unk12 = memory.read_u16_be(ptr_data + 0x12, "RDRAM")
    local unk14 = memory.read_u32_be(ptr_data + 0x14, "RDRAM")
    
    local log = string.format("%08X,%08X,%08X,%08X,%04X,%04X,%08X",unk0, unk4, unk8, unkC, unk10, unk12, unk14)

    
    -- local ptr_region_data = GetPointerFromAddress(0x08C560)
    -- local ptr_region_start = GetPointerFromAddress(ptr_region_data)
    -- local total_regions = GetPointerFromAddress(ptr_region_data + 4)

    -- local log = total_regions .. " Regions:"

    -- for k=0, total_regions-1 do
    --     local region_addr = ptr_region_start + 0x18 * k

    --     local xmin = memory.read_u16_be(region_addr + 0x0, "RDRAM")
    --     local xmax = memory.read_u16_be(region_addr + 0x2, "RDRAM")
    --     local zmin = memory.read_u16_be(region_addr + 0x4, "RDRAM")
    --     local zmax = memory.read_u16_be(region_addr + 0x6, "RDRAM")
    --     local preset_count = memory.read_u16_be(region_addr + 0x8, "RDRAM")
    --     local preset_1 = memory.read_u16_be(region_addr + 0xA, "RDRAM")
    --     local preset_2 = memory.read_u16_be(region_addr + 0xC, "RDRAM")
    --     local preset_3 = memory.read_u16_be(region_addr + 0xE, "RDRAM")
    --     local preset_4 = memory.read_u16_be(region_addr + 0x10, "RDRAM")
    --     local preset_5 = memory.read_u16_be(region_addr + 0x12, "RDRAM")
    --     local preset_6 = memory.read_u16_be(region_addr + 0x14, "RDRAM")
    --     local preset_7 = memory.read_u16_be(region_addr + 0x16, "RDRAM")
        
    --     log = log .. "\n" .. string.format("%08X,%04X,%04X,%04X,%04X,%04X,%04X,%04X,%04X,%04X,%04X,%04X,%04X", region_addr, xmin, xmax, zmin, zmax, preset_count, preset_1, preset_2, preset_3, preset_4, preset_5, preset_6, preset_7)
    -- end

    if log ~= last_log then
        console.log(log)
    end
    GuiTextCenter(5, log, "white")

    last_log = log
end

while true do

    PrintMerrowValues()
    emu.frameadvance()
end