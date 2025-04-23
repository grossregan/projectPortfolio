# Zorkstranauts

A text-based adventure game set on Mars, where you navigate through different locations while encountering and fighting alien xenomorphs.

## About the Game

Zorkstranauts is a text-based adventure game inspired by classic text adventures like Zork. You play as an astronaut stranded on a Mars base who must explore various locations while avoiding or confronting dangerous xenomorph aliens.

## Game Features

- **Text-based Navigation**: Move between different locations like Base, Greenhouse, and Communications Tower.
- **Item Collection**: Find and use weapons to defend yourself against xenomorphs.
- **Combat System**: Battle alien xenomorphs with different outcomes based on your choices and whether you've collected weapons.
- **Exploration**: Discover different Mars environments including the base, greenhouse, hills, and communications tower.

## How to Play

1. Start the game in the Base room.
2. Read the description of your current location carefully.
3. Search for weapons when prompted.
4. Navigate between rooms by typing the name of the room you want to visit.
5. When you encounter a xenomorph, choose to either fight or run.
6. Your goal is to survive and explore all areas of the Mars base.

## Game Controls

- Type the name of the room you want to visit when prompted
- Type 'y' or 'Y' to affirm actions (picking up weapons, opening lockers)
- Type 'n' or 'N' to decline actions
- Type 'H' during combat to attack a xenomorph
- Choose option '1' or '2' during xenomorph encounters to attack or run

## Development Team

- Regan Gross
- Jonathan Kivisto
- Kamden T. Ernste

## Course Project

This game was created as a project for CS1511, started on 11/1/2023.

## Technical Information

- Language: C++
- Features included:
  - Structs and Classes
  - Dynamic memory allocation
  - Randomization for combat and encounters
  - ASCII-based interface

## Game Map

```
    [North]
       |
       v
[West] - [Base] - [East]
   |       |
   v       v
[CommTower] - [South]
              |
              v
        [Greenhouse]
```

## Build Instructions

1. Compile the game using a C++ compiler:
   ```
   g++ main.cpp -o zorkstranauts
   ```
2. Run the executable:
   ```
   ./zorkstranauts
   ```

Enjoy your adventure on Mars!
