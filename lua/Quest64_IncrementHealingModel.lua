
local MEM_HEALING_1_MODEL = 0x0C2888

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local function GetHealingModel()
    return memory.read_u16_be(MEM_HEALING_1_MODEL, "RDRAM")
end

local function IncrementHealingModel(delta)
    local current = GetHealingModel()
    memory.write_u16_be(MEM_HEALING_1_MODEL, current + delta, "RDRAM")
end

function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function ProcessKeyboardInput()

    local keys = input.get()

    if keys["PageUp"] == true and previous_keys["PageUp"] ~= true then
        IncrementHealingModel( 1)
    end

    if keys["PageDown"] == true and previous_keys["PageDown"] ~= true then
        IncrementHealingModel(-1)
    end

    previous_keys = input.get()
end

while true do

    ProcessKeyboardInput()

    local current_model = GetHealingModel()
    GuiTextCenterWithColor(10, string.format("Healing Model: %8X", current_model), "white")

    emu.frameadvance()

end