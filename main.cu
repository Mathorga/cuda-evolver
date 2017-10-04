#include <stdio.h>
#include <stdlib.h>
#include <GAGenome.C>

float Objective(GAGenome&) {
return 0.5;
}

int main(int argc, char const *argv[]) {
    GA1DBinaryStringGenome genome(length, Objective);
    // create a genome
    GASimpleGA ga(genome);
    // create the genetic algorithm
    ga.evolve();
    // do the evolution
    cout << ga.statistics() << endl;
    return 0;
}
