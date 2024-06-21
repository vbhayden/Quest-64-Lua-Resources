PrevRNG = 0
PrevRNG2 = 0
PrevRNG3 = 0
RNGTableGlobal = {}

MEM_AGI_XP = 0x7BAAD
MEM_AGI_TOWN = 0x7BC1C
MEM_AGI_FIELD = 0x7BC18
MEM_AGI_BATTLE = 0x7BCA0

MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
MEM_ENCOUNTER_ACCUMULATION = 0x8C578

local COLOR_FOR_NEXT_ENCOUNTER = true

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 160 + 100

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

local function GuiTextColor(row_index, text, color)
    GuiTextWithColor(row_index, text, color)
end

local function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

local function GuiTextRightColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text, color)
end


local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GetEncounterAccumulation()
    return memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM")
end

local function GetNextRNG(currentRNG)
    local A1 = memory.read_u16_be(0x22FE2, "RDRAM")
    local B1 = memory.read_u16_be(0x22FE4, "RDRAM") - 1000
    local C1 = memory.read_u16_be(0x22FE6, "RDRAM")

    local R_HI1 = math.floor(currentRNG / 0x10000)
    local R_LO1 = currentRNG % 0x10000

    local R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    local R_HI2 = R_HI2 % 65536
    local R_LO2 = R_LO1 * C1 + B1 -- 16,16,16

    return (65536 * R_HI2 + R_LO2) % 0x100000000

    -- return (currentRNG * 0x41C64E6D + 0x3039) % 0x100000000
end

local function GetFutureRNG(seed, advances)
    local future = seed
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function SimulateRNGCall(rngValue, rollAgainst)
    local checkBase = math.floor(rngValue / 0x10000)
    local rollValue = checkBase % rollAgainst

    return rollValue
end

local function CheckIfEncounterWillTriggerForSeed(seed, futureIndex)

    local rng = GetFutureRNG(seed, futureIndex)

    local currentAccumulation = GetEncounterAccumulation() + 50 * futureIndex
    local encounterRoll = SimulateRNGCall(rng, 2000)

    return rng, encounterRoll < currentAccumulation, encounterRoll, currentAccumulation
end

local function CheckSeedRollFrom100(seed, futureIndex)

    local rng = GetFutureRNG(seed, futureIndex)
    local roll = SimulateRNGCall(rng, 100)

    return rng, roll
end

local function GetCurrentRNG()
    return memory.read_u32_be(0x04D748, "RDRAM")
end

local function PrintRNG(rng, duration)
    return string.format("%08X ", rng) .. "- " .. duration
end

cacheTable = {}

local function appendHistory(table, newValue, historyLength)
    
    for key, value in pairs(table) do

        if key <= historyLength then
            cacheTable[key+1] = value
        end
    end
    
    for key, value in pairs(cacheTable) do
        table[key] = cacheTable[key]
    end

    table[0] = newValue

    return table
end

local function PrintPreviewSeedInfo(row, previewIndex, seed, GuiFunction)

    local rng, willTrigger, roll, accumulation = CheckIfEncounterWillTriggerForSeed(seed, previewIndex)

    local color = "white"
    if COLOR_FOR_NEXT_ENCOUNTER then
        local accumulation = memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION)
        if roll < GetEncounterAccumulation() + 50 then
            color = "cyan" 
        end
    end

    local rngString = string.format("%08X ", rng)
    local indexString = string.format("%02d", previewIndex)

    local battleString = Ternary(willTrigger, "FIGHT", "     ")

    GuiFunction(row, string.format("%s: %s-> %04s %s", indexString, rngString, roll, battleString), color)
end

local function streamRNG(index, historyLength, previewLength, onLeft)

    local duration = 0
    local previousRNG = GetCurrentRNG()

    local table = {}
    local GuiFunction = Ternary(onLeft, GuiTextColor, GuiTextRightColor)

    while true do

        local currentRNG = memory.read_u32_be(0x04D748, "RDRAM")
        
        if currentRNG == previousRNG then 
            duration = duration + 1
        else
            
            local entry = PrintRNG(previousRNG, duration)
            table = appendHistory(table, entry, historyLength)

            duration = 1
        end

        GuiFunction(index, PrintRNG(currentRNG, duration))
        -- PrintPreviewSeedInfo(index, 0, currentRNG, GuiFunction)

        for key, value in pairs(table) do
            GuiFunction(index + key + 1 + 1, "" .. value)
        end
        
        for previewIndex=1, previewLength do
            PrintPreviewSeedInfo(index - previewIndex - 1, previewIndex, currentRNG, GuiFunction)   
        end        
        
        emu.frameadvance()

        previousRNG = currentRNG
    end
end

local function main()
    streamRNG(45, 5, 35, false)
    -- streamRNG(20, 5, 5, false)
    -- streamRNG(28, 5, 30, true)
end

main()
