
with open("./data/spells/spells.tsv") as fp:
    lines = fp.readlines()
    
    for k, line in enumerate(lines[1:]):
        cols = line.split("\t")
        hex = "".join(cols[1:])
        
        print(f"{hex.strip()}")
