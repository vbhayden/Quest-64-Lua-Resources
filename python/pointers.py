import struct


def find_pointer_chains(rom_path: str, chain_length: int, endianness: str = ">"):
    """
    Finds chains of consecutive 80XXXXXX pointers.

    Args:
        rom_path: Path to ROM file.
        chain_length: Minimum number of consecutive pointers required.
        endianness: '>' for big-endian (.z64), '<' for little-endian (.n64).

    Returns:
        List of tuples:
        [
            (start_offset, pointer_count),
            ...
        ]
    """

    def is_pointer(value: int) -> bool:
        return (value & 0xFF000000) == 0x80000000

    with open(rom_path, "rb") as f:
        data = f.read()

    matches = []

    offset = 0
    first_ptr = ""
    while offset <= len(data) - 4:
        count = 0

        while offset + (count * 4) <= len(data) - 4:
            value = struct.unpack_from(f"{endianness}I", data, offset + (count * 4))[0]

            if not is_pointer(value):
                break

            count += 1
            
            if count == 1:
                first_ptr = f"{value:8X}"

        if count >= chain_length:
            matches.append((offset, count, first_ptr))
            offset += count * 4
        else:
            offset += 4

    return matches


# Example usage
chains = find_pointer_chains("./roms/quest.clean.z64", 63)

for start_offset, count, first_ptr in chains:
    print(f"0x{start_offset:08X} ({count} pointers, start: {first_ptr})")