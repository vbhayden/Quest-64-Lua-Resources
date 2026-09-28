

local hex_ram_start = 0x8000BCB4
local hex_instructions = {
    0x3C028008,
    0x00056040,
    0x3C038005,
    0x2442BA80,
    0x006C1821,
    0x9463C2C0,
    0x944D0006,
    0x944F000A,
    0x0003C043,
    0x01A34021,
    0x01F84821,
    0xA4480006,
    0xA449000A,
    0xA4480004,
    0xA4490008,
    0x8FBF0014,
    0x27BD0018,
    0x03E00008,
    0x00000000
}

local iter_addr = hex_ram_start - 0X80000000
for _, instruction in pairs(hex_instructions) do
    memory.write_u32_be(iter_addr, instruction, "RDRAM")
    iter_addr = iter_addr + 0x4
end
