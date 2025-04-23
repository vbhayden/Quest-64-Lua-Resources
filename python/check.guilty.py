import math
import numpy as np
import matplotlib.pyplot as plt

collision_radius = 9.52
collision_height = 24.64

data = np.genfromtxt("./data/guilty-00.01.csv", delimiter=',', names=['x', 'y'])

def est_collision_function(x):
    
    """
    For a tiny projectile, the distance is checked against:

    projectile_size + collision_radius < math.sqrt(dx^2 + dy^2)

    
    Since dy here is halved, so for a small projectile, we get:
    
    collision_radius < math.sqrt(dx^2 + (actual_dy/2)^2)

    
    Solving for Y and assuming positive values / the lower semicircle, we get:
    
    collision_radius^2 < dx^2 + (actual_dy/2)^2
    collision_radius^2 - dx^2 < (actual_dy/2)^2
    2 * math.sqrt(collision_radius^2 - dx^2) < actual_dy
    """
    dx = x
    return 2 * math.sqrt(collision_radius**2 - dx**2) + collision_height / 2

data["x"] -= 0
data["y"] -= 50

est_domain = np.linspace(-collision_radius, +collision_radius, 101)
est_border = np.array([est_collision_function(x) for x in est_domain])
    

# print(data[1])
# exit(0)

fig = plt.figure()

plt.scatter(data["x"], data["y"], c='r', s=10)
plt.scatter(-data["x"], data["y"], c='r', s=10)


enemy_x = [-collision_radius, +collision_radius]
enemy_y = [collision_height / 2, collision_height / 2]

# plt.plot(enemy_x, enemy_y, c='g')
plt.plot(est_domain, est_border, c='grey')

plt.axis('scaled')
plt.grid(True)

plt.title(f"Radius: {collision_radius:.2f}, Height: {collision_height:.2f}")
plt.suptitle("Guilty Collision Boundary")

# plt.xlim([-100, 100])
# plt.ylim([0, 30])

plt.show()
