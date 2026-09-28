local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_LOADED_MODELS_COUNT_PTR = 0x84F20
local MEM_LOADED_MODELS_ARRAY_PTR = 0x84F24

local MovementMagnitude = 1

local CHARMAP_80 = {
    [0x00] = "0",
    [0x01] = "1",
    [0x02] = "2",
    [0x03] = "3",
    [0x04] = "4",
    [0x05] = "5",
    [0x06] = "6",
    [0x07] = "7",
    [0x08] = "8",
    [0x09] = "9",
    [0x0A] = "!",
    [0x0B] = "?",
    [0x0C] = "「",
    [0x0D] = "」",
    [0x0E] = "『",
    [0x0F] = "』",
    [0x10] = ".",
    [0x11] = ",",
    [0x12] = "…",
    [0x13] = "‧",
    [0x14] = ":",
    [0x15] = "-",
    [0x16] = "♪",
    [0x17] = "♡",
    [0x18] = "〜",
    [0x19] = "。",
    [0x1A] = "、",
    [0x1B] = "ー",
    [0x1C] = "々",
    [0x1D] = "ヴ",
    [0x1E] = " ",
    [0x1F] = " ",
}

local CHARMAP_81 = {
    [0x00] = "A",
    [0x01] = "B",
    [0x02] = "C",
    [0x03] = "D",
    [0x04] = "E",
    [0x05] = "F",
    [0x06] = "G",
    [0x07] = "H",
    [0x08] = "I",
    [0x09] = "J",
    [0x0A] = "K",
    [0x0B] = "L",
    [0x0C] = "M",
    [0x0D] = "N",
    [0x0E] = "O",
    [0x0F] = "P",
    [0x10] = "Q",
    [0x11] = "R",
    [0x12] = "S",
    [0x13] = "T",
    [0x14] = "U",
    [0x15] = "V",
    [0x16] = "W",
    [0x17] = "X",
    [0x18] = "Y",
    [0x19] = "Z",
    [0x1A] = "&",
    [0x1B] = " ",
    [0x1C] = " ",
    [0x1D] = " ",
    [0x1E] = " ",
    [0x1F] = " ",
}

local CHARMAP_82 = {
    [0x00] = "a",
    [0x01] = "b",
    [0x02] = "c",
    [0x03] = "d",
    [0x04] = "e",
    [0x05] = "f",
    [0x06] = "g",
    [0x07] = "h",
    [0x08] = "i",
    [0x09] = "j",
    [0x0A] = "k",
    [0x0B] = "l",
    [0x0C] = "m",
    [0x0D] = "n",
    [0x0E] = "o",
    [0x0F] = "p",
    [0x10] = "q",
    [0x11] = "r",
    [0x12] = "s",
    [0x13] = "t",
    [0x14] = "u",
    [0x15] = "v",
    [0x16] = "w",
    [0x17] = "x",
    [0x18] = "y",
    [0x19] = "z",
    [0x1A] = "'",
    [0x1B] = "“",
    [0x1C] = "”",
    [0x1D] = " ",
    [0x1E] = " ",
    [0x1F] = " ",
}

local QUEST_CHARMAPS = {
    [0x80] = CHARMAP_80,
    [0x81] = CHARMAP_81,
    [0x82] = CHARMAP_82,
}

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

local function GuiTextWithColor(row_index, text, color)
    
    local borderWidth = client.borderwidth();
    gui.text(borderWidth + 40, 240 + row_index * 15, text, color)
end

local function GuiText(row_index, text)
    GuiTextWithColor(row_index, text, "white")
end

