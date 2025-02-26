local MEM_BRIAN_POSITION_X = 0x7BACC
local MEM_BRIAN_POSITION_Z = 0x7BAD4
local MEM_BRIAN_ROTATION_Y = 0x7BADC

local MEM_LOADED_MODELS_COUNT_PTR = 0x84F20
local MEM_LOADED_MODELS_ARRAY_PTR = 0x84F24

local function GetBrianLocation()
    return {
        x = memory.readfloat(MEM_BRIAN_POSITION_X, true, "RDRAM"),
        z = memory.readfloat(MEM_BRIAN_POSITION_Z, true, "RDRAM")
    }
end

local function SetBrianLocation(x, z)
    memory.writefloat(MEM_BRIAN_POSITION_X, x, true, "RDRAM")
    memory.writefloat(MEM_BRIAN_POSITION_Z, z, true, "RDRAM")
end

local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return ptr, TrimPointer(ptr)
end

local function GetModelInfoAtAddress(addr)

    return {
        x = memory.readfloat(addr, true, "RDRAM"),
        y = memory.readfloat(addr + 4, true, "RDRAM"),
        z = memory.readfloat(addr + 8, true, "RDRAM"),
        angle = memory.readfloat(addr + 12, true, "RDRAM"),
        size = memory.readfloat(addr + 16, true, "RDRAM"),
        anim = memory.read_u16_be(addr + 20, "RDRAM"),
        model = memory.read_u16_be(addr + 22, "RDRAM")
    }
end

local function IsTree(model)
    if model == 0x8010 then
        return true
    end

    return false
end

local function Distance(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z

    return math.sqrt(dx * dx + dz * dz)
end

local function Direction(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z

    local magnitude = math.sqrt(dx * dx + dz * dz)

    return {
        x = dx / magnitude,
        z = dz / magnitude   
    }
end

local function Multiply(a, coefficient)
    return {
        x = a.x * coefficient,
        z = a.z * coefficient
    }
end

local function Add(a, b)
    return {
        x = a.x + b.x,
        z = a.z + b.z
    }
end

local function ProcessKeyboardInput()

    local keys = input.get()
    local slot = 0

    for k = 1, 10 do
        if keys["Number" .. k] == true and previous_keys["Number" .. k] ~= true then
            slot = k
        end
    end
    
    previous_keys = input.get()

    return slot
end

while true do

    local CLOSENESS = 0
    local CLOSENESS = 0.00005
    local warp_slot = ProcessKeyboardInput()

    local ptr_1, ptr_models_count = GetPointerFromAddress(MEM_LOADED_MODELS_COUNT_PTR)
    local ptr_2, ptr_models_array = GetPointerFromAddress(MEM_LOADED_MODELS_ARRAY_PTR)

    if bit.band(ptr_1, 0X80000000) == 0x80000000 then

        local brian = GetBrianLocation()
        local close_index = 1

        local models_count = memory.read_u16_be(ptr_models_count, "RDRAM")
        for k = 0, models_count - 1 do
            
            local addr = ptr_models_array + k * 24
            local model_info = GetModelInfoAtAddress(addr)
            local distance_to_brian = Distance(brian, model_info)

            if distance_to_brian < 100 then

                local is_tree = IsTree(model_info.model)
                if is_tree then
                    gui.text(200, 200 + close_index * 15, string.format("%2d: %08X %04X:%04X, %3.1f", close_index, addr, model_info.model, model_info.anim, distance_to_brian))
                    
                    if close_index == warp_slot then

                        local direction_to_brian = Direction(brian, model_info)
                        local placement_offset = Multiply(direction_to_brian, CLOSENESS)
                        local placement_spot = Add(model_info, placement_offset)

                        SetBrianLocation(placement_spot.x, placement_spot.z)
                        console.log(string.format("SNAP BRIAN TO: %4.1f, %4.1f", placement_spot.x, placement_spot.z))
                    end
    
                    close_index = close_index + 1
                end
            end
        end
    else
        gui.text(200, 200, "--Invalid Model Count PTR: " .. string.format("%08X", ptr_1))
    end

    emu.frameadvance()
end
