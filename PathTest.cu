#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <ga/ga.h>
#include "PathGenome.h"

// Translates bidimensional indexes to a monodimensional one.
// |i| is the column index.
// |j| is the row index.
// |n| is the number of columns (length of the rows).
#define IDX(i, j, n) ((i) * (n) + (j))

#define POP_SIZE 10
#define GEN_NUMBER 100
#define MUT_RATE 0.001

#define FIELD_SIZE 512
#define CHECKS_NUMBER 10

typedef unsigned char cell_t;

enum {
    EMPTY = 0,
    CHECK = 1,
    PATH = 2
};

// Code taken from Rosettacode:
// https://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#C.2B.2B
// Implementing Bresenham’s line drawing algorithm.
void drawLine(cell_t *field, int n, int x0, int y0, int x1, int y1) {
    int x = x0;
    int y = y0;

    int dx = abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
    int dy = abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
    int err = (dx > dy ? dx : -dy) / 2, e2;

    for(;;){
        if (!(x == x0 && y == y0) && !(x == x1 && y == y1)) {
            field[IDX(x, y, n)] = PATH;
        }
        if (x == x1 && y == y1) {
            break;
        }
        e2 = err;
        if (e2 >-dx) {
            err -= dy;
            x += sx;
        }
        if (e2 < dy) {
            err += dx;
            y += sy;
        }
    }
}

void dump(const cell_t *field, const PathGenome::_2DDot *path, int n, const char *filename) {

    cell_t *fieldCopy = (cell_t *) malloc(n * n * sizeof(cell_t));
    for (int x = 0; x < n; x++) {
        for (int y = 0; y < n; y++) {
            fieldCopy[IDX(x, y, n)] = field[IDX(x, y, n)];
        }
    }

    if (path != NULL) {
        for (int i = 0; i < CHECKS_NUMBER; i++) {
            drawLine(fieldCopy, n, path[i].x, path[i].y, path[(i + 1) % CHECKS_NUMBER].x, path[(i + 1) % CHECKS_NUMBER].y);
        }
    }
    FILE *out = fopen(filename, "w");
    if (out == NULL) {
        printf("Cannot create \"%s\"\n", filename);
        abort();
    }
    fprintf(out, "P6\n");
    fprintf(out, "%d %d\n", n, n);
    fprintf(out, "255\n");
    for (int x = 0; x < n; x++) {
        for (int y = 0; y < n; y++) {
            if (fieldCopy[IDX((x + 1) % n, y, n)] == CHECK ||
                fieldCopy[IDX(x, (y + 1) % n, n)] == CHECK ||
                fieldCopy[IDX((x + 1) % n, (y + 1) % n, n)] == CHECK ||
                fieldCopy[IDX((x - 1 + n) % n, y, n)] == CHECK ||
                fieldCopy[IDX(x, (y - 1 + n) % n, n)] == CHECK ||
                fieldCopy[IDX((x - 1 + n) % n, (y - 1 + n) % n, n)] == CHECK ||
                fieldCopy[IDX((x + 1) %n, (y - 1 + n) % n, n)] == CHECK ||
                fieldCopy[IDX((x - 1 + n) %n, (y + 1) % n, n)] == CHECK) {
                fprintf(out, "%c%c%c", 255, 30, 30);
            } else if (fieldCopy[IDX(x, y, n)] == CHECK) {
                fprintf(out, "%c%c%c", 20, 20, 0);
            } else if (fieldCopy[IDX(x, y, n)] == EMPTY) {
                fprintf(out, "%c%c%c", 20, 20, 20);
            } else if (fieldCopy[IDX(x, y, n)] == PATH) {
                fprintf(out, "%c%c%c", 250, 175, 53);
            } else {
                printf("Unknown cell state (%d) of cell %d-%d", fieldCopy[IDX(x, y, n)], x, y);
                abort();
            }
        }
    }
    fclose(out);
}


// |-----------------------------------------------------------------------------------------|
// Fitness function test.
// |-----------------------------------------------------------------------------------------|
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
// |-----------------------------------------------------------------------------------------|



// |-----------------------------------------------------------------------------------------|
// Initializers.
// |-----------------------------------------------------------------------------------------|
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
// |-----------------------------------------------------------------------------------------|


// |-----------------------------------------------------------------------------------------|
// CUDA population evaluator.
// |-----------------------------------------------------------------------------------------|
__global__ void evaluate(GAPopulation &pop) {
    // pop.individual(threadIdx.x).evaluate();
}

void cudaEvaluator(GAPopulation &p) {
    dim3 blockSize(p.size());

    // TODO Allocate device memory for the population and cudaMemcpy it.
    // cudaMalloc();
    // cudaMemcpy();

    evaluate<<<1, blockSize>>>(p);
}
// |-----------------------------------------------------------------------------------------|



