local function TrimPointer(address)
    return bit.band(address, 0x00FFFFFF)
end

local function ToShort(first_byte, second_byte)

    local unsigned = first_byte * 256 + second_byte

    if unsigned >= 32768 then
        return unsigned - 32768 * 2
    else
        return unsigned
    end
end 

local function GetPointerFromAddress(address)
    local ptr = memory.read_u32_be(address, "RDRAM")
    return TrimPointer(ptr)
end

local function GetEncounterPointers()

    local ptr_region_data = GetPointerFromAddress(0x08C560)
    local ptr_circle_data = GetPointerFromAddress(0x08C564)

    return {
        ptr_region_start = GetPointerFromAddress(ptr_region_data),
        total_regions = GetPointerFromAddress(ptr_region_data + 4),
        ptr_circle_start = GetPointerFromAddress(ptr_circle_data + 8),
        total_circles = GetPointerFromAddress(ptr_circle_data + 12)
    }
end

local function ReadEncountersFromMemory()
    local data = GetEncounterPointers()

    local encounter_centers = {}

    local bytes = memory.read_bytes_as_array(data.ptr_circle_start, data.total_circles * 4, "RDRAM")
    for k=1,#bytes/4 do
        
        local index = (k - 1) * 4

        local center = {
            x = ToShort(bytes[index + 1], bytes[index + 2]),
            z = ToShort(bytes[index + 3], bytes[index + 4])
        }

        encounter_centers[#encounter_centers + 1] = center
    end

    return encounter_centers
end

local function WriteEncounterCSV(centers, path)
    local outputFile = io.open(path, "w+")

    console.log("Writing encounters to " .. path .. " ...")

    for k, center in pairs(centers) do
        outputFile:write(center.x..","..center.z.."\n")
    end
    
    console.log("... done!")

    outputFile:close()
end

local centers = ReadEncountersFromMemory()
WriteEncounterCSV(centers, "Generated/holy-plains.csv")
