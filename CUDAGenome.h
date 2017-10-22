#ifndef __CUDA_GENOME__
#define __CUDA_GENOME__

class CUDAGenome {
public:
    __host__ __device__ virtual void initialize() = 0;
    __device__ virtual void evaluate() = 0;
    __device__ virtual void crossover(CUDAGenome *partner, CUDAGenome *offspring) = 0;
    __device__ virtual void mutate() = 0;
    __device__ virtual void scale(float base) = 0;
    virtual CUDAGenome *clone() = 0;
    virtual void allocateCopySingle(CUDAGenome **deviceIndividual, CUDAGenome **hostIndividual, cudaMemcpyKind direction) = 0;
    virtual void allocateCopyMultiple(CUDAGenome ***deviceIndividuals, CUDAGenome ***hostIndividuals, unsigned int count, cudaMemcpyKind direction) = 0;

    __host__ __device__ CUDAGenome(unsigned int xDim, unsigned int yDim = 1, unsigned int zDim = 1) {
        xSize = xDim;
        ySize = yDim;
        zSize = zDim;
        score = 0;
    }

    __host__ __device__ unsigned int getXSize() {
        return xSize;
    }
    __host__ __device__ unsigned int getYSize() {
        return ySize;
    }
    __host__ __device__ unsigned int getZSize() {
        return zSize;
    }
    __host__ __device__ float getScore() {
        return score;
    }
    __host__ __device__ float getFitness() {
        return fitness;
    }

protected:
    unsigned int xSize;
    unsigned int ySize;
    unsigned int zSize;
    float score;
    float fitness;
};

#endif
