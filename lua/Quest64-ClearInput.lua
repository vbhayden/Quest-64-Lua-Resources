
-- Controller Inputs
--
function clearAnalog()
    joypad.setanalog({ ['X Axis'] = '', ['Y Axis'] = '', }, 1)
end

function main()

    clearAnalog()
end

main()