MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Z = 0x7BAD4
MEM_BRIAN_ROTATION_Y = 0x7BADC

MEM_ENEMY_POSITION_X = 0x7C9BC
MEM_ENEMY_POSITION_Z = 0x7C9C4
MEM_ENEMY_ROTATION_Y = 0x7C9CC

MEM_BATTLE_LAST_X = 0x86B18
MEM_BATTLE_LAST_Z = 0x86B20

MEM_BATTLE_CENTER_X = 0x880B8
MEM_BATTLE_CENTER_Z = 0x880D8

MEM_ENEMY_COUNT = 0x07C993

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

MovementMagnitude = 1

MoveEnemy = false
MoveEnemyIndex = 0

PreviousKeys = {}

PreviousX = nil
PreviousZ = nil

BattleCenters = {}

BattleDistanceMin = 9999
BattleDistanceMax = 0
EncounterWasActive = false

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Ternary ( cond , T , F )
    if cond then return T else return F end
end

function GetBrianLocationCoord()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return {
        x = brianX,
        z = brianZ
    }
end

function SetBrianLocation(x, z)
    memory.writefloat(MEM_BRIAN_POSITION_X, x, true, "RDRAM")
    memory.writefloat(MEM_BRIAN_POSITION_Z, z, true, "RDRAM")
end

function SetBrianDirection(angle)
    memory.writefloat(MEM_BRIAN_ROTATION_Y, angle, true, "RDRAM")
end

function MoveAnalogForward()
    joypad.setanalog({ ['X Axis'] = 0, ['Y Axis'] = 127, }, 1)
end

function ClearAnalog()
    joypad.setanalog({ ['X Axis'] = "", ['Y Axis'] = "", }, 1)
end

function OpenItemMenu()
    joypad.set({ ['R'] = 1, ['B'] = "", }, 1)
end

function CloseItemMenu()
    joypad.set({ ['R'] = "", ['B'] = 1, }, 1)
end

function ClearButtons()
    joypad.set({ ['R'] = "", ['B'] = "", }, 1)
end

function LoadSaveSlot(slot)
    savestate.loadslot(slot)
end

function GetCoordDistance(c1, c2)
    local dx = c1.x - c2.x
    local dz = c1.z - c2.z

    return math.sqrt(dx*dx + dz*dz)
end

function WalkForwardForDistance(distanceRequired)

    local tracker = {}
    local iterations = 0
    local distanceTravelled = 0
    local oldPosition = GetBrianLocationCoord()

    MoveAnalogForward()

    console.log("Logging movement data ...")
    
    while distanceTravelled < distanceRequired do

        emu.frameadvance()

        local newPosition = GetBrianLocationCoord()
        local distance = DistanceBetweenCoords(oldPosition, newPosition)

        distanceTravelled = distanceTravelled + distance
        tracker[#tracker+1] = iterations .. ", " .. Round(distanceTravelled, 3)

        iterations = iterations + 1
        oldPosition = newPosition
    end

    ClearAnalog()
    
    console.log("... done!")

    return tracker
end

function SaveResultsToFile(results, path)

    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    for _, coord_line in pairs(results) do
        file:write(coord_line .. "\n")
    end

    file:close()
end

function Main()
    LoadSaveSlot(9)
    SetBrianDirection(-math.pi)
    
    local results = WalkForwardForDistance(700)
    SaveResultsToFile(results, "Data/walk-current.csv")
end

Main()