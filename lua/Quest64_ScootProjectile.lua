local MEM_PROJECTILE_ONE_X = 0x086F24
local MEM_PROJECTILE_ONE_Y = 0x086F28
local MEM_PROJECTILE_ONE_Z = 0x086F2C

local MEM_PROJECTILE_FOUR_X = 0x086FD8
local MEM_PROJECTILE_FOUR_Y = 0x086FDC
local MEM_PROJECTILE_FOUR_Z = 0x086FE0

 local MEM_BOSS_HEALTH_CURRENT = 0x07C9A2

local required_accuracy = 0.001
local save_slots = { 5 }
local scoot_distances = { 0.2, 0.1, 0.1 }
local frame_duration = 600

local function GetBossHP()
    return memory.read_u16_be(MEM_BOSS_HEALTH_CURRENT, "RDRAM")
end

local function GetRNG()
    return memory.read_u32_be(0x04D748, "RDRAM")
end

console.clear()

for si, slot in pairs(save_slots) do
    
    local safe_x = 0
    local safe_z = 16
    local collision_z = 0
    local accuracy = 9999.0
    local scoot_distance = scoot_distances[si]

    while accuracy > required_accuracy do
        
        savestate.loadslot(slot)
        
        emu.frameadvance()
        emu.frameadvance()
        emu.frameadvance()
        emu.frameadvance()

        local hit_something = false
        local k = 0.0
        while k < frame_duration and not hit_something do
            
            local sample_x = safe_x
            local sample_z = safe_z - scoot_distance * k

            local rngBefore = GetRNG()

            memory.writefloat(MEM_PROJECTILE_ONE_X, sample_x, true, "RDRAM")
            memory.writefloat(MEM_PROJECTILE_ONE_Z, sample_z, true, "RDRAM")

            emu.frameadvance()
            
            local rngAfter = GetRNG()
            if rngBefore ~= rngAfter then
                accuracy = math.abs(safe_z - sample_z)
                collision_z = sample_z
                hit_something = true
                
                console.log(string.format("[Slot %d] %f --> %f, Accuracy: %f", slot, safe_z, sample_z, accuracy))
            else 
                safe_z = sample_z
            end

            k = k + 1
        end
        
        scoot_distance = scoot_distance * 0.8
    end

    console.log(string.format("[Slot %d] Collision Spot: %f -- %f", slot, collision_z, accuracy))
end
