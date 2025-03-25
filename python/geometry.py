import matplotlib.pyplot as plt
import matplotlib.patches as patches
import seaborn as sns
import numpy as np
import math

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
            print(stripped)
            if stripped == "-" or stripped == "":
                if len(obj) > 0:
                    objects.append(obj)
                obj = []
            
            else:    
                (x, z) = tuple(map(float, stripped.split(",")))
                obj.append((x, z))
        
        return objects
    
    return None


def plot_crumbs(data_path):
    geometry = load_geometry_at_path(data_path)
    verts = [(x, z) for block in geometry for (x, z) in block]
    
    xs = [x for (x, _) in verts]
    zs = [z for (_, z) in verts]
    
    width = max(xs) - min(xs)
    height = max(zs) - min(zs)
    
    plt.title(label=data_path)
    
    plt.xlim([min(xs) - width/20, max(xs) + width/20])
    plt.ylim([min(zs) - height/20, max(zs) + height/20])
    
    for k, block in enumerate(geometry):
        xs = [x for (x, _) in block]
        zs = [z for (_, z) in block]
        
        plt.plot(xs, zs)
        
        print("Plotting object:", k)
    
    ax = plt.gca()
    ax.set_ylim(ax.get_ylim()[::-1])  # Reverse the Y-axis
    
    fig = plt.gcf()
    fig.set_dpi(100)
    fig.set_size_inches(width / 200, height / 200)
    fig.savefig(data_path + ".png")
    
    plt.show()

def main():
    import sys
    filename = sys.argv[1]
    plot_crumbs(filename)

if __name__ == "__main__":
    main()
