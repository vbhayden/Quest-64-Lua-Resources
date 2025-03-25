from dataclasses import dataclass
from typing import List

@dataclass
class MapEntry:
    area: str
    map_id: int
    submap: int
    uid: str
    description: str
    npcs: str
    
    def clean(self):
        self.map_id = int(self.map_id)
        self.map_id = int(self.submap)
        return self


def load_entries(filepath) -> List[MapEntry]:
    entries = []
    
    with open(filepath) as fp:
        lines = fp.readlines()
        entries = [MapEntry(*line.split(",")).clean() for line in lines[1:] if line.strip() != ""]

    return entries

def main():
    entries = load_entries("data/maps.csv")
    uid_map = {}
    
    for entry in entries:
        if entry.uid in uid_map:
            uid_map[entry.uid].append(entry)
        else:
            uid_map[entry.uid] = [entry]
            
    duplicates = {entry.uid: uid_map[entry.uid] for entry in entries if len(uid_map[entry.uid]) > 1}
    
    for duplicate_uid in duplicates:
        print(f"Duplicate UID Found: {duplicate_uid}:")
        for duplicate in duplicates[duplicate_uid]:
            print(f"  - {duplicate.area}: {duplicate.description}")

if __name__=="__main__":
    main()