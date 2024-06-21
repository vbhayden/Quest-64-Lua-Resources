function setBrianLocation(px, py)
    memory.writefloat(0x7BACC, px, true, "RDRAM")
    memory.writefloat(0x7BAD4, py, true, "RDRAM")
end

setBrianLocation(-450, -200)
