import matplotlib.pyplot as plt
import matplotlib.patches as patches
import seaborn as sns
import numpy as np
import statistics
import json
import os.path
import math

import numpy.typing

from PIL import Image
from typing import List, Tuple, Dict
from dataclasses import dataclass
from matplotlib.offsetbox import OffsetImage, AnnotationBbox

def sqr_distance(x1, z1, x2, z2):
    dx = x1 - x2
    dz = z1 - z2
    return dx * dx + dz * dz

class MapData:
    walls: List[List[Dict]]
    circles: List[Dict]
    regions: List[Dict]
    spirits: List[Dict]
    chests: List[Dict]
    path: str

    @classmethod
    def load_from_path(cls, full_path) -> 'MapData':
        with open(full_path) as fp:
            map_json = json.load(fp)
            
            map_data = MapData()
            
            map_data.walls   = map_json["walls"]
            map_data.circles = map_json["circles"]
            map_data.regions = map_json["regions"]
            map_data.spirits = map_json["spirits"]
            map_data.chests  = map_json["chests"]
            map_data.path = full_path
            
            return map_data

    def get_bounds(self) -> Tuple[float]:
        verts = [vert for block in self.walls for vert in block]
        
        xs = [vert["x"] for vert in verts]
        zs = [vert["z"] for vert in verts]
        
        width = max(xs) - min(xs)
        height = max(zs) - min(zs)
        
        return (math.floor(min(xs)), math.floor(min(zs)), math.ceil(width), math.ceil(height))

    def get_density_image_data(self) -> numpy.typing.NDArray:
        
        (x, z, width, depth) = self.get_bounds()
        data = np.ndarray((width, depth, 4))
        
        for ix in range(x, x + width + 1, 1):
            
            if ix % 100 == 0:
                print(ix, "of", x+width)
            
            for iz in range(z, z + depth + 1, 1):
                
                # print(ix-x, ix, iz-z, iz)
                data[ix-x-1, iz-z-1] = self.sample_for_encounters(ix, iz)    
        
        return data

    def sample_for_encounters(self, x, z) -> Tuple[float]:
        
        max_dist_sqr = 0
        min_dist_sqr = 10000
        
        valid_sqr_dists = []
        
        for circle in self.circles:
            cx, cz = circle["x"], circle["z"]
            dist_sqr = sqr_distance(x, z, cx, cz)
            
            if dist_sqr < 2500:
                continue
            if dist_sqr > 8100:
                continue
            
            if dist_sqr < min_dist_sqr:
                min_dist_sqr = dist_sqr
                
            if dist_sqr > max_dist_sqr:
                max_dist_sqr = dist_sqr
                
            valid_sqr_dists.append(dist_sqr)
        
        if len(valid_sqr_dists) == 0:
            return (0, 0, 0, 0)
        
        mean_dist_sqr = sum(valid_sqr_dists) / len(valid_sqr_dists)
        median_dist_sqr = statistics.median(valid_sqr_dists)
        
        max_dist = math.sqrt(max_dist_sqr)
        min_dist = math.sqrt(min_dist_sqr)
        mean_dist = math.sqrt(mean_dist_sqr)
        median_dist = math.sqrt(median_dist_sqr)
        
        return (max_dist, min_dist, mean_dist, median_dist)

def plot_map(map_data: MapData):
    verts = [vert for block in map_data.walls for vert in block]
    
    xs = [vert["x"] for vert in verts]
    zs = [vert["z"] for vert in verts]
    
    width = max(xs) - min(xs)
    height = max(zs) - min(zs)
    
    base_height = 50
    size_ratio = width / height
    
    plt.title(label=map_data.path)
    
    plt.xlim([min(xs) - width/20, max(xs) + width/20])
    plt.ylim([min(zs) - height/20, max(zs) + height/20])
    
    ax = plt.gca()
    ax.set_ylim(ax.get_ylim()[::-1])  # Reverse the Y-axis
    
    
    # Walls
    for block in map_data.walls:
        xs = [vert["x"] for vert in block]
        zs = [vert["z"] for vert in block]
        
        plt.plot(xs, zs, color="black", lw="1")
        
    # Regions 
    for region in map_data.regions:        
        rect = patches.Rectangle((region["x"], region["z"]), region["width"], region["depth"], fill=False)
        ax.add_patch(rect)
        
    # Circles 
    for circle in map_data.circles:        
        circle = patches.Circle((circle["x"], circle["z"]), radius=90, color="r", fill=False)
        ax.add_patch(circle)
        
    icon_chest = np.asarray(Image.open("icons/icon-chest.png"))
    icon_spirit = np.asarray(Image.open("icons/icon-spirit.png"))
    
    for spirit in map_data.spirits:    
        sx = spirit["x"]  
        sz = spirit["z"]  
        
        imagebox = OffsetImage(icon_spirit, zoom=0.4)
        ab = AnnotationBbox(imagebox, (sx, sz), frameon=False, xycoords='data')

        ax.add_artist(ab)
        
    for chest in map_data.chests:    
        sx = chest["x"]  
        sz = chest["z"]  
        
        imagebox = OffsetImage(icon_chest, zoom=0.4)
        ab = AnnotationBbox(imagebox, (sx, sz), frameon=False, xycoords='data')

        ax.add_artist(ab)
    
    fig = plt.gcf()
    fig.set_dpi(100)
    fig.set_size_inches(base_height * size_ratio, base_height)
    fig.savefig("check.png")
    
    plt.show()

def main():
    import sys
    
    # filename = sys.argv[1]
    # plot_crumbs(filename)
    
    # geometry_path = sys.argv[1]
    # find_oob_angles(geometry_path)

    mapdata_path = sys.argv[1]
    mapdata = MapData.load_from_path(mapdata_path)
    
    density_path = mapdata_path + ".density"
    
    if os.path.exists(density_path + ".npy"):
        print("Loading existing density array ...")
        density = np.load(density_path + ".npy")
    else:
        print("Density data not found, generating one ...")
        density = mapdata.get_density_image_data()
        np.save(density_path, density)
        print("Saved new density array ...")
    
    print("Done!")
    print(density.shape)
    
    # plot_map(mapdata)

if __name__ == "__main__":
    main()
