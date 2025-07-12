import matplotlib.pyplot as plt
import matplotlib.patches as patches
import seaborn as sns
import numpy as np
import statistics
import json
import glob
import os.path
import math
import re

import numpy.typing

from numba import njit
from PIL import Image
from typing import List, Tuple, Dict
from dataclasses import dataclass
from matplotlib.offsetbox import OffsetImage, AnnotationBbox

ENCOUNTER_AREAS = {
    (2, 0): "Holy Plains",
    (31, 0): "Connor Forest",
    (3, 0): "Dondoran Flats",
    (32, 0): "Glencoe Forest",
    (5, 0): "West Carmaugh",
    (27, 0): "Cull Hazard",
    (33, 0): "Windward Forest",
    (26, 0): "Blue Cave",
    (12, 0): "Isle of Skye",
    (7, 0): "East Limelin",
    (28, 0): "Baragoon Tunnel",
    (9, 0): "Dindom Dries",
    (29, 0): "Boil Hole",
    (11, 2): "Baragoon Moor",
    (11, 1): "Brannoch Courtyard",
    (30, 0): "Brannoch Castle 1F",
    (30, 1): "Brannoch Castle 2F",
    (30, 2): "Brannoch Castle 3F",
    (30, 3): "Brannoch Castle 4F",
    (30, 4): "Brannoch Castle 5F",
    (30, 5): "Brannoch Castle 6F",
    (34, 0): "Mammon's World 1",
    (34, 7): "Mammon's World 2",
    (34, 4): "Mammon's World 3",
    (34, 2): "Mammon's World 4",
    (34, 5): "Mammon's World 5",
    (34, 8): "Mammon's World 6",
}

@njit
def sqr_distance(x1, z1, x2, z2):
    dx = x1 - x2
    dz = z1 - z2
    return dx * dx + dz * dz

@njit
def distance(x1, z1, x2, z2):
    dx = x1 - x2
    dz = z1 - z2
    return math.sqrt(dx * dx + dz * dz)

class MapData:
    walls: List[List[Dict]]
    circles: List[Dict]
    regions: List[Dict]
    spirits: List[Dict]
    chests: List[Dict]
    path: str
    density_data: str = ""

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
        data = np.zeros((width, depth), dtype=np.uint32)
        
        for ix in range(x, x + width + 1, 1):
            
            if ix % 100 == 0:
                print(ix, "of", x+width)
            
            for iz in range(z, z + depth + 1, 1):
                data[ix-x-1, iz-z-1] = self.sample_for_encounters(ix, iz)  
        
        return data
        
    def sample_for_encounters(self, x, z) -> Tuple[float]:
        
        max_dist = 0
        min_dist = 10000
        
        valid_count = 0
        # valid_dists = np.array([0, 0, 0, 0, 0])
        
        for circle in self.circles:
            cx, cz = circle["x"], circle["z"]
            
            dx = cx - x
            if dx*dx > 8100:
                continue
            
            dz = cz - z
            if dz*dz > 8100:
                continue
            
            sqr_circle_dist = dx*dx + dz*dz
            
            if sqr_circle_dist < 2500:
                continue
            if sqr_circle_dist > 8100:
                continue
            
            circle_dist = math.sqrt(sqr_circle_dist)
            
            if circle_dist < min_dist:
                min_dist = int(circle_dist)
                
            if circle_dist > max_dist:
                max_dist = int(circle_dist)
                
            # valid_dists[valid_count] = circle_dist
            valid_count += 1
            
            if valid_count >= 5:
                break
        
        if valid_count == 0:
            return 0xFFFFFFFF
        
        # avg_dist = sum(valid_dists[:valid_count]) // valid_count
        # median_dist = int(statistics.median(valid_dists[:valid_count]))
        
        a = (max_dist & 0xFF) << 24
        b = (min_dist & 0xFF) << 16
        # c = (avg_dist & 0xFF) << 8
        # d = (median_dist & 0xFF)
        
        # return a + b + c + d
        return a + b

