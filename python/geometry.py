import matplotlib.pyplot as plt
import matplotlib.patches as patches
import seaborn as sns
import numpy as np
import math
import glob

from os import listdir
from os.path import isfile, join
from typing import List, Tuple
from dataclasses import dataclass
from multiprocessing import Pool, cpu_count

def load_geometry_at_path(full_path: str) -> List[List[Tuple[float]]]:
    
    with open(full_path, "r") as fp:
        geometry_lines = fp.readlines()
        
        objects = []
        obj = []
            
        for line in geometry_lines:
            stripped = line.rstrip("-\n")
            if stripped == "-" or stripped == "":
                if len(obj) > 0:
                    objects.append(obj)
                obj = []
            
            else:    
                (x, z) = tuple(map(float, stripped.split(",")))
                obj.append((x, z))
        
        return objects
    
    return None


def find_oob_angles(folder_path):
    """
    Check the angles of each vertex chain for all known maps
    and see if any are below the known threshold of Baragoon's
    2nd bridge section of ~20.2 degrees.
    """
    filenames = glob.glob("*.csv", root_dir=folder_path)
    
    for filename in filenames:
        data_path = folder_path + "/" + filename
        geometry = load_geometry_at_path(data_path)
        
        # print(data_path)
        
        for block in geometry:
            for k, coord in enumerate(block[:-2]):
                a = np.array(block[k+0])
                b = np.array(block[k+1])
                c = np.array(block[k+2])
                
                ba = a - b
                bc = c - b
                
                ba_length = np.linalg.norm(ba)
                bc_length = np.linalg.norm(bc)
                
                if ba_length < 15 or bc_length < 15:
                    continue
                
                cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
                radians = np.arccos(cosine_angle)
                degrees = math.degrees(radians)
                
                if degrees < 1:
                    continue
                
                if degrees < 30:
                    print(f"Sharp Corner found: {degrees} @ {k}, {coord} in {data_path}")
    
    pass


def plot_crumbs(data_path):
    geometry = load_geometry_at_path(data_path)
    verts = [(x, z) for block in geometry for (x, z) in block]
    
    xs = [x for (x, _) in verts]
    zs = [z for (_, z) in verts]
    
    width = max(xs) - min(xs)
    height = max(zs) - min(zs)
    
    base_height = 50
    size_ratio = width / height
    
    plt.title(label=data_path)
    
    plt.xlim([min(xs) - width/20, max(xs) + width/20])
    plt.ylim([min(zs) - height/20, max(zs) + height/20])
    
    print(f"Plotting {len(geometry)} object(s)...")
    
    for k, block in enumerate(geometry):
        xs = [x for (x, _) in block]
        zs = [z for (_, z) in block]
        
        plt.plot(xs, zs)
        
        # print("Plotting object:", k)
    
    ax = plt.gca()
    ax.set_ylim(ax.get_ylim()[::-1])  # Reverse the Y-axis
    
    fig = plt.gcf()
    fig.set_dpi(200)
    fig.set_size_inches(base_height * size_ratio, base_height)
    fig.savefig(data_path + ".png")
    
    plt.show()

def main():
    import sys
    
    filename = sys.argv[1]
    plot_crumbs(filename)
    
    # geometry_path = sys.argv[1]
    # find_oob_angles(geometry_path)

if __name__ == "__main__":
    main()
