local MEM_SPIRIT_INFO_START = 0x86A00

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
        return true, -1, -1
    end
    
    local actual_countdown = memory.read_u16_be(state_address + 2, "RDRAM")
    if actual_countdown > 0xFF00 then
        local tick_timer = 6 + 0xFFFF - actual_countdown
        return false, tick_timer, actual_countdown
    else
        local tick_timer = 6 - actual_countdown
        return false, tick_timer, actual_countdown
    end
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

local duration_min = 9999
local duration_max = 0

local previous_values = {}

while true do

    GuiText(18, "Spirit Timers:")
    GuiText(19, "--------------")

    local total_spirits = GetTotalSpiritsInArea()
    for k = 1, total_spirits do

        local collected, duration, raw_value  = GetSpiritDurationRemaining(k)

        if previous_values[k] ~= nil then
            
            local previous_value = previous_values[k]
            local value_increased = previous_value < duration
            if value_increased then
                if duration < duration_min then
                    duration_min = duration
                end

                if duration > duration_max then
                    duration_max = duration
                end
            end
        end

        previous_values[k] = duration


        local duration_str = string.format("%04X -> %02d", raw_value, duration) .. "|" .. string.rep("=", duration) .. string.rep(" ", 100 - duration) .. "|"
        local info_str = Ternary(collected, "Collected!", duration_str)
        local text = string.format("%d: " .. info_str, k)
        
        GuiText(19 + k, text)
    end
    
    GuiText(25, string.format("Observed Duration Range: %02d - %02d", duration_min, duration_max))
    
    emu.frameadvance()
end