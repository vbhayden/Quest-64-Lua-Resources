MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Z = 0x7BAD4
MEM_BRIAN_ROTATION_Y = 0x7BADC

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

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

function ReadEncounterCSV(path)
    local encounterCenters = {}
    for line in io.lines(path) do

        if string.len(line) > 1 then
            
            local xstr, zstr = line:match("([^,]+),([^,]+)")

            encounterCenters[#encounterCenters + 1] = { 
                x = tonumber(xstr),
                z = tonumber(zstr)
            }
        end

    end
    return encounterCenters
end

function GetBrianLocationCoord()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return {
        x = brianX,
        z = brianZ
    }
end

function DistanceBetweenCoords(c1, c2)

    local dx = c1.x - c2.x
    local dz = c1.z - c2.z

    return math.sqrt(dx * dx + dz * dz)
end

local path = "Data/mammons-world-5.csv"
local data = ReadEncounterCSV(path)

while true do

    local brian = GetBrianLocationCoord()

    local closest = nil
    local closestDistance = 9999
    
    local furthest = nil
    local furthestDistance = 0

    for _, coord in pairs(data) do
        local distance = DistanceBetweenCoords(brian, coord)
        if closestDistance > distance and distance > 50 and distance < 90 then
            closestDistance = distance
            closest = coord
        end
        
        if furthestDistance < distance and distance > 50 and distance < 90 then
            furthestDistance = distance
            furthest = coord
        end
    end

    GuiTextBottomCenterWithColor(4, "Encounter Data: " .. path, "white")

    if closest ~= nil then
        GuiTextBottomCenterWithColor(5, "Closest Encounter: " .. closest.x .. ", " .. closest.z .. " (" .. Round(closestDistance) .. ")", "white")
    end
    
    if furthest ~= nil then
        GuiTextBottomCenterWithColor(6, "Furthest Encounter: " .. furthest.x .. ", " .. furthest.z .. " (" .. Round(furthestDistance) .. ")", "white")
    end

    emu.frameadvance()
end
