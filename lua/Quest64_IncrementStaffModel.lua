
local MEM_STAFF_SLOT_ADDR = 0x206054
local MEM_STAFF_SLOT_DEFAULT = 0X8020BFE0
-- local MEM_MODELS_START = 0x206000  -- BRIAN
local MEM_MODELS_START = 0X2B0C34  -- ?

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local current_index = 0
local current_model_ptr = MEM_STAFF_SLOT_DEFAULT
local model_count = 0
local known_models = {}

local function Init()
    local iteration = 0
    local acceptable_dead_spots = 20
    local found_dead_spots = 0
    
    console.clear()
    
    while found_dead_spots < acceptable_dead_spots do
        local ptr = memory.read_u32_be(MEM_MODELS_START + iteration * 4, "RDRAM")

        console.log(string.format("%02s: %08X", iteration, ptr))

        if ptr > 0 and bit.band(ptr, 0x80000000) > 0 then
            known_models[#known_models + 1] = ptr
            model_count = model_count + 1

            if ptr == MEM_STAFF_SLOT_DEFAULT then
                current_index = model_count - 1
            end
        else
            found_dead_spots = found_dead_spots + 1
        end

        iteration = iteration + 1
    end

    console.log(known_models)
end

local function GetStaffModel()
    return memory.read_u32_be(MEM_STAFF_SLOT_ADDR, "RDRAM")
end

local function IncrementStaffModel(delta)
    local adjusted = current_index + delta
    local new_index = adjusted

    if new_index >= model_count then
        new_index = model_count - 1
    elseif new_index < 0 then
        new_index = 0
    end

    local new_model_address = known_models[new_index + 1]
    memory.write_u32_be(MEM_STAFF_SLOT_ADDR, new_model_address, "RDRAM")

    console.log(string.format("New Model: %08X", new_model_address))

    current_index = new_index
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
        IncrementStaffModel( 1)
    end

    if keys["PageDown"] == true and previous_keys["PageDown"] ~= true then
        IncrementStaffModel(-1)
    end

    previous_keys = input.get()
end

Init()

while true do

    ProcessKeyboardInput()

    local current_model = GetStaffModel()
    GuiTextCenterWithColor(10, string.format("Current Index: %s", current_index), "white")
    GuiTextCenterWithColor(11, string.format("Staff Model: %8X", current_model), "white")

    emu.frameadvance()

end