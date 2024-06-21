

function getCounter()
    return memory.read_u16_be(0x8C578, "RDRAM")
end

function setCounter(counterValue)
    local updatedValue = math.max(0, math.min(1999, counterValue))
    memory.write_u16_be(0x8C578, updatedValue, "RDRAM")
    return updatedValue
end


function getCounter()
    return memory.read_u16_be(0x8C578, "RDRAM")
end

function setCounter(counterValue)
    local updatedValue = math.max(0, math.min(1999, counterValue))
    memory.write_u16_be(0x8C578, updatedValue, "RDRAM")
    return updatedValue
end


function addToCounter(amount)
    local currentValue = getCounter()
    return setCounter(currentValue + amount)
end


function addToIncrement(amount)
    local currentValue = getCounter()
    return setCounter(currentValue + incrementAmount)
end


function main()
    addToCounter(50)
end

main()