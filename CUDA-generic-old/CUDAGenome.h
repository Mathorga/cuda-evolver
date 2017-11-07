#ifndef __CUDA_GENOME__
#define __CUDA_GENOME__

class CUDAGenome {
public:
    __device__ virtual void initialize() = 0;
    __device__ virtual void evaluate() = 0;
    __device__ virtual void crossover(CUDAGenome *partner, CUDAGenome **offspring) = 0;
    __device__ virtual void mutate() = 0;
    __device__ virtual CUDAGenome *clone() = 0;
    __device__ virtual void scale(float base) = 0;
    __device__ virtual void print() = 0;
    __device__ virtual void output(char *string) = 0;
    __device__ virtual void dealloc() = 0;

    __device__ CUDAGenome(unsigned int xDim = 1, unsigned int yDim = 1, unsigned int zDim = 1) {
        xSize = xDim;
        ySize = yDim;
        zSize = zDim;
        score = 0;
    }

    __device__ unsigned int getXSize() {
        return xSize;
    }
    __device__ unsigned int getYSize() {
        return ySize;
    }
    __device__ unsigned int getZSize() {
        return zSize;
    }
    __device__ float getScore() {
        return score;
    }
    __device__ float getFitness() {
        return fitness;
    }
    __device__ void setFitness(float fness) {
        fitness = fness;
    }
    __device__ void setScore(float scr) {
        score = scr;
    }

protected:
    unsigned int xSize;
    unsigned int ySize;
    unsigned int zSize;
    float score;
    float fitness;
};

#endif