GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

function GuiTextBottomCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth
    
    local borderHeight = client.borderheight();
    local screenHeight = client.screenheight();
    local resolvedOffsetY = screenHeight - borderHeight

    gui.text(resolvedCenter, resolvedOffsetY - (row_index * 15), text, color)
end

function GetEnemyCount()
    return memory.readbyte(0x07C993, "RDRAM")
end

function IsEncounterActive()
    return GetEnemyCount() > 0
end

function IsOnSpirit()
    local interactable_pointer = memory.read_u32_be(MEM_INTERACTABLE_SPIRIT_POINTER, "RDRAM")
    return interactable_pointer > 0
end

function IsSpellMenuOpen()
    local spellDepth = memory.readbyte(MEM_SPELL_MENU_DEPTH, "RDRAM")
    return spellDepth > 0
end

function GetEnemyIds()

    local enemyCount = GetEnemyCount()
    local enemyIds = {}
    
    for i = 1, enemyCount do
        local id = memory.readbyte(0x07CA0D + 296 * (i - 1), "RDRAM")
        table.insert(enemyIds, id)
    end

    return enemyIds
end

function GetFirstEnemyID()
    local ids = GetEnemyIds()
    if #ids == 0 then
        return nil
    else
        return ids[1]
    end
end

EncounterWasActive = false

while true do

    GuiTextBottomCenterWithColor(3, "Auto-State Active")

    local encounterActive = IsEncounterActive()
    if encounterActive and not EncounterWasActive then

        local firstEnemyId = GetFirstEnemyID()
        
        -- Ignore Were Hare and Big Mouth packs for now
        if (firstEnemyId ~= 0) and (firstEnemyId ~= 3) then
            
            local onSpirit = IsOnSpirit()
            local menuOpen = IsSpellMenuOpen()

            if onSpirit and menuOpen then
                savestate.saveslot(2)
            end
        end
    end
    emu.frameadvance()

    EncounterWasActive = encounterActive
end
