PrevRNG = 0
PrevRNG2 = 0
PrevRNG3 = 0
RNGTableGlobal = {}

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

function getNextRNG(passedRNG)
    local A1 = memory.read_u16_be(0x22FE2, "RDRAM")
    local B1 = memory.read_u16_be(0x22FE4, "RDRAM") - 1000
    local C1 = memory.read_u16_be(0x22FE6, "RDRAM")

    local R_HI1 = math.floor(passedRNG / 0x10000)
    local R_LO1 = passedRNG % 0x10000

    local R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    local R_HI2 = R_HI2 % 65536
    local R_LO2 = R_LO1 * C1 + B1 -- 16,16,16
    passedRNG = (65536 * R_HI2 + R_LO2) % 0x100000000

    return passedRNG
end

function PrintRNG(index)
    local RNG1 = memory.read_u32_be(0x04D748, "RDRAM")
    local Next1RNG = getNextRNG(RNG1)
    local Next2RNG = getNextRNG(Next1RNG)
    local Next3RNG = getNextRNG(Next2RNG)

    -- gui.text(400,490,"NextLo: " .. string.format("%08X ",R_LO2))
    -- gui.text(400,505,"NextHi: " .. string.format("%08X ",R_HI2))
    GuiTextRight(index + 0,  "Current RNG: " .. string.format("%08X ", RNG1))
    GuiTextRight(index + 1, "Next RNG 1:  " .. string.format("%08X ", Next1RNG))
    GuiTextRight(index + 2, "Next RNG 2:  " .. string.format("%08X ", Next2RNG))
    GuiTextRight(index + 3, "Next RNG 3:  " .. string.format("%08X ", Next3RNG))

    if RNGTableGlobal[1] ~= nil then
        for i = 1, 10000 do
            if RNG1 == RNGTableGlobal[i] then
                GuiTextRight(index + 6 + i, "RNG Increment: " .. i)
                i = 1000000
            end
        end
    end
end

while true do

    PrintRNG(5)

    emu.frameadvance()
end