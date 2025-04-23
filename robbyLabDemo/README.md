# Robby the Robot Simulation

A genetic algorithm implementation for optimizing Robby the Robot's can-collecting behavior.

## Project Overview

This project implements Robby the Robot, a simple AI that collects cans in a grid environment. The system uses a genetic algorithm to evolve optimal strategies for can collection, based on concepts from Melanie Mitchell's book "Complexity: A Guided Tour."

## Components

- **Robby World Simulator**: A graphical interface for visualizing Robby's behavior.
- **Genetic Algorithm**: Creates and evolves strategies for Robby to efficiently collect cans.
- **Graphics Library**: Provides visualization support via a simple object-oriented graphics system.

## Files

- `main.py`: Contains the genetic algorithm implementation for evolving Robby's strategies.
- `__init__.py`: Provides the Robby World simulator and defines Robby's possible actions and environment.
- `graphics.py`: A simple graphics library used by the simulator for visualization.

## How It Works

### Robby's Environment

Robby navigates a grid world where some cells contain cans. He can:
- Move (north, south, east, west)
- Stay in place
- Attempt to pick up a can
- Move randomly

Robby receives rewards and penalties:
- +10 for successfully picking up a can
- -1 for attempting to pick up when no can is present
- -5 for crashing into a wall

### Genetic Algorithm

The program evolves strategies through:
1. **Fitness Function**: Evaluates how well a strategy performs by running Robby through multiple cleaning sessions.
2. **Selection**: Chooses higher-performing strategies for reproduction.
3. **Crossover**: Combines successful strategies to create offspring.
4. **Mutation**: Introduces random changes to maintain genetic diversity.

### Parameters

Current parameters are set to:
- 200 actions per cleaning session
- 200 individuals in the population
- 1.0 crossover rate
- 0.005 mutation rate
- 500 generations
- 100 cleaning sessions per fitness evaluation

## Running the Project

To run the simulation:

```python
python main.py
```

This will:
1. Create a random initial population of strategies
2. Run the genetic algorithm to evolve better strategies
3. Save results to output files:
   - `GAoutput.txt`: Records progress of the genetic algorithm
   - `bestStrategy.txt`: Contains the best strategy found and its fitness score

## Visualization

The simulation provides a graphical interface showing Robby's movement and can collection. The graphics can be toggled on/off with:
- `rw.graphicsOn()`
- `rw.graphicsOff()`

## Output Files

- **GAoutput.txt**: Records generation number, average fitness, best fitness, and best genome for intervals during evolution.
- **bestStrategy.txt**: Contains the overall best strategy found and its fitness score.

## Credits

- Original Robby the Robot concept from "Complexity: A Guided Tour" by Melanie Mitchell
- Graphics library and World simulator by Jim Marshall, Sarah Lawrence College
- Genetic algorithm implementation by Regan Gross
