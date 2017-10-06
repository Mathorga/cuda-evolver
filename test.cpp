#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <ga/ga.h>

#define POP_SIZE 10

float fitness(GAGenome &g) {
    GA1DBinaryStringGenome &genome = (GA1DBinaryStringGenome &)g;

    float score=0.0;
    for (int i = 0; i < genome.length(); i++) {
        // The more 1s are contained in the string, the higher is the fitness.
        // The score is incremented by the value of the current element of the string (0 or 1).
        score += genome.gene(i);
    }
    return score;
}

void randomInitializer(GAGenome &g) {
    GA1DBinaryStringGenome &genome=(GA1DBinaryStringGenome &)g;

    for (int i = 0; i < genome.size(); i++) {
        genome.gene(i, GARandomBit());
    }
}

void worstCaseInitializer(GAGenome &g) {
    GA1DBinaryStringGenome &genome=(GA1DBinaryStringGenome &)g;

    for (int i = 0; i < genome.size(); i++) {
        genome.gene(i, 0);
    }
}

void myEvaluator(GAPopulation &p){
    for (int i = 0; i < p.size(); i++) {
        p.individual(i).evaluate();
    }
}

int main(int argc, char const *argv[]) {
    // Create a genome.
    GA1DBinaryStringGenome genome(20, fitness);
    genome.initializer(worstCaseInitializer);

    // Create a population.
    GAPopulation population(genome, POP_SIZE);
    population.evaluator(myEvaluator);

    // Create the genetic algorithm.
    GASimpleGA ga(population);
    ga.nGenerations(354);
    ga.pMutation(0.001);

    ga.initialize();

    GAPopulation tmpPop = ga.population();
    printf("\nInitial population:\n");
    for (int i = 0; i < tmpPop.size(); i++) {
        printf("Individual %d: ", i);
        GA1DBinaryStringGenome& individual = (GA1DBinaryStringGenome&)tmpPop.individual(i);
        for (int j = 0; j < individual.length(); j++) {
            printf("%d", individual.gene(j));
        }
        printf("\n");
    }
    printf("\nBest: ");
    GA1DBinaryStringGenome &currentBest = (GA1DBinaryStringGenome &)tmpPop.best();
    for (int i = 0; i < currentBest.length(); i++) {
        printf("%d", currentBest.gene(i));
    }
    printf("\n\n");


    for (int i = 0; i < ga.nGenerations(); i++) {
        // getchar();
        printf("\n\n\nGENERATION %d\n", ga.generation() + 1);
        ga.step();
        GAPopulation tmpPop = ga.population();
        // Print the population.
        printf("\nPopulation:\n");
        for (int i = 0; i < tmpPop.size(); i++) {
            printf("Individual %d: ", i);
            GA1DBinaryStringGenome& individual = (GA1DBinaryStringGenome&)tmpPop.individual(i);
            for (int j = 0; j < individual.length(); j++) {
                printf("%d", individual.gene(j));
            }
            printf("\n");
        }
        printf("\nBest: ");
        currentBest = (GA1DBinaryStringGenome &)tmpPop.best();
        for (int i = 0; i < currentBest.length(); i++) {
            printf("%d", currentBest.gene(i));
        }
        printf("\tfitness: %2f", tmpPop.max());
        printf("\n\n");

        std::cout << ga.statistics() << std::endl;
    }
    return 0;
}
