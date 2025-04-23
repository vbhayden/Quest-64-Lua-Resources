local MEM_PROJECTILE_ONE_X = 0x086F24
local MEM_PROJECTILE_ONE_Y = 0x086F28
local MEM_PROJECTILE_ONE_Z = 0x086F2C

local MEM_PROJECTILE_FOUR_X = 0x086FD8
local MEM_PROJECTILE_FOUR_Y = 0x086FDC
local MEM_PROJECTILE_FOUR_Z = 0x086FE0

local MEM_BOSS_HEALTH_CURRENT = 0x07C9A2
local MEM_BOSS_
local MEM_AVALANCHE_ROCK_SIZE = 0x0C0CD8

local SAVE_SLOT_IN_USE = 5

local REQUIRED_ACCURACY = 0.001

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function GetBossInfo()

    local id = memory.readbyte(0x07CA0D, "RDRAM")

    local hp = memory.read_u16_be(0x07C9A2, "RDRAM")
    local hpMax = memory.read_u16_be(0x07C9A4, "RDRAM")

    local attack = memory.read_u16_be(0x07CAAC, "RDRAM")
    local agility = memory.read_u16_be(0x07CAAE, "RDRAM")
    local defense = memory.read_u16_be(0x07CAB0, "RDRAM")
    
    local x = memory.readfloat(0x7C9BC, true, "RDRAM")
    local y = memory.readfloat(0x7C9C0, true, "RDRAM")
    local z = memory.readfloat(0x7C9C4, true, "RDRAM")
    
    local sizeModifier = memory.readfloat(0x7C9E0 , true, "RDRAM")
    local rawSize = memory.readfloat(0x7C9E4, true, "RDRAM")
    local size = sizeModifier * rawSize

    local ptr_attributes = GetPointerFromAddress(0x07CA20)
    local rawHeight = memory.readfloat(ptr_attributes + 0x1C, true, "RDRAM")
    local height = rawHeight * sizeModifier

    local weaknessTurns = memory.readbyte(0x07CA34, "RDRAM")

    return {
        id = id,
        hp = hp,
        hpMax = hpMax,
        attack = attack,
        agi = agility,
        def = defense,
        x = x,
        y = y,
        z = z,
        size = size,
        height = height,
        rawSize = rawSize,
        weaknessTurns = weaknessTurns
    }
end

local function GetBossHP()
    return memory.read_u16_be(MEM_BOSS_HEALTH_CURRENT, "RDRAM")
end

local function GetRNG()
    return memory.read_u32_be(0x04D748, "RDRAM")
end

local function GetRockSize()
    return memory.readfloat(MEM_AVALANCHE_ROCK_SIZE, true, "RDRAM")
end

local function SetRockSize(size)
    memory.writefloat(MEM_AVALANCHE_ROCK_SIZE, size, true, "RDRAM")
end 

console.clear()

local results = {}

local function Main()
    -- For Guilty, start at the origin and fan out
    -- along the X-axis until we're just beyond his 
    -- planar collision radius
    --
    local boss_health_undamaged = GetBossHP()
    local boss_info = GetBossInfo()
    local boss_x = boss_info.x
    local boss_y = boss_info.y
    local boss_z = boss_info.z
    local boss_radius = boss_info.size
    local boss_height = boss_info.height
    local rock_start_height = boss_y + 60

    -- SetRockSize(10.0)

    local rock_size = GetRockSize()
    local offset_spacing = 0.02
    local collision_tuning_distance = 0.02
    local reset_adjustment = 0.5
    local current_x = boss_x

    local rock_height = rock_start_height
    local last_collision_height = rock_start_height

    while current_x < (boss_radius + rock_size) do

        -- console.log(string.format("%.2f, %.2f", current_x, rock_height))

        rock_height = last_collision_height + reset_adjustment

        savestate.loadslot(SAVE_SLOT_IN_USE)

        memory.writefloat(MEM_PROJECTILE_ONE_X, current_x, true, "RDRAM")
        memory.writefloat(MEM_PROJECTILE_ONE_Y, rock_start_height, true, "RDRAM")
        memory.writefloat(MEM_PROJECTILE_ONE_Z, boss_z, true, "RDRAM")

        local scoots = 0

        local boss_health_now = GetBossHP()
        while boss_health_now == boss_health_undamaged  do
            
            emu.frameadvance()
            emu.frameadvance()

            boss_health_now = GetBossHP()
            
            -- Check if this rock hit the boss
            --
            if boss_health_now == boss_health_undamaged then
                scoots = scoots + 1
                rock_height = rock_height - collision_tuning_distance
                
                -- console.log(string.format("%.2f, %.2f", current_x, rock_height))
                
                -- We did not, so reload and scoot the rock downwards
                savestate.loadslot(SAVE_SLOT_IN_USE)
    
                memory.writefloat(MEM_PROJECTILE_ONE_X, current_x, true, "RDRAM")
                memory.writefloat(MEM_PROJECTILE_ONE_Y, rock_height, true, "RDRAM")
                memory.writefloat(MEM_PROJECTILE_ONE_Z, boss_z, true, "RDRAM")
            else
                local collision_height = memory.readfloat(MEM_PROJECTILE_ONE_Y, true, "RDRAM")
                console.log(string.format("%.2f, %.2f", current_x, collision_height))
                results[current_x] = collision_height

                last_collision_height = collision_height
            end
        end

        current_x  = current_x + offset_spacing
    end

    console.log(results)
end

Main()
