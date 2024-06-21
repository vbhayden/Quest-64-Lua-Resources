local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Y = 0x7BAD0
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ENCOUNTER_STEPS = 0x8C574

local GUILTY_CASTLE_APPROACH = "3117F029"
local GUILTY_CASTLE_ENTRY = "FEFD9FFF"
local GUILTY_HALLWAY_1_EXIT = "49174777"
local GUILTY_HALLWAY_2_ENTRY = "49174777"
local GUILTY_HALLWAY_2_MIDPOINT_ENTRY = "C2BCB104"
local GUILTY_HALLWAY_2_MIDPOINT_EXIT = "3ED5D970"
local GUILTY_HALLWAY_2_EXIT = "50CA0ED2"
local GUILTY_HALLWAY_3_ENTRY = "50CA0ED2"
local GUILTY_BOSSFIGHT_ENTRY = "4004C2E7"

local BEIGIS_HALLWAY_1_ENTRY = "AFFE8A33"
local BEIGIS_HALLWAY_2_ENTRY = "B029E7B9"
local BEIGIS_HALLWAY_2_SHANNON_ROOM = "E280D76F"
local BEIGIS_HALLWAY_3_ENTRY = "E280D76F"
local BEIGIS_BOSSFIGHT_ENTRY = "6FCAD62D"

local MAMMON_AREA_1 = "3E3CC7F8"
local MAMMON_CHECKER_1 = "CCE73A85"
local MAMMON_AREA_2 = "0FA60FC1"
local MAMMON_AREA_3 = "0EA4FABB"
local MAMMON_AREA_4 = "DFC282A1"
local MAMMON_AREA_5 = "A30C9E6C"
local MAMMON_CHECKER_2 = "2882E3E1"
local MAMMON_AREA_6 = "754F6EDD"

local MAMMON_FINAL_PLATFORM_ENTRY = "084C487C"
local MAMMON_BOSS_ROOM_ENTRY = "95D6E10E"

local MAP_ID_BARAGOON_MOOR = 11
local SUBMAP_ID_BARAGOON_MOOR_CASTLE_APPROACH = 1

local MAP_ID_BRANNOCH_CASTLE = 30
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_1 = 0
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2 = 1
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_3 = 2
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_4 = 3
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_5 = 4
local SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_6 = 5

local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_1 = 7
local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_2 = 8
local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_3 = 9
local SUBMAP_ID_BRANNOCH_CASTLE_BOSS_GUILY = 10

local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_POST_GUILTY_CHESTS = 12
local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_LEONARDO_HIDEOUT = 15
local SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_SHANNON_AND_BART = 13
local SUBMAP_ID_BRANNOCH_CASTLE_BOSS_BEIGIS = 14

local MAP_ID_MELRODE_MONASTERY = 34
local MAP_ID_MAMMONS_WORLD = 34
local SUBMAP_ID_MAMMONS_WORLD_1 = 0
local SUBMAP_ID_MAMMONS_WORLD_CHECKER_1 = 6
local SUBMAP_ID_MAMMONS_WORLD_2 = 7
local SUBMAP_ID_MAMMONS_WORLD_3 = 4
local SUBMAP_ID_MAMMONS_WORLD_4 = 2
local SUBMAP_ID_MAMMONS_WORLD_5 = 5
local SUBMAP_ID_MAMMONS_WORLD_CHECKER_2 = 9
local SUBMAP_ID_MAMMONS_WORLD_6 = 8
local SUBMAP_ID_MAMMONS_WORLD_END = 3
local SUBMAP_ID_MAMMONS_WORLD_BOSS = 10

local MAP_ID_MELRODE_MONASTERY = 0
local SUBMAP_ID_MAMMONS_WORLD_FLOATING_MONASTERY = 2
local SUBMAP_ID_MAMMONS_WORLD_MELRODE_OUTDOORS = 3

local MAP_ID_MELRODE_TOWN = 15
local SUBMAP_ID_MAMMONS_WORLD_EPONA_ROOM = 13

local MAP_ID_DONDORAN_CASTLE = 14
local SUBMAP_ID_MAMMONS_WORLD_FLORA_ROOM = 13

