import matplotlib.pyplot as plt
from typing import List, Tuple

def read_speed_csv(csv_path) -> List[Tuple[int, float]]:
    
    data = []
    
    with open(csv_path, "r") as fp:
        
        lines = fp.readlines()
        lines = lines[1:]
        
        for line in lines:
            input_value, resulting_speed = line.split(",")
            data.append((int(input_value), float(resulting_speed)))
            
    return data


def plot_speed_data(data: List[Tuple[int, float]]) -> None:
    
    walk_data = [(input_value, speed) for (input_value, speed) in data if input_value < 60]
    run_data = [(input_value, speed) for (input_value, speed) in data if input_value >= 60]
    
    (walk_x, walk_y) = zip(*walk_data)
    (run_x, run_y) = zip(*run_data)
    
    
    
    plt.plot(walk_x, walk_y, c="green")
    plt.scatter(walk_x, walk_y, s=20, c="green", alpha=0.5)
    
    plt.plot(run_x, run_y, c="red")
    plt.scatter(run_x, run_y, s=20, c="red", alpha=0.5)
    
    plt.xlabel("Joystick Input, 0 to 127")
    plt.ylabel("Speed")
    plt.title("Joystick Input to Brian Movement Speed")
    
    plt.grid(True)
    plt.show()


def main():
    data = read_speed_csv("data/speed.csv")
    plot_speed_data(data)

if __name__ == "__main__":
    main()
