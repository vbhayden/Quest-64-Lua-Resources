MEM_AGI_XP = 0x7BAAD
MEM_AGI_TOWN = 0x7BC1C
MEM_AGI_FIELD = 0x7BC18
MEM_AGI_BATTLE = 0x7BCA0

MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
MEM_ENCOUNTER_ACCUMULATION = 0x8C578

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 200 + row_index * 15, text, color)
end

function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

function GetEncounterSteps()
    return memory.readfloat(MEM_ENCOUNTER_STEP_DISTANCE, true, "RDRAM")
end

function GetEncounterAccumulation()
    return memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM")
end

function PrintAgility(index)

    local agiXP = "Agi XP: " memory.readbyte(MEM_AGI_XP, "RDRAM")
    local townAgi = "Town Agi:   " .. Round(memory.readfloat(MEM_AGI_TOWN, true, "RDRAM"), 4) .. " / 2000"
    local fieldAgi = "Field Agi:  " .. Round(memory.readfloat(MEM_AGI_FIELD, true, "RDRAM"), 4) .. " / 1000"
    local battleAgi = "Battle Agi: " .. Round(memory.readfloat(MEM_AGI_BATTLE, true, "RDRAM"), 4) .. " / 50"

    local stepDistance = "Trigger Steps: " .. Round(GetEncounterSteps(), 0) .. " / 50"
    local stepAccumulation = "Trigger Hist:  " .. Round(GetEncounterAccumulation(), 0) .. " / 2000"

    GuiText(index + 0, agiXP)
    GuiText(index + 2, townAgi)
    GuiText(index + 3, fieldAgi)
    GuiText(index + 4, battleAgi)

    GuiText(index + 6, stepDistance)
    GuiText(index + 7, stepAccumulation)
end

while true do

    PrintAgility(1)

    emu.frameadvance()
end