local MAP_ID_LIMELIN = 22
local SUBMAP_ID_MAMMONS_WORLD_LIMELIN_HOUSE = 24
local SUBMAP_ID_MAMMONS_WORLD_LIMELIN_UPSTAIRS = 25

local MAP_ID_ISLE_OF_SKYE_SHIP = 25
local SUBMAP_ID_MAMMONS_WORLD_SHIP_UPPER = 6
local SUBMAP_ID_MAMMONS_WORLD_SHIP_LOWER = 7

local EXTRA_RNG_MAPPINGS = {
    [MAP_ID_MELRODE_MONASTERY] = {
        [SUBMAP_ID_MAMMONS_WORLD_FLOATING_MONASTERY] = MAMMON_AREA_1,
        [SUBMAP_ID_MAMMONS_WORLD_MELRODE_OUTDOORS] = MAMMON_AREA_6
    },
    [MAP_ID_MELRODE_TOWN] = {
        [SUBMAP_ID_MAMMONS_WORLD_EPONA_ROOM] = MAMMON_AREA_6
    },
    [MAP_ID_DONDORAN_CASTLE] = {
        [SUBMAP_ID_MAMMONS_WORLD_FLORA_ROOM] = MAMMON_AREA_2
    },
    [MAP_ID_LIMELIN] = {
        [SUBMAP_ID_MAMMONS_WORLD_LIMELIN_HOUSE] = MAMMON_AREA_4,
        [SUBMAP_ID_MAMMONS_WORLD_LIMELIN_UPSTAIRS] = MAMMON_AREA_4
    },
    [MAP_ID_ISLE_OF_SKYE_SHIP] = {
        [SUBMAP_ID_MAMMONS_WORLD_SHIP_UPPER] = MAMMON_CHECKER_2,
        [SUBMAP_ID_MAMMONS_WORLD_SHIP_LOWER] = MAMMON_CHECKER_2,
    },
    [MAP_ID_BRANNOCH_CASTLE] = {
        [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2] = GUILTY_HALLWAY_2_ENTRY,
        [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_3] = GUILTY_HALLWAY_3_ENTRY,
        [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_POST_GUILTY_CHESTS] = BEIGIS_HALLWAY_2_ENTRY,
        [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_SHANNON_AND_BART] = BEIGIS_HALLWAY_3_ENTRY
    }
}

