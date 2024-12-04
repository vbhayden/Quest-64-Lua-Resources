
-- Memory Locations

MEM_BRIAN_POSITION_X = 0x7BACC
MEM_BRIAN_POSITION_Y = 0x7BAD4
MEM_BRIAN_SPEED_X = 0x7BAE4
MEM_BRIAN_SPEED_Y = 0x7BAEC

function getBrianSpeed()
    _sx = memory.readfloat(MEM_BRIAN_SPEED_X, true, "RDRAM")
    _sy = memory.readfloat(MEM_BRIAN_SPEED_Y, true, "RDRAM")

    return _sx, _sy
end

function getBrianLocation()
    _x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    _y = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")

    return _x, _y
end

function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function printMemoryDomains(x, y)
    local list = {}
    list = memory.getmemorydomainlist()
    local curr = memory.getcurrentmemorydomain()
    local num = table.getn(list)
    local i
    gui.text(x, y, "Current: " .. curr)
    for i = 0, num do
        gui.text(x, y + 15 * (i + 1), list[i])
    end
end

function printLocation(x, y)
    -- 0x7BABC related to movement startup
    XSpeed, YSpeed = getBrianSpeed()
    XPos, YPos = getBrianSpeed()

    Speed = math.sqrt(XSpeed * XSpeed + YSpeed * YSpeed)

    gui.text(x, y + 0, "X: " .. Round(XPos, 4))
    gui.text(x, y + 15, "Y: " .. Round(YPos, 4))
    gui.text(x, y + 30, "XSpeed: " .. Round(XSpeed, 4))
    gui.text(x, y + 45, "YSpeed: " .. Round(YSpeed, 4))
    gui.text(x, y + 60, "Speed: " .. Round(Speed, 4))
end
-- 84EE6 and 84EEE strongly related to "area/zone or maybe music"
-- memory.write_u16_be(0x084EE6, 2, "RDRAM")
-- memory.write_u16_be(0x084EEE, 2, "RDRAM")
-- memory.write_u16_be(0x08536A, 2, "RDRAM")

function printItems(x, y)
    for i = 1, 30 do
        Item = memory.readbyte(0x8CF78 + (i - 1), "RDRAM")
        if Item ~= 255 and Item <= 25 then
            gui.text(x, y + 15 * (i - 1), "Item:" .. globalItemList[Item + 1])
        end
    end
end

function printAgility(x, y)
    -- gui.text(x,y + 15*0,"Agi(?): " .. round(memory.readfloat(0x7BC14, true, "RDRAM"),4))
    -- gui.text(x+200,y + 15*0,"/800")
    gui.text(x, y + 15 * 1, "AgiField: " .. Round(memory.readfloat(0x7BC18, true, "RDRAM"), 4))
    gui.text(x + 200, y + 15 * 1, "/1000")
    gui.text(x, y + 15 * 2, "AgiTown:  " .. Round(memory.readfloat(0x7BC1C, true, "RDRAM"), 4))
    gui.text(x + 200, y + 15 * 2, "/2000")
    gui.text(x, y + 15 * 3, "AgiBattle:" .. Round(memory.readfloat(0x7BCA0, true, "RDRAM"), 4))
    gui.text(x + 200, y + 15 * 3, "/50")
    gui.text(x, y + 15 * 4, "MPRecharge: " .. Round(memory.readfloat(0x7BC0C, true, "RDRAM"), 4))
    gui.text(x + 200, y + 15 * 4, "/35")

    gui.text(x, y + 15 * 7, "BattleLastX: " .. Round(memory.readfloat(0x86B18, true, "RDRAM"), 4))
    -- gui.text(x,y+15*8,"BattleLastZ: " .. round(memory.readfloat(0x86B1C, true, "RDRAM"),4))
    gui.text(x, y + 15 * 8, "BattleLastY: " .. Round(memory.readfloat(0x86B20, true, "RDRAM"), 4))
    -- gui.text(x, y + 15 * 9, "CameraCenteredHereX: " .. round(memory.readfloat(0x86DD8, true, "RDRAM"), 4))
    -- -- gui.text(x,y+15*9,"CameraCenteredHereZ: " .. round(memory.readfloat(0x86DDC, true, "RDRAM"),4))
    -- gui.text(x, y + 15 * 10, "CameraCenteredHereY: " .. round(memory.readfloat(0x86DE0, true, "RDRAM"), 4))
    -- gui.text(x,y+15*9,"ArenaX: " .. round(memory.readfloat(0x88188, true, "RDRAM"),4))
    -- gui.text(x,y+15*10,"ArenaX: " .. round(memory.readfloat(0x881B8, true, "RDRAM"),4))
    -- gui.text(x,y+15*11,"ArenaX: " .. round(memory.readfloat(0x8C5A4, true, "RDRAM"),4))
end

function printEncounterCounter(x, y)

    EnemiesLeft = memory.readbyte(0x07C993, "RDRAM")
    TimeUntilYouAct = memory.read_u16_be(0x07C99A, "RDRAM")



    gui.text(x, y, "EncCount: " .. memory.read_u16_be(0x8C578, "RDRAM"))
    -- You can cheese 1.9 pixels as it rolls over.
    gui.text(x + 190, y, "/2000")
    gui.text(x, y + 15, "Increment: " .. Round(memory.readfloat(0x8C574, true, "RDRAM"), 4))
    RNG_EC = memory.read_u32_be(0x4D748, "RDRAM")
    gui.text(x, y + 30, "RNG: " .. RNG_EC .. " = " .. string.format("%08X ", RNG_EC))
    gui.text(x, y + 45, "A: " .. memory.read_u16_be(0x22FE2, "RDRAM"))
    gui.text(x, y + 60, "B: " .. memory.read_u16_be(0x22FE4, "RDRAM") - 1000)
    gui.text(x, y + 75, "C: " .. memory.read_u16_be(0x22FE6, "RDRAM"))
    
    gui.text(x, y + 90, "Enemies: " .. EnemiesLeft)
    gui.text(x, y + 105, "Actions: " .. TimeUntilYouAct)
end

function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return table.concat(t)
end

function freeze_encounters()
    memory.write_u16_be(0x8C578, 0, "RDRAM")
    memory.writefloat(0x8C574, 0, true, "RDRAM")
end

function highEncounterCounter()
    memory.write_u16_be(0x8C578, 1999, "RDRAM")
