"""
All code in this file written by Regan Gross.
Code in __init__.py and graphics.py was provided from external sources (shown on files)
"""


import random

import robby
from robby import POSSIBLE_ACTIONS

rw = robby.World(10, 10)

NUM_ACTIONS = 200
POPULATION_SIZE = 200
CROSSOVER_RATE = 1.0
MUTATION_RATE = 0.005
NUM_GENERATIONS = 500
SAVE_INTERVAL = 10
CLEANING_SESSION = 100


##Step 1: fitness function
def fitness(genomes):
    total_score = 0
    for r in range(CLEANING_SESSION):
        rw.goto(0, 0)
        rw.distributeCans()
        session_score = 0

        for p in range(NUM_ACTIONS):
            action = genomes[p]
            move = POSSIBLE_ACTIONS[int(action)]
            reward = rw.performAction(move)
            session_score += reward
        total_score += session_score
    return total_score / CLEANING_SESSION

##Step 2: fitness sorting
def sort_by_fitness(genomes):
    tuples = [(fitness(g), g) for g in genomes]
    tuples.sort()
    sortedFitnessValues = [f for (f, g) in tuples]
    sortedGenomes = [g for (f, g) in tuples]
    averageFitnessValue = sum(sortedFitnessValues) / len(sortedFitnessValues)
    return sortedGenomes, sortedFitnessValues, averageFitnessValue

##Step 3: genome selection
def genome_selection(genomes):
    ranks = list(range(1, POPULATION_SIZE+1)) #recreate the ranks for sorted genomes starting at 1 to give lowest fitness a probability of selection

    probability_ranks = [rank/POPULATION_SIZE for rank in ranks]

    selected_genomes = random.choices(genomes, probability_ranks, k=2)
    return selected_genomes

##Step 4: single point crossover
def crossover(parent1, parent2):
    if random.random() < CROSSOVER_RATE:
        point = random.randrange(1, NUM_ACTIONS-1) ##point for crossover, must be within range of the genome, and cannot be last (no crossover would occur)
        child1 = parent1[:point] + parent2[point:]
        child2 = parent2[:point] + parent1[point:]
        return child1, child2
    return parent1, parent2

##Step 5: mutate population
def mutate_genome(genome):
    mutated_genome = list(genome)
    for i in range(len(mutated_genome)):
        if random.random() < MUTATION_RATE:
            mutated_genome[i] = random.choice('0123456') ##change action = mutated genome
    return ''.join(mutated_genome)

##Final Step: Evolve population
def evolution(genome):
    GAoutput = open('GAoutput.txt', 'w')
    bestFitness = 0
    bestGenome = genome[0]
    for g in range(NUM_GENERATIONS):
        new_population = []
        sorted_genome, sorted_fitness, average_fitness = sort_by_fitness(genome)
        current_best_genome = sorted_genome[-1]
        current_best_fitness = sorted_fitness[-1]

        new_population.append(bestGenome)  # always adding best genome (elitism)

        while len(new_population) < POPULATION_SIZE:
            parent1, parent2 = genome_selection(sorted_genome)
            child1, child2= crossover(parent1, parent2)

            new_population.append(''.join(map(str, mutate_genome(child1))))

            while len(new_population) < POPULATION_SIZE:
                new_population.append(''.join(map(str, mutate_genome(child2))))

        if g % SAVE_INTERVAL == 0:
            print('Generation: ' + str(g) + '   Average Fitness: ' + str(average_fitness) + '   Best Fitness: ' + str(
                current_best_fitness) + '   Current best genome: ' + current_best_genome)
            GAoutput.write('Generation: ' + str(g) + '   Average Fitness: ' + str(average_fitness) + '   Best Fitness: ' + str(
                current_best_fitness) + '   Current best genome: ' + current_best_genome + '\n')
        elif g == NUM_GENERATIONS - 1:
            print('Generation: ' + str(g) + '   Average Fitness: ' + str(average_fitness) + '   Best Fitness: ' + str(
                current_best_fitness) + '   Current best genome: ' + current_best_genome + '\n')
            GAoutput.write(
                'Generation: ' + str(g) + '   Average Fitness: ' + str(average_fitness) + '   Best Fitness: ' + str(
                    current_best_fitness) + '   Current best genome: ' + current_best_genome + '\n')

        if bestFitness < current_best_fitness:
            bestStrategy = open('bestStrategy.txt', 'w')
            bestFitness = current_best_fitness
            bestGenome = current_best_genome
            bestStrategy.write('Best strategy: ' + str(current_best_genome + '\n  Fitness: ' + str(current_best_fitness)))
            bestStrategy.close()


        genome = new_population


    return genome


def main():
    startPopulation = [''.join(random.choices('0123456', k=243)) for _ in range(POPULATION_SIZE)]
    rw.graphicsOff()
    evolution(startPopulation)


if __name__ == '__main__':
    main()

