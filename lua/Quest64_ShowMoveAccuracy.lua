MEM_AGI_XP = 0x7BAAD
MEM_AGI_TOWN = 0x7BC1C
MEM_AGI_FIELD = 0x7BC18
MEM_AGI_BATTLE = 0x7BCA0

MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
MEM_ENCOUNTER_ACCUMULATION = 0x8C578

MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Y = 0x7BAD0
MEM_BRIAN_POSITION_Z = 0x7BAD4
MEM_BRIAN_ROTATION_Y = 0x7BADC

MEM_ELEMENT_FIRE = 0x7BAA4
MEM_ELEMENT_EARTH = 0x7BAA5
MEM_ELEMENT_WATER = 0x7BAA6
MEM_ELEMENT_WIND = 0x7BAA7

MEM_ENEMY_POSITION_X = 0x7C9BC
MEM_ENEMY_POSITION_Z = 0x7C9C4
MEM_ENEMY_ROTATION_Y = 0x7C9CC

local MEM_PTR_PROJECTILE_START = 0x86F60
local MEM_PTR_PROJECTILE_LENGTH = 60

MEM_CASTING_DELAY = 0x07BBD9
MEM_TIME_UNTIL_ACTION_16BE = 0x07C99A

MEM_CURRENT_RNG = 0x04D748

MAP_BRANNOCH_CASTLE = 30

SUBMAP_GUILTY = 10
SUBMAP_BEIGIS = 14

ELEMENT_FIRE = 1
ELEMENT_EARTH = 2
ELEMENT_WATER = 3
ELEMENT_WIND = 4

SPELL_POWER_AVALANCHE = 460
SPELL_POWER_ROCK_1 = 290

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

local AVALANCHE_ROCK_INITIAL_HEIGHT = 32.4
local AVALANCHE_ROCK_FALLING_SPEED = 0.3

BONUS_TABLE = {
    0.0240, -- Level 1,  Bonus Percent: 2.4%,
    0.0281, -- Level 2,  Bonus Percent: 2.8%,
    0.0324, -- Level 3,  Bonus Percent: 3.2%,
    0.0367, -- Level 4,  Bonus Percent: 3.7%,
    0.0412, -- Level 5,  Bonus Percent: 4.1%,
    0.0459, -- Level 6,  Bonus Percent: 4.6%,
    0.0506, -- Level 7,  Bonus Percent: 5.1%,
    0.0556, -- Level 8,  Bonus Percent: 5.6%,
    0.0606, -- Level 9,  Bonus Percent: 6.1%,
    0.0659, -- Level 10, Bonus Percent: 6.6%,
    0.0712, -- Level 11, Bonus Percent: 7.1%,
    0.0768, -- Level 12, Bonus Percent: 7.7%,
    0.0825, -- Level 13, Bonus Percent: 8.2%,
    0.0883, -- Level 14, Bonus Percent: 8.8%,
    0.0944, -- Level 15, Bonus Percent: 9.4%,
    0.1006, -- Level 16, Bonus Percent: 10.1%,
    0.1070, -- Level 17, Bonus Percent: 10.7%,
    0.1137, -- Level 18, Bonus Percent: 11.4%,
    0.1205, -- Level 19, Bonus Percent: 12.1%,
    0.1275, -- Level 20, Bonus Percent: 12.8%,
    0.1347, -- Level 21, Bonus Percent: 13.5%,
    0.1421, -- Level 22, Bonus Percent: 14.2%,
    0.1498, -- Level 23, Bonus Percent: 15.0%,
    0.1577, -- Level 24, Bonus Percent: 15.8%,
    0.1658, -- Level 25, Bonus Percent: 16.6%,
    0.1742, -- Level 26, Bonus Percent: 17.4%,
    0.1828, -- Level 27, Bonus Percent: 18.3%,
    0.1917, -- Level 28, Bonus Percent: 19.2%,
    0.2009, -- Level 29, Bonus Percent: 20.1%,
    0.2103, -- Level 30, Bonus Percent: 21.0%,
    0.2200, -- Level 31, Bonus Percent: 22.0%,
    0.2300, -- Level 32, Bonus Percent: 23.0%,
    0.2403, -- Level 33, Bonus Percent: 24.0%,
    0.2509, -- Level 34, Bonus Percent: 25.1%,
    0.2618, -- Level 35, Bonus Percent: 26.2%,
    0.2731, -- Level 36, Bonus Percent: 27.3%,
    0.2847, -- Level 37, Bonus Percent: 28.5%,
    0.2966, -- Level 38, Bonus Percent: 29.7%,
    0.3089, -- Level 39, Bonus Percent: 30.9%,
    0.3216, -- Level 40, Bonus Percent: 32.2%,
    0.3347, -- Level 41, Bonus Percent: 33.5%,
    0.3481, -- Level 42, Bonus Percent: 34.8%,
    0.3619, -- Level 43, Bonus Percent: 36.2%,
    0.3762, -- Level 44, Bonus Percent: 37.6%,
    0.3909, -- Level 45, Bonus Percent: 39.1%,
    0.4060, -- Level 46, Bonus Percent: 40.6%,
    0.4216, -- Level 47, Bonus Percent: 42.2%,
    0.4376, -- Level 48, Bonus Percent: 43.8%,
    0.4542, -- Level 49, Bonus Percent: 45.4%,
    0.4712, -- Level 50, Bonus Percent: 47.1%,
    0.4887, -- Level 51, Bonus Percent: 48.9%,
    0.5068, -- Level 52, Bonus Percent: 50.7%,
    0.5254, -- Level 53, Bonus Percent: 52.5%,
    0.5445, -- Level 54, Bonus Percent: 54.5%,
    0.5643, -- Level 55, Bonus Percent: 56.4%,
    0.5846, -- Level 56, Bonus Percent: 58.5%,
    0.6056, -- Level 57, Bonus Percent: 60.6%,
    0.6271, -- Level 58, Bonus Percent: 62.7%,
    0.6493, -- Level 59, Bonus Percent: 64.9%,
    0.6722, -- Level 60, Bonus Percent: 67.2%,
    0.6958, -- Level 61, Bonus Percent: 69.6%,
    0.7201, -- Level 62, Bonus Percent: 72.0%,
    0.7451, -- Level 63, Bonus Percent: 74.5%,
    0.7708, -- Level 64, Bonus Percent: 77.1%,
    0.7973, -- Level 65, Bonus Percent: 79.7%
}

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

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

