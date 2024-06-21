-- Brian Memory Locations
--
MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Y = 0x7BAD4

MEM_INTERACTABLE_SPIRIT_POINTER = 0x7BA78
MEM_SPELL_MENU_DEPTH = 0x7bbd5
MEM_COMBAT_ENEMY_COUNT = 0x07C993

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 100

function Trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function IsOnSpirit()
    local interactable_pointer = memory.read_u32_be(MEM_INTERACTABLE_SPIRIT_POINTER, "RDRAM")
    return interactable_pointer > 0
end

function IsSpellMenuOpen()
    local spellDepth = memory.readbyte(MEM_SPELL_MENU_DEPTH, "RDRAM")
    return spellDepth > 0
end

function GetEnemyCount()
    return memory.readbyte(MEM_COMBAT_ENEMY_COUNT, "RDRAM")
end

function IsEncounterActive()
    return GetEnemyCount() > 0
end

function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 200 + row_index * 15, text, color)
end

function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

function GuiTextRight(row_index, text)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text)
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

function Ternary ( cond , T , F )
    if cond then return T else return F end
end

function SetStats(hp, maxHp, mp, maxMp, agility, defense)
    memory.write_u16_be(0x7BA84, hp, "RDRAM")
    memory.write_u16_be(0x7BA86, maxHp, "RDRAM")
    memory.write_u16_be(0x7BA88, mp, "RDRAM")
    memory.write_u16_be(0x7BA8A, maxMp, "RDRAM")
    memory.writebyte(0x7BA8D, agility, "RDRAM")
    memory.writebyte(0x7BA8F, defense, "RDRAM")
end

function GetStepPromptColor(stepDistance)

    local color = "red"

    if (stepDistance > 40) then
        color = "cyan"
    elseif (stepDistance > 30) then
        color = "yellow"
    elseif (stepDistance > 20) then
        color = "orange"
    end

    return color
end

MESSAGE_SHOW_DURATION_MS = 3500
MESSAGE_SUCCESS_COLOR_A = "cyan"
MESSAGE_SUCCESS_COLOR_B = "white"

RecentEncountersOnSpirit = 0
CurrentStreak = 0
LastStepDistance = 0
LastInputSuccess = false
WasSpellMenuOpen = false
RecentlyStoppedMoving = false
MessageShownAt = 0
MostRecentEncounterFeedback = "Unknown"
MessageColor = "white"
MessageSuccessAlternate = false

RecentSuccessTable = {}