local RNGToExpectedSubmap = {
    [GUILTY_CASTLE_APPROACH] = SUBMAP_ID_BARAGOON_MOOR_CASTLE_APPROACH,

    [GUILTY_CASTLE_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_1,
    [GUILTY_HALLWAY_1_EXIT] = SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_1,
    [GUILTY_HALLWAY_2_MIDPOINT_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_2,
    [GUILTY_HALLWAY_2_MIDPOINT_EXIT] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2,
    [GUILTY_HALLWAY_2_EXIT] = SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_3,
    [GUILTY_HALLWAY_3_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_3,
    [GUILTY_BOSSFIGHT_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_BOSS_GUILY,

    [BEIGIS_HALLWAY_1_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_4,
    [BEIGIS_HALLWAY_2_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_5,
    [BEIGIS_HALLWAY_2_SHANNON_ROOM] = SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_SHANNON_AND_BART,
    [BEIGIS_HALLWAY_3_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_6,
    [BEIGIS_BOSSFIGHT_ENTRY] = SUBMAP_ID_BRANNOCH_CASTLE_BOSS_BEIGIS,

    [MAMMON_AREA_1] = SUBMAP_ID_MAMMONS_WORLD_1,
    [MAMMON_AREA_2] = SUBMAP_ID_MAMMONS_WORLD_2,
    [MAMMON_AREA_3] = SUBMAP_ID_MAMMONS_WORLD_3,
    [MAMMON_AREA_4] = SUBMAP_ID_MAMMONS_WORLD_4,
    [MAMMON_AREA_5] = SUBMAP_ID_MAMMONS_WORLD_5,
    [MAMMON_AREA_6] = SUBMAP_ID_MAMMONS_WORLD_6,

    [MAMMON_CHECKER_1] = SUBMAP_ID_MAMMONS_WORLD_CHECKER_1,
    [MAMMON_CHECKER_2] = SUBMAP_ID_MAMMONS_WORLD_CHECKER_2,

    [MAMMON_FINAL_PLATFORM_ENTRY] = SUBMAP_ID_MAMMONS_WORLD_END,
    [MAMMON_BOSS_ROOM_ENTRY] = SUBMAP_ID_MAMMONS_WORLD_BOSS
}

local BRANNOCH_1_HALLWAY_DEFINITIONS = {
    {x = 75, z = 0, y = 0},
    {x = 75, z = -425, y = -60},
    {x = 225, z = -425, y = -100},
    {x = 225, z = -75, y = -100},
    {x = 300, z = -75, y = -100}
}

local BRANNOCH_2_HALLWAY_DEFINITIONS = {
    {x = 25, z = 25, y = 0},
    {x = 25, z = -525, y = 10},
    {x = -425, z = -525, y = 30},
    {x = -425, z = -175, y = 50},
    {x = -75, z = -175, y = 70},
    {x = -75, z = -425, y = 90}
}

local BRANNOCH_3_HALLWAY_DEFINITIONS = {
    {x = 25, z = 25, y = 0},
    {x = 25, z = -125, y = 0},
    {x = -225, z = -125, y = 20},
    {x = -225, z = 325, y = 40},
    {x = 425, z = 325, y = 80},
    {x = 425, z = -125, y = 120},
    {x = 175, z = -125, y = 140},
}

local BRANNOCH_4_HALLWAY_DEFINITIONS = {
    {x = -25, z = 25, y = 0},
    {x = 325, z = 25, y = 20},
    {x = 325, z = -525, y = 60},
    {x = -25, z = -525, y = 100},
    {x = -25, z = -425, y = 100}
}

local BRANNOCH_5_HALLWAY_DEFINITIONS = {
    {x = -25, z = -25, y = 0},
    {x = -25, z = 125, y = 0},
    {x = 325, z = 125, y = 20},
    {x = 325, z = -425, y = 60},
    {x = -325, z = -425, y = 100},
    {x = -325, z = 25, y = 160},
    {x = -175, z = 25, y = 160},
}

local BRANNOCH_6_HALLWAY_DEFINITIONS = {
    {x = -25, z = -25, y = 0},
    {x = 600, z = -25, y = 0},
    {x = 600, z = 200, y = 20}
}

local BRANNOCH_HALLWAY_1_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Align camera and run straight down"
    },
    {
        hallway = 1,
        heals = 2,
        coord = { x = 75, z = -327},
        accuracy = 15,
        hint = "ENCOUNTER: Heal both turns, leave right on the dot"
    },
    {
        hallway = 2,
        heals = 0,
        hint = "Stay in the center"
    },
    {
        hallway = 3,
        heals = 0,
        hint = "Stay in the center"
    },
    {
        hallway = 3,
        heals = 0,
        hint = "ENCOUNTER: Cast Escape at the edge"
    },
    {
        hallway = 4,
        heals = 0,
        hint = "Run to door, spin once"
    },
}

local BRANNOCH_HALLWAY_2_MIDPOINT_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Grab Spirit ASAP"
    }
}

local BRANNOCH_HALLWAY_2_HINTS = {
    {
        hallway = 1, 
        heals = 0, 
        hint="Stay in the center, no encounters on this hallway", 
    },
    {
        hallway = 2, 
        heals = 0, 
        coord = {x = -175, z = -525 }, 
        accuracy = 15,
        hint="ENCOUNTER: Escape on the Middle Stair", 
    },
    {
        hallway = 2, 
        heals = 1,
        coord = {x = -290, z = -525 },
        accuracy = 15,
        hint="Heal %d time(s) between the columns after leaving", 
    },
    {
        hallway = 3, 
        heals = 0,  
        hint="Spin TWICE before entering spirit room", 
    },
    {
        hallway = 4, 
        heals = 0,  
        hint="Stay in the center, no encounters or spins before door", 
    },
}

local BRANNOCH_HALLWAY_3_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Run straight to the corner"
    },
    {
        hallway = 2, 
        heals = 1, 
        coord = { x = -85, z = -125 }, 
        hint="Heal %d time(s) on the center stair", 
    },
    {
        hallway = 3, 
        heals = 1, 
        coord = {x = -225, z = -12 }, 
        hint="Heal %d time(s) again on the next center stair", 
    },
    {
        hallway = 3, 
        heals = 0,  
        coord = { x = -225, z = 250 },
        accuracy = 5,
        hint="ENCOUNTER: Cast Escape at start of the pillar",
    },
    {
        hallway = 4, 
        heals = 3,  
        hint="Heal %d time(s) again on the 2nd column", 
        coord = {x = 150, z = 325 }
    },
    {
        hallway = 4, 
        heals = 0,
        accuracy = 5,
        coord = {x = 395, z = 325},
        hint="ENCOUNTER: Cast Escape when flush with wall and behind dot", 
    },
    {
        hallway = 5, 
        heals = 0,  
        hint="Hug walls, spin twice before Guilty", 
    },
}

local BRANNOCH_HALLWAY_4_HINTS = {
    {
        hallway = 1,
        heals = 1,
        hint = "Heal once if you haven't already"
    },
    {
        hallway = 2,
        heals = 1,
        coord = { x = 303, z = -446},
        accuracy = 8,
        hint = "FORCE ENCOUNTER: last pillar, Escape twice to leave"
    },
    {
        hallway = 3,
        heals = 0,
        coord = { x = 53, z = -506},
        accuracy = 8,
        hint = "FORCE ENCOUNTER: last pillar, Escape once"
    },
    {
        hallway = 4,
        heals = 0,
        hint = "Run to door"
    }
}

local BRANNOCH_HALLWAY_5_HINTS = {
    {
        hallway = 1,
        heals = 0,
        coord = { x = -3.6, z = 46.4},
        accuracy = 8,
        hint = "FORCE ENCOUNTER: on first pillar, Escape once"
    },
    {
        hallway = 2,
        heals = 1,
        coord = { x = 222, z = 110},
        accuracy = 16,
        hint = "Heal at top of 2nd stairwell"
    },
    {
        hallway = 3,
        heals = 0,
        coord = { x = 303, z = -46.4},
        accuracy = 8,
        hint = "FORCE ENCOUNTER: on second pillar, STAND STILL, Escape"
    },
    {
        hallway = 3,
        heals = 0,
        coord = { x = 303, z = -346.4},
        accuracy = 8,
        hint = "FORCE ENCOUNTER: on last pillar, Escape"
    },
    {
        hallway = 4,
        heals = 3,
        coord = {x = -135, z = -411},
        accuracy = 7,
        hint = "Heal 3x at 2nd pillar after door"
    },
    {
        hallway = 4,
        heals = 0,
        coord = {x = -278, z = -404},
        accuracy = 7,
        hint = "FORCE ENCOUNTER: Backwards pillar, Escape on corner"
    },
    {
        hallway = 6,
        heals = 0,
        hint = "Run straight to door, spin once"
    }
}

local BRANNOCH_HALLWAY_5_MIDPOINT_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Get the Spirit Light"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Always talk to Shannon for good luck"
    }
}

