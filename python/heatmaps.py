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
    
@dataclass
class EncounterAABB:
    x: int
    z: int
    width: int
    depth: int
    
    def contains(self, sample_x: float, sample_z: float) -> bool:
        if not (self.x <= sample_x <= (self.x + self.width)):
            return False

        if not (self.z <= sample_z <= (self.z + self.depth)):
            return False
        
        return True

@dataclass
class Circle:
    x: int
    z: int

    def sqr_distance(self, sample_x: float, sample_z: float) -> float:
        dx = sample_x - self.x
        dz = sample_z - self.z
        
        return dx*dx + dz*dz

@dataclass
class RegionDefinition:
    name: str
    aabbs: List[EncounterAABB]
    circles: List[Circle]
    walls: RegionWallDefinition
    
    def get_full_bounds(self) -> Tuple[int, int, int, int]:
        min_x = +999999
        max_x = -999999
        min_z = +999999
        max_z = -999999
        
        for aabb in self.aabbs:
            if min_x > aabb.x:
                min_x = aabb.x
            if max_x < aabb.x + aabb.width:
                max_x = aabb.x + aabb.width
            if min_z > aabb.z:
                min_z = aabb.z
            if max_z < aabb.z + aabb.depth:
                max_z = aabb.z + aabb.depth
                
        return (min_x, min_z, max_x, max_z)
    
    def aabbs_contain_point(self, sample_x: float, sample_z: float) -> bool:
        for aabb in self.aabbs:
            if aabb.contains(sample_x, sample_z):
                return True
            
        return False
    
    def calculate_density_map(self, density=1) -> List[List[float]]:
        
        print(f"Creating density map for: {self.name}")
        
        (min_x, min_z, max_x, max_z) = self.get_full_bounds()
        
        x = np.linspace(min_x, max_x, int((max_x - min_x ) / density))
        z = np.linspace(min_z, max_z, int((max_z - min_z ) / density))
        
        X, Z = np.meshgrid(x, z)
        
        distances = np.zeros_like(X) 
        
        # Total iterations and progress tracking
        total_iterations = X.size  # Total number of grid points
        progress_interval = total_iterations // 10  # For 10% intervals

        for count, (i, j) in enumerate(np.ndindex(X.shape)): 
            sample_x = X[i, j] 
            sample_z = Z[i, j]
            
            overlaps_an_aabb = self.aabbs_contain_point(sample_x, sample_z)
            if overlaps_an_aabb:
                for circle in self.circles:
                    dist_sqr = circle.sqr_distance(sample_x, sample_z)
                    if 2500 <= dist_sqr <= 8100:
                        distances[i, j] = math.sqrt(dist_sqr)
                        break
        
            # Print progress every 10% of the iterations
            if count % progress_interval == 0:
                progress = (count / total_iterations) * 100
                print(f"Progress: {progress:.1f}%")
        
        # Plot the heatmap
        plt.figure(figsize=(50, 30))
        plt.imshow(
            distances,
            extent=[x.min(), x.max(), z.min(), z.max()],
            origin='lower',
            aspect='auto',
            cmap='viridis'
        )
        plt.colorbar(label='Density')
        plt.xlabel('X-axis')
        plt.ylabel('Z-axis')
        plt.title(self.name + " Density Map")
        plt.gca().invert_xaxis()
        
        ax = plt.gca()
        
        for aabb in self.aabbs:
            rect = patches.Rectangle(
                (aabb.x, aabb.z),
                aabb.width,
                aabb.depth,
                linewidth=2,
                edgecolor='red',
                facecolor='none'
            )
            ax.add_patch(rect)
        
        for wall_segment in self.walls.walls:
            plt.plot(wall_segment.x, wall_segment.z, linewidth=2, color="black")
        
        # plt.show()
        plt.savefig(f"out/{self.name}.png")
        plt.close()
        
        return distances
    
def get_region_names(data_path: str) -> List[str]:
    filenames = [filename for filename in listdir(data_path) if isfile(join(data_path, filename))]
    region_names = set([f.removesuffix("-circles").removesuffix("-regions") for f in filenames])
    
    return list(region_names)


def load_rows_at_path(full_path: str) -> List[List[float]]:
    
    with open(full_path, "r") as fp:
        lines = fp.readlines()
        rows = [[float(col) for col in line.split(",")] for line in lines if line.strip() != ""]
        
        return rows
    
    return []

def load_circles_at_path(data_path: str, region_name: str) -> List[Circle]:
    
    path = join(data_path, region_name + "-circles")
    rows = load_rows_at_path(path)
    circles = [Circle(x=row[0], z=row[1]) for row in rows]
        
    return circles
    
def load_aabbs_at_path(data_path: str, region_name: str) -> List[EncounterAABB]:
    
    path = join(data_path, region_name + "-regions")
    rows = load_rows_at_path(path)
    aabbs = [EncounterAABB(x=row[0], z=row[1], width=row[2], depth=row[3]) for row in rows]
        
    return aabbs

def load_walls_at_path(data_path: str, region_name: str) -> RegionWallDefinition:
    
    walls = []
    
    filenames = [filename for filename in listdir(data_path) if isfile(join(data_path, filename))]
    crumb_names = [f for f in filenames if ("-crumbs" in f) and (region_name in f)]
    for crumb_filename in crumb_names:
        full_path = join(data_path, crumb_filename)
        crumb_rows = load_rows_at_path(full_path)
        
        xs = [row[0] for row in crumb_rows]
        zs = [row[1] for row in crumb_rows]
        
        wall = WallDefinition(x=xs, z=zs)
        walls.append(wall)
    
    return RegionWallDefinition(walls=walls)

def get_data_for_region(data_path: str, region_name: str) -> RegionDefinition:

    walls = load_walls_at_path("data/crumbs", region_name)
    aabbs = load_aabbs_at_path(data_path, region_name)
    circles = load_circles_at_path(data_path, region_name)
    region = RegionDefinition(name=region_name, aabbs=aabbs, circles=circles, walls=walls)

    return region


def plot_crumbs(filename):
    
    

def main():
    
    # # region_names = get_region_names("data")
    
    # # for name in region_names:
    # #     region = get_data_for_region("data", name)
    # #     density_map = region.calculate_density_map(density=2)      
    
    # region = get_data_for_region("data", "cull-hazard")
    # density_map = region.calculate_density_map(density=5)        
    
    import sys
    filename = sys.argv[1]
    plot_crumbs(filename)

if __name__ == "__main__":
    main()