end

function printEnemyStats(x, y)
    EnemiesLeft = memory.readbyte(0x07C993, "RDRAM")
    TimeUntilYouAct = memory.read_u16_be(0x07C99A, "RDRAM")

    gui.text(x, y, "ToAct:" .. TimeUntilYouAct)

    NumEnemies = EnemiesLeft -- For Now, Not Ideal
    if NumEnemies > 0 then
        for i = 1, NumEnemies do

            Base = 0x07C99C -- next = 0x07CAC4
            WalkDec1 = memory.read_u16_be(0x07C99C + 296 * (i - 1), "RDRAM")

            RelatedToAttacking = memory.read_u16_be(0x07C99E + 296 * (i - 1), "RDRAM")
            RelatedToAttacking2 = memory.read_u16_be(0x07C9A0 + 296 * (i - 1), "RDRAM")
            FloatSomething = memory.readfloat(0x7C9A8 + 296 * (i - 1), true, "RDRAM")

            CurrHP = memory.read_u16_be(0x07C9A2 + 296 * (i - 1), "RDRAM") -- 9A2 and ACA and BF2  --7C993 = dead?  3 = alive, 2 = dead? (296 = 0x128)
            MaxHP = memory.read_u16_be(0x07C9A4 + 296 * (i - 1), "RDRAM")

            X = memory.readfloat(0x7C9BC + 296 * (i - 1), true, "RDRAM")
            Z = memory.readfloat(0x7C9C0 + 296 * (i - 1), true, "RDRAM")
            Y = memory.readfloat(0x7C9C4 + 296 * (i - 1), true, "RDRAM")

            RapidlyChanging1 = memory.read_u16_be(0x07C9C6 + 296 * (i - 1), "RDRAM")
            RapidlyChanging2 = memory.read_u16_be(0x07C9D4 + 296 * (i - 1), "RDRAM")
            RapidlyChanging3 = memory.read_u16_be(0x07C9D6 + 296 * (i - 1), "RDRAM")
            RapidlyChanging4 = memory.read_u16_be(0x07C9DC + 296 * (i - 1), "RDRAM")
            RapidlyChanging5 = memory.read_u16_be(0x07C9DE + 296 * (i - 1), "RDRAM")

            SizeModifier = memory.readfloat(0x7C9E0 + 296 * (i - 1), true, "RDRAM")

            -- memory.writefloat(0x7C9E0, 0.4, true, "RDRAM") -- Meme Address
            
            TrueSize = memory.readfloat(0x7C9E4 + 296 * (i - 1), true, "RDRAM")
            Float3 = memory.readfloat(0x7C9E8 + 296 * (i - 1), true, "RDRAM")
            Float4 = memory.readfloat(0x7C9EC + 296 * (i - 1), true, "RDRAM")
            Float5 = memory.readfloat(0x7C9F0 + 296 * (i - 1), true, "RDRAM")

            -- Hell Hound: Anything below 20.9 distance from center to center."
            -- Were Hare less than 15.6 hits.  Difference of 5.3     

            -- Hell Hound sphere of influence is about 27.0
            -- 0.084
            -- 130
            -- 130 * 0.084 = 10.92
            -- -1.428
            -- 1
            -- 120

            -- 0.07
            -- 80
            -- 80 * 0.07 = 5.6
            -- 0.2275
            -- 1
            -- 120

            OTHER = memory.readbyte(0x07CA09 + 296 * (i - 1), "RDRAM") -- A0D
            ID = memory.readbyte(0x07CA0D + 296 * (i - 1), "RDRAM") -- A0D

            RapidlyChanging6 = memory.read_u16_be(0x07CA10 + 296 * (i - 1), "RDRAM")
            RapidlyChanging7 = memory.read_u16_be(0x07CA12 + 296 * (i - 1), "RDRAM")

            RelatedToAttacking3 = memory.readbyte(0x07CA19 + 296 * (i - 1), "RDRAM")
            Dunno1 = memory.readbyte(0x07CA1B + 296 * (i - 1), "RDRAM")

            Atk = memory.read_u16_be(0x07CAAC + 296 * (i - 1), "RDRAM")
            Agi = memory.read_u16_be(0x07CAAE + 296 * (i - 1), "RDRAM")
            Def = memory.read_u16_be(0x07CAB0 + 296 * (i - 1), "RDRAM")
            -- Exp does not appear to be here.  Total Exp for battle maybe?

            gui.text(x + 100 * (i - 1), y + 15, "HP:" .. CurrHP .. "/" .. MaxHP)
            gui.text(x + 100 * (i - 1), y + 30, "At:" .. Atk)
            gui.text(x + 100 * (i - 1), y + 45, "De:" .. Def)
            gui.text(x + 100 * (i - 1), y + 60, "Ag:" .. Agi)
            gui.text(x + 100 * (i - 1), y + 75, "ID:" .. ID)
            gui.text(x + 100 * (i - 1), y + 90, "OTHER:" .. OTHER)
            gui.text(x + 100 * (i - 1), y + 105, "WalkDec:" .. WalkDec1)
            gui.text(x + 100 * (i - 1), y + 120, "Size:" .. Round(SizeModifier * TrueSize, 4))
        end
    end
end

function printEnemyMysteryValues(x, y)

    EnemiesLeft = memory.readbyte(0x07C993, "RDRAM")
    TimeUntilYouAct = memory.read_u16_be(0x07C99A, "RDRAM")

    gui.text(x, y, "ToAct:" .. TimeUntilYouAct)

    NumEnemies = EnemiesLeft -- For Now, Not Ideal
    if NumEnemies > 0 then
        for i = 1, NumEnemies do

            iterOffset = 250

            _offset = 296 * (i - 1)

            -- Whether Brian can move currently during the attack
            AllowBrianMovement = memory.read_u16_be(0x07C99E + _offset, "RDRAM") 

            for k = 1, 10 do
                val = memory.read_u16_be(0x07C99E + _offset + 4 * k, "RDRAM")
                -- bits = toBits(val)
                bits = val
                gui.text(x + iterOffset * (i - 1), y + 60 + 15 * k,  "Combat Byte " .. k .. ": " .. bits)
            end

            -- Whether the Boss will move to attack
            BossWillMove = memory.readbyte(0x07C9A1 + _offset, "RDRAM")

            Float2 = memory.readfloat(0x7C9A8 + _offset, true, "RDRAM")
            Float3 = memory.readfloat(0x7C9E8 + _offset, true, "RDRAM")
            Float4 = memory.readfloat(0x7C9EC + _offset, true, "RDRAM")
            -- Float5 = memory.readfloat(0x7C9F0 + _offset, true, "RDRAM")
            

            -- RapidlyChanging1 = memory.read_u16_be(0x07C9C6 + 296 * (i - 1), "RDRAM")
            -- RapidlyChanging2 = memory.read_u16_be(0x07C9D4 + 296 * (i - 1), "RDRAM")
            -- RapidlyChanging3 = memory.read_u16_be(0x07C9D6 + 296 * (i - 1), "RDRAM")
            -- RapidlyChanging4 = memory.read_u16_be(0x07C9DC + 296 * (i - 1), "RDRAM")
            -- RapidlyChanging5 = memory.read_u16_be(0x07C9DE + 296 * (i - 1), "RDRAM")
            
            RapidlyChanging1 = memory.read_u16_be(0x07C9C6 + 296 * (i - 1), "RDRAM")
            RapidlyChanging2 = memory.read_u16_be(0x07C9CA + 296 * (i - 1), "RDRAM")
            RapidlyChanging3 = memory.read_u16_be(0x07C9CE + 296 * (i - 1), "RDRAM")
            RapidlyChanging4 = memory.read_u16_be(0x07C9D2 + 296 * (i - 1), "RDRAM")
            RapidlyChanging5 = memory.read_u16_be(0x07C9D6 + 296 * (i - 1), "RDRAM")

            RapidlyChanging6 = memory.read_u16_be(0x07CA10 + _offset, "RDRAM")
            RapidlyChanging7 = memory.read_u16_be(0x07CA12 + _offset, "RDRAM")

            RelatedToAttacking3 = memory.readbyte(0x07CA14 + _offset, "RDRAM")
            RelatedToAttacking4 = memory.readbyte(0x07CA16 + _offset, "RDRAM")
            RelatedToAttacking5 = memory.readbyte(0x07CA18 + _offset, "RDRAM")
            RelatedToAttacking6 = memory.readbyte(0x07CA1A + _offset, "RDRAM")
            
            WalkDec1 = memory.read_u16_be(0x07C99C + _offset, "RDRAM")

            Dunno1 = memory.readbyte(0x07CA1B + _offset, "RDRAM")
            Dunno2 = memory.readbyte(0x07CA1F + _offset, "RDRAM")
            Dunno3 = memory.readbyte(0x07CA20 + _offset, "RDRAM")
            Dunno4 = memory.readbyte(0x07CA24 + _offset, "RDRAM")
            Dunno5 = memory.readbyte(0x07CA28 + _offset, "RDRAM")
            
            local sy = 0
            local function hudText(text)
                sy = sy + 15
                gui.text(x + iterOffset * (i - 1), y + sy, text)
            end


            hudText("Brian Can Move: " .. AllowBrianMovement)
            hudText("Boss Will Move: " .. BossWillMove)
            
            hudText("?Atk 3: " .. RelatedToAttacking3)
            hudText("?Atk 3: " .. RelatedToAttacking4)
            hudText("?Atk 4: " .. RelatedToAttacking5)
            hudText("?Atk 5: " .. RelatedToAttacking6)
            hudText("?Walk : " .. WalkDec1)

            -- gui.text(x + iterOffset * (i - 1), y + 60,  "?Rapid 1: " .. RapidlyChanging1)
            -- gui.text(x + iterOffset * (i - 1), y + 75,  "?Rapid 2: " .. RapidlyChanging2)
            -- gui.text(x + iterOffset * (i - 1), y + 90,  "?Rapid 3: " .. RapidlyChanging3)
            -- gui.text(x + iterOffset * (i - 1), y + 105, "?Rapid 4: " .. RapidlyChanging4)
            -- gui.text(x + iterOffset * (i - 1), y + 120, "?Rapid 5: " .. RapidlyChanging5)

            hudText("?Val 2: " .. Float3)
            hudText("?Val 3: " .. Float3)
            hudText("?Val 4: " .. Float4)

            hudText("?idk 2: " .. Dunno2)
            hudText("?idk 3: " .. Dunno3)
            hudText("?idk 4: " .. Dunno4)
            hudText("?idk 5: " .. Dunno5)
            
            -- gui.text(x + iterOffset * (i - 1), y + 120, "?Rapid 6: " .. RapidlyChanging6)
            -- gui.text(x + iterOffset * (i - 1), y + 135, "?Rapid 7: " .. RapidlyChanging7)

            -- gui.text(x + iterOffset * (i - 1), y + 150, "?idk 1: " .. Dunno1)
        end
    end
end

-- Solvaring
-- Zelse
-- Nepty
-- Shilf
-- Fargo
-- Guilty
-- Beigis Stats in ROM at D87944
-- Mammon in ROM at D8797C --Offset is 0x38
-- *
-- *
-- 6 areas and bosses
--
-- 0x112664 07D0BF 07D0AF 07D0AE 07D0AD 07D0AA 07D0A9
-- 1 96 68 9 39 8 39
-- 0 116 112 90 41 89 41
-- 255 136 184 144 38 144 38
-- 0 156 164 32 40 31 40
-- 0 176 192 140 39 140 39

-- 39 39 39 39 39 8 144 39 9 68 96 65 141
-- 41 41 41 41 41 89 144 41 90 112 116 129 147

-- Were Hare ADC094 80, 140, 0.07
-- Hell Hound 130, 170, 0.084
-- Man Eater 115, 135, 0.084
-- Big Mouth ADC13C 130, 70, 0.105
-- Parassault 90, 150, 0.077
-- Orc Jr 90, 150, 0.077
-- Gremlin 90, 140, 0.084
-- Skeleton 90, 135, 0.084
-- Ghost Hound 90, 238, 0.084
-- Merrow 130, 170, 0.084
-- Wolf Goat 80, 125, 0.084, 130, 170, 0.091
-- *
-- Goblin B6337C
-- Frog King
-- Apophis
-- Mad Doll
-- Death Hugger
-- Kobold
-- Man Trap
-- Bat
-- Frog Knight
-- Marionasty
-- Dark Goblin
-- Hot Lips
-- Ghost Stalker B6361C
-- Treant
-- Cockatrice
-- *
-- Multi-Optics BBDE9C
-- Mimic
-- Crawler
-- Scorpion
-- Scare Crow
-- Wyvern
-- Skelebat
-- Cryshell BBE024
-- Blood Jell
-- Caterpillar (9)  -- C7D935 is interesting, may be red herring
-- Fish Man
-- *
-- Sandman (ID 0) C317EC
-- Werecat
-- Nightmare
-- Blue Man
-- Winged Sunfish
-- Gloon Wing
-- Ogre (ID 6)  
-- Rocky (ID 7)
-- Red Wyvern
-- FlamedMane
-- Magma Fish
-- RedRose (ID 11)
-- WhiteRoseKnight: C31A8C
-- *
-- Orc C9BE54
-- Ghost C9BE8C 
-- Will o Wisp
-- Sprite
-- JackoLantern
-- Arachnoid
-- Lamia
-- Temptress
-- Pixie
-- Grangach
-- Thunder Jell
-- Termant
-- *
-- Judgment HP: CC443C
-- Pin Head HP: CC44AC
-- Pale Rider: CC4474
-- Spriggan: CC44E4

-- RNG ROM
-- 023BE2 =16838 and 023BE6 = 20077
-- 41C64E6Dh + 3039h
-- 12345 or 13345  ??
-- 023BE4

-- RNG RAM
-- 022FE0
-- memory.write_u16_be(0x22FE2, 0, "RDRAM")
-- memory.write_u16_be(0x22FE4, 300, "RDRAM")
-- memory.write_u16_be(0x22FE6, 0, "RDRAM")

-- Avalanche Y starts at 0x86F2C

function printStats(x, y)
    local Exp = memory.read_u32_be(0x07BA90, "RDRAM")
    local HPLv = memory.readbyte(0x07BAB0, "RDRAM")
    local MPLv = memory.readbyte(0x07BAB1, "RDRAM")
    local AgiLv = memory.readbyte(0x07BAB2, "RDRAM")
    local DefLv = memory.readbyte(0x07BAB3, "RDRAM")
    local Lv = memory.readbyte(0x07BAB4, "RDRAM")
    local CurrHP = memory.read_u16_be(0x7BA84, "RDRAM")
    local MaxHP = memory.read_u16_be(0x7BA86, "RDRAM")
    local HPSub = memory.readbyte(0x7BAA9, "RDRAM")
    local CurrMP = memory.read_u16_be(0x7BA88, "RDRAM")
    local MaxMP = memory.read_u16_be(0x7BA8A, "RDRAM")
    local MPSub = memory.readbyte(0x7BAAB, "RDRAM")
    local Def = memory.readbyte(0x7BA8F, "RDRAM")
    local DefSub = memory.readbyte(0x7BAAF, "RDRAM")
    local Agi = memory.readbyte(0x7BA8D, "RDRAM")
    local AgiSub = memory.readbyte(0x7BAAD, "RDRAM")
    gui.text(x, y + 0, "HP: " .. CurrHP .. "/" .. MaxHP .. " (" .. HPSub .. "/" .. globalStatTable[HPLv + 1] .. ")")
    gui.text(x, y + 15, "MP: " .. CurrMP .. "/" .. MaxMP .. " (" .. MPSub .. "/" .. 4 * globalStatTable[MPLv + 1] .. ")")
    gui.text(x, y + 30, "Def: " .. Def .. " (" .. DefSub .. "/" .. 2 * globalStatTable[DefLv + 1] .. ")")
    gui.text(x, y + 45, "Agi: " .. Agi .. " (" .. AgiSub .. "/" .. globalStatTable[AgiLv + 1] .. ")")
    gui.text(x, y + 60, "Lv: " .. Lv .. " (" .. Exp .. "/" .. globalLvTable[Lv + 1] .. ")")
end

function HP50()
    memory.write_u16_be(0x7BA84, 50, "RDRAM")
end
function setSpirits(f, e, wa, wi)
    memory.writebyte(0x7BAA4, f, "RDRAM")
    memory.writebyte(0x7BAA5, e, "RDRAM")
    memory.writebyte(0x7BAA6, wa, "RDRAM")
    memory.writebyte(0x7BAA7, wi, "RDRAM")
end
function setStats(CurrHP, MaxHP, CurrMP, MaxMP, De, Ag)
    
    memory.write_u16_be(0x7BA84, CurrHP, "RDRAM")
    memory.write_u16_be(0x7BA86, MaxHP, "RDRAM")
    memory.write_u16_be(0x7BA88, CurrMP, "RDRAM")
    memory.write_u16_be(0x7BA8A, MaxMP, "RDRAM")
    memory.writebyte(0x7BA8F, De, "RDRAM")
    memory.writebyte(0x7BA8D, Ag, "RDRAM")
end
function stackOfJewelsAndWings()
    -- Earth Orb opens Connor Fortress door.
    -- Wind Jade opens door to access Blue Cave.
    -- Water Jewel reopens ship.
    -- Fire Ruby shortcut.
    memory.writebyte(0x8CF78, 20, "RDRAM")
    memory.writebyte(0x8CF79, 21, "RDRAM")
    memory.writebyte(0x8CF7A, 22, "RDRAM")
    memory.writebyte(0x8CF7B, 23, "RDRAM")
    memory.writebyte(0x8CF7C, 14, "RDRAM")
    memory.writebyte(0x8CF7D, 15, "RDRAM")
    memory.writebyte(0x8CF7E, 16, "RDRAM")
    memory.writebyte(0x8CF7F, 17, "RDRAM")
    memory.writebyte(0x8CF80, 18, "RDRAM")
    memory.writebyte(0x8CF81, 19, "RDRAM")
    
    -- 9:  Celine's Bell
    memory.writebyte(0x8CF82, 9, "RDRAM")
    -- 11: Giant's Shoes
    memory.writebyte(0x8CF83, 11, "RDRAM")
end

function setInventory(...)

    local index = 0x8CF78

    for k, item in ipairs(arg) do
        memory.writebyte(index, item, "RDRAM")
        index = index + 1
    end

    memory.writebyte(index, -1, "RDRAM")

end

function setupLvTable(tmpTable)
    -- This table is calculated off the current level.
    local i
    for i = 1, 99 do
        tmpTable[i] = memory.read_u32_be(0x05493C + 4 * (i - 1), "ROM")
    end
    return tmpTable
end
function printLvTable(x, y, tmpTable)
    local i
    for i = 1, 99 do
        gui.text(x, y + i * 15, tmpTable[i])
    end
end
function setupStatTable(tmpTable1)
    -- This table is calculated off the concept of numStatLevels, not current level.
    local i
    for i = 1, 70 do
        tmpTable1[i] = memory.read_u16_be(0x054ACC + 2 * (i - 1), "ROM")
    end
    return tmpTable1
end
function printStatTable(x, y, tmpTable1)
    -- ROM 0x054909 is starting stats I think?
    local i
    for i = 1, 70 do
        gui.text(x, y + i * 15, tmpTable1[i])
    end
end

function printBrianLocation(x, y)
    local brianX = memory.readfloat(0x7BACC, true, "RDRAM")
    local brianY = memory.readfloat(0x7BAD4, true, "RDRAM")
    
    gui.text(x, y + 0, "Brian X: " .. brianX)
    gui.text(x, y + 15, "Brian Y: " .. brianY)
end

function setBrianLocation(px, py)
    memory.writefloat(0x7BACC, px, true, "RDRAM")
    memory.writefloat(0x7BAD4, py, true, "RDRAM")
end

function printObjectCoordinates(x, y)
    -- memory.writefloat(0x86F2C, 1600, true, "RDRAM")
    brianX = memory.readfloat(0x7BACC, true, "RDRAM")
    brianY = memory.readfloat(0x7BAD4, true, "RDRAM")

    i = 1 -- Enemy number 1 (starting at 1)
    EnemyX = memory.readfloat(0x7C9BC + 296 * (i - 1), true, "RDRAM")
    EnemyY = memory.readfloat(0x7C9C4 + 296 * (i - 1), true, "RDRAM")

    for i = 1, 10 do
        -- memory.writefloat(0x86F24 + 60*(i-1), -20, true, "RDRAM") --X
        -- memory.writefloat(0x86F2C + 60*(i-1), -350, true, "RDRAM") --Y

        -- RightSide -1367,930
        -- LeftSide -1327, 930
        -- BackSide -1347, 948
        -- FrontSide -1347, 908

        -- Hell Hound: Anything below 20.9 distance from center to center."
        -- Were Hare less than 15.6 hits.
        --
        -- Solvaring 10 + 8.4  Note: Solvaring is moving about half a pixel during standing.
        -- Zelse 10 + 5.6  (Investigate Zelse Mid-Range)  Zelse moves about 0.4 pixels during standing.  He recoils a couple pixels when hit.
        -- Nepty 10 + 4.9  Nepty moves about 0.4 px during standing.
        -- Shilf 10 + 4.9  Shilf moves about 0.05
        -- Fargo 10 + 7 moves about 0.05
        -- Guilty 10 + 9.52 No movement
        -- Beigis 10 + 6.3 No movement
        -- Mammon 10 + 94.5 Moves around 0.6 px.

        Timer = memory.read_u16_be(0x86F1C + 60 * (i - 1), "RDRAM")
        X = memory.readfloat(0x86F24 + 60 * (i - 1), true, "RDRAM")
        Z = memory.readfloat(0x86F28 + 60 * (i - 1), true, "RDRAM")
        Y = memory.readfloat(0x86F2C + 60 * (i - 1), true, "RDRAM")
        XDiff = brianX - X
        YDiff = brianY - Y
        D = math.sqrt(XDiff * XDiff + YDiff * YDiff)
        A = math.atan2(XDiff, YDiff) * (180 / (math.pi))
        EnemyXDiff = EnemyX - X
        EnemyYDiff = EnemyY - Y
        EnemyD = math.sqrt(EnemyXDiff * EnemyXDiff + EnemyYDiff * EnemyYDiff)
        EnemyA = math.atan2(EnemyXDiff, EnemyYDiff) * (180 / (math.pi))

        j = 0
        if i > 5 then
            j = 1
        end

        if (Timer > 0) then
            gui.text(x + 140 * (i - j * 5 - 1), y + 0 * 15 + j * 100, "Timer: " .. Timer)
            gui.text(x + 140 * (i - j * 5 - 1), y + 1 * 15 + j * 100, "X: " .. Round(X, 3))
            gui.text(x + 140 * (i - j * 5 - 1), y + 2 * 15 + j * 100, "Z: " .. Round(Z, 3))
            gui.text(x + 140 * (i - j * 5 - 1), y + 3 * 15 + j * 100, "Y: " .. Round(Y, 3))
            gui.text(x + 140 * (i - j * 5 - 1), y + 4 * 15 + j * 100, "D: " .. Round(D, 3))
            gui.text(x + 140 * (i - j * 5 - 1), y + 5 * 15 + j * 100, "A: " .. Round(A, 3)) -- 16 angles
            -- gui.text(x+140*(i-j*5-1),y+4*15 + j*100,"D: " .. round(EnemyD,3))
            -- gui.text(x+140*(i-j*5-1),y+5*15 + j*100,"A: " .. round(EnemyA,3))
        end
    end

    -- F1C Timer
    -- F24 X
    -- F28 Z
    -- F2C Y

    -- F60 X
    -- F64 Z
    -- F68 Y
end

function displayMusic(x, y)

    -- 84EE6 and 84EEE strongly related to "area/zone or maybe music"
    -- memory.write_u16_be(0x084EE6, 2, "RDRAM")
    -- memory.write_u16_be(0x084EEE, 2, "RDRAM")
    -- memory.write_u16_be(0x08536A, 2, "RDRAM")

    music1 = memory.read_u16_be(0x084EE6, "RDRAM")
    music2 = memory.read_u16_be(0x084EEE, "RDRAM")
    music3 = memory.read_u16_be(0x08536A, "RDRAM")
    
    gui.text(x, y + 15 * 0, "Music 1?: " .. music1)
    gui.text(x, y + 15 * 1, "Music 2?: " .. music2)
    gui.text(x, y + 15 * 2, "Music 3?: " .. music3)
end

globalItemList = {"0. Spirit Light", "1. Fresh Bread", "2. Honey Bread", "3. Healing Potion", "4  Dragon's Potion",
                  "5. Dew Drop", "6. Mint Leaves", "7. Heroes Drink", "8. Silent Flute", "9.Celine's Bell",
                  "10.Replica", "11.Giant's Shoes", "12.Silver Amulet", "13.Golden Amulet", "14.White Wings",
                  "15.Yellow Wings", "16.Blue Wings", "17.Green Wings", "18.Red Wings", "19.Black Wings",
                  "20.Earth Orb", "21.Wind Jade", "22.Water Jewel", "23.Fire Ruby", "24.Eletale Book",
                  "25.Dark Gaol Key"}

ITEM_SPIRIT_LIGHT = 0
ITEM_FRESH_BREAD = 1
ITEM_HONEY_BREAD = 2
ITEM_HEALING_POTION = 3

ITEM_DRAGONS_POTION = 4
ITEM_DEW_DROP = 5
ITEM_MINT_LEAVES = 6
ITEM_HEROES_DRINK = 7

ITEM_SILENT_FLUTE = 8
ITEM_CELINES_BELL = 9
ITEM_REPLICA = 10
ITEM_GIANTS_SHOES = 11
ITEM_SILVER_AMULET = 12
ITEM_GOLDEN_AMULET = 13

ITEM_WINGS_WHITE = 14
ITEM_WINGS_YELLOW = 15
ITEM_WINGS_BLUE = 16
ITEM_WINGS_GREEN = 17
ITEM_WINGS_RED = 18
ITEM_WINGS_BLACK = 19

ITEM_KEY_EARTH_ORB = 20
ITEM_KEY_WIND_JADE = 21
ITEM_KEY_WATER_JEWEL = 22
ITEM_KEY_FIRE_RUBY = 23
ITEM_KEY_ELETALE_BOOK = 24
ITEM_KEY_DARK_GAOL = 25


function CalcNextRNG(x, y)
    RNG1 = memory.read_u32_be(0x04D748, "RDRAM")
    Next1RNG = getNextRNG(RNG1)
    Next2RNG = getNextRNG(Next1RNG)
    Next3RNG = getNextRNG(Next2RNG)

    -- gui.text(400,490,"NextLo: " .. string.format("%08X ",R_LO2))
    -- gui.text(400,505,"NextHi: " .. string.format("%08X ",R_HI2))
    gui.text(x, y + 0, "NextRNG1: " .. string.format("%08X ", Next1RNG))
    gui.text(x, y + 15, "NextRNG2: " .. string.format("%08X ", Next2RNG))
    gui.text(x, y + 30, "NextRNG3: " .. string.format("%08X ", Next3RNG))
    gui.text(x, y + 45, "BufRNG1: " .. string.format("%08X ", BufRNG))
    gui.text(x, y + 60, "BufRNG2: " .. string.format("%08X ", BufRNG2))
    gui.text(x, y + 75, "BufRNG3: " .. string.format("%08X ", BufRNG3))

    if RNGTableGlobal[1] ~= nil then
        for i = 1, 10000 do
            if RNG1 == RNGTableGlobal[i] then
                gui.text(x, y + 90 + i * 15, "RNG Increment: " .. i)
                i = 1000000
            end
        end
    end

    if PrevRNG ~= Next1RNG then
        BufRNG3 = PrevRNG3
        BufRNG2 = PrevRNG2
        BufRNG = PrevRNG
        PrevRNG3 = Next3RNG -- This is poorly buffered and doesn't quite work right, basically just a sanity check.
        PrevRNG2 = Next2RNG -- This is poorly buffered and doesn't quite work right, basically just a sanity check.
        PrevRNG = Next1RNG -- Lol double buffer
    end
end

function getNextRNG(passedRNG)
    A1 = memory.read_u16_be(0x22FE2, "RDRAM")
    B1 = memory.read_u16_be(0x22FE4, "RDRAM") - 1000
    C1 = memory.read_u16_be(0x22FE6, "RDRAM")

    R_HI1 = math.floor(passedRNG / 0x10000)
    R_LO1 = passedRNG % 0x10000

    R_HI2 = A1 * R_LO1 + (R_HI1 * C1)
    R_HI2 = R_HI2 % 65536
    R_LO2 = R_LO1 * C1 + B1 -- 16,16,16
    passedRNG = (65536 * R_HI2 + R_LO2) % 0x100000000

    return passedRNG
end

function generateRNGTable(makeDumpfile)

    RNGTextfile = "RNGDump"
    RNGDumpfile = RNGTextfile .. ".txt"
    if makeDumpfile then
        io.output(RNGDumpfile)
        startRNGSeed = 2209236614
        ThisR = startRNGSeed
        io.write(ThisR)
        io.write("\n")
        for i = 2, 10000 do
            ThisR = getNextRNG(ThisR)
            io.write(ThisR)
            io.write("\n")
        end
        io.output():close()
    end

    -- Magic Barrier Test Section
    --[[
  NN = 39
  RNGTextfile2 = "RNGDumpNOrdered"
  RNGDumpfile2 = RNGTextfile2..".txt"
  if makeDumpfile then
  io.output(RNGDumpfile2)
  startRNGSeed = 1
  ThisR = startRNGSeed
  for j = 1,NN do
  ThisR = getNextRNG(ThisR)
  end
  AA = ThisR
  for j = 1,NN do
  ThisR = getNextRNG(ThisR)
  end
  BB = ThisR
  
  if ((math.floor(AA)/65536) % 100) >= 90 and ((math.floor(BB)/65536) % 100) >= 90 then
  io.write("1")
  io.write("\n")
  elseif ((math.floor(AA)/65536) % 100) >= 90 then
  io.write("0")
  io.write("\n")
  end
  
  --io.write(ThisR)
  --io.write("\n")
  for i=2,10000 do
  ThisR = i
  for j = 1,NN do
  ThisR = getNextRNG(ThisR)
  end
  AA = ThisR
  for j = 1,NN do
  ThisR = getNextRNG(ThisR)
  end
  BB = ThisR
  
  if ((math.floor(AA)/65536) % 100) >= 90 and ((math.floor(BB)/65536) % 100) >= 90 then
  io.write("1")
  io.write("\n")
  elseif ((math.floor(AA)/65536) % 100) >= 90 then
  io.write("0")
  io.write("\n")
  end
  
  --io.write(ThisR)
  --io.write("\n")
  end
  io.output():close()
  end
  ]]
    -- End Magic Barrier Test Section

    -- Make table
    startRNGSeed = 2209236614
    ThisR = startRNGSeed
    RNGTableGlobal[1] = ThisR
    for i = 2, 10000 do
        ThisR = getNextRNG(ThisR)
        RNGTableGlobal[i] = ThisR
    end

