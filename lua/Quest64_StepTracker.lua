local MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
local MEM_ENCOUNTER_ACCUMULATION = 0x8C578
local MEM_COMBAT_ENEMY_COUNT = 0x07C993

local MESSAGE_SHOW_DURATION_MS = 1000

local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local EncounterCheckedAt = 0
local LastStepDistance = 0

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function Trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GuiTextCenter(row_index, text, color)
    return GuiTextCenterWithColor(row_index, text, "white")
end

local function GetEnemyCount()
    return memory.readbyte(MEM_COMBAT_ENEMY_COUNT, "RDRAM")
end

local function IsEncounterActive()
    return GetEnemyCount() > 0
end

local checks = 0
local last_map = -1
local last_submap = -1
local was_in_combat = false

local function PrintStepTracker()
    
    local encounterCount = memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM");
    local encounterAttempts = encounterCount / 50
    local encounterChance = (encounterAttempts + 1) * 2.5

    local stepDistance = Round(memory.readfloat(MEM_ENCOUNTER_STEP_DISTANCE, true, "RDRAM"), 1)
    local stepColor = "white"

    if stepDistance < LastStepDistance then
        EncounterCheckedAt = os.time()
        checks = checks + 1
    end

    LastStepDistance = stepDistance

    local stepDivisor = 2.5
    local blockCount = 50 / stepDivisor

    local progress = Round(stepDistance / stepDivisor, 0);
    
    GuiTextCenterWithColor(0, "Encounter Chance: " .. encounterChance .. "%, Checks: " .. checks, "white")
    GuiTextCenterWithColor(1, "|" .. string.rep("=", progress) .. string.rep(" ", blockCount - progress) .. "|" , stepColor)
    
    return 3
end

local function PrintFeedback(index)

    local currentTime = os.time()
    local messageDelta = os.difftime(currentTime, EncounterCheckedAt)
    if messageDelta * 1000 < MESSAGE_SHOW_DURATION_MS then

        GuiTextCenterWithColor(index, "Encounter Checked!", "white")
    end
end

while true do

    local map, submap = GetMapIDs()
    local in_combat = IsEncounterActive()

    if not in_combat and was_in_combat then
        checks = 0
    end
    if map ~= last_map or submap ~= last_submap then
        checks = 0
    end

    last_map = map
    last_submap = submap
    was_in_combat = in_combat

    -- PrintFeedback(-1)
    PrintStepTracker()
    emu.frameadvance()
end