local function BitwiseAnd(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 200 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function GuiTextRightWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    local screenWidth = client.screenwidth();
    local resolvedOffset = screenWidth - borderWidth - GUI_PADDING_RIGHT

    gui.text(resolvedOffset, 20 + row_index * 15, text, color)
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function GetEncounterSteps()
    return memory.readfloat(MEM_ENCOUNTER_STEP_DISTANCE, true, "RDRAM")
end

local function GetEncounterAccumulation()
    return memory.read_u16_be(MEM_ENCOUNTER_ACCUMULATION, "RDRAM")
end

local function GetCurrentRNG()
    return memory.read_u32_be(MEM_CURRENT_RNG, "RDRAM")
end

local function ResetSeed(value)
    memory.write_u32_be(MEM_CURRENT_RNG, value, "RDRAM")
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianY = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return brianX, brianY, brianZ
end

local function SetBrianLocation(x, z)
    memory.writefloat(MEM_BRIAN_POSITION_X, x, true, "RDRAM")
    memory.writefloat(MEM_BRIAN_POSITION_Z, z, true, "RDRAM")
end

local function GetBrianDirection()
    local angleRadians = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

local function IsCombatActive()
    local battleState = memory.readbyte(0x08C593, "RDRAM")
    return battleState % 2 ~= 0
end

local function IsCurrentlyBriansTurn()
    local battleState = memory.readbyte(0x08C593, "RDRAM")
    if battleState ~= 1 then
        return false
    end

    local castingDelay = memory.readbyte(MEM_CASTING_DELAY, "RDRAM")
    local timeUntilAction = memory.readbyte(MEM_TIME_UNTIL_ACTION_16BE, "RDRAM")
    
    return castingDelay == 0 and timeUntilAction == 0
end

local function GetEnemyAtIndex(index)

    local indexOffset = 296 * (index - 1)

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
        size = size,
        height = height,
        rawSize = rawSize,
        weaknessTurns = weaknessTurns
    }
end

