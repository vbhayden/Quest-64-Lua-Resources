local MEM_AGI_XP = 0x7BAAD
local MEM_AGI_TOWN = 0x7BC1C
local MEM_AGI_FIELD = 0x7BC18
local MEM_AGI_BATTLE = 0x7BCA0
 
local MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
local MEM_ENCOUNTER_ACCUMULATION = 0x8C578
 
local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC
 
local MEM_ELEMENT_FIRE = 0x7BAA4
local MEM_ELEMENT_EARTH = 0x7BAA5
local MEM_ELEMENT_WATER = 0x7BAA6
local MEM_ELEMENT_WIND = 0x7BAA7
 
local MEM_ENEMY_POSITION_X = 0x7C9BC
local MEM_ENEMY_POSITION_Z = 0x7C9C4
local MEM_ENEMY_ROTATION_Y = 0x7C9CC
 
local MEM_PTR_PROJECTILE_START = 0x86F60
local MEM_PTR_PROJECTILE_LENGTH = 60
 
local MEM_CASTING_DELAY = 0x07BBD9
local MEM_TIME_UNTIL_ACTION_16BE = 0x07C99A
local MEM_BARRIER_DURATION = 0x7BB42
 
local MEM_CURRENT_RNG = 0x04D748
 
local MAP_BRANNOCH_CASTLE = 30
 
local SUBMAP_GUILTY = 10
local SUBMAP_BEIGIS = 14
 
local ELEMENT_FIRE = 1
local ELEMENT_EARTH = 2
local ELEMENT_WATER = 3
local ELEMENT_WIND = 4
local SPELL_POWER_AVALANCHE = 460
local SPELL_POWER_ROCK_1 = 290
local SPELL_POWER_WATER_1 = 365
local SPELL_POWER_WATER_2 = 374
local SPELL_POWER_WATER_3 = 384
local GUI_CHAR_WIDTH = 10
local GUI_PADDING_RIGHT = 240 + 60

local GUILTY_SPELLS = {
    [0] = {
        name = "Pound",
        advances = 0,
        advances_after = 30,
        accuracy = 100,
        hits = 1,
        power = 600,
        dispels = true
    },
}

local ACTION_DURATIONS = {
    ["Light"] = 4.0,
    ["Waves"] = 4.65,
    ["Arrows"] = 3.5,
    ["Avalanche"] = 4.8
}

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

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function printf(str, ...)
    console.log(string.format(str, ...))
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
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

local function GetCurrentRNG()
    return memory.read_u32_be(MEM_CURRENT_RNG, "RDRAM")
end

local function GetFutureRNGExplicit(advances, explicit_seed)
    local future = explicit_seed
    
    while advances > 0 do
        future = GetNextRNG(future)
        advances = advances - 1
    end

    return future
end

local function SimulateRNGCall(rngValue, rollAgainst)
    local checkBase = math.floor(rngValue / 0x10000)
    local rollValue = checkBase % rollAgainst

    return rollValue
end

local function GetEnemyAtIndex(index)

    local indexOffset = 296 * (index - 1)

    local id = memory.readbyte(0x07CA0D + indexOffset, "RDRAM")

    local hp = memory.read_u16_be(0x07C9A2 + indexOffset, "RDRAM")
    local hpMax = memory.read_u16_be(0x07C9A4 + indexOffset, "RDRAM")

    local attack = memory.read_u16_be(0x07CAAC + indexOffset, "RDRAM")
    local agility = memory.read_u16_be(0x07CAAE + indexOffset, "RDRAM")
    local defense = memory.read_u16_be(0x07CAB0 + indexOffset, "RDRAM")
    
    local x = memory.readfloat(0x7C9BC + indexOffset, true, "RDRAM")
    local y = memory.readfloat(0x7C9C0 + indexOffset, true, "RDRAM")
    local z = memory.readfloat(0x7C9C4 + indexOffset, true, "RDRAM")
    
    local sizeModifier = memory.readfloat(0x7C9E0, true, "RDRAM")
    local trueSize = memory.readfloat(0x7C9E4, true, "RDRAM")
    local size = sizeModifier * trueSize

    local weaknessTurns = memory.readbyte(0x07CA34, "RDRAM")

    local ptr_base_values_raw = memory.read_u32_be(0x7CA20, "RDRAM")
    local ptr_base_values = TrimPointer(ptr_base_values_raw)
    local ptr_base_defense = ptr_base_values + 14

    local baseDefense = memory.read_u16_be(ptr_base_defense, "RDRAM")

    return {
        id = id,
        hp = hp,
        hpMax = hpMax,
        attack = attack,
        agi = agility,
        def = defense,
        baseDefense = baseDefense,
        x = x,
        y = y,
        z = z,
        size = size,
        trueSize = trueSize,
        weaknessTurns = weaknessTurns
    }
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return brianX, brianZ
end

