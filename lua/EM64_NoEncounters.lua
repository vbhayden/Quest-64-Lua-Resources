function freeze_encounters()
    memory.write_u16_be(0x8BFB0, 0, "RDRAM")
    memory.writefloat(0x8BFAC, 0, true, "RDRAM")
end

while true do

    freeze_encounters()
    emu.frameadvance()
end