local function GetBrianCombatInfo()
    local baseAgi = memory.read_u16_be(0x07BA8C, "RDRAM")
    local combatAgi = memory.read_u16_be(0x07BBBE, "RDRAM")
    local combatDef = memory.read_u16_be(0x07BBC0, "RDRAM")

    local bx, by, bz = GetBrianLocation()
    local angle = GetBrianDirection()

    local fire = memory.readbyte(MEM_ELEMENT_FIRE, "RDRAM")
    local earth = memory.readbyte(MEM_ELEMENT_EARTH, "RDRAM")
    local water = memory.readbyte(MEM_ELEMENT_WATER, "RDRAM")
    local wind = memory.readbyte(MEM_ELEMENT_WIND, "RDRAM")
    local totalElements = fire + earth + water + wind

    local barrierTurns = memory.readbyte(0x07BB42, "RDRAM")
    local powerStaffTurns = memory.readbyte(0x07BB3C, "RDRAM")

    return {
        baseAgi = baseAgi,
        agi = combatAgi,
        def = combatDef,
        x = bx,
        y = by,
        z = bz,
        fire = fire,
        earth = earth,
        water = water,
        wind = wind,
        angle = angle,
        totalElements = totalElements,
        barrierTurns = barrierTurns,
        powerStaffTurns = powerStaffTurns
    }
end

local function GetBrianElementPower(element)

    local brianInfo = GetBrianCombatInfo()

    local fireInfluence = math.floor(brianInfo.fire / 8)
    local earthInfluence = math.floor(brianInfo.earth / 8)
    local waterInfluence = math.floor(brianInfo.water / 8)
    local windInfluence = math.floor(brianInfo.wind / 8)

    if element == ELEMENT_FIRE then
        fireInfluence = brianInfo.fire
        waterInfluence = math.floor(brianInfo.water / 16)
    elseif element == ELEMENT_EARTH then
        earthInfluence = brianInfo.earth
        windInfluence = math.floor(brianInfo.wind / 16)
    elseif element == ELEMENT_WATER then
        waterInfluence = brianInfo.water
        fireInfluence = math.floor(brianInfo.fire / 16)
    elseif element == ELEMENT_WIND then
        windInfluence = brianInfo.wind
        earthInfluence = math.floor(brianInfo.earth / 16)
    end

    return fireInfluence + earthInfluence + waterInfluence + windInfluence
end

local function GetAffinityCoefficientByID(id, element)
    -- Guilty and Mammon
    if id == 5 or id == 7 then
        return 0.5
    end

    -- Zelse and Shilf
    if id == 1 or id == 3 then
        if element == ELEMENT_EARTH then return 1.25 end 
        if element == ELEMENT_WIND then return 0.5 end 
    end

    -- Fargo and Beigis
    if id == 4 or id == 6 then
        if element == ELEMENT_WATER then return 1.25 end 
        if element == ELEMENT_FIRE then return 0.5 end 
    end

    -- Nepty
    if id == 2 then
        if element == ELEMENT_FIRE then return 1.25 end
        if element == ELEMENT_WATER then return 0.5 end
    end

    -- Solvaring
    if id == 0 then
        if element == ELEMENT_WIND then return 1.25 end
        if element == ELEMENT_EARTH then return 0.5 end
    end

    return 1
end

