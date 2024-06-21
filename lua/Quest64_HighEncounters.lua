MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
MEM_ENCOUNTER_ACCUMULATION = 0x8C578

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

function Trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

function GuiTextCenter(row_index, text, color)
    return GuiTextCenterWithColor(row_index, text, "white")
end

function HighEncounters()
    memory.write_u16_be(MEM_ENCOUNTER_ACCUMULATION, 1999, "RDRAM")
    memory.writefloat(MEM_ENCOUNTER_STEP_DISTANCE, 49.95, true, "RDRAM")
end

function PrintStepTracker()
    
    local encounterCount = memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM");
    local encounterAttempts = encounterCount / 50
    local encounterChance = (encounterAttempts + 1) * 2.5

    local stepDistance = Round(memory.readfloat(MEM_ENCOUNTER_STEP_DISTANCE, true, "RDRAM"), 1)
    local stepColor = "white"

    local stepDivisor = 2.5
    local blockCount = 50 / stepDivisor

    local progress = Round(stepDistance / stepDivisor, 0);
    
    GuiTextCenterWithColor(0, "Encounter Chance: " .. encounterChance .. "%", "white")
    GuiTextCenterWithColor(1, "|" .. string.rep("=", progress) .. string.rep(" ", blockCount - progress) .. "|" , stepColor)
    
    return 3
end

while true do

    HighEncounters()
    PrintStepTracker()
    
    emu.frameadvance()
end
