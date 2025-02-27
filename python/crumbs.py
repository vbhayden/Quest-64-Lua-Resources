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

@dataclass
class WallDefinition:
    x: List[float]
    z: List[float]

@dataclass 
class RegionWallDefinition:
    walls: List[WallDefinition]

def load_rows_at_path(full_path: str) -> List[List[float]]:
    
    with open(full_path, "r") as fp:
        lines = fp.readlines()
        rows = [[float(col) for col in line.split(",")] for line in lines if line.strip() != ""]
        
        return rows
    
    return []

def load_crumbs_at_path(filename: str) -> WallDefinition:
    
    crumb_rows = load_rows_at_path(filename)
    
    xs = [row[0] for row in crumb_rows]
    zs = [row[1] for row in crumb_rows]
    
    return WallDefinition(x=xs, z=zs)


def plot_crumbs(data_path):
    crumbs = load_crumbs_at_path(data_path)
    
    plt.plot(crumbs.x, crumbs.z)
    ax = plt.gca()
    ax.set_ylim(ax.get_ylim()[::-1])  # Reverse the Y-axis
    plt.show()

def main():
    import sys
    filename = sys.argv[1]
    plot_crumbs(filename)

if __name__ == "__main__":
    main()