local function CalculateSpellBonus(attackPower)
    if attackPower >= #BONUS_TABLE then
        return BONUS_TABLE[#BONUS_TABLE]
    
    elseif attackPower < 0 then
        return 0.2

    else
        return BONUS_TABLE[attackPower]
    end
end

local function CalculateBrianMinDamage(element, spellPower)
    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local elementLevel = GetBrianElementPower(element)
    local bonusPercent = CalculateSpellBonus(elementLevel)

    local resultingPower = spellPower * bonusPercent

    local affinityCoefficient = GetAffinityCoefficientByID(enemyInfo.id, element)
    local rawDamage = resultingPower * affinityCoefficient

    local defenseCoefficient = brianInfo.totalElements / (brianInfo.totalElements + enemyInfo.def)
    local minDamage = math.floor(math.floor(rawDamage) * defenseCoefficient)

    return minDamage
end

local function CalculateEnemyMinDamage(spellPower)
    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local elementLevel = enemyInfo.attack
    local bonusPercent = CalculateSpellBonus(elementLevel)

    local resultingPower = spellPower * bonusPercent

    local affinityCoefficient = 1
    local rawDamage = resultingPower * affinityCoefficient

    local defenseCoefficient = enemyInfo.attack / (enemyInfo.attack + brianInfo.def)
    local minDamage = math.floor(math.floor(rawDamage) * defenseCoefficient)

    return minDamage
end

local function GetNextRNG(currentRNG)

    -- console.log(debug.traceback())

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

local function GetFutureRNG(advances)
    local current = GetCurrentRNG()
    local future = current
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function GetFutureRNGExplicit(advances, explicit_seed)
    local future = explicit_seed
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function CalculateHitChance(attackerAgi, defenderAgi)
    local top = attackerAgi * 100.0
    local bottom = attackerAgi + math.floor((defenderAgi + 7.0) / 8.0)

    local hitChance = math.floor(top / bottom)
    return hitChance
end

local function SimulateRNGCall(rngValue, rollAgainst)
    local checkBase = math.floor(rngValue / 0x10000)
    local rollValue = checkBase % rollAgainst

    return rollValue
end

local function SimulateCastBarrier()

    local futureSeed = GetFutureRNG(30)
    local hitSeed = GetNextRNG(futureSeed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local turnSeed = GetNextRNG(hitSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, 2)

    return true, roll, turns, turnSeed
end

local function SimulateCastPowerStaff()

    local futureSeed = GetFutureRNG(30)
    local hitSeed = GetNextRNG(futureSeed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local turnSeed = GetNextRNG(hitSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, 5)

    return true, roll, turns, turnSeed
end

local function SimulateCastDrainMagic()

    local futureSeed = GetFutureRNG(0)
    local hitSeed = GetNextRNG(futureSeed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 70 then
        return false, roll, 0, hitSeed
    end

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local hitSeed = GetNextRNG(hitSeed)

    local hitChance = CalculateHitChance(brianInfo.agi, enemyInfo.agi)
    local hitRoll = SimulateRNGCall(hitSeed, 100)

    if hitRoll > hitChance then
        return false, roll, 0, hitSeed
    end

    return true, roll, hitRoll, hitSeed
end

local function SimulateCastWeakness()

    local futureSeed = GetFutureRNG(0)
    local hitSeed = GetNextRNG(futureSeed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local hitSeed = GetNextRNG(hitSeed)
    local hitChance = CalculateHitChance(brianInfo.agi, enemyInfo.agi)
    local hitRoll = SimulateRNGCall(hitSeed, 100)

    if hitRoll >= hitChance then
        return false, roll, 0, hitSeed
    end

    local statusSeed = GetNextRNG(hitSeed)
    local statusRoll = SimulateRNGCall(statusSeed, 32)
    local statusChance = 20

    if statusRoll >= statusChance then
        return false, roll, 0, statusSeed
    end

    local turnSeed = GetNextRNG(statusSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, 5)

    return true, roll, turns, turnSeed
end

local function SimulateRockOneCast()
    
    local current_rng = GetCurrentRNG()
    local accuracy_seed = GetNextRNG(current_rng)

    local roll = SimulateRNGCall(accuracy_seed, 100)
    if roll >= 100 then
        return false, 0, accuracy_seed
    end

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local hitSeed = GetNextRNG(accuracy_seed)
    local hitChance = CalculateHitChance(brianInfo.agi, enemyInfo.agi)
    local hitRoll = SimulateRNGCall(hitSeed, 100)

    if hitRoll >= hitChance then
        return false, 0, hitSeed
    end

    local damageSeed = GetNextRNG(hitSeed)
    local damageMin = CalculateBrianMinDamage(ELEMENT_EARTH, SPELL_POWER_ROCK_1)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll

    return true, damage, damageSeed
end

local function SimulateBrianMelee()


    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local agilitySeed = GetFutureRNG(1)
    local hitChance = CalculateHitChance(brianInfo.agi, enemyInfo.agi)
    local hitRoll = SimulateRNGCall(agilitySeed, 100)

    if hitRoll >= hitChance then
        return false, 0, agilitySeed
    end

    local damageSeed = GetNextRNG(agilitySeed)
    -- local damageMin = CalculateEnemyMinDamage(600)
    -- local damageRange = math.floor(math.sqrt(damageMin))

    -- local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    -- local damage = damageMin + damageRoll
    
    -- console.log(string.format("Post-Collision Seed: %X, Damage: %d", damageSeed, damage))

    return true, 1, damageSeed
end

local function SimulateGuiltyPound(seed)
    local accuracySeed = GetFutureRNGExplicit(30, seed)

    local roll = SimulateRNGCall(accuracySeed, 100)
    if roll >= 100 then
        return false, 0, accuracySeed
    end

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local agilitySeed = GetNextRNG(accuracySeed)
    local hitChance = CalculateHitChance(enemyInfo.agi, brianInfo.agi)
    local hitRoll = SimulateRNGCall(agilitySeed, 100)

    if hitRoll >= hitChance then
        return false, 0, agilitySeed
    end

    local damageSeed = GetNextRNG(agilitySeed)
    local damageMin = CalculateEnemyMinDamage(600)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll
    
    -- console.log(string.format("Post-Collision Seed: %X, Damage: %d", damageSeed, damage))

    return true, damage, damageSeed
end

local function SimulateAvalancheRockHit(current_rng)

    local accuracySeed = GetNextRNG(current_rng)

    local roll = SimulateRNGCall(accuracySeed, 100)
    if roll >= 100 then
        return false, 0, accuracySeed
    end

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local agilitySeed = GetNextRNG(accuracySeed)
    local hitChance = CalculateHitChance(brianInfo.agi, enemyInfo.agi)
    local hitRoll = SimulateRNGCall(agilitySeed, 100)

    if hitRoll >= hitChance then
        return false, 0, agilitySeed
    end

    local damageSeed = GetNextRNG(agilitySeed)
    local damageMin = CalculateBrianMinDamage(ELEMENT_EARTH, SPELL_POWER_AVALANCHE)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll
    
    -- console.log(string.format("Post-Collision Seed: %X, Damage: %d", damageSeed, damage))

    return true, damage, damageSeed
end

local print_now = true

local function DoesRockOverlapEnemy(index, rock_x, rock_y, rock_z, enemyInfo)
    
    local cx = enemyInfo.x
    local cy = enemyInfo.y
    local cz = enemyInfo.z
    local collision_radius = enemyInfo.size
    local collision_height = enemyInfo.height

    local dx = cx - rock_x
    local dz = cz - rock_z

    local dy = 0.0

    if enemyInfo.enemy_type ~= 0 then
        if enemyInfo.enemy_type ~= 1 then
            -- Mammon
            dy = 0
        else
            -- Flying Enemy
            dy = (enemyInfo.flying_y - rock_y) * 0.5
        end
    else
        -- Normal Enemy
        dy = (cy + collision_height * 0.5 - rock_y) * 0.5
    end

    local radial_sum = 10.0 + collision_radius
    local elliptical_distance = math.sqrt(dx*dx + dy*dy + dz*dz)

    -- console.log(string.format("Radial: %.4f, Distance: %.4f", radial_sum, elliptical_distance))

    return radial_sum > elliptical_distance
end

local function HexPadLeft(hex)
    local str = string.format("%X", hex)
    local current_length = string.len(str)
    if current_length >= 8 then
        return str
    end

    local extras = 8 - current_length
    return string.rep("0", extras) .. str
end

local function SimulateCastAvalanche(brianInfo)

    -- local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    local seed = GetCurrentRNG()
    local rockOverlaps = 0
    local rockHits = 0
    local totalDamage = 0

    -- local beforeLast = false
    -- local lastHit = false

    -- local first_delay = 4
    local rock_delay = 5
    local next_rock_at = 0
    local harmless_duration = 4
    local max_rocks = 10

    local active_rocks = {}
    local collision_queue = {}

    if print_now then
        console.clear()
        console.log(string.format("[%s] == START ==", HexPadLeft(seed)))
    end

    for current_frame = 1, rock_delay * 10 + harmless_duration * 2 do

        for i, rock in pairs(active_rocks) do
            
            local collision_enabled = rock.frames_active >= harmless_duration
            local rock_can_damage = collision_enabled and not rock.already_collided
            if rock_can_damage then

                local falling_frames = rock.frames_active - harmless_duration + 1
                rock.y = rock.y - AVALANCHE_ROCK_FALLING_SPEED * falling_frames

                local recently_activated = rock.frames_active == harmless_duration
                if recently_activated then
                    if print_now then
                        console.log(string.format("[%s] PRE-COLLISION, Rock %d", HexPadLeft(seed), rock.index))
                    end
                end

                local overlaps_enemy = DoesRockOverlapEnemy(i, rock.x, rock.y, rock.z, enemyInfo)
                if overlaps_enemy then
                    collision_queue[#collision_queue+1] = rock
                end
            end

            rock.frames_active = rock.frames_active + 1
            
            -- if i == 1 and print_now then
            --     console.log(string.format("[%s] %.4f, %.4f %.4f", HexPadLeft(seed), rock.x, rock.y, rock.z))
            -- end
        end
        
        local allow_more_rocks = #active_rocks < max_rocks
        if allow_more_rocks and current_frame >= next_rock_at then
            next_rock_at = next_rock_at + rock_delay
            
            local offsetSeed = GetNextRNG(seed)
            local angleSeed = GetNextRNG(offsetSeed)

            local angleRoll = SimulateRNGCall(angleSeed, 16)
            local offsetRoll = SimulateRNGCall(offsetSeed, 20)

            seed = angleSeed

            local angle = angleRoll * 22.5 * math.pi / 180
            local offset = 20.0 + offsetRoll

            -- Angle Notes
            --
            -- +pi   -> +z
            --   0   -> -z
            -- +pi/2 -> -x
            -- -pi/2 -> +x
            --
            -- The avalanche orientations are aligned with world space, so the only thing
            -- that would make sense is if these angles were also for world space.
            
            local rock_x = brianInfo.x - offset * math.sin(angle)
            local rock_y = brianInfo.y + AVALANCHE_ROCK_INITIAL_HEIGHT
            local rock_z = brianInfo.z - offset * math.cos(angle)
            
            if print_now then
                console.log(string.format("[%s] %d: %.4f, %.4f %.4f", HexPadLeft(seed), #active_rocks+1, rock_x, rock_y, rock_z))

                -- if current_frame == 1 then
                --     local perfect_brian_x = enemyInfo.x - (rock_x - brianInfo.x)
                --     local perfect_brian_z = enemyInfo.z - (rock_z - brianInfo.z)

                --     SetBrianLocation(perfect_brian_x, perfect_brian_z)
                -- end
            end

            active_rocks[#active_rocks+1] = {
                frames_active = 0,
                already_collided = false,
                x = rock_x,
                y = rock_y,
                z = rock_z,
                index = #active_rocks + 1
            }
        end

        if #collision_queue > 0 then
            
            for _, rock in pairs(collision_queue) do
            
                rock.already_collided = true
                rockOverlaps = rockOverlaps + 1

                local hit, damage, finalSeed = SimulateAvalancheRockHit(seed)
                if hit then
                    rockHits = rockHits + 1
                    totalDamage = totalDamage + damage
                end

                seed = finalSeed

                if print_now then
                    console.log(string.format("[%s] POST-COLLISION, Rock %d - %s", HexPadLeft(seed), rock.index, Ternary(hit, "HIT: " .. damage, "MISS")))
                    console.log(string.format("[%s] POST-COLLISION, Rock %d - %.4f, %.4f, %.4f", HexPadLeft(seed), rock.index, rock.x, rock.y, rock.z))
                end
            end

            collision_queue = {}
        end
        
        if print_now then
            console.log(string.format("[%s] Frame %d", HexPadLeft(seed), current_frame))
        end
    end

    print_now = false

    return rockOverlaps, rockHits, totalDamage, seed
end

local function DrawSpellRow(index, name, willHit, turns, defaultColor)
    local color = Ternary(willHit, "cyan", defaultColor)
    local emoji = Ternary(willHit, "Y", "N")
    local infoString = Ternary(turns > 0, ", " .. turns .. " Turns", Ternary(willHit, "", ", Miss!"))
    local line = emoji .. " - " .. name .. infoString

    GuiTextWithColor(index, line, color)
end

local function DrawGenericDamageSpellRow(index, name, hits, damage, defaultColor)
    local color = Ternary(hits >= 1, "cyan", defaultColor)
    local emoji = Ternary(hits > 0, "Y", "N")
    local infoString = ", " .. hits .. " Hits for " .. damage .. " Damage"
    local line = emoji .. " - " .. name .. infoString

    GuiTextWithColor(index, line, color)
end

local function DrawAvalancheRow(index, name, overlaps, hits, damage, defaultColor)
    local misses = overlaps - hits
    local color = Ternary(hits >= 5, "cyan", defaultColor)
    local emoji = Ternary(hits > 0, "Y", "N")
    local infoString = string.format(", %d Miss + %d Hit, %d Damage", misses, hits, damage)
    local line = emoji .. " - " .. name .. infoString

    GuiTextWithColor(index, line, color)
end

local function DrawInactiveSpellRow(index, name, willHit, turns, defaultColor)
    local line = "?" .. " - " .. name
    GuiTextWithColor(index, line, defaultColor)
end

local function DrawInactiveAvalancheRow(index, name, overlaps, hits, damage, defaultColor)
    local line = "?" .. " - " .. name
    GuiTextWithColor(index, line, defaultColor)
end

local function DrawMissPredictionRow(index, name, missPredicted)
    local miss_icon = Ternary(missPredicted, "X", " ")
    local row_color = Ternary(missPredicted, "cyan", "gray")
    GuiTextRightWithColor(index, string.format("%s - %s", miss_icon, name), row_color)
end

-- local enemyInfo = GetEnemyAtIndex(1)
-- console.clear()
-- console.log(enemyInfo)

-- exit()

-- print_now = true
-- SimulateCastAvalanche()

-- exit()

-- local enemy_info = GetEnemyAtIndex(1)
-- local overlaps = DoesRockOverlapEnemy(1, 22.7866, 23.7513, 15.4733, enemy_info)

-- console.log(Ternary(overlaps, "TRUE", "FALSE"))
-- exit()

local function CheckAvalancheVolatility(expected_damage, expected_seed)

    local brian_info = GetBrianCombatInfo()
    local safety_result = "UNSAFE"
    local safety_distance = 0
    local volatility_results = {
        {
            distance = 1.0,
            result = "VOLATILE"
        },
        {
            distance = 2.0,
            result = "MODERATE"
        },
        {
            distance = 5.0,
            result = "SAFE"
        },
        {
            distance = 10.0,
            result = "VERY SAFE"
        }
    }

    local distance_signs = {
        {
            x = 1,
            z = 0
        },
        {
            x = -1,
            z = 0
        },
        {
            x = 0,
            z = -1
        },
        {
            x = 0,
            z = 1
        },
        {
            x = 1,
            z = 1
        },
        {
            x = -1,
            z = 1
        },
        {
            x = 1,
            z = -1
        },
        {
            x = -1,
            z = -1
        }
    }

    local still_safe = true

    for _, result in pairs(volatility_results) do
        for __, signs in pairs(distance_signs) do
            if still_safe then
                local brian_x = brian_info.x + result.distance * signs.x
                local brian_z = brian_info.z + result.distance * signs.z
                brian_info.x = brian_x
                brian_info.z = brian_z
                local _, __, damage, seed = SimulateCastAvalanche(brian_info)

                if (damage ~= expected_damage) or (seed ~= expected_seed) then
                    still_safe = false
                end
            end
        end

        if still_safe then
            safety_result = result.result
            safety_distance = result.distance
        end
    end

    return safety_result, safety_distance
end

while true do

    local combatActive = IsCombatActive()
    local headerColor = Ternary(combatActive, "white", "gray")

    local brianInfo = GetBrianCombatInfo()
    local enemyInfo = GetEnemyAtIndex(1)

    GuiTextWithColor(2, "Spell Calculation " .. string.format("(%d Agi)", brianInfo.baseAgi), headerColor)
    GuiTextWithColor(3, "-----------------------", headerColor)

    local briansTurn = IsCurrentlyBriansTurn()
    local bodyColor = Ternary(briansTurn, "white", headerColor)

    local meleeHit, meleeDamage, meleeSeed = SimulateBrianMelee()
    local powerHit, powerRoll, powerTurns, powerSeed = SimulateCastPowerStaff()
    local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier()
    local drainHit, drainAccuracyRoll, drainAgilityRoll, drainSeed = SimulateCastDrainMagic()
    local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness()
    local rockOverlaps, rockHits, avalancheDamage, avalancheSeed = SimulateCastAvalanche(brianInfo)
    local rockHit, rockDamage, rockSeed = SimulateRockOneCast()

    local avalanche_safety, avalanche_safety_distance = CheckAvalancheVolatility(avalancheDamage, avalancheSeed)

    local DrawHandler = Ternary(briansTurn, DrawSpellRow, DrawInactiveSpellRow)
    local DrawDamageHandler = Ternary(briansTurn, DrawGenericDamageSpellRow, DrawInactiveSpellRow)
    local DrawAvalancheHandler = Ternary(briansTurn, DrawAvalancheRow, DrawInactiveAvalancheRow)

    local map, submap = GetMapIDs()

    if map == MAP_BRANNOCH_CASTLE and submap == SUBMAP_GUILTY then
        
        local hitsAfterPower, _, _ = SimulateGuiltyPound(powerSeed)
        local hitsAfterBarrier, _, _ = SimulateGuiltyPound(barrierSeed)
        local hitsAfterDrain, _, _ = SimulateGuiltyPound(drainSeed)
        local hitsAfterWeakness, _, _ = SimulateGuiltyPound(weaknessSeed)
        local hitsAfterMelee, _, _ = SimulateGuiltyPound(meleeSeed)
        local hitsAfterRockOne, _, _ = SimulateGuiltyPound(rockSeed)
        
        GuiTextRightWithColor(10, "Guilty Miss Predictions:")
        GuiTextRightWithColor(11, "--------------------------")
        DrawMissPredictionRow(12, "Barrier", not hitsAfterBarrier)
        DrawMissPredictionRow(13, "Drain Magic", not hitsAfterDrain)
        DrawMissPredictionRow(14, "Weakness", not hitsAfterWeakness)
        DrawMissPredictionRow(15, "Power Staff", not hitsAfterPower)
        DrawMissPredictionRow(16, "Rock One", not hitsAfterRockOne)
        DrawMissPredictionRow(17, "Melee", not hitsAfterMelee)
    end
    
    GuiTextRightWithColor(20, "Avalanche Reliability:")
    GuiTextRightWithColor(21, "--------------------------")
    GuiTextRightWithColor(22, "Safety:   " .. avalanche_safety)
    GuiTextRightWithColor(23, "Distance: " .. string.format("%.2f", avalanche_safety_distance))

    DrawSpellRow(4, "Magic Barrier", barrierHit, barrierTurns, bodyColor)
    DrawHandler(5, "Drain Magic", drainHit, 0, bodyColor)
    DrawHandler(6, "Power Staff", powerHit, powerTurns, bodyColor)
    DrawHandler(7, "Weakness", weaknessHit, weaknessTurns, bodyColor)
    DrawAvalancheHandler(8, "Avalanche", rockOverlaps, rockHits, avalancheDamage, bodyColor)
    DrawDamageHandler(9, "Rock One", Ternary(rockHit, 1, 0), rockDamage, bodyColor)
    DrawDamageHandler(10, "Melee Attack", Ternary(meleeHit, 1, 0), meleeDamage, bodyColor)

    local current_seed = string.format("%8X", GetCurrentRNG())

    if combatActive then
        local spellRows = 11
        local infoStart = spellRows + 1
    
        local bossHealth = enemyInfo.hp .. " of " .. enemyInfo.hpMax
    
        GuiTextWithColor(infoStart + 1, "Combat Info - " .. current_seed, "white")
        GuiTextWithColor(infoStart + 2, "-----------------------", "white")
        GuiTextWithColor(infoStart + 3, "Boss Health: " .. bossHealth, "white")
        GuiTextWithColor(infoStart + 4, "Barrier Turns: " .. brianInfo.barrierTurns, Ternary(brianInfo.barrierTurns > 1, "cyan", "yellow"))
        GuiTextWithColor(infoStart + 5, "Weakness Turns: " .. enemyInfo.weaknessTurns, Ternary(enemyInfo.weaknessTurns > 1, "cyan", "white"))
        GuiTextWithColor(infoStart + 6, "Power Staff Turns: " .. brianInfo.powerStaffTurns, Ternary(brianInfo.powerStaffTurns > 1, "cyan", "yellow"))
    end

    emu.frameadvance()
end


