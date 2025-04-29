local MEM_EXIT_CONDITION_A = 0x84EE0
local MEM_EXIT_CONDITION_B = 0x84F04
local MEM_EXIT_CONDITION_C = 0x84F1C
local MEM_EXIT_CONDITION_D = 0x84EE4
local MEM_EXIT_CONDITION_E = 0x84EE4

local MEM_RETURN_CONDITION_A = 0x84EE0
local MEM_RETURN_CONDITION_B = 0x84EF8
local MEM_RETURN_CONDITION_C = 0x84F1C

local MEM_WINGS_CONDITION_A = 0x84EE0
local MEM_WINGS_CONDITION_B = 0x84F1C

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function CanCastReturn()
    local a_val = memory.read_u16_be(MEM_RETURN_CONDITION_A, "RDRAM")
    local b_val = memory.read_u32_be(MEM_RETURN_CONDITION_B, "RDRAM")
    local c_ptr = GetPointerFromAddress(MEM_RETURN_CONDITION_C)
    local c_val = memory.read_u16_be(c_ptr + 0x14, "RDRAM")

    local a = a_val == 4
    local b = b_val ~= -1
    local c = not (bit.band(c_val, 0x4) > 0)

    return a and b and c
end

-- https://decomp.me/scratch/dUocd
local function CanUseWings()
    local a_val = memory.read_u16_be(MEM_WINGS_CONDITION_A, "RDRAM")
    local b_ptr = GetPointerFromAddress(MEM_WINGS_CONDITION_B)
    local b_val = memory.read_u16_be(b_ptr + 0x14, "RDRAM")

    local a = bit.band(a_val, 0xA) ~= 0
    local b = bit.band(b_val, 0x4) ~= 0

    if a or b then
        return false
    else
        return true
    end
end

local function CanCastExit()
    local a_val = memory.read_u16_be(MEM_EXIT_CONDITION_A, "RDRAM")
    local b_val = memory.read_u32_be(MEM_EXIT_CONDITION_B, "RDRAM")
    local c_ptr = GetPointerFromAddress(MEM_EXIT_CONDITION_C)
    local c_val = memory.read_u16_be(c_ptr + 0x14, "RDRAM")
    local d_val = memory.read_u32_be(MEM_EXIT_CONDITION_D, "RDRAM")
    local e_val = memory.read_u32_be(MEM_EXIT_CONDITION_E, "RDRAM")

    local a = bit.band(a_val, 0x8) > 0
    local b = b_val ~= -1
    local c = not (bit.band(c_val, 0x8) > 0)
    local d = d_val ~= 0x1E
    local e = e_val ~= 0x22

    return a and b and c and d and e
end

local function ShowInfo(index)

    local can_exit = CanCastExit()
    local can_return = CanCastReturn()
    local can_wings = CanUseWings()

    GuiTextWithColor(index + 0, "Can Exit:   " .. Ternary(can_exit, "Yes", "No"), Ternary(can_exit, "cyan", 0xAAAAAAAA))
    GuiTextWithColor(index + 1, "Can Return: " .. Ternary(can_return, "Yes", "No"), Ternary(can_return, "cyan", 0xAAAAAAAA))
    GuiTextWithColor(index + 2, "Can Wings:  " .. Ternary(can_wings, "Yes", "No"), Ternary(can_wings, "cyan", 0xAAAAAAAA))
end

while true do

    ShowInfo(0)
    emu.frameadvance()
end
