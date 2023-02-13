function HighEncounters()
    memory.write_u16_be(0x8C578, 1999, "RDRAM")
end

while true do

    HighEncounters()
    emu.frameadvance()
end
