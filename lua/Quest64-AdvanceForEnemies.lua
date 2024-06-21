
-- Controller Inputs
--
function moveForward()
    joypad.setanalog({ ['X Axis'] = 0, ['Y Axis'] = 127, }, 1)
end

function clearAnalog()
    joypad.setanalog({ ['X Axis'] = '', ['Y Axis'] = '', }, 1)
end

function getCurrentRNG()
    local currentRNG = memory.read_u32_be(0x04D748, "RDRAM")
    return currentRNG
end

function GetEnemyCount()
    return memory.readbyte(0x07C993, "RDRAM")
end

function IsEncounterActive()
    return GetEnemyCount() > 0
end

function GetEnemyIds()

    local _enemyCount = GetEnemyCount()
    local _enemyIds = ""
    
    for i = 1, _enemyCount do
        local _enemyId = memory.readbyte(0x07CA0D + 296 * (i - 1), "RDRAM")
        
        if _enemyIds == "" then
            _enemyIds = "".._enemyId
        else
            _enemyIds = _enemyIds .. "," .. _enemyId
        end
    end

    return _enemyCount, _enemyIds
end

function loadSaveSlot(saveSlot)
    savestate.loadslot(saveSlot)
end

function saveToSaveSlot(saveSlot)
    savestate.saveslot(saveSlot)
end

function percentString(num, total)

    local percent = 100 * num / total
    local result = string.format("%.2f %%", percent)
    
    return result
end

function advanceAndCheck(totalTestingInterval, checkDuration, startingLoadSlot, iterLoadSlot)
    
    print("RUNNING ADVANCE SCRIPT :: ")

    local results = {}

    loadSaveSlot(startingLoadSlot)
    saveToSaveSlot(iterLoadSlot)
    
    moveForward()

    -- How long is our testing interval
    for startingMovementFrame=1, totalTestingInterval do

        clearAnalog()
        loadSaveSlot(iterLoadSlot)
        moveForward()

        local encounterFound = false

        -- How long to run the actual movement Inputs
        -- and check for enemies
        for frameIndex=1, checkDuration do
            
            local rng = getCurrentRNG()
            emu.frameadvance()
            
            local iterCount, iterResults = GetEnemyIds()
            if iterCount > 0 then
                
                results[startingMovementFrame] = frameIndex..","..iterResults..",RNG: "..string.format("%08X ", rng)
                encounterFound = true

                print("Found Encounter:: "..iterResults)
            end

            if encounterFound then
                break
            end
        end

        if not encounterFound then
            results[startingMovementFrame] = ""
        end

        clearAnalog()

        local percentComplete = percentString(startingMovementFrame, totalTestingInterval)
        print(startingMovementFrame .. ", " .. percentComplete)

        loadSaveSlot(iterLoadSlot)
        emu.frameadvance()
        saveToSaveSlot(iterLoadSlot)
    end

    clearAnalog()

    print("CLOSING ADVANCE SCRIPT :: ")

    return results
end

function saveResultsToFile(results, path)

    local outputFile = io.open(path, "w+")

    for key, value in pairs(results) do

        outputFile:write(key..","..value.."\n")
        
    end

    outputFile:close()
end

function main()

    local results = advanceAndCheck(180, 35, 9, 0)

    saveResultsToFile(results, "results.csv")

end

main()

