/*
    nvcc -arch=sm_30 bitonic_sort.cu
    ./a.out
*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

/*
  * Every thread gets exactly one value in the unsorted array.
  * must be powers of 2
  * (reduction) to help create better visualizations
*/
#define THREADS 4  // 2^2
#define BLOCKS 16  // 2^4
#define NUM_VALS THREADS*BLOCKS

FILE *fp;

void print_elapsed(clock_t start, clock_t stop) {
    double elapsed = ((double) (stop - start)) / CLOCKS_PER_SEC;
    printf("Elapsed time: %.3fs\n", elapsed);
}

float random_float() {
    return (float) rand() / (float) RAND_MAX;
}

void array_print(float *arr, int length) {
    for (int i = 0; i < length; ++i) {
        printf("%1.3f ", arr[i]);
    }
    printf("\n");
}

/*
  * this function writes the current data in the arr
  * to the file pointer fp
  * (this function helps store the various configurations of the array during the sorting procedure)
*/
void array_write(float *arr, int length) {
    for (int i = 0; i < length; i++) {
        if (i + 1 < length) fprintf(fp, "%f, ", arr[i]);
        else fprintf(fp, "%f\n", arr[i]);
    }
}

/*
  * fill the array with randomized floating point values
*/
void array_fill(float *arr, int length) {
    srand(time(NULL));
    for (int i = 0; i < length; ++i) {
        arr[i] = random_float();
    }
}

__global__ void bitonic_sort_step(float *dev_values, int j, int k) {
    unsigned int i, ixj;  /* Sorting partners: i and ixj */
    i = threadIdx.x + blockDim.x * blockIdx.x;
    ixj = i ^ j;

    /* The threads with the lowest ids sort the array. */
    if ((ixj) > i) {
        if ((i & k) == 0) {
            /* Sort ascending */
            if (dev_values[i] > dev_values[ixj]) {
                /* exchange(i,ixj); */
                float temp = dev_values[i];
                dev_values[i] = dev_values[ixj];
                dev_values[ixj] = temp;
            }
        }
        if ((i & k) != 0) {
            /* Sort descending */
            if (dev_values[i] < dev_values[ixj]) {
                /* exchange(i,ixj); */
                float temp = dev_values[i];
                dev_values[i] = dev_values[ixj];
                dev_values[ixj] = temp;
            }
        }
    }
}


/**
 * Inplace bitonic sort using CUDA.
 */

void bitonic_sort(float *values) {
    float *print_values = (float *) malloc(NUM_VALS * sizeof(float));
    float *dev_values;
    size_t size = NUM_VALS * sizeof(float);

    cudaMalloc((void **) &dev_values, size);
    cudaMemcpy(dev_values, values, size, cudaMemcpyHostToDevice);

    dim3 blocks(BLOCKS, 1);  /* Number of blocks   */
    dim3 threads(THREADS, 1);  /* Number of threads  */

    /* Major step */
    for (int k = 2; k <= NUM_VALS; k <<= 1) {
        /* Minor step */
        for (int j = k >> 1; j > 0; j = j >> 1) {
            bitonic_sort_step << < blocks, threads >> > (dev_values, j, k);
            cudaMemcpy(print_values, dev_values, size, cudaMemcpyDeviceToHost);
            array_write(print_values, NUM_VALS);
        }
    }
    cudaMemcpy(values, dev_values, size, cudaMemcpyDeviceToHost);
    cudaFree(dev_values);
}

int main(void) {
    float *values = (float *) malloc(NUM_VALS * sizeof(float));
    array_fill(values, NUM_VALS);

    fp = fopen("tmp.csv", "w");
    if (fp == NULL) {
        puts("Couldn't open file");
        exit(0);
    }

    /*
      * add the header row to the csv file
    */
    for (int i = 0; i < NUM_VALS; i++) {
        if (i + 1 < NUM_VALS) fprintf(fp, "%d, ", i);
        else fprintf(fp, "%d\n", i);
    }

    bitonic_sort(values);

    fclose(fp);

    return 0;
}