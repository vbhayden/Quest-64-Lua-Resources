---@diagnostic disable: deprecated
MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Z = 0x7BAD4
MEM_BRIAN_ROTATION_Y = 0x7BADC

MEM_ENEMY_POSITION_X = 0x7C9BC
MEM_ENEMY_POSITION_Z = 0x7C9C4
MEM_ENEMY_ROTATION_Y = 0x7C9CC

CONST_BRIAN_RADIUS = 3.5

local function Factorial(k)
	local result = 1;
    
    for i = 1, k do
	    result = result * i;
    end

	return result;
end

local function NChooseK(n, k)
    local numerator = Factorial(n)
    local demoninator = Factorial(n - k) * Factorial(k)

    return numerator / demoninator
end

local function Binomial(chance, successes, trials)
    
    local coefficient = NChooseK(trials, successes)
    return coefficient * (chance ^ successes) * (1 - chance) ^ (trials - successes)
end

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

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

local function GetExpectedRockHits(overlaps)
    local TOTAL_POSSIBLE = 320
    local ROCK_COUNT = 10

    local percent = (1.0 * overlaps) / TOTAL_POSSIBLE
    local expected = ROCK_COUNT * percent

    return expected
end

local function RocksBrianToEnemy(BrianX1, BrianY1, EnemyX1, EnemyY1, Size1)

    local validRocks = 0
    local totalPossible = 0

    for i = 0, 15 do -- Angles
        for j = 20, 39 do -- Distances
            local x = BrianX1 + j * math.cos(i * 22.5 * math.pi / 180)
            local y = BrianY1 + j * math.sin(i * 22.5 * math.pi / 180)

            XDiff1 = x - EnemyX1
            YDiff1 = y - EnemyY1
            D1 = math.sqrt(XDiff1 * XDiff1 + YDiff1 * YDiff1)
            if D1 <= Size1 + 10 then
                validRocks = validRocks + 1
            end

            totalPossible = totalPossible + 1
        end
    end

    local hitChance = (1.0 * validRocks) / totalPossible

    return validRocks, hitChance, totalPossible
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function CalculateBossSize()
    local sizeModifier = memory.readfloat(0x7C9E0, true, "RDRAM")
    local trueSize = memory.readfloat(0x7C9E4, true, "RDRAM")
    local size = sizeModifier * trueSize

    return Round(size, 3)
end

LastMapID = -1
LastSubMapID = -1
BestExpected = 0
BestIntersections = 0

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return brianX, brianZ
end

local function GetEnemyLocation()
    local brianX = memory.readfloat(MEM_ENEMY_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_ENEMY_POSITION_Z, true, "RDRAM")
    
    return brianX, brianZ
end

local function GetBrianDirection()
    local angleRadians = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

local function GetEnemyDirection()
    local angleRadians = memory.readfloat(MEM_ENEMY_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

local function TransformDirectionForEnemy(x, y, z)
    -- Direction Notes:
    --
    -- -X = WEST
    -- +X = EAST
    -- -Z = NORTH
    -- +Z = SOUTH
    --
    -- This gives us a traditional quadrant system aligned to
    -- World South as +Z and World East as +X.  Swapping Z and Y
    -- for notation, this aligns with the game's opinion that 
    -- due North is a -pi orientation on the vertical axis.
    --
    -- We need to make a small adjustment to account for the 
    -- symmetry issue and flip the sign of our angle below.
    --
    -- Brian himself cannot rotate along any non-vertical axis,
    -- so our Y component of the provided vector will not be 
    -- adjusted at all.
    --
    -- With that, we can use the standard 2D rotation matrix
    -- to finish the math.
    --
    local theta = GetEnemyDirection()

    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return xp, y, zp
end

local function CrossProduct2D(x1, y1, x2, y2)
    return x1 * y2 - y1 * x2
end

local function AngleBetween(x1, y1, x2, y2)
    local cross2D = CrossProduct2D(x1, y1, x2, y2)
    local cross2DMagnitude = math.abs(cross2D)

    local mag1 = math.sqrt(x1 * x1 + y1 * y1)
    local mag2 = math.sqrt(x2 * x2 + y2 * y2)
    
    local radians = math.asin(cross2DMagnitude / (mag1 * mag2))
    local degrees = radians * 180 / math.pi
    
    return degrees
end

local function VectorFromTo(x1, y1, x2, y2)
    return {
        x = x2 - x1,
        y = y2 - y1
    }
end

local function CoordString(x, y)
    return Round(x, 1) .. ", " .. Round(y, 1)
end

local function AngleFromBossToBrian()
    local bx, by = GetBrianLocation()
    local ex, ey = GetEnemyLocation()
    local fx, _, fy = TransformDirectionForEnemy(0, 0, 1)

    local a = VectorFromTo(ex, ey, bx, by)
    local b = VectorFromTo(ex, ey, ex + fx, ey + fy)
    
    local angle = AngleBetween(a.x, a.y, b.x, b.y)

    return angle
end

local function GetEnemyMana()
    local manaCurrent = memory.read_u16_be(0x07C9A6, "RDRAM")
    local manaMax = memory.read_u16_be(0x07C9A8, "RDRAM")
end

local function ShowBossInfo(index)

    local brianX, brianY = GetBrianLocation()
    local enemyX, enemyY = GetEnemyLocation()
    
    local dx = brianX - enemyX
    local dy = brianY - enemyY

    local size = CalculateBossSize()
    local angle = AngleFromBossToBrian()

    local distance = math.sqrt(dx * dx + dy * dy) - size
    
    GuiText(index + 0, "Boss Info:  " .. size)
    GuiText(index + 1, "Size:  " .. size)
    GuiText(index + 2, "Angle : " .. Round(angle, 2))
    GuiText(index + 3, "Distance: " .. Round(distance, 2))
end

while true do

    ShowBossInfo(0)
    emu.frameadvance()
end