local BRANNOCH_HALLWAY_6_HINTS = {
    {
        hallway = 1,
        heals = 0,
        coord = {x = 221.4, z = -3.6},
        accuracy = 7,
        hint = "FORCE ENCOUNTER: Second column, walk out on post"
    },
    {
        hallway = 2,
        heals = 0,
        hint = "Run to the door, middle of last hallway one spin"
    },
}

local MAMMON_1_HINTS = {
    {
        hallway = 1,
        heals = 0,
        coord = {x = 101, z = 70},
        accuracy = 10,
        hint = "Cast EXIT TWICE before crossing platform"
    },
    {
        hallway = 1,
        heals = 0,
        coord = {x = 300, z = 125},
        accuracy = 10,
        hint = "Run to 3rd line from the right"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Center to door, spin once"
    },
}

local MAMMON_2_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Cut corners, run to door, Spin once before entering"
    }
}

local MAMMON_3_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Run to door, align brian with right of last tree"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Follow terrain parallel to door"
    }
}

local MAMMON_4_HINTS = {
    {
        hallway = 1,
        heals = 0,
        coord = {x = -203, z = 305},
        accuracy = 10,
        hint = "Cast Exit immediately"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Run straight to ramp"
    },
    {
        hallway = 1,
        heals = 0,
        coord = {x = 20, z = -150},
        accuracy = 10,
        hint = "Cast Exit twice in doorframe at top of ramp"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Run to door, stutter step 4 times"
    },
}