local function ReadNPCsFromMemory()

    local ptr_npcs_start = 0x7BD30
    local npc_block_size = 0x84
    local npc_count = memory.read_u32_be(0x7BCE4, "RDRAM")
    local npcs = {}

    local npc_index = 0

    -- console.log("NPC Count: " .. npc_count)

    while npc_index < npc_count do

        local ptr_npc = ptr_npcs_start + npc_index * npc_block_size
        local ptr_npc_data = GetPointerFromAddress(ptr_npc + 0x80)
        local ptr_name_start = GetPointerFromAddress(ptr_npc_data + 0x14)

        -- console.log(string.format("NPC BASE: %08X, NPC PTR: %08X, NAME PTR: %08X", ptr_npc, ptr_npc_data, ptr_name_start))

        local name_chars = {}
        local is_name = memory.read_u16_be(ptr_name_start, "RDRAM") == 0xA0C0

        local charmap_active = CHARMAP_80

        if is_name then
            for k=2,32 do

                local code = memory.readbyte(ptr_name_start + k, "RDRAM")
                
                -- console.log(string.format("RAW CODE:: %02X", code))
                if code == 0xFF then
                    break
                end

                if code >= 0x80 then
                    charmap_active = QUEST_CHARMAPS[code]

                    -- console.log(string.format("Switching Charmaps:: %02X", code))
                elseif code < 0x20 then
                    local char = charmap_active[code]

                    -- console.log(string.format("Adding Char:: %02X -> %s", code, char))

                    name_chars[#name_chars+1] = char
                elseif code == 0x7F then
                    name_chars[#name_chars+1] = " "
                end
            end
        end

        local name = table.concat(name_chars)
        -- console.log(string.format("NPC Name @ %08X:: %s", ptr_name_start, table.concat(name_chars)))
        
        local npc = {
            base_addr = ptr_npc,

            base_x = memory.readfloat(ptr_npc + 0x4, true, "RDRAM"),
            base_z = memory.readfloat(ptr_npc + 0x8, true, "RDRAM"),
            base_angle = memory.readfloat(ptr_npc + 0x18, true, "RDRAM"),
            

            x = memory.readfloat(ptr_npc + 0x14, true, "RDRAM"),
            y = memory.readfloat(ptr_npc + 0x18, true, "RDRAM"),
            z = memory.readfloat(ptr_npc + 0x1C, true, "RDRAM"),

            scale = memory.readfloat(ptr_npc + 0x38, true, "RDRAM"),

            angle = memory.readfloat(ptr_npc + 0x24, true, "RDRAM"),
            mode = memory.readbyte(ptr_npc_data + 0x4, "RDRAM"),
            name = name
        }

        npcs[#npcs+1] = npc

        npc_index = npc_index + 1
    end

    return npcs
end

local function TransformDirectionForNPC(x, y, z, angle)
    local theta = angle

    local xp = x * math.cos(-theta) - z * math.sin(-theta)
    local zp = x * math.sin(-theta) + z * math.cos(-theta)

    return xp, y, zp
end

local function MoveNPCRelative(x, y, z, npc_x, npc_y, npc_z, npc_angle)
    local dx, dy, dz = TransformDirectionForNPC(x, y, z, npc_angle)
    return npc_x + dx * MovementMagnitude, npc_y, npc_z + dz * MovementMagnitude
end

local function MoveNPCAtIndex(npcs, index, local_x, local_y, local_z)
    local npc = npcs[index]
    local new_x, new_y, new_z = MoveNPCRelative(local_x, local_y, local_z, npc.x, npc.y, npc.z, npc.angle)

    memory.writefloat(npc.base_addr + 0x14, new_x, true, "RDRAM")
    memory.writefloat(npc.base_addr + 0x18, new_y, true, "RDRAM")
    memory.writefloat(npc.base_addr + 0x1C, new_z, true, "RDRAM")
end

local function ScaleNPCAtIndex(npcs, index, size_multiplier)
    local npc = npcs[index]
    memory.writefloat(npc.base_addr + 0x38, npc.scale * size_multiplier, true, "RDRAM")
end

local selected_npc_index = 1
local previous_keys = {}

local function ProcessKeyboardInput(npcs)

    local keys = input.get()

    if keys["Tab"] == true and previous_keys["Tab"] ~= true then
        selected_npc_index = selected_npc_index + 1
    end

    if selected_npc_index > #npcs then
        selected_npc_index = 1
    end

    if keys["KeypadSubtract"] and previous_keys["KeypadSubtract"] ~= true then
        ScaleNPCAtIndex(npcs, selected_npc_index, 0.5)
    end

    if keys["KeypadAdd"] and previous_keys["KeypadAdd"] ~= true then
        ScaleNPCAtIndex(npcs, selected_npc_index, 2.0)
    end
    
    if keys["PageUp"] == true and previous_keys["PageUp"] ~= true then
        MovementMagnitude = MovementMagnitude * 2
    end

    if keys["PageDown"] == true and previous_keys["PageDown"] ~= true then
        MovementMagnitude = MovementMagnitude / 2
    end
    
    if keys["Up"] == true and previous_keys["Up"] ~= true then
        MoveNPCAtIndex(npcs, selected_npc_index, 0, 0, 1)
    end

    if keys["Down"] == true and previous_keys["Down"] ~= true then
        MoveNPCAtIndex(npcs, selected_npc_index, 0, 0, -1)
    end

    if keys["Left"] == true and previous_keys["Left"] ~= true then
        MoveNPCAtIndex(npcs, selected_npc_index, 1, 0, 0)
    end

    if keys["Right"] == true and previous_keys["Right"] ~= true then
        MoveNPCAtIndex(npcs, selected_npc_index, -1, 0, 0)
    end
    
    previous_keys = input.get()
end



while true do

    local npcs = ReadNPCsFromMemory()

    for k, npc in pairs(npcs) do
        
        local color = Ternary(k == selected_npc_index, "cyan", "white")
        GuiTextWithColor(k, string.format("%d:: %08X: %s", k, npc.base_addr, npc.name), color)
    end
    
    GuiTextWithColor(#npcs + 2, string.format("Movement: %.2f", MovementMagnitude), "white")

    ProcessKeyboardInput(npcs)

    emu.frameadvance()
end
