-- Brian Memory Locations
--
MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Y = 0x7BAD4

MAP_ID_BLUE_CAVE = 26
MAP_ID_CULL_HAZARD = 27
MAP_ID_BOIL_HOLE = 29

PIVOT_CULL_HAZARD_X = 936.64978
PIVOT_CULL_HAZARD_Y = -251.180084

PIVOT_BOIL_HOLE_X = 4.5
PIVOT_BOIL_HOLE_Y = -18.8

PIVOT_BLUE_CAVE_RAMP_X = -17
PIVOT_BLUE_CAVE_RAMP_Y = -18
PIVOT_BLUE_CAVE_CLIP_X = -36.5
PIVOT_BLUE_CAVE_CLIP_Y = 5.5

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Ternary ( cond , T , F )
    if cond then return T else return F end
end

function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

function GetPivotPoint()
    local mapID, subMapID = GetMapIDs()

    if mapID == MAP_ID_CULL_HAZARD then
        return PIVOT_CULL_HAZARD_X, PIVOT_CULL_HAZARD_Y
    elseif mapID == MAP_ID_BLUE_CAVE then
        return 0, 0
    end
end

function GetBrianPosition()
    local x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")

    return x, y
end

function BrianDistanceTo(cx, cy)

    local bx, by = GetBrianPosition()
    
    local dx = cx - bx
    local dy = cy - by

    return math.sqrt(dx * dx + dy * dy)
end

function GetCurrentAgility()
    return memory.readbyte(0x7BA8D, "RDRAM")
end

function SetCurrentAgility(agility)
    memory.writebyte(0x7BA8D, agility, "RDRAM")
end

function IncreaseAgility()
    local current_agility = GetCurrentAgility()
    
    if current_agility < 499 then
        SetCurrentAgility(current_agility + 1)
    end
end

function DecreaseAgility()
    local current_agility = GetCurrentAgility()

    if current_agility > 2 then
        SetCurrentAgility(current_agility - 1)
    end
end

function CalculateMovementRadius()
    local agi = GetCurrentAgility()
    local radius = agi * 0.2857 + 17
    
    return radius
end

function CurrentClippingDelta()
    local px, py = GetPivotPoint()
    
    local radius = CalculateMovementRadius()
    local distance = BrianDistanceTo(px, py)

    return Round(distance - radius, 2)
end

function CalculateBrianClippingDelta(cx, cy)
    local radius = CalculateMovementRadius()
    local distance = BrianDistanceTo(cx, cy)

    return Round(distance - radius, 2)
end

function CalculateBrianClippingDeltaWithGiantsShoes(cx, cy)
    local radius = 2 * CalculateMovementRadius()
    local distance = BrianDistanceTo(cx, cy)

    return Round(distance - radius, 2)
end

PreviousKeys = {}

function ProcessKeyboardInput()

    local keys = input.get()

    if keys["Up"] == true and PreviousKeys["Up"] ~= true then
        IncreaseAgility()
    end

    if keys["Down"] == true and PreviousKeys["Down"] ~= true then
        DecreaseAgility()
    end

    PreviousKeys = input.get()
end

function GuiText(row_index, text)
    gui.text(60, 300 + row_index * 15, text)
end

function GuiTextWithColor(row_index, text, color)
    gui.text(60, 300 + row_index * 15, text, color)
end

function PrintAgilityPrompt(first_index)

    local current_agility = GetCurrentAgility()

    GuiText(first_index + 0, "Key UP:   AGI +")
    GuiText(first_index + 1, "Key DOWN: AGI -")

    GuiText(first_index + 3, "Current Agility: " .. current_agility)
end

function PrintPositioning(first_index)

    local x, z = GetBrianPosition()

    GuiText(first_index + 0, "Current Position: ")
    GuiText(first_index + 1, "Brian X: " .. Round(x, 4))
    GuiText(first_index + 2, "Brian Z: " .. Round(z, 4))
end

function ClippingDeltaColor(delta)

    local message = Ternary(delta < 0, "Too Close", "Too Far")
    local color = "red"

    local absDelta = math.abs(delta)

    if (delta > 0 and absDelta < 2) then
        message = "Right There!"
        color = "cyan"
    elseif (absDelta < 5) then
        color = "yellow"
    elseif (absDelta < 10) then
        color = "orange"
    end

    return message, color
end

function ClippingDeltaRampColor(delta)

    local message = Ternary(delta < 0, "Too Close", "Too Far")
    local color = "red"

    local absDelta = math.abs(delta)

    if (absDelta < 1) then
        message = "Right There!"
        color = "cyan"
    elseif (absDelta < 5) then
        color = "yellow"
    elseif (absDelta < 10) then
        color = "orange"
    end

    return message, color
end

function PrintClippingInfo(index)

    local mapID, subMapID = GetMapIDs()
    if mapID == MAP_ID_BLUE_CAVE then
        PrintBlueCaveInfo(index)

    elseif mapID == MAP_ID_CULL_HAZARD then
        PrintCullHazardInfo(index)
    
    elseif mapID == MAP_ID_BOIL_HOLE then
        PrintBoilHoleInfo(index)
    end
end

function SignedNumberStr(number)
    return Ternary(number > 0, "+" .. number, "" .. number)
end

function PrintBlueCaveInfo(index)
    local rampDistance = CalculateBrianClippingDelta(PIVOT_BLUE_CAVE_RAMP_X, PIVOT_BLUE_CAVE_RAMP_Y)
    local clipDistance = CalculateBrianClippingDelta(PIVOT_BLUE_CAVE_CLIP_X, PIVOT_BLUE_CAVE_CLIP_Y)

    local rampMessage, rampColor = ClippingDeltaRampColor(rampDistance)
    local clipMessage, clipColor = ClippingDeltaColor(clipDistance)

    local rampDistanceStr = SignedNumberStr(rampDistance)
    local clipDistanceStr = SignedNumberStr(clipDistance)
    
    GuiTextWithColor(index + 0, "Ramp: " .. rampDistanceStr .. ", " .. rampMessage, rampColor)
    GuiTextWithColor(index + 1, "Clip: " .. clipDistanceStr .. ", " .. clipMessage, clipColor)
end

function PrintCullHazardInfo(index)

    local pivotDistance = CalculateBrianClippingDelta(PIVOT_CULL_HAZARD_X, PIVOT_CULL_HAZARD_Y)
    local message, color = ClippingDeltaColor(pivotDistance)

    GuiTextWithColor(index + 0, pivotDistance .. ", " .. message, color)
end

function PrintBoilHoleInfo(index)

    local pivotDistance = CalculateBrianClippingDeltaWithGiantsShoes(PIVOT_BOIL_HOLE_X, PIVOT_BOIL_HOLE_Y)
    local message, color = ClippingDeltaColor(pivotDistance)

    GuiTextWithColor(index + 0, pivotDistance .. ", " .. message, color)
end

function SetOtherStats(hp, mp, defense)
    
    memory.write_u16_be(0x7BA84, hp, "RDRAM")
    memory.write_u16_be(0x7BA86, hp, "RDRAM")
    memory.write_u16_be(0x7BA88, mp, "RDRAM")
    memory.write_u16_be(0x7BA8A, mp, "RDRAM")
    memory.writebyte(0x7BA8F, defense, "RDRAM")
end

while true do

    ProcessKeyboardInput()

    PrintAgilityPrompt(0)
    PrintClippingInfo(5)
    PrintPositioning(10)

    SetOtherStats(300, 48, 500)

    emu.frameadvance()
end
