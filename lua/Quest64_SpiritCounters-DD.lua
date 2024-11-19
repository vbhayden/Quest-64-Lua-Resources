local MEM_SPIRIT_INFO_START = 0x86A00

local function GetNPCTimerInfo(map, submap)
    -- I have no clue how to determine these locations through
    -- the actual map info / pointers.  For the sake of getting
    -- something working, I've just added in the addresses and
    -- observed reset durations for each wandering npc.
    --
    -- Melrode Town
    if map == 0 and submap == 0 then
        return {
            {
                -- Farmer
                name = "Farmer",
                address = 0x07BDB4,
                rest_duration = 0x96
            },  
            {
                -- Sheep 1
                name = "Sheep1",
                address = 0x07C1D4,
                rest_duration = 0x94
            },  
            {
                -- Sheep 2
                name = "Sheep2",
                address = 0x07C258,
                rest_duration = 0x94
            },
        }
    -- Pat's room with the chest
    elseif map == 13 and submap == 7 then
        return {
            {
                -- Pat, the bread giver
                name = "Pat",
                address = 0x07BD30,
                rest_duration = 0X3C
            }
        }
    -- Librarian room when starting game
    elseif map == 13 and submap == 15 then
        return {
            {
                -- Gelis, the librarian
                name = "Gelis",
                address = 0x07BD30,
                rest_duration = 0X95
            }
        }
    end

    return nil
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function GetSpiritDurationRemaining(index)

    local block_size = 6 * 4
    local state_address = 4 + MEM_SPIRIT_INFO_START + (index) * block_size - 4
    local status = memory.read_u16_be(state_address, "RDRAM")

    if status > 0 then
        return true, -1
    end
    
    local countdown = memory.read_u16_be(state_address + 2, "RDRAM")
    if countdown > 0xFF00 then
        return false, 6 + 0xFFFF - countdown
    else
        return false, 6 - countdown
    end
end

local function GetNPCAnimationRemaining(address, rest_duration)

    local state = memory.read_u16_be(address, "RDRAM")
    local value = memory.read_u16_be(address + 2, "RDRAM")

    if state >= 1 then
        return value + rest_duration
    end

    return value
end

local function GetTotalSpiritsInArea()
    return memory.read_u32_be(MEM_SPIRIT_INFO_START, "RDRAM")
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 200 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

while true do

    local index = 18
    GuiText(index, "Spirit Timers:")
    GuiText(index + 1, "--------------")

    local total_spirits = GetTotalSpiritsInArea()
    for k = 1, total_spirits do

        local collected, duration = GetSpiritDurationRemaining(k)

        local duration_str = "|" .. string.rep("=", duration) .. string.rep(" ", 100 - duration) .. "|"
        local info_str = Ternary(collected, "Collected!", duration_str)
        local text = string.format("%d: " .. info_str, k)
        
        GuiText(19 + k, text)
    end

    index = index + 3 + total_spirits


    GuiText(index + 1, "NPC Timers:")
    GuiText(index + 2, "--------------")

    local map, submap = GetMapIDs()
    local npc_timers = GetNPCTimerInfo(map, submap)

    if npc_timers ~= nil then
        for k = 1, #npc_timers do

            local info = npc_timers[k]
            local duration = info

            local duration = GetNPCAnimationRemaining(info.address, info.rest_duration)

            local duration_displayed = duration / 3
    
            local duration_str = string.format("%03d|" .. string.rep("=", duration_displayed) .. string.rep(" ", 100 - duration_displayed) .. "|", duration)
            local info_str = Ternary(collected, "Collected!", duration_str)
            local text = string.format("%6s: " .. info_str, info.name)
            
            GuiText(index + 2 + k, text)
        end
    end
    
    emu.frameadvance()
end