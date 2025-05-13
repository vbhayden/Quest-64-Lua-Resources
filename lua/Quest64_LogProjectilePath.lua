local MEM_PTR_PROJ_1_START = 0x86F24
local MEM_PTR_ENEMY_1_START = 0x86F24
local MEM_PROJECTILE_SIZE = 0x3C

local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Y = 0x7BAD0
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function GetEnemyAtIndex(enemy_index)

    local indexOffset = 296 * (enemy_index - 1)

    local x = memory.readfloat(0x7C9BC + indexOffset, true, "RDRAM")
    local y = memory.readfloat(0x7C9C0 + indexOffset, true, "RDRAM")
    local z = memory.readfloat(0x7C9C4 + indexOffset, true, "RDRAM")

    local id = memory.readbyte(0x07CA0D + indexOffset, "RDRAM")

    local hp = memory.read_u16_be(0x07C9A2 + indexOffset, "RDRAM")
    local hpMax = memory.read_u16_be(0x07C9A4 + indexOffset, "RDRAM")

    local attack = memory.read_u16_be(0x07CAAC + indexOffset, "RDRAM")
    local agility = memory.read_u16_be(0x07CAAE + indexOffset, "RDRAM")
    local defense = memory.read_u16_be(0x07CAB0 + indexOffset, "RDRAM")
    
    local sizeModifier = memory.readfloat(0x7C9E0 + indexOffset, true, "RDRAM")
    local rawSize = memory.readfloat(0x7C9E4 + indexOffset, true, "RDRAM")
    local size = sizeModifier * rawSize

    local ptr_attributes = GetPointerFromAddress(0x07CA20 + indexOffset)
    local rawHeight = memory.readfloat(ptr_attributes + 0x1C, true, "RDRAM")
    local height = rawHeight * sizeModifier

    local enemy_type = memory.read_u16_be(ptr_attributes + 0x0, "RDRAM")

    local strange_data = GetPointerFromAddress(0x07CA24 + indexOffset)
    local flying_y = memory.readfloat(ptr_attributes + 0x94, true, "RDRAM")

    local weaknessTurns = memory.readbyte(0x07CA34, "RDRAM")

    local collision_y_normal = y + height * 0.5
    local collision_y_flying = flying_y

    local collision_y = Ternary(enemy_type == 1, collision_y_flying, collision_y_normal)

    return {
        enemy_type = enemy_type,
        flying_y = flying_y,
        id = id,
        hp = hp,
        hpMax = hpMax,
        attack = attack,
        agi = agility,
        def = defense,
        x = x,
        y = y,
        z = z,
        collision_y = collision_y,
        size = size,
        height = height,
        rawSize = rawSize,
        weaknessTurns = weaknessTurns
    }
end

local function GetProjectileInfo(projectile_index)
    local offset = (projectile_index - 1) * MEM_PROJECTILE_SIZE
    local x = memory.readfloat(MEM_PTR_PROJ_1_START + 0x0 + offset, true, "RDRAM")
    local y = memory.readfloat(MEM_PTR_PROJ_1_START + 0x4 + offset, true, "RDRAM")
    local z = memory.readfloat(MEM_PTR_PROJ_1_START + 0x8 + offset, true, "RDRAM")
    local vx = memory.readfloat(MEM_PTR_PROJ_1_START + 0xC + offset, true, "RDRAM")
    local vy = memory.readfloat(MEM_PTR_PROJ_1_START + 0x10 + offset, true, "RDRAM")
    local vz = memory.readfloat(MEM_PTR_PROJ_1_START + 0x14 + offset, true, "RDRAM")

    return {
        x = x,
        y = y,
        z = z,
        vx = vx,
        vy = vy,
        vz = vz,
    }
end

local function GetBrianLocation()
    local x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local z = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    local angle = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")

    return { x=x, y=y, z=z, angle=angle }
end

local breadcrumbs = {}
local previous_keys = {}
local reading_crumbs = false

local last_dx = -9999
local last_dz = -9999

local function WriteCrumbCSV(path)
    local file = io.open(path, "w+")
    if file == nil then 
        return console.log("Could not open file at path: " .. path)
    end

    -- console.log("WRITING CSV: " .. #breadcrumbs)
    for _, coord_line in pairs(breadcrumbs) do
        -- console.log(coord_line)
        file:write(coord_line .. "\n")
    end

    file:close()
end

local function ToRow(formatter, ...)
    local result = ""
    for i, v in ipairs(arg) do
        result = result .. string.format(formatter, v)
        if i < #arg then
            result = result .. ","
        end
    end
    return result
end

local function ResetCrumbs()
    breadcrumbs = {}
    breadcrumbs[#breadcrumbs+1] = ToRow("%s",
        "brian x",
        "brian y",
        "brian z",
        "brian angle",
        "enemy x",
        "enemy y",
        "enemy z",
        "enemy collision_y",
        "enemy size",
        "enemy height",
        "projectile x",
        "projectile y",
        "projectile z",
        "projectile vx",
        "projectile vy",
        "projectile vz"
    )
end

local function ReadCrumbs()

    local brian = GetBrianLocation()
    local enemy = GetEnemyAtIndex(1)
    local projectile = GetProjectileInfo(1)

    if projectile.x == last_dx then
        return
    end
    if projectile.z == last_dz then
        return
    end

    breadcrumbs[#breadcrumbs+1] = ToRow("%.4f",
        brian.x,
        brian.y,
        brian.z,
        brian.angle,
        enemy.x,
        enemy.y,
        enemy.z,
        enemy.collision_y,
        enemy.size,
        enemy.height,
        projectile.x,
        projectile.y,
        projectile.z,
        projectile.vx,
        projectile.vy,
        projectile.vz
    )

    console.log(breadcrumbs[#breadcrumbs])

    last_dx = projectile.x
    last_dz = projectile.z
end

local function ProcessKeyboardInput()

    local keys = input.get()

    if keys["Space"] == true and previous_keys["Space"] ~= true then
        if reading_crumbs then
            local filename = "data/projectiles/" .. os.time()
            WriteCrumbCSV(filename .. ".csv")
        end

        reading_crumbs = not reading_crumbs
        console.log("READING CRUMBS: " .. Ternary(reading_crumbs, "YES", "NO"))

        ResetCrumbs()
        
        last_dx = -9999
        last_dz = -9999
    end

    previous_keys = input.get()
end

ResetCrumbs()

while true do

    ReadCrumbs()
    ProcessKeyboardInput()

    emu.frameadvance()
end

-- 42.7, 79.4
--