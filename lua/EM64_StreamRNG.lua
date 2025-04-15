local PrevRNG = 0

local MEM_ENCOUNTER_ACCUMULATION = 0x8BFB0
local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 160 + 100

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
end

local function GetEncounterAccumulation()
    return memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM")
end

local function getNextRNG(currentRNG)
    local A1 = memory.read_u16_be(0x26EA2, "RDRAM")
    local B1 = memory.read_u16_be(0x26EA4, "RDRAM") - 1000
    local C1 = memory.read_u16_be(0x26EA6, "RDRAM")

    local R_HI1 = math.floor(currentRNG / 0x10000)
    local R_LO1 = currentRNG % 0x10000

    local R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    local R_HI2 = R_HI2 % 65536
    local R_LO2 = R_LO1 * C1 + B1 -- 16,16,16

    return (65536 * R_HI2 + R_LO2) % 0x100000000

    -- return (currentRNG * 0x41C64E6D + 0x3039) % 0x100000000
end

local function SimulateRNGCall(rngValue, rollAgainst)
    local checkBase = math.floor(rngValue / 0x10000)
    local rollValue = checkBase % rollAgainst

    return rollValue
end

local function CheckIfEncounterWillTriggerForSeed(seed, futureIndex)

    local currentAccumulation = GetEncounterAccumulation()
    local currentPercent = 2.5 * (currentAccumulation + 50.0 * futureIndex) / 50.0

    local currentThreshold = currentPercent * 10
    local encounterRoll = SimulateRNGCall(seed, 1000)

    return encounterRoll <= currentThreshold
end

local function getCurrentRNG()
    return memory.read_u32_be(0x04F778, "RDRAM")
end

local function printRNG(rng, duration)
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

local function streamRNG(index, historyLength, previewLength)

    local duration = 0
    local previousRNG = getCurrentRNG()

    local table = {}

    while true do

        local currentRNG = getCurrentRNG()
        
        if currentRNG == previousRNG then 
            duration = duration + 1
        else
            
            local entry = printRNG(previousRNG, duration)
            table = appendHistory(table, entry, historyLength)

            duration = 1
        end

        GuiTextRight(index, printRNG(currentRNG, duration))

        for key, value in pairs(table) do
            
            -- local px = x
            -- local py = y + 15 * (key + 1) + 10

            GuiTextRight(index + key + 1 + 1, "" .. value)
        end
        
        local nextRNG = currentRNG
        for previewIndex=1, previewLength do

            nextRNG = getNextRNG(nextRNG)
            local previewPad = ""
            if previewIndex < 10 then 
                previewPad = " " 
            end

            local willTrigger = CheckIfEncounterWillTriggerForSeed(nextRNG, previewIndex)

            GuiTextRight(index - previewIndex - 1, previewIndex .. previewPad .. ": " .. string.format("%08X ", nextRNG) .. ", " .. Ternary(willTrigger, "BATTLE", ""))
        end        
        
        emu.frameadvance()

        previousRNG = currentRNG
    end
end

local function main()
    streamRNG(40, 5, 35)
end

main()
