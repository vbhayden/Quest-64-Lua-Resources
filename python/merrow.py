import dataclasses
from typing import List

@dataclasses.dataclass
class PackRow:
    addr: str
    name: str
    enemies_as_csharp: List[str]
    
    def __str__(self):
        
        for enemy in self.enemies_as_csharp:
            print(enemy)
        return ""

@dataclasses.dataclass
class PackDefinitions:
    name: str
    first_addr: str
    packs: List
    
    def __str__(self):
        print("//", self.name)
        print("// ")
        print(f'public static MonsterPackDefinition[] packs{self.name.replace(" ", "").strip()} = new MonsterPackDefinition[]'.replace("'", ""))
        print("{")
        
        for pack in self.packs:
            
            # print(pack)
            print(f"    new MonsterPackDefinition(0x{pack.addr}, new EnemyPackMember[]")
            print("    {")
            
            for enemy in pack.enemies_as_csharp:
                print(f"        {enemy},")
            
            print("    }),")
        
        print("};")
        return ""

def pack_to_csharp(pack_array):
    # print(pack_array)
    return f"new EnemyPackMember(0x{pack_array[0]:08X}, 0x{pack_array[1]:08X}, 0x{pack_array[2]:08X})"

def packs_to_csharp(tsv_path):
    rows_raw = []
    with open(tsv_path) as fp:
        rows_raw = fp.readlines()[1:]
        
    rows_parsed = [row.split("\t") for row in rows_raw]
    rows_parsed = [[col if k <= 1 else int(col, 16) for k, col in enumerate(row) if col not in ["", "\n"]] for row in rows_parsed]
    
    area_defs = []
    area_dict = {}
    for k, row in enumerate(rows_parsed):
        
        pack_data = row[2:]
        
        pack_row = PackRow(row[0], row[1], [])
        
        if len(pack_data) > 0: pack_row.enemies_as_csharp.append(pack_to_csharp(pack_data[0:3]))
        if len(pack_data) > 3: pack_row.enemies_as_csharp.append(pack_to_csharp(pack_data[3:6]))
        if len(pack_data) > 6: pack_row.enemies_as_csharp.append(pack_to_csharp(pack_data[6:9]))
        if len(pack_data) > 9: pack_row.enemies_as_csharp.append(pack_to_csharp(pack_data[9:]))
        
        area_name = row[1]
        if area_name not in area_dict:
            area_addr = row[0]
            area_dict[area_name] = PackDefinitions(area_name, area_addr, [pack_row])
            area_defs.append(area_dict[area_name])
        else:
            area_dict[area_name].packs.append(pack_row)
    
    for area_def in area_defs:
        print(area_def, end="\n\n")
    
    # last_name = ""
    # for area in area_dict:
    #     [rom_addr, name] = area.split(",")
    #     if name != last_name:
    #         print(f"new MonsterPackDefinition({rom_addr}, new MonsterPackDefinition[] {{")
        
    #     for pack in area_dict[area]:
    #         print(f"    new MonsterPackDefinition(0x{area_addr}, new EnemyPackMember[] {{")
    #         for member in pack:
    #             print(f"        {member},")
    #         print("}),")
            
    #     if name != last_name:
    #         print("}),")

@dataclasses.dataclass
class RegionDef:
    name: str
    rom_addr: int
    ram_addr: int
    x_min: int
    x_max: int
    z_min: int
    z_max: int
    preset_count: int
    preset_indices: List[int]
    
    def __str__(self):
        indices = [f"0x{index:04X}" for index in self.preset_indices]
        print(f"new EncounterRegion(0x{self.rom_addr:08X}, 0x{self.x_min:04X}, 0x{self.x_max:04X}, 0x{self.x_min:04X}, 0x{self.z_max:04X}, 0x{self.preset_count:04X}, {', '.join(indices)}),")
        return ""

@dataclasses.dataclass
class AreaRegionDefs:
    name: str
    regions: List[RegionDef]
    
    def __str__(self):
        var_name = self.name.replace(" ", "").replace("'", "").strip()
        print(f"public static EncounterRegion[] regions{var_name} = new EncounterRegion[] {{")
        for region in self.regions:
            print(" " * 4, region, end="")
        print("};", end="")
        return ""

def regions_to_csharp(tsv_path):
    rows_raw = []
    with open(tsv_path) as fp:
        rows_raw = fp.readlines()[1:]
        
    rows_parsed = [row.split("\t") for row in rows_raw]
    rows_parsed = [[col if k < 1 else int(col, 16) for k, col in enumerate(row) if col not in ["", "\n"]] for row in rows_parsed]

    area_defs = []
    area_dict = {}
    for row in rows_parsed:
        
        base_data = row[:8]
        vary_data = row[8:]
        
        region_def = RegionDef(*base_data, preset_indices=vary_data)
        
        area_name = region_def.name
        if area_name not in area_dict:
            area_dict[area_name] = AreaRegionDefs(area_name, [region_def])
            area_defs.append(area_dict[area_name])
        else:
            area_dict[area_name].regions.append(region_def)

    for area_def in area_defs:
        print(area_def, end="\n\n")

def main():
    # packs_to_csharp("data/packs.tsv")
    regions_to_csharp("data/regions.tsv")

if __name__ == "__main__":
    main()
