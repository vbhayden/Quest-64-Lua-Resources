
function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function printEncounterCounter(x, y)

    local enemiesLeft = memory.readbyte(0x07C993, "RDRAM")
    local timeUntilYouAct = memory.read_u16_be(0x07C99A, "RDRAM")
    local counter = memory.read_u16_be(0x8C578, "RDRAM")

    gui.text(x, y, "Counter: " .. counter)
    -- You can cheese 1.9 pixels as it rolls over.
    gui.text(x + 190, y, "/2000")
    gui.text(x, y + 15, "Increment: " .. Round(memory.readfloat(0x8C574, true, "RDRAM"), 4))
    RNG_EC = memory.read_u32_be(0x4D748, "RDRAM")
    gui.text(x, y + 30, "RNG: " .. RNG_EC .. " = " .. string.format("%08X ", RNG_EC))
    gui.text(x, y + 45, "A: " .. memory.read_u16_be(0x22FE2, "RDRAM"))
    gui.text(x, y + 60, "B: " .. memory.read_u16_be(0x22FE4, "RDRAM") - 1000)
    gui.text(x, y + 75, "C: " .. memory.read_u16_be(0x22FE6, "RDRAM"))
    
    gui.text(x, y + 90, "Enemies: " .. enemiesLeft)
    gui.text(x, y + 105, "Actions: " .. timeUntilYouAct)
end

while true do

    printEncounterCounter(1600, 50)

    emu.frameadvance()
end