--
-- 00000009B0 is the default RNG value when the game starts
--
memory.write_u32_be(0x04D748, 0x00000009B0, "RDRAM")