function AddToRecentTable(success)
    if #RecentSuccessTable > 10 then
        table.remove(RecentSuccessTable, 1)
    end

    table.insert(RecentSuccessTable, #RecentSuccessTable + 1, success)
end

function GetRecentSuccessPercent()
    local recentSuccesses = 0
    local tableElements = #RecentSuccessTable
    for _, successReport in pairs(RecentSuccessTable) do
        if successReport then
            recentSuccesses = recentSuccesses + 1
        end
    end

    if tableElements == 0 then
        return 0
    else
        return Round(100 * recentSuccesses / tableElements, 0)
    end
end

function GetRecentSuccessColor(percent)
    if percent >= 90 then
        return "cyan"
    elseif percent >= 70 then
        return "white"
    elseif percent >= 50 then
        return "yellow"
    elseif percent >= 30 then
        return "orange"
    end
    
    return "red"
end

function GetRelevantDeathDupeData()
    
    local encounterCount = memory.read_u16_be(0x8C578, "RDRAM")
    local encounterAttempts = encounterCount / 50
    local encounterChance = (encounterAttempts + 1) * 2.5
    
    local stepDistance = Round(memory.readfloat(0x8C574, true, "RDRAM"), 1)
    local stepColor = GetStepPromptColor(stepDistance)
    local currentlyMoving = (stepDistance ~= LastStepDistance)
    
    local spellMenuOpen = IsSpellMenuOpen()
    local currentlyOnSpirit = IsOnSpirit()
    local recentSuccessPercent = GetRecentSuccessPercent()
    local currentTime = os.time()

    return {
        encounterCount = encounterCount,
        encounterAttempts = encounterAttempts,
        encounterChance = encounterChance,
    
        stepDistance = stepDistance,
        stepColor = stepColor,
        currentlyMoving = currentlyMoving,
        
        spellMenuOpen = spellMenuOpen,
        currentlyOnSpirit = currentlyOnSpirit,
        recentSuccessPercent = recentSuccessPercent,
        currentTime = currentTime
    }

end

function DetermineFeedback(data)

    if data.stepDistance < LastStepDistance then
        LastInputSuccess = data.spellMenuOpen and data.currentlyOnSpirit
        if LastInputSuccess then

            MessageColor = "cyan"
            CurrentStreak = CurrentStreak + 1
            MostRecentEncounterFeedback = "Great! " .. "x" .. CurrentStreak

            AddToRecentTable(true)
        
        elseif not data.currentlyOnSpirit then

            MessageColor = "yellow"
            CurrentStreak = 0
            MostRecentEncounterFeedback = "Not on Spirit!"
            
            AddToRecentTable(false)

        elseif not data.spellMenuOpen then

            MessageColor = "yellow"
            CurrentStreak = 0
            MostRecentEncounterFeedback = "Spell Menu Closed!"

            AddToRecentTable(false)
        end
        
        MessageShownAt = data.currentTime
    end
end

function PrintMiscData(index, data)

    GuiText(index + 0, "Flags:")
    GuiText(index + 1, "--------------------------")

    GuiTextWithColor(index + 3, "On Spirit: " .. Ternary(data.currentlyOnSpirit, "Yes", "No"), Ternary(data.currentlyOnSpirit, "cyan", "yellow"));
    GuiTextWithColor(index + 4, "Menu Open: " .. Ternary(data.spellMenuOpen, "Yes", "No"), Ternary(data.spellMenuOpen, "cyan", "yellow"));

    GuiTextWithColor(index + 6, "Recent Accuracy: " .. data.recentSuccessPercent .. "%", data.recentSuccessColor)
    
    return 7
end

function PrintDeathDupeAbout(index)

    local info = [[
        About Death Dupe
        --------------------

        Death Dupe is an advanced
        glitch that allows you to
        duplicate a spirit during
        the death transition.
    ]]

    -- Note: 

    -- - The enemy must be faster.
    -- - Item menu must be open.
    -- - The enemy should teleport.

    local lineIndex = index + 0
    for line in string.gmatch(info, "(.-)\n") do
        GuiTextRight(lineIndex, Trim(line))
        lineIndex = lineIndex + 1
     end
     
     return lineIndex;
end

function PrintDeathDupeInstructions(index)

    local info = [[
        --------------------
        How-To Perform
        --------------------
        
        1. Have very low HP.

        2. Trigger an encounter 
        on a spirit while the spell
        selection menu is open.

        3. Cast a spell as soon
        as the HUD slides in.

        4. Open the item menu

        5. Once Brian takes damage,
        use the Fresh Bread just as
        the enemy takes their next
        turn.

        6. Escape the encounter.

        7. Mash the Spirit.


        Note:
        It is possible to move 
        with the item menu active.

        Ideally, we will trigger
        the death animation and
        use the Fresh Bread while
        Brian has already escaped
        the battle.
    ]]

    local lineIndex = 0
    for line in string.gmatch(info, "(.-)\n") do
        GuiTextRight(index + lineIndex, Trim(line))
        lineIndex = lineIndex + 1
     end

     return lineIndex;
end

function PrintStepTracker(data)
    
    local stepDivisor = 2.5
    local blockCount = 50 / stepDivisor

    local progress = Round(data.stepDistance / stepDivisor, 0);
    
    GuiTextCenterWithColor(0, "Encounter Chance: " .. data.encounterChance .. "%", "white")
    GuiTextCenterWithColor(1, "|" .. string.rep("=", progress) .. string.rep(" ", blockCount - progress) .. "|" , data.stepColor)
    
    return 3
end

function PrintFeedback(index)

    local currentTime = os.time()
    local messageDelta = os.difftime(currentTime, MessageShownAt)
    if messageDelta * 1000 < MESSAGE_SHOW_DURATION_MS then

        local messageColor = MessageColor
        if CurrentStreak > 0 then
            messageColor = Ternary(MessageSuccessAlternate, MESSAGE_SUCCESS_COLOR_A, MESSAGE_SUCCESS_COLOR_B)
            MessageSuccessAlternate = not MessageSuccessAlternate
        end

        GuiTextCenterWithColor(index + 0, "Timing Feedback:", "white")
        GuiTextCenterWithColor(index + 1, "-----------------------", "white")
        GuiTextCenterWithColor(index + 2, MostRecentEncounterFeedback, messageColor)
    end
end

ShowAbout = true
ShowExplanation = true
ShowFeedback = true
ShowExtraData = true
ShowStepTracker = true

function PrintDeathDupeHeader(index)

    GuiText(index + 1, "Death Dupe Practice")
    GuiText(index + 2, "+-------------------------")
    GuiTextWithColor(index + 3, "| A - " .. Ternary(ShowAbout, "Hide", "Show") .. " About", Ternary(ShowAbout, "white", "cyan"))
    GuiTextWithColor(index + 7, "| S - " .. Ternary(ShowExplanation, "Hide", "Show") .. " DD Steps", Ternary(ShowExplanation, "white", "cyan"))
    GuiTextWithColor(index + 4, "| T - " .. Ternary(ShowStepTracker, "Hide", "Show") .. " Enc. Tracker", Ternary(ShowStepTracker, "white", "cyan"))
    GuiTextWithColor(index + 5, "| D - " .. Ternary(ShowFeedback, "Hide", "Show") .. " Feedback", Ternary(ShowFeedback, "white", "cyan"))
    GuiTextWithColor(index + 6, "| X - " .. Ternary(ShowExtraData, "Hide", "Show") .. " Extra Data", Ternary(ShowExtraData, "white", "cyan"))
    GuiText(index + 8, "+-------------------------")

    -- local otherInfo = [[
    --     --------------------------
    --     Death Dupe Practice
    --     +-------------------------
    --     | A - Show About
    --     | S - Show Steps
    --     | F - Show Feedback 
    --     +-------------------------
        
    -- ]]

    local lineIndex = index + 9
    -- for line in string.gmatch(otherInfo, "(.-)\n") do
    --     GuiText(index + lineIndex, Trim(line))
    --     lineIndex = lineIndex + 1
    --  end

     return lineIndex;
end

PreviousKeys = {}
KEY_TOGGLE_ABOUT = "A"
KEY_TOGGLE_DD_STEPS = "S"
KEY_TOGGLE_STEP_TRACKER = "T"
KEY_TOGGLE_FEEDBACK = "D"
KEY_TOGGLE_EXTRA_DATA = "X"

function ProcessControls()
    
    local keys = input.get()

    if keys[KEY_TOGGLE_ABOUT] == true and PreviousKeys[KEY_TOGGLE_ABOUT] ~= true then
        ShowAbout = not ShowAbout
    end

    if keys[KEY_TOGGLE_DD_STEPS] == true and PreviousKeys[KEY_TOGGLE_DD_STEPS] ~= true then
        ShowExplanation = not ShowExplanation
    end

    if keys[KEY_TOGGLE_FEEDBACK] == true and PreviousKeys[KEY_TOGGLE_FEEDBACK] ~= true then
        ShowFeedback = not ShowFeedback
    end

    if keys[KEY_TOGGLE_EXTRA_DATA] == true and PreviousKeys[KEY_TOGGLE_EXTRA_DATA] ~= true then
        ShowExtraData = not ShowExtraData
    end

    if keys[KEY_TOGGLE_STEP_TRACKER] == true and PreviousKeys[KEY_TOGGLE_STEP_TRACKER] ~= true then
        ShowStepTracker = not ShowStepTracker
    end
    
    PreviousKeys = input.get()
end

SetStats(1, 51, 15, 15, 5, 4)

while true do

    ProcessControls()

    local data = GetRelevantDeathDupeData()
    DetermineFeedback(data)

    local encounterLines = 0
    local aboutLines = 0
    local instructionLines = 0

    -- Left side
    local headerRows = PrintDeathDupeHeader(4)

    if ShowExtraData then 
        encounterLines = PrintMiscData(headerRows + 1, data)
    end

    -- Right side
    if ShowAbout then
        aboutLines = PrintDeathDupeAbout(10)
    end

    if ShowExplanation then 
        instructionLines = PrintDeathDupeInstructions(aboutLines + 3)
    end

    -- Center Overlay
    local trackerLines = 0
    local feedbackLines = 0

    if ShowStepTracker then
        trackerLines = PrintStepTracker(data)
    end

    if ShowFeedback then
        feedbackLines = PrintFeedback(3)
    end
    
    LastStepDistance = data.stepDistance
    WasSpellMenuOpen = data.spellMenuOpen

    emu.frameadvance()
end