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
        return true, -1
    end
    
    local countdown = memory.read_u16_be(state_address + 2, "RDRAM")
    if countdown > 0xFF00 then
        return false, 6 + 0xFFFF - countdown
    else
        return false, 6 - countdown
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

while true do

    GuiText(18, "Spirit Timers:")
    GuiText(19, "--------------")

    local total_spirits = GetTotalSpiritsInArea()
    for k = 1, total_spirits do

        local collected, duration = GetSpiritDurationRemaining(k)

        local duration_str = "|" .. string.rep("=", duration) .. string.rep(" ", 100 - duration) .. "|"
        local info_str = Ternary(collected, "Collected!", duration_str)
        local text = string.format("%d: " .. info_str, k)
        
        GuiText(19 + k, text)
    end
    
    emu.frameadvance()
end