local MAMMON_5_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Cut across first platform"
    },
    {
        hallway = 1,
        heals = 0,
        coord = {x = 105, z = -44},
        accuracy = 7,
        hint = "Cast Exit twice when crossing the tree"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Follow wall, wide arc into door"
    },
}

local MAMMON_6_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Cut across first platform"
    },
    {
        hallway = 1,
        heals = 0,
        hint = "Follow wall, wide arc into door"
    },
}

local MAMMON_FINAL_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Say goodbye to Shannon :("
    }
}

local MAMMON_CHECKER_HINTS = {
    {
        hallway = 1,
        heals = 0,
        hint = "Cut corners, spin twice before door"
    },
}

local BRANNOCH_HINTS = {
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_1] = BRANNOCH_HALLWAY_1_HINTS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2] = BRANNOCH_HALLWAY_2_HINTS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_3] = BRANNOCH_HALLWAY_3_HINTS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_4] = BRANNOCH_HALLWAY_4_HINTS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_5] = BRANNOCH_HALLWAY_5_HINTS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_6] = BRANNOCH_HALLWAY_6_HINTS,

    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_1] = nil,
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_2] = BRANNOCH_HALLWAY_2_MIDPOINT_HINTS,

    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_POST_GUILTY_CHESTS] = nil,
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_SHANNON_AND_BART] = BRANNOCH_HALLWAY_5_MIDPOINT_HINTS   ,
}

local BRANNOCH_DEFINITIONS = {
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_1] = BRANNOCH_1_HALLWAY_DEFINITIONS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2] = BRANNOCH_2_HALLWAY_DEFINITIONS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_3] = BRANNOCH_3_HALLWAY_DEFINITIONS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_4] = BRANNOCH_4_HALLWAY_DEFINITIONS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_5] = BRANNOCH_5_HALLWAY_DEFINITIONS,
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_6] = BRANNOCH_6_HALLWAY_DEFINITIONS,
}

local BRANNOCH_NAMES = {
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_1] = "Brannoch 1",
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_2] = "Brannoch 2",
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_3] = "Brannoch 3",
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_4] = "Brannoch 4",
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_5] = "Brannoch 5",
    [SUBMAP_ID_BRANNOCH_CASTLE_HALLWAY_6] = "Brannoch 6",

    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_1] = "Brannoch Midpoint 1",
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_2] = "Brannoch Midpoint 2 - Spirit Room",
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_3] = "Brannoch Midpoint 3",

    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_POST_GUILTY_CHESTS] = "Brannoch Midpoint 4",
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_LEONARDO_HIDEOUT] = "Brannoch Midpoint 5 - Leo Room",
    [SUBMAP_ID_BRANNOCH_CASTLE_MIDPOINT_SHANNON_AND_BART] = "Brannoch Midpoint 6 - Shannon Room",
}

local MAMMONS_WORLD_HINTS = {
    [SUBMAP_ID_MAMMONS_WORLD_1] = MAMMON_1_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_2] = MAMMON_2_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_3] = MAMMON_3_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_4] = MAMMON_4_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_5] = MAMMON_5_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_6] = MAMMON_6_HINTS,
    
    [SUBMAP_ID_MAMMONS_WORLD_CHECKER_1] = MAMMON_CHECKER_HINTS,
    [SUBMAP_ID_MAMMONS_WORLD_CHECKER_2] = MAMMON_CHECKER_HINTS,
    
    [SUBMAP_ID_MAMMONS_WORLD_END] = MAMMON_FINAL_HINTS
}

local MAMMONS_WORLD_DEFINITIONS = {}

local MAMMONS_WORLD_NAMES = {
    [SUBMAP_ID_MAMMONS_WORLD_1] = "Mammon 1",
    [SUBMAP_ID_MAMMONS_WORLD_2] = "Mammon 2",
    [SUBMAP_ID_MAMMONS_WORLD_3] = "Mammon 3",
    [SUBMAP_ID_MAMMONS_WORLD_4] = "Mammon 4",
    [SUBMAP_ID_MAMMONS_WORLD_5] = "Mammon 5",
    [SUBMAP_ID_MAMMONS_WORLD_6] = "Mammon 6",

    [SUBMAP_ID_MAMMONS_WORLD_CHECKER_1] = "Mammon Checker 1",
    [SUBMAP_ID_MAMMONS_WORLD_CHECKER_2] = "Mammon Checker 2",

    [SUBMAP_ID_MAMMONS_WORLD_END] = "Mammons World - Final Room",
}

local MESSAGE_SHOW_DURATION_MS = 5000
local GUI_CHAR_WIDTH = 10

local function Ternary ( cond , T , F )
    if cond then return T else return F end
end

local function DoesAreaAdvanceSteps()
    local stateFlags = memory.read_u32_be(0x8C592, "RDRAM")
    local stateFlagsOther = memory.read_u32_be(0x7BB2C, "RDRAM")
    
    local a = bit.band(stateFlags, 1) == 0
    local b = bit.band(stateFlags, 0x8000) == 0
    local c = bit.band(stateFlagsOther, 1) == 0

    return a and b and c
end

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 200 + row_index * 15, text, color)
end

local function GetMapIDs()
    local mapID = memory.readbyte(0x8536B, "RDRAM")
    local subMapID = memory.readbyte(0x8536F, "RDRAM")

    return mapID, subMapID
end

local function GetSubmapExpectedForRNG(rng)

    local map, submap = GetMapIDs()

    local extra_pairings = EXTRA_RNG_MAPPINGS[map]
    if extra_pairings ~= nil then
        local expected_rng = extra_pairings[submap]
        if expected_rng == rng then
            return submap
        end
    end

    local expected_submap = RNGToExpectedSubmap[rng]
    if expected_submap ~= nil then
        return expected_submap
    end

    return nil
end

local function GetBrianLocation()
    local brianX = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM")
    local brianY = memory.readfloat(MEM_BRIAN_POSITION_Y, true, "RDRAM")
    local brianZ = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    
    return {
        x = brianX,
        y = brianY,
        z = brianZ
    }
end

local function GetBrianSteps()
    return memory.readfloat(MEM_BRIAN_ENCOUNTER_STEPS, true, "RDRAM") 
end

local function GuiTextCenterWithColor(row_index, text, color)
    local length = string.len(text)
    local halfWidth = GUI_CHAR_WIDTH * length / 2

    local screenWidth = client.screenwidth();
    local resolvedCenter = screenWidth / 2 - halfWidth

    gui.text(resolvedCenter, 100 + row_index * 15, text, color)
end

local function Distance(x1, z1, x2, z2)
    local dx = x1 - x2
    local dz = z1 - z2
    return math.sqrt(dx * dx + dz * dz)
end

local function DistanceToLine(x, z, p1x, p1z, p2x, p2z)
    local dp = Distance(p1x, p1z, p2x, p2z)

    local a = (p2x - p1x) * (p1z - z)
    local b = (p2z - p1z) * (p1x - x)
    
    return math.abs(a - b) / dp
end

local function GetHallwayInfoFromDefinitions(definitions)

    if definitions == nil then
        return nil
    end

    if #definitions < 2 then
        return nil
    end

    local brian = GetBrianLocation()

    local closest_index = -1
    local closest_distance = 999999999
    
    for i=1,#definitions-1 do

        local a = definitions[i]
        local b = definitions[i+1]

        local lower_bound = Ternary(a.y < b.y, a.y, b.y)
        local upper_bound = Ternary(a.y > b.y, a.y, b.y)

        if brian.y > lower_bound - 1 and brian.y < upper_bound + 1 then
            local distance = DistanceToLine(brian.x, brian.z, a.x, a.z, b.x, b.z)
            if distance < closest_distance then
                closest_index = i
                closest_distance = distance
            end
        end
    end

    return {
        index = closest_index
    }
end