local function GetBrianDirection()
    local angleRadians = memory.readfloat(MEM_BRIAN_ROTATION_Y, true, "RDRAM")
    return angleRadians
end

local function GetBrianCombatInfo()

    local hp = memory.read_u16_be(0x07BA84, "RDRAM")
    local hpMax = memory.read_u16_be(0x07BA86, "RDRAM")

    local mp = memory.read_u16_be(0x07BA88, "RDRAM")
    local mpMax = memory.read_u16_be(0x07BA8A, "RDRAM")

    local baseAgi = memory.read_u16_be(0x07BA8C, "RDRAM")
    local combatAgi = memory.read_u16_be(0x07BBBE, "RDRAM")
    local combatDef = memory.read_u16_be(0x07BBC0, "RDRAM")

    local bx, bz = GetBrianLocation()
    local angle = GetBrianDirection()

    local fire = memory.readbyte(MEM_ELEMENT_FIRE, "RDRAM")
    local earth = memory.readbyte(MEM_ELEMENT_EARTH, "RDRAM")
    local water = memory.readbyte(MEM_ELEMENT_WATER, "RDRAM")
    local wind = memory.readbyte(MEM_ELEMENT_WIND, "RDRAM")
    local totalElements = fire + earth + water + wind

    local barrierTurns = memory.readbyte(0x07BB42, "RDRAM")
    local confusionTurns = memory.readbyte(0x07BB43, "RDRAM")
    local powerStaffTurns = memory.readbyte(0x07BB3C, "RDRAM")

    local staffPowerBase = 16

    return {
        hp = hp,
        hpMax = hpMax,
        mp = mp,
        mpMax = mpMax,
        baseAgi = baseAgi,
        agi = combatAgi,
        def = combatDef,
        staffPowerBase = staffPowerBase,
        staffPower = staffPowerBase,
        x = bx,
        z = bz,
        fire = fire,
        earth = earth,
        water = water,
        wind = wind,
        angle = angle,
        totalElements = totalElements,
        barrierTurns = barrierTurns,
        confusionTurns = confusionTurns,
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

local function CalculateBrianMinDamage(element, spellPower, brian_info, enemy_info)
    local elementLevel = GetBrianElementPower(element)
    local bonusPercent = CalculateSpellBonus(elementLevel)

    local resultingPower = spellPower * bonusPercent

    local affinityCoefficient = GetAffinityCoefficientByID(enemy_info.id, element)
    local rawDamage = resultingPower * affinityCoefficient

    local defenseCoefficient = brian_info.totalElements / (brian_info.totalElements + enemy_info.def)
    local minDamage = math.floor(math.floor(rawDamage) * defenseCoefficient)

    return minDamage
end

local function CalculateEnemyMinDamage(attackPower, spellPower, brian_info, enemy_info)

    local bonusPercent = CalculateSpellBonus(attackPower)
    local resultingPower = spellPower * bonusPercent

    local rawDamage = resultingPower

    local defenseCoefficient = attackPower / (attackPower + brian_info.def)
    local minDamage = math.floor(math.floor(rawDamage) * defenseCoefficient)

    return minDamage
end

local function CalculateHitChance(attackerAgi, defenderAgi)
    local top = attackerAgi * 100.0
    local bottom = attackerAgi + math.floor((defenderAgi + 7.0) / 8.0)

    local hitChance = math.floor(top / bottom)
    return hitChance
end

local function SimulateEnemyAttackRoll(current_seed, spell_accuracy, spell_power, enemy_info, brian_info)
    
    local hitSeed = GetNextRNG(current_seed)
    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= spell_accuracy then
        return false, 0, hitSeed
    end
    
    local agiSeed = GetNextRNG(hitSeed)
    local hitRoll = SimulateRNGCall(agiSeed, 100)
    local hitChance = CalculateHitChance(enemy_info.agi, brian_info.agi)
    if hitRoll >= hitChance then
        return false, 0, agiSeed
    end

    local damageSeed = GetNextRNG(agiSeed)
    local damageMin = CalculateEnemyMinDamage(enemy_info.attack, spell_power, brian_info, enemy_info)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll
    
    return true, damage, damageSeed
end

local function SimulateFollowUpStatusRoll(current_seed, effect_accuracy_out_of_32, max_effect_turns, brian_info, enemy_info)
    
    local statusSeed = GetNextRNG(current_seed)
    local roll = SimulateRNGCall(statusSeed, 32)
    if roll >= effect_accuracy_out_of_32 then
        return false, 0, statusSeed
    end

    local turnSeed = GetNextRNG(statusSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, max_effect_turns)

    return true, turns, turnSeed
end

local function SimulateBrianDamage(brian_info, damage, remove_buffs)
    if brian_info.confusionTurns > 0 then
        brian_info.mp = brian_info.mp + damage
        brian_info.mp = math.max(brian_info.mpMax, brian_info.mp)
    end

    if remove_buffs then
        brian_info.confusionTurns = 0
        brian_info.powerStaffTurns = 0
    end

    brian_info.hp = brian_info.hp - damage
end

local function SimulateGuiltyMove(seed, enemy_info, brian_info)

    local next = GetNextRNG(seed)
    -- local mammonRoll = SimulateRNGCall(next, 3)

    local spell = GUILTY_SPELLS[0]
    local attackSeed = GetFutureRNGExplicit(spell.advances, next)

    if brian_info.barrierTurns > 0 then
        return attackSeed, 0, spell
    end

    local attackSeed = attackSeed
    local attackDamage = 0

    for k=1,spell.hits do
        local hit, damage, iterSeed = SimulateEnemyAttackRoll(attackSeed, spell.accuracy, spell.power, enemy_info, brian_info)
        
        SimulateBrianDamage(brian_info, damage, spell.dispels)

        attackSeed = iterSeed
        attackDamage = attackDamage + damage
    end
    
    local finalSeed = GetFutureRNGExplicit(spell.advances_after, next)

    return finalSeed, attackDamage, spell
end

local function SimulateBrianMelee(seed, brian_info, enemy_info)

    local agilitySeed = GetFutureRNGExplicit(1, seed)
    local hitChance = CalculateHitChance(brian_info.agi, enemy_info.agi)
    local hitRoll = SimulateRNGCall(agilitySeed, 100)

    if hitRoll >= hitChance then
        return false, 0, agilitySeed
    end

    local totalElements = brian_info.totalElements
    local totalElementsInfluence = math.floor(totalElements * 1.5)
    
    local reductionThreshold = math.floor(totalElements / 4)
    local attackReduction = 0

    if brian_info.fire > reductionThreshold then
        attackReduction = attackReduction + brian_info.fire - reductionThreshold
    end
    
    if brian_info.earth > reductionThreshold then
        attackReduction = attackReduction + brian_info.earth - reductionThreshold
    end
    
    if brian_info.water > reductionThreshold then
        attackReduction = attackReduction + brian_info.water - reductionThreshold
    end
    
    if brian_info.wind > reductionThreshold then
        attackReduction = attackReduction + brian_info.wind - reductionThreshold
    end

    local spiritInfluence = totalElementsInfluence - attackReduction
    local attackPower = math.floor(spiritInfluence * brian_info.staffPower / 16)
    local defenseCoefficient = attackPower / (attackPower + enemy_info.def)

    local damageSeed = GetNextRNG(agilitySeed)
    local damageMin = math.floor(attackPower * defenseCoefficient)
    local damageRange = math.floor(math.sqrt(damageMin) + 1)
    local damage = damageMin + SimulateRNGCall(damageSeed, damageRange)

    return true, damage, damageSeed
end

local function SimulateCastBarrier(current_seed, brian_info, enemy_info)

    local futureSeed = GetFutureRNGExplicit(30, current_seed)
    local hitSeed = GetNextRNG(futureSeed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local turnSeed = GetNextRNG(hitSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, 2)

    return true, roll, turns, turnSeed
end

local function SimulateCastConfusion(current_seed, brian_info, enemy_info)

    local hitSeed = GetNextRNG(current_seed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local turnSeed = GetNextRNG(hitSeed)
    local turns = 2 + SimulateRNGCall(turnSeed, 5)

    local particleSeed = GetFutureRNGExplicit(30, turnSeed)

    return true, roll, turns, particleSeed
end

local function SimulateCastWeakness(current_seed, brian_info, enemy_info)

    local hitSeed = GetNextRNG(current_seed)

    local roll = SimulateRNGCall(hitSeed, 100)
    if roll >= 90 then
        return false, roll, 0, hitSeed
    end

    local hitSeed = GetNextRNG(hitSeed)
    local hitChance = CalculateHitChance(brian_info.agi, enemy_info.agi)
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

    local particleSeed = GetFutureRNGExplicit(30, turnSeed)

    return true, roll, turns, particleSeed
end

local function DoesRockOverlapEnemy(index, rock_x, rock_z, enemyInfo)
    
    local dx = rock_x - enemyInfo.x
    local dz = rock_z - enemyInfo.z

    local size = enemyInfo.size
    local skin_width = 0
    local enemy_bounds = size + size * skin_width
    local distance = math.sqrt(dx * dx + dz * dz)

    local rock_radius = 10.0
    local rock_bounds = rock_radius

    local overlaps = distance <= rock_bounds + enemy_bounds
    return overlaps
end

local function SimulateAvalancheRockHit(current_rng, brian_info, enemy_info)

    local accuracySeed = GetNextRNG(current_rng)

    local roll = SimulateRNGCall(accuracySeed, 100)
    if roll >= 100 then
        return false, 0, accuracySeed
    end

    local agilitySeed = GetNextRNG(accuracySeed)
    local hitChance = CalculateHitChance(brian_info.agi, enemy_info.agi)
    local hitRoll = SimulateRNGCall(agilitySeed, 100)

    if hitRoll >= hitChance then
        return false, 0, agilitySeed
    end

    local damageSeed = GetNextRNG(agilitySeed)
    local damageMin = CalculateBrianMinDamage(ELEMENT_EARTH, SPELL_POWER_AVALANCHE, brian_info, enemy_info)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll
    
    -- console.log(string.format("Post-Collision Seed: %X, Damage: %d", damageSeed, damage))

    return true, damage, damageSeed
end

local function SimulateCastAvalanche(current_rng, brian_info, enemy_info)

    local seed = current_rng
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
        printf("[%08X] == START ==", seed)
    end

    for current_frame = 1, rock_delay * 10 + harmless_duration * 2 do

        for i, rock in pairs(active_rocks) do
            
            local collision_enabled = rock.frames_active >= harmless_duration
            local rock_can_damage = collision_enabled and not rock.already_collided
            if rock_can_damage then

                local recently_activated = rock.frames_active == harmless_duration
                if recently_activated then
                    if print_now then
                        printf("[%08X] PRE-COLLISION, Rock %d", seed, rock.index)
                    end
                end

                local overlaps_enemy = DoesRockOverlapEnemy(i, rock.x, rock.z, enemy_info)
                if overlaps_enemy then
                    collision_queue[#collision_queue+1] = rock
                end
            end

            rock.frames_active = rock.frames_active + 1
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
            local offset = 20 + offsetRoll

            -- Angle Notes
            --
            -- +pi   -> +z
            --   0   -> -z
            -- +pi/2 -> -x
            -- -pi/2 -> +x
            --
            -- The avalanche orientations are aligned with world space, so the only thing
            -- that would make sense is if these angles were also for world space.
            
            local rock_x = brian_info.x - offset * math.sin(angle)
            local rock_z = brian_info.z - offset * math.cos(angle)
            
            if print_now then
                printf("[%08X] %d: %f, %f", seed, #active_rocks+1, rock_x, rock_z)

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
                z = rock_z,
                index = #active_rocks + 1
            }
        end

        if #collision_queue > 0 then
            
            for _, rock in pairs(collision_queue) do
            
                rock.already_collided = true
                rockOverlaps = rockOverlaps + 1

                local hit, damage, finalSeed = SimulateAvalancheRockHit(seed, brian_info, enemy_info)
                if hit then
                    rockHits = rockHits + 1
                    totalDamage = totalDamage + damage
                end

                seed = finalSeed

                if print_now then
                    printf("[%08X] POST-COLLISION, Rock %d - %s", seed, rock.index, Ternary(hit, "HIT: " .. damage, "MISS"))
                    printf("[%08X] POST-COLLISION, Rock %d - %f, %f", seed, rock.index, rock.x, rock.z)
                end
            end

            collision_queue = {}
        end
        
        if print_now then
            printf("[%08X] Frame %d", seed, current_frame)
        end
    end

    print_now = false

    return rockHits, totalDamage, seed
end

local function SimulateGenericDamagingSpellCast(seed, brian_info, enemy_info, element, spell_power)
    local accuracy_seed = GetNextRNG(seed)

    local roll = SimulateRNGCall(accuracy_seed, 100)
    if roll >= 100 then
        return false, 0, accuracy_seed
    end

    local hitSeed = GetNextRNG(accuracy_seed)
    local hitChance = CalculateHitChance(brian_info.agi, enemy_info.agi)
    local hitRoll = SimulateRNGCall(hitSeed, 100)

    if hitRoll >= hitChance then
        return false, 0, hitSeed
    end

    local damageSeed = GetNextRNG(hitSeed)
    local damageMin = CalculateBrianMinDamage(element, spell_power, brian_info, enemy_info)
    local damageRange = math.floor(math.sqrt(damageMin))

    local damageRoll = SimulateRNGCall(damageSeed, damageRange + 1)
    local damage = damageMin + damageRoll

    return true, damage, damageSeed
end

local function SimulateRockOneCast(seed, brian_info, enemy_info)
    return SimulateGenericDamagingSpellCast(seed, brian_info, enemy_info, ELEMENT_EARTH, SPELL_POWER_ROCK_1)
end

local function SimulateWaterOneCast(seed, brian_info, enemy_info)
    local advanced_seed = GetFutureRNGExplicit(30, seed)
    return SimulateGenericDamagingSpellCast(advanced_seed, brian_info, enemy_info, ELEMENT_WATER, SPELL_POWER_WATER_1)
end

local function SimulateManaItem(brian_info)
    brian_info.mp = brian_info.mpMax
end

local function SimulateHealingItem(brian_info)
    brian_info.hp = brian_info.hpMax
end

local function Roll(amount)
    return math.random(amount)
end

local function Coinflip()
    return math.random(2) == 1
end

local function SpendBrianMana(brian_info, mana)
    brian_info.mp = brian_info.mp - mana
end

local function EndBrianTurn(brian_info)
    if brian_info.barrierTurns > 0 then
        brian_info.barrierTurns = brian_info.barrierTurns - 1
    end
    if brian_info.confusionTurns > 0 then
        brian_info.confusionTurns = brian_info.confusionTurns - 1
    end
end

local function EndMammonTurn(mammon_info)
    if mammon_info.weaknessTurns > 0 then
        mammon_info.weaknessTurns = mammon_info.weaknessTurns - 1
    end
    
    if mammon_info.weaknessTurns > 0 then
        mammon_info.def = mammon_info.baseDefense / 2
    else
        mammon_info.def = mammon_info.baseDefense
    end
end

local function ProcessBrianTurn(final_seed, brian_info, enemy_info, turn_title, enemy_damage)
    enemy_info.hp = enemy_info.hp - enemy_damage

    return final_seed, turn_title
end

local function AddWeightedMove(pool, weight, move)
    for k=1,weight do
        pool[#pool+1] = move
    end
end

local function SimulateBrianTurn(seed, turn_index, cannot_attack_until, brian_info, enemy_info)

    local can_attack = turn_index >= cannot_attack_until
    local cannot_attack = not can_attack

    local can_afford_spells = brian_info.mp >= 3
    local can_afford_cheap_spells = brian_info.mp >= 1
    
    local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier(seed, brian_info)
    local rockHits, avalancheDamage, avalancheSeed = SimulateCastAvalanche(seed, brian_info, enemy_info)
    local meleeHit, meleeDamage, meleeSeed = SimulateBrianMelee(seed, brian_info, enemy_info)
    local waterHit, waterDamage, waterSeed = SimulateWaterOneCast(seed, brian_info, enemy_info)
    local rockHit, rockDamage, rockSeed = SimulateRockOneCast(seed, brian_info, enemy_info)
    local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(seed, brian_info, enemy_info)

    local move_pool = {}

    local barrier_reliable = brian_info.barrierTurns >= 2

    AddWeightedMove(move_pool, Ternary(barrier_reliable, 1, Ternary(barrierHit, 40, 1)), {
        move = "Barrier",
        mana = 3,
    })

    if can_afford_cheap_spells then
        AddWeightedMove(move_pool, Ternary(rockHit, 1, 0), {
            move = "Rock One",
            mana = 1,
        })
        AddWeightedMove(move_pool, Ternary(waterHit, 1, 0), {
            move = "Water One",
            mana = 1,
        })
    end

    if can_afford_spells then
        AddWeightedMove(move_pool, 7, {
            move = "Avalanche",
            mana = 3,
        })
        AddWeightedMove(move_pool, Ternary(weaknessHit, 4, 1), {
            move = "Weakness",
            mana = 3,
        })
    end

    AddWeightedMove(move_pool, Ternary(brian_info.hp <= 100, 4, 0), {
        move = "Healing Item",
    })

    AddWeightedMove(move_pool, Ternary(can_afford_spells, 1, 2), {
        move = "Melee",
        mana = -1
    })
    
    AddWeightedMove(move_pool, Ternary(can_afford_spells, 1, 4), {
        move = "Confusion",
        mana = 3,
    })
    
    AddWeightedMove(move_pool, Ternary(can_afford_spells, 1, 4), {
        move = "Mana Item",
        recover_mana = true,
    })

    AddWeightedMove(move_pool, 1, {
        move = "Passed",
    })

    local roll = Roll(#move_pool)
    local decision = move_pool[roll]
    local move = decision.move

    if move == "Weakness" then

        SpendBrianMana(brian_info, 3)
        enemy_info.weaknessTurns = weaknessTurns

        return ProcessBrianTurn(weaknessSeed, brian_info, enemy_info, "Weakness", 0)
    
    elseif move == "Avalanche" then 
        
        SpendBrianMana(brian_info, 3)
        return ProcessBrianTurn(avalancheSeed, brian_info, enemy_info, "Avalanche", avalancheDamage)

    elseif move == "Rock One" then 

        SpendBrianMana(brian_info, 1)
        return ProcessBrianTurn(rockSeed, brian_info, enemy_info, "Rock 1", rockDamage)

    elseif move == "Water One" then 

        SpendBrianMana(brian_info, 1)
        return ProcessBrianTurn(waterSeed, brian_info, enemy_info, "Water 1", waterDamage)
        
    elseif move == "Melee" then 

        SpendBrianMana(brian_info, -1)
        return ProcessBrianTurn(meleeSeed, brian_info, enemy_info, "Melee", meleeDamage)
        
    elseif move == "Mana Item" then 

        SimulateManaItem(brian_info)
        return ProcessBrianTurn(seed, brian_info, enemy_info, "Mana Item", 0)
        
    elseif move == "Confusion" then 

        SimulateManaItem(brian_info)
        return ProcessBrianTurn(seed, brian_info, enemy_info, "Confusion", 0)
    
    elseif move == "Healing Item" then 

        SimulateHealingItem(brian_info)
        return ProcessBrianTurn(seed, brian_info, enemy_info, "Healing Item", 0)
        
    elseif move == "Barrier" then

        SpendBrianMana(brian_info, 3)
        brian_info.barrierTurns = barrierTurns + 1

        return ProcessBrianTurn(barrierSeed, brian_info, enemy_info, "Barrier", 0)

    else 

        return ProcessBrianTurn(seed, brian_info, enemy_info, "Passed", 0)

    end
end

local function SimulateGuiltyFightRandomly(seed, stop_after, brian_x, brian_z, mammon_x, mammon_z)

    local brian_info = GetBrianCombatInfo()
    local mammon_info = GetEnemyAtIndex(1)

    brian_info.x = brian_x
    brian_info.z = brian_z
    
    mammon_info.x = mammon_x
    mammon_info.z = mammon_z

    local decisions = {}
    local turns = 0
    local CANNOT_ATTACK_UNTIL = 0

    while brian_info.hp > 0 and mammon_info.hp > 0 and turns < stop_after do

        local summaryLine = ""

        local brianSeed, decision = SimulateBrianTurn(seed, turns, CANNOT_ATTACK_UNTIL, brian_info, mammon_info)
        summaryLine = summaryLine .. decision

        seed = brianSeed

        EndBrianTurn(brian_info)
        
        if mammon_info.hp > 0 then
            local enemySeed, brianDamage, mammonSpell = SimulateGuiltyMove(seed, mammon_info, brian_info)
            seed = enemySeed

            EndMammonTurn(mammon_info)

            summaryLine = summaryLine .. ", " .. mammonSpell.name
        end
        
        summaryLine = summaryLine .. ", " .. brian_info.hp
        summaryLine = summaryLine .. ", " .. mammon_info.hp

        decisions[#decisions+1] = summaryLine
        
        turns = turns + 1
    end

    if brian_info.hp > 0 and mammon_info.hp > 0 then
        return false, turns, decisions
    end

    if brian_info.hp > 0 then
        return true, turns, decisions
    end

    if mammon_info.hp > 0 then
        return false, turns, decisions
    end
end

local function SimulateMammonFightManually(seed, stop_after, brian_x, brian_z, mammon_x, mammon_z)

    local brian_info = GetBrianCombatInfo()
    local mammon_info = GetEnemyAtIndex(1)

    brian_info.x = brian_x
    brian_info.z = brian_z
    
    mammon_info.x = mammon_x
    mammon_info.z = mammon_z

    local decisions = {}
    local turns = 0
    local CANNOT_ATTACK_UNTIL = 2
    
    printf("%08X", seed)
    
    local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier(seed, brian_info, mammon_info)
    brian_info.barrierTurns = barrierTurns + 1
    EndBrianTurn(brian_info)
    printf("%08X", barrierSeed)

    local mammonSeed, brianDamage, mammonSpell = SimulateGuiltyMove(barrierSeed, mammon_info, brian_info)
    EndMammonTurn(mammon_info)
    printf("%08X", mammonSeed)
    
    local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(mammonSeed, brian_info, mammon_info)
    mammon_info.weaknessTurns = weaknessTurns
    EndBrianTurn(brian_info)
    printf("%08X", weaknessSeed)
    
    local mammonSeed, brianDamage, mammonSpell = SimulateGuiltyMove(weaknessSeed, mammon_info, brian_info)
    EndMammonTurn(mammon_info)
    printf("%08X", mammonSeed)
    
    local rockHits, avalancheDamage, avalancheSeed = SimulateCastAvalanche(mammonSeed, brian_info, mammon_info)
    EndBrianTurn(brian_info)
    printf("%08X", avalancheSeed)
end

local function SaveResultsToFile(results, path)

    local outputFile = io.open(path, "w+")

    for key, value in pairs(results) do
        outputFile:write(key..","..value.."\n")
    end

    outputFile:close()
end

console.clear()

local brian_x = -4.07846
local brian_z = -99.88261

local mammon_x = 0.03925863
local mammon_z = -74.59898

local SIM_RUNS = 2000
local initial_seed = GetCurrentRNG()

local upper_bound = 15
local best_observed = 13

local brian_info = GetBrianCombatInfo()
local enemy_info = GetEnemyAtIndex(1)

console.clear()

for heals=0,12 do
    for exits=0,12 do

--         local advances = heals * 32 + exits * 31
--         local advanced_seed = GetFutureRNGExplicit(advances, initial_seed)

--         local had_success = false
--         local best_fight_duration = 20
--         local best_fight_decisions = {}

        local advances = heals * 32 + exits * 31
        local advanced_seed = GetFutureRNGExplicit(advances, initial_seed)

        -- local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier(advanced_seed, brian_info)

        -- if barrierHit and barrierTurns >= 3 then

        --     -- local enemyAttackHit, enemyAttackDamage, enemyAttackSeed = SimulateEnemyAttackRoll(barrierSeed, 100, 600, enemy_info, brian_info)
        --     -- local statusHit, statusTurns, statusSeed = SimulateFollowUpStatusRoll(enemyAttackSeed, 10, 6, enemy_info, brian_info)

        --     -- local endTurnSeed = Ternary(enemyAttackHit, statusSeed, enemyAttackSeed)
        --     -- local checkWeaknessSeed = GetFutureRNGExplicit(30, endTurnSeed)

        --     local endTurnSeed = GetFutureRNGExplicit(30, barrierSeed)

        --     local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(endTurnSeed, brian_info, enemy_info)
        --     if weaknessHit and weaknessTurns >= 4 then
        --         printf("%d heals, %d exits --> %08X w/ %d turns", heals, exits, weaknessSeed, weaknessTurns)
        --     end
        -- end
        
        local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(advanced_seed, brian_info, enemy_info)
        if weaknessHit and weaknessTurns >= 5 then

            local enemyAttackHit, enemyAttackDamage, enemyAttackSeed = SimulateEnemyAttackRoll(weaknessSeed, 100, 600, enemy_info, brian_info)
            local statusHit, statusTurns, statusSeed = SimulateFollowUpStatusRoll(enemyAttackSeed, 10, 6, enemy_info, brian_info)

            local beginExtraParticleSeed = Ternary(enemyAttackHit, statusSeed, enemyAttackSeed)
            local endTurnSeed = GetFutureRNGExplicit(30, beginExtraParticleSeed)

            local barrierHit, barrierRoll, barrierTurns, barrierSeed = SimulateCastBarrier(endTurnSeed, brian_info)
            if barrierHit and barrierTurns >= 3 then
                printf("%d heals, %d exits --> %08X w/ %d turns %s", heals, exits, barrierSeed, weaknessTurns, Ternary(not enemyAttackHit, "XXXX", ""))
            end
        end


        -- local advances = heals * 32 + exits * 31
        -- local advanced_seed = GetFutureRNGExplicit(advances, initial_seed)

        -- local weaknessHit, weaknessRoll, weaknessTurns, weaknessSeed = SimulateCastWeakness(advanced_seed, brian_info, enemy_info)

        -- if weaknessHit and weaknessTurns >= 4 then
        --     printf("%d heals, %d exits --> %08X w/ %d turns", heals, exits, weaknessSeed, weaknessTurns)
        -- end

--         printf("Simulating %d exits, %d heals ...", exits, heals)

--         for i=1,SIM_RUNS do

--             -- console.clear()

--             if i % 100 == 0 then
--                 printf("Simulating %d of %d (%d heals, %d exits)", i, SIM_RUNS, heals, exits)
--                 emu.frameadvance()
--             end
        
--             local success, turns, decisions = SimulateGuiltyFightRandomly(advanced_seed, upper_bound, brian_x, brian_z, mammon_x, mammon_z)
        
--             if success then
--                 had_success = true

--                 if turns < best_fight_duration then
--                     best_fight_duration = turns
--                     best_fight_decisions = decisions
--                 end

--                 if turns <= best_observed then
--                     if turns < best_observed then
--                         printf("New Best -- %d turns!", turns)
--                     end

--                     best_observed = turns
--                     upper_bound = turns + 2
--                 end
--             end
--         end
        
--         printf("Simulation done!  Best: %d", best_fight_duration)

--         for i,decision in pairs(best_fight_decisions) do
--             printf("%02d: %s", i, decision)
--         end
        
--         if had_success then
--             SaveResultsToFile(best_fight_decisions, string.format("%02d-turn guilty.csv", best_fight_duration, heals, exits))
--         end
    end
end

-- local brian_info = GetBrianCombatInfo()
-- local enemy_info = GetEnemyAtIndex(1)

-- local seed = GetCurrentRNG()
-- local hit, damage, seed = SimulateEnemyAttackRoll(seed, 100, 600, enemy_info, brian_info)

-- printf("Attacked for %d Damage!  %08X", damage, seed)