end

function avalancheBasher()
    -- Start with a file loaded ready to cast avalanche.

    -- =20*(W2/22.5)+(V2-20)+180
    savestate.saveslot(9)
    AvTextfile = "Avalanche Basher"
    AvDumpfile = AvTextfile .. ".txt"
    io.output(AvDumpfile)
    startRNGSeed = 2209236614
    ThisR = startRNGSeed
    D = 0
    A = 0
    for j = 1, 20000 do
        savestate.loadslot(9)
        memory.write_u32_be(0x04D748, j, "RDRAM") -- RNG
        emu.frameadvance()
        joypad.set({
            ["A"] = true
        }, 1)
        memory.write_u32_be(0x04D748, j, "RDRAM") -- RNG
        emu.frameadvance()
        joypad.set({
            ["A"] = true
        }, 1)
        for k = 1, 36 do
            emu.frameadvance()
            memory.write_u32_be(0x04D748, j, "RDRAM") -- RNG
            gui.text(100, 100, "D: " .. Round(D, 3))
            gui.text(100, 115, "A: " .. Round(A, 3)) -- 16 angles
            gui.text(100, 130, "Iteration: " .. j) -- 16 angles
        end

        brianX = memory.readfloat(0x7BACC, true, "RDRAM")
        brianY = memory.readfloat(0x7BAD4, true, "RDRAM")

        i = 1 -- Enemy number 1 (starting at 1)
        EnemyX = memory.readfloat(0x7C9BC + 296 * (i - 1), true, "RDRAM")
        EnemyY = memory.readfloat(0x7C9C4 + 296 * (i - 1), true, "RDRAM")
        Timer = memory.read_u16_be(0x86F1C + 60 * (i - 1), "RDRAM")
        X = memory.readfloat(0x86F24 + 60 * (i - 1), true, "RDRAM")
        Z = memory.readfloat(0x86F28 + 60 * (i - 1), true, "RDRAM")
        Y = memory.readfloat(0x86F2C + 60 * (i - 1), true, "RDRAM")
        XDiff = brianX - X
        YDiff = brianY - Y
        D = math.sqrt(XDiff * XDiff + YDiff * YDiff)
        D = Round(D, 3)
        A = math.atan2(XDiff, YDiff) * (180 / (math.pi))
        A = Round(A, 3)
        EnemyXDiff = EnemyX - X
        EnemyYDiff = EnemyY - Y
        EnemyD = math.sqrt(EnemyXDiff * EnemyXDiff + EnemyYDiff * EnemyYDiff)
        EnemyA = math.atan2(EnemyXDiff, EnemyYDiff) * (180 / (math.pi))

        ThisR = getNextRNG(ThisR)
        -- =20*(W4/22.5)+(V4-20)+180
        V = 20 * (A / 22.5) + (D - 20) + 180 -- unique Rock ID

        io.write(V)
        io.write("\n")
    end
    io.output():close()

end

function setupConnorDD()
    setStats(
        50,  -- HP Max
        50,  -- HP Current
        15,  -- Mana Max
        15,  -- Mana Current
        4,   -- Defense
        8    -- Agility
    )
    setSpirits(
        1, --Fire 
        1, --Earth
        7, -- Water
        1 -- Wind
    )

    setInventory(
        ITEM_WINGS_YELLOW,
        ITEM_FRESH_BREAD,
        ITEM_FRESH_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_DEW_DROP,
        ITEM_DEW_DROP,
        ITEM_DEW_DROP,
        ITEM_MINT_LEAVES,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupSolvaring()
    setStats(
        59,  -- HP Max
        59,  -- HP Current
        16,  -- Mana Max
        16,  -- Mana Current
        9,   -- Defense
        8    -- Agility
    )
    setSpirits(
        1, --Fire 
        1, --Earth
        17, -- Water
        1 -- Wind
    )

    setInventory(
        ITEM_WINGS_YELLOW,
        ITEM_FRESH_BREAD,
        ITEM_FRESH_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_DEW_DROP,
        ITEM_DEW_DROP,
        ITEM_DEW_DROP,
        ITEM_MINT_LEAVES,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupZelse()
    setStats(
        84,  -- HP Max
        84,  -- HP Current
        20,  -- Mana Max
        20,  -- Mana Current
        18,   -- Defense
        16    -- Agility
    )
    setSpirits(
        1, --Fire 
        24, --Earth
        23, -- Water
        1 -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_BLUE,
        ITEM_MINT_LEAVES,
        ITEM_DEW_DROP,
        ITEM_FRESH_BREAD,
        ITEM_FRESH_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupNepty()
    setStats(
        98,  -- HP Max
        98,  -- HP Current
        21,  -- Mana Max
        21,  -- Mana Current
        20,   -- Defense
        20    -- Agility
    )
    setSpirits(
        1,  --Fire 
        37, --Earth
        25, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_BLUE,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_DEW_DROP,
        ITEM_MINT_LEAVES,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupNeptyRock1()
    setStats(
        98,  -- HP Max
        98,  -- HP Current
        21,  -- Mana Max
        21,  -- Mana Current
        20,   -- Defense
        20    -- Agility
    )
    setSpirits(
        1,  --Fire 
        40, --Earth
        23, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_BLUE,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_DEW_DROP,
        ITEM_MINT_LEAVES,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupShilf()
    setStats(
        115,  -- HP Max
        115,  -- HP Current
        21,  -- Mana Max
        21,  -- Mana Current
        22,   -- Defense
        22    -- Agility
    )
    setSpirits(
        1,  --Fire 
        49, --Earth
        25, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_KEY_WATER_JEWEL,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupFargo()
    setStats(
        137,  -- HP Max
        137,  -- HP Current
        24,  -- Mana Max
        24,  -- Mana Current
        24,   -- Defense
        24    -- Agility
    )
    setSpirits(
        1,  --Fire 
        50, --Earth
        34, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_KEY_WATER_JEWEL,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupGuilty()
    setStats(
        158,  -- HP Max
        158,  -- HP Current
        24,  -- Mana Max
        24,  -- Mana Current
        23,   -- Defense
        28    -- Agility
    )
    setSpirits(
        1,  --Fire 
        50, --Earth
        48, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_KEY_WATER_JEWEL,
        ITEM_KEY_FIRE_RUBY,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_WINGS_BLACK,
        ITEM_HONEY_BREAD,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_SPIRIT_LIGHT,
        ITEM_SPIRIT_LIGHT,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_HEROES_DRINK,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupBeigis()
    setStats(
        183,  -- HP Max
        183,  -- HP Current
        24,  -- Mana Max
        24,  -- Mana Current
        23,   -- Defense
        27    -- Agility
    )
    setSpirits(
        5,  --Fire 
        50, --Earth
        48, -- Water
        1   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_KEY_WATER_JEWEL,
        ITEM_KEY_FIRE_RUBY,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_WINGS_BLACK,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupMammon()
    setStats(
        208,  -- HP Max
        208,  -- HP Current
        25,  -- Mana Max
        25,  -- Mana Current
        23,   -- Defense
        26    -- Agility
    )
    setSpirits(
        1,  --Fire 
        50, --Earth
        48, -- Water
        7   -- Wind
    )

    setInventory(
        ITEM_KEY_EARTH_ORB,
        ITEM_KEY_WIND_JADE,
        ITEM_KEY_WATER_JEWEL,
        ITEM_KEY_FIRE_RUBY,
        ITEM_KEY_ELETALE_BOOK,
        ITEM_KEY_DARK_GAOL,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_WINGS_BLACK,
        ITEM_HONEY_BREAD,
        ITEM_HEALING_POTION,
        ITEM_HEALING_POTION,
        ITEM_MINT_LEAVES,
        ITEM_HEROES_DRINK,
        ITEM_HEROES_DRINK,
        ITEM_DRAGONS_POTION,
        ITEM_DRAGONS_POTION,
        ITEM_GIANTS_SHOES,
        ITEM_CELINES_BELL,
        ITEM_SILVER_AMULET
    )
end

function setupNavigator()
    setInventory(
        ITEM_WINGS_WHITE,
        ITEM_WINGS_YELLOW,
        ITEM_WINGS_BLUE,
        ITEM_WINGS_GREEN,
        ITEM_WINGS_RED,
        ITEM_WINGS_BLACK,
        ITEM_REPLICA,
        ITEM_GIANTS_SHOES,
        ITEM_GIANTS_SHOES,
        ITEM_GIANTS_SHOES,
        ITEM_GIANTS_SHOES
    )
end

-- Initializations
local i
globalLvTable = {}
globalLvTable = setupLvTable(globalLvTable)
globalStatTable = {}
globalStatTable = setupStatTable(globalStatTable)
memory.usememorydomain("RDRAM")
RNGTableGlobal = {}

local tmp
-- for i=0x1,0xFFFF00 do
-- -- if memory.readbyte(i) == 9 then
-- -- if memory.readbyte(i+1) == 9 and memory.readbyte(i+2) == 9 and memory.readbyte(i+3) == 9 then
-- -- end
-- -- end

-- -- memory.writebyte(0x07BAB4, 10, "RDRAM")
-- -- HP50()
-- setSpirits(38, 39, 40, 41)
-- setStats(200, 200, 100, 100, 250, 20) -- HP MP De Ag
-- makeDumpFile = false
-- generateRNGTable(makeDumpFile)
-- -- avalancheBasher()

-- -- memory.write_u32_be(0x04D748, 1, "RDRAM")  -- RNG

-- PrevRNG = 0
-- PrevRNG2 = 0
-- PrevRNG3 = 0
-- BufRNG3 = 0
-- BufRNG2 = 0
-- BufRNG = 0
while true do

    -- memory.write_u32_be(0x7508C, 0, "RDRAM")  -- did this do something?
    -- memory.write_u16_be(0x22FE2, 0, "RDRAM")  --41C6
    -- memory.write_u16_be(0x22FE4, 10001, "RDRAM")
    -- memory.write_u16_be(0x22FE6, 0, "RDRAM") --4E6D
    -- memory.write_u32_be(0x04D748, 29, "RDRAM")  -- RNG

    -- High Byte: =(65536* (A*B + RNG_HIGH * 2*C) * (C * C + 1) 
    -- Low Byte: =(B * (C + 1) + C*C*RNG_LOW)
    -- Start = 0. A = 0, B = 12345, C = 3
    -- 0
    -- 49380
    -- 493800
    -- 4493580
    -- 40491600

    -- 0 goes to 37035
    -- 1 goes to 37039
    -- 2 goes to 37043
    -- 3 goes to 37047
    -- 4 goes to 37051

    -- E4 is adder. E6 of 1 adds 2x adder.

    -- 0,7,68,617,5561,50053
    -- X*3+1

    -- X*0 + Y
    -- X*1 + Y

    -- RNG increment 0,N,1 rotates in a circle around you.
    -- RNG increment 0,0,0 stays in one spot

    -- Thing1
    -- memory.writefloat(0x86FA4, 1600, true, "RDRAM")
    -- memory.write_u32_be(0x4D748, 0, "RDRAM")
    -- stackOfJewelsAndWings()

    -- HP50()
    -- highEncounterCounter()
    -- memory.writebyte(0x07CAB2,0,"RDRAM")
    -- memory.writebyte(0x07CAB5,0,"RDRAM")
    -- memory.writebyte(0x07CAB4,0,"RDRAM")
    -- memory.writebyte(0x07CAB3,0,"RDRAM")
    -- printEnemyStats(50,10)
    -- printEnemyMysteryValues(50, 200)
    -- CalcNextRNG(50, 500)

    -- printBrianLocation(50, 10)

    -- BOSS SAVE STATE PREP FOR US GLITCHLESS

    -- setupNavigator()

    -- setupConnorDD()
    -- setupSolvaring()
    -- setupZelse()
    -- setupNepty()
    -- setupNeptyRock1()
    -- setupShilf()
    -- setupFargo()
    -- setupGuilty()
    -- setupBeigis()
    setupMammon()

    -- Boil Hole OOB:  75, 55, 

    -- printObjectCoordinates(50, 10)

    -- freeze_encounters()
    -- highEncounterCounter()
    -- printEncounterCounter(50, 10)
    -- printStats(100, 420)
    -- printLocation(100,150)
    -- printAgility(400, 10)
    -- printItems(500, 250)
    -- printMemoryDomains(100,115)
    -- printLvTable(100,115,globalLvTable)
    -- printStatTable(100,115,globalStatTable)

    -- displayMusic(50, 600)

    -- RNG 2480
    -- 2209236614

    emu.frameadvance()
end