@njit
def get_median(arr: np.array):
    length = len(arr)
    if length % 2 == 1:
        return arr[length // 2]
    else:
        return (arr[length // 2 - 1] + arr[length // 2]) / 2

@njit
def generate_density_map_sparse(circles: List[Tuple[int]], x, z, width, height, step_divisor=1) -> np.ndarray:
    padding = 100
    matrix = np.zeros((width+2*padding, height+2*padding), dtype=np.uint32)
    
    matrix_work = np.zeros((width+2*padding, height+2*padding, 5), dtype=np.uint8)
    matrix_count = np.zeros((width+2*padding, height+2*padding), dtype=np.uint8)
    
    for (cx, cz) in circles:
        for ix in range(-90, 90, 1):
            for iz in range(-90, 90, 1):
                sqr_dist = ix*ix + iz*iz
                
                if not (2500 < sqr_dist < 8100):
                    continue
                
                dist = int(math.sqrt(sqr_dist))
                
                mx = cx + ix - x + padding
                mz = cz + iz - z + padding
                
                count = matrix_count[mx, mz]
                if count >= 5:
                    continue
                
                matrix_work[mx, mz, count] = dist
                matrix_count[mx, mz] = count + 1
                
                prev_count = matrix_count[mx, mz]
                prev_value = matrix[mx, mz]
                
                prev_min = (prev_value >> 0x18) & 0xFF
                prev_max = (prev_value >> 0x10) & 0xFF
                prev_avg = (prev_value >> 0x08) & 0xFF
                
                new_count = prev_count + 1
                new_min = dist if prev_min == 0 else min(dist, prev_min)
                new_max = dist if prev_max == 0 else max(dist, prev_min)
                new_avg = dist if prev_count == 0 else int((dist + prev_count * prev_avg) / new_count) 
                
                new_collection = matrix_work[mx, mz, :new_count]
                new_median = int(get_median(new_collection))
                
                new_value = ((new_min & 0xFF) << 0x18) + ((new_max & 0xFF) << 0x10) + ((new_avg & 0xFF) << 0x08) + new_median & 0xFF
                
                matrix_count[mx, mz] = prev_count + 1
                matrix[mx, mz] = new_value
            
    print(matrix.shape)
               
    return matrix
                
def sample_for_encounters(self, x, z) -> Tuple[float]:
    
    max_dist = 0
    min_dist = 10000
    
    valid_count = 0
    # valid_dists = np.array([0, 0, 0, 0, 0])
    
    for circle in self.circles:
        cx, cz = circle["x"], circle["z"]
        
        dx = cx - x
        if dx*dx > 8100:
            continue
        
        dz = cz - z
        if dz*dz > 8100:
            continue
        
        sqr_circle_dist = dx*dx + dz*dz
        
        if sqr_circle_dist < 2500:
            continue
        if sqr_circle_dist > 8100:
            continue
        
        circle_dist = math.sqrt(sqr_circle_dist)
        
        if circle_dist < min_dist:
            min_dist = int(circle_dist)
            
        if circle_dist > max_dist:
            max_dist = int(circle_dist)
            
        # valid_dists[valid_count] = circle_dist
        valid_count += 1
        
        if valid_count >= 5:
            break
    
    if valid_count == 0:
        return 0xFFFFFFFF
    
    # avg_dist = sum(valid_dists[:valid_count]) // valid_count
    # median_dist = int(statistics.median(valid_dists[:valid_count]))
    
    a = (max_dist & 0xFF) << 24
    b = (min_dist & 0xFF) << 16
    # c = (avg_dist & 0xFF) << 8
    # d = (median_dist & 0xFF)
    
    # return a + b + c + d
    return a + b

## Taken from:
## https://matplotlib.org/stable/gallery/lines_bars_and_markers/multicolored_line.html
##
def colored_line_between_pts(x, y, c, ax, **lc_kwargs):
    from matplotlib.collections import LineCollection
    """
    Plot a line with a color specified between (x, y) points by a third value.

    It does this by creating a collection of line segments between each pair of
    neighboring points. The color of each segment is determined by the
    made up of two straight lines each connecting the current (x, y) point to the
    midpoints of the lines connecting the current point with its two neighbors.
    This creates a smooth line with no gaps between the line segments.

    Parameters
    ----------
    x, y : array-like
        The horizontal and vertical coordinates of the data points.
    c : array-like
        The color values, which should have a size one less than that of x and y.
    ax : Axes
        Axis object on which to plot the colored line.
    **lc_kwargs
        Any additional arguments to pass to matplotlib.collections.LineCollection
        constructor. This should not include the array keyword argument because
        that is set to the color argument. If provided, it will be overridden.

    Returns
    -------
    matplotlib.collections.LineCollection
        The generated line collection representing the colored line.
    """
    # if "array" in lc_kwargs:
    #     warnings.warn('The provided "array" keyword argument will be overridden')

    # # Check color array size (LineCollection still works, but values are unused)
    # if len(c) != len(x) - 1:
    #     warnings.warn(
    #         "The c argument should have a length one less than the length of x and y. "
    #         "If it has the same length, use the colored_line function instead."
    #     )

    # Create a set of line segments so that we can color them individually
    # This creates the points as an N x 1 x 2 array so that we can stack points
    # together easily to get the segments. The segments array for line collection
    # needs to be (numlines) x (points per line) x 2 (for x and y)
    points = np.array([x, y]).T.reshape(-1, 1, 2)
    segments = np.concatenate([points[:-1], points[1:]], axis=1)
    lc = LineCollection(segments, **lc_kwargs)

    # Set the values used for colormapping
    lc.set_array(c)

    return ax.add_collection(lc)

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
    
    plt.axis('scaled')
    
    ax = plt.gca()
    ax.set_ylim(ax.get_ylim()[::-1])  # Reverse the Y-axis
    
    
    # Walls
    for block in map_data.walls:
        xs = [vert["x"] for vert in block]
        zs = [vert["z"] for vert in block]
        
        # cs = np.linspace(0, 1, num=len(xs)+1)
        # plt.plot(xs, zs, color="black", lw="1")
        plt.plot(xs, zs, lw="1")
        # colored_line_between_pts(xs, zs, cs, ax, cmap="viridis")
        
        for k in range(len(xs)-1):
            x1 = xs[k]
            z1 = zs[k]
            x2 = xs[k+1]
            z2 = zs[k+1]
            ax.annotate("", (x1, z1), (x2, z2), arrowprops=dict(arrowstyle="->"))
        
    # Regions 
    for region in map_data.regions:        
        rect = patches.Rectangle((region["x"], region["z"]), region["width"], region["depth"], fill=False)
        ax.add_patch(rect)
        
    # Circles 
    for circle in map_data.circles:        
        circle = patches.Circle((circle["x"], circle["z"]), radius=90, color="#AA000022", fill=False)
        ax.add_patch(circle)
        
    icon_chest = np.asarray(Image.open("icons/icon-chest.png"))
    icon_spirit = np.asarray(Image.open("icons/icon-spirit.png"))
    
    for spirit in map_data.spirits:    
        sx = spirit["x"]  
        sz = spirit["z"]  
        
        imagebox = OffsetImage(icon_spirit, zoom=0.4)
        ab = AnnotationBbox(imagebox, (sx, sz), frameon=False, xycoords='data')

        ax.add_artist(ab)
        
    # for chest in map_data.chests:    
    #     sx = chest["x"]  
    #     sz = chest["z"]  
        
    #     imagebox = OffsetImage(icon_chest, zoom=0.4)
    #     ab = AnnotationBbox(imagebox, (sx, sz), frameon=False, xycoords='data')

    #     ax.add_artist(ab)
    
    fig = plt.gcf()
    # fig.set_dpi(1000)
    # fig.set_size_inches(base_height * size_ratio, base_height)
    fig.savefig("check.png")
    
    plt.show()

def get_map_ids_from_filename(filename):
    match = re.search(r'mapdata-(\d+)-(\d+)\.json$', filename)
    if match:
        map_id = int(match.group(1))
        submap_id = int(match.group(2))
        return True, map_id, submap_id
    else:
        return False, -1, -1

def generate_all_mapping_data(map_json_folder_path):
    map_json_pattern = os.path.join(map_json_folder_path, "*.json")
    map_json_files = glob.glob(map_json_pattern)
    
    for file_path in map_json_files:
        found_ids, map_id, submap_id = get_map_ids_from_filename(file_path)
        if found_ids and (map_id, submap_id) in ENCOUNTER_AREAS: 
            area_name = ENCOUNTER_AREAS[(map_id, submap_id)]
            print(area_name)
            data = MapData.load_from_path(file_path)
            
            circles = [(int(circle["x"]), int(circle["z"])) for circle in data.circles]
            (x, z, width, height) = data.get_bounds()
            density_map = generate_density_map_sparse(circles, x, z, width, height)
            
            # if area_name == "Holy Plains":
            #     plt.imshow(density_map)
                
            #     plt.axis('scaled')
            #     plt.show()
                
            #     exit(0)
            
            np.save(file_path, density_map)
            
            print("... done!")

def main():
    import sys
    
    # filename = sys.argv[1]
    # plot_crumbs(filename)
    
    # geometry_path = sys.argv[1]
    # # find_oob_angles(geometry_path)

    mapdata_path = sys.argv[1]
    mapdata = MapData.load_from_path(mapdata_path)
    plot_map(mapdata)
    
    # density_path = mapdata_path + ".density"
    
    # if os.path.exists(density_path + ".npy"):
    #     print("Loading existing density array ...")
    #     density = np.load(density_path + ".npy")
    # else:
    #     print("Density data not found, generating one ...")
    #     density = mapdata.get_density_image_data()
    #     np.save(density_path, density)
    #     print("Saved new density array ...")
    
    # print("Done!")
    # print(density.shape)
    
    # plot_map(mapdata)
    
    # generate_all_mapping_data("../lua/data")

if __name__ == "__main__":
    main()