local function GetAreaInfo(map, submap)

    if map == MAP_ID_BRANNOCH_CASTLE then
        local name = BRANNOCH_NAMES[submap]
        local hints = BRANNOCH_HINTS[submap]
        local hallway_defs = BRANNOCH_DEFINITIONS[submap]
        local hallway_info = GetHallwayInfoFromDefinitions(hallway_defs)

        return name, hints, hallway_defs, hallway_info
    end
    
    if map == MAP_ID_MAMMONS_WORLD then
        local name = MAMMONS_WORLD_NAMES[submap]
        local hints = MAMMONS_WORLD_HINTS[submap]
        local hallway_defs = MAMMONS_WORLD_DEFINITIONS[submap]
        local hallway_info = GetHallwayInfoFromDefinitions(hallway_defs)

        return name, hints, hallway_defs, hallway_info
    end

    return nil, nil, nil, nil
end

local function PrintAreaFeedback(index, map, submap)

    -- if submap > 6 then
    --     return
    -- end

    local brian = GetBrianLocation()
    local name, hints, definitions, hallway_info = GetAreaInfo(map, submap)
    
    if hints == nil then
        return
    end
    
    local title = name .. " Setup"
    local dots = "+" .. string.rep("-", math.max(string.len(title), 20)) .. "+"

    GuiTextWithColor(index + 0, name .. " Setup")
    GuiTextWithColor(index + 1, dots)

    for k, hint in pairs(hints) do
        
        local row_index = index + 1 + k
        local hint_color = "white"

        if hallway_info ~= nil then
            hint_color = Ternary(hallway_info.index == hint.hallway, "white", "gray")
        end
        
        local hint_coord = hint["coord"]

        if hint_coord ~= nil then
            local distance = Distance(brian.x, brian.z, hint_coord.x, hint_coord.z)
            local required_distance = Ternary(hint["accuracy"] ~= nil, hint.accuracy, 40)

            if hallway_info ~= nil then
                hint_color = Ternary(distance < required_distance and hallway_info.index == hint.hallway, "cyan", hint_color)
            else
                hint_color = Ternary(distance < required_distance, "cyan", hint_color)
            end
        end

        local heal_count = Ternary(hint["heals"] ~= nil, hint.heals, 0)

        GuiTextWithColor(row_index, string.format(hint.hint, heal_count), hint_color)
    end
end

local last_map = -1
local last_submap = -1
local last_result_successful = false
local last_checked_at = nil
local last_checked_rng = ""
local last_accuracy_result = ""
local last_accuracy_delta = 0.0
local accuracy_range = 15.0
local could_get_encounters = false

local function PrintRNGFeedback(index, rng, successful, last_checked_at)

    if last_checked_at == nil then
        return
    end

    local currentTime = os.time()
    local messageDelta = os.difftime(currentTime, last_checked_at)
    if messageDelta * 1000 < MESSAGE_SHOW_DURATION_MS then
        
        if successful then
            GuiTextCenterWithColor(index, "Success! " .. last_accuracy_result, "cyan")
            GuiTextCenterWithColor(index+1, "Current RNG: " .. rng, "cyan")
        else
            GuiTextCenterWithColor(index, "Unexpected RNG!", "orange")
            GuiTextCenterWithColor(index+1, "Current RNG: " .. rng, "orange")
        end
    end
end

while true do

    local map, submap = GetMapIDs()

    if map ~= last_map or submap ~= last_submap then
        local current_rng_32 = memory.read_u32_be(0x04D748, "RDRAM")
        local current_rng = string.format("%08X", current_rng_32)

        local expected_submap = GetSubmapExpectedForRNG(current_rng)

        last_result_successful = submap == expected_submap
        last_checked_at = os.time()
        last_checked_rng = current_rng

        local encounters_possible = DoesAreaAdvanceSteps()

        if encounters_possible and could_get_encounters then
            local steps = GetBrianSteps()
            
            if steps - accuracy_range < 0 then
                last_accuracy_result = string.format("-- Little Fast! %d of 50", Round(steps, 0))
            elseif steps + accuracy_range >= 50.0 then
                last_accuracy_result = string.format("-- Little Slow! %d of 50", Round(steps, 0))
            else
                last_accuracy_result = "-- Safe!"
            end
        else
            last_accuracy_result = ""
        end
    end

    last_map = map
    last_submap = submap

    could_get_encounters = DoesAreaAdvanceSteps()

    PrintAreaFeedback(1, map, submap)
    PrintRNGFeedback(-1, last_checked_rng, last_result_successful, last_checked_at)
    
    emu.frameadvance()
end