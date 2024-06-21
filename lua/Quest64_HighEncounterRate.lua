MEM_ENCOUNTER_STEP_DISTANCE = 0x8C574
MEM_ENCOUNTER_ACCUMULATION = 0x8C578

GUI_CHAR_WIDTH = 10
GUI_PADDING_RIGHT = 240 + 60

function HighEncounters()
    memory.write_u16_be(MEM_ENCOUNTER_ACCUMULATION, 1999, "RDRAM")
end

while true do

    HighEncounters()    
    emu.frameadvance()
end
