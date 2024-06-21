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

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 160 + 100

local function Ternary ( cond , T , F )
    if cond then return T else return F end
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

local function GetCurrentRNG()
    return memory.read_u32_be(0x04D748, "RDRAM")
end

local function printf(template, ...)
    console.log(string.format(template, ...))
end

local target = 0x7A5246E4
local current = GetCurrentRNG()

local advances = 0

while current ~= target do
    current = GetFutureRNG(current, 1)
    advances = advances + 1
end

if current == target then
    printf("Found it!  %d advances!", advances)

    for exits=0,16 do
        for heals=0,16 do
            local extra = 31 * exits + 32 * heals
            if advances == extra then
                printf("%d exits, %d heals", exits, heals)
            end
        end
    end
else
    console.log(string.format("Not found :(("))
end