// |-----------------------------------------------------------------------------------------|
// Main.
// |-----------------------------------------------------------------------------------------|
int main(int argc, char const *argv[]) {
    // Create a field of checks.
    cell_t *field;
    PathGenome::_2DDot *checks;

    field = (cell_t *) malloc(FIELD_SIZE * FIELD_SIZE * sizeof(cell_t));
    checks = (PathGenome::_2DDot *) malloc(CHECKS_NUMBER * sizeof(PathGenome::_2DDot));

    for (int i = 0; i < FIELD_SIZE * FIELD_SIZE; i++) {
        field[i] = EMPTY;
    }

    srand(time(NULL));
    for (int i = 0; i < CHECKS_NUMBER; i++) {
        checks[i].x = (rand() % FIELD_SIZE);
        checks[i].y = (rand() % FIELD_SIZE);
        checks[i].id = i;
        field[IDX(checks[i].x, checks[i].y, FIELD_SIZE)] = true;
    }

    dump(field, NULL, FIELD_SIZE, "field.ppm");

    std::cout << "Original checks:\n";
    for (int i = 0; i < CHECKS_NUMBER; i++) {
        std::cout << "x:" << checks[i].x << "\ty:" << checks[i].y << "\n";
    }

    // Create a genome.
    PathGenome genome(CHECKS_NUMBER, checks);
    std::cout << "genome after creation:\n" << genome << std::endl;

    genome.initialize();
    std::cout << "genome after initialization:\n" << genome << std::endl;

    dump(field, genome.getPath(), FIELD_SIZE, "path.ppm");

    genome.mutate(MUT_RATE);
    std::cout << "genome after mutation:\n" << genome << std::endl;

    dump(field, genome.getPath(), FIELD_SIZE, "pathMutated.ppm");


    PathGenome genome2(CHECKS_NUMBER, checks);
    std::cout << "genome2 after creation:\n" << genome2 << std::endl;

    genome.initialize();
    std::cout << "genome2 after initialization:\n" << genome << std::endl;

    PathGenome *c1 = new PathGenome(CHECKS_NUMBER);
    PathGenome *c2 = new PathGenome(CHECKS_NUMBER);
    PathGenome::onePointCrossover(genome, genome2, c1, NULL);

    std::cout << "child:\n" << *c1 << std::endl;

    // for (int i = 0; i < 1000; i++) {
    //     genome.mutate(MUT_RATE);
    //     char fileName[200];
    //     snprintf(fileName, 200, "pathMut%d.ppm", i);
    //     dump(field, genome.getPath(), FIELD_SIZE, fileName);
    // }

    // for (int i = 0; i < 100; i++) {
    //     genome.initialize();
    //     char fileName[200];
    //     snprintf(fileName, 200, "path%d.ppm", i);
    //     dump(field, genome.getPath(), FIELD_SIZE, fileName);
    // }

    // // Create a population.
    // GAPopulation population(genome);
    // population.evaluator(cudaEvaluator);
    //
    // // Create the genetic algorithm.
    // GASimpleGA ga(population);
    // ga.nGenerations(GEN_NUMBER);
    // ga.pMutation(MUT_RATE);
    //
    // ga.initialize();
    //
    // GAPopulation tmpPop = ga.population();
    // printf("\nInitial population:\n");
    // for (int i = 0; i < tmpPop.size(); i++) {
    //     printf("Individual %d: ", i);
    //     GA1DBinaryStringGenome& individual = (GA1DBinaryStringGenome&)tmpPop.individual(i);
    //     for (int j = 0; j < individual.length(); j++) {
    //         printf("%d", individual.gene(j));
    //     }
    //     printf("\n");
    // }
    // printf("\nBest: ");
    // GA1DBinaryStringGenome &currentBest = (GA1DBinaryStringGenome &)tmpPop.best();
    // for (int i = 0; i < currentBest.length(); i++) {
    //     printf("%d", currentBest.gene(i));
    // }
    // printf("\n\n");


    // for (int i = 0; i < ga.nGenerations(); i++) {
    //     // getchar();
    //     printf("\n\n\nGENERATION %d\n", ga.generation() + 1);
    //     ga.step();
    //     GAPopulation tmpPop = ga.population();
    //     // Print the population.
    //     printf("\nPopulation:\n");
    //     for (int i = 0; i < tmpPop.size(); i++) {
    //         printf("Individual %d: ", i);
    //         GA1DBinaryStringGenome& individual = (GA1DBinaryStringGenome&)tmpPop.individual(i);
    //         for (int j = 0; j < individual.length(); j++) {
    //             printf("%d", individual.gene(j));
    //         }
    //         printf("\n");
    //     }
    //     printf("\nBest: ");
    //     currentBest = (GA1DBinaryStringGenome &)tmpPop.best();
    //     for (int i = 0; i < currentBest.length(); i++) {
    //         printf("%d", currentBest.gene(i));
    //     }
    //     printf("\tfitness: %f", tmpPop.max());
    //     printf("\n\n");
    //
    //     // Print statistics.
    //     // std::cout << ga.statistics() << std::endl;
    // }

    // delete a;
    return 0;
}
// |-----------------------------------------------------------------------------------------|
