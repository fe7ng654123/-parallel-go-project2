#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<cuda.h>
#include<cuda_runtime.h>

#include"util.h"

// If you have referenced to any source code that is not written by you
// You have to cite them here.

__global__ void
vectorComp(const float *A, int *C, const int number, const int dim)
{
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
	// int counter =0;
	// int z =0; // step from 0..dim

	float tmp[7] = {0};

	for (int i = 0; i < dim; i++)
	{
		tmp[i] = A[tid*dim+i];
	}

	for (int j = 0; j < number*dim; j+=dim){
		// counter =0;
		if(j == tid*dim) continue;

		for (int k = 0; k< dim; k++)
		{
			if (tmp[k]<A[k+j]){
				goto come_here;
			}
				
		}
		
		C[tid] = -1;
		break;

		come_here:
			continue;
		
	}
	
}

extern "C" int asgn2b(Point * points, Point ** pPermissiblePoints, int number, int dim, int gpuid)
{
    // points -- input data
    // pPermissiblePoints -- your computed answer
    // number -- number of points in dataset
    // dim -- the dimension of the dataset
    // gpuid -- the gpu used to run the program
    
	int permissiblePointNum = 0;
	Point * permissiblePoints = NULL;
	// Point * permissiblePoints = (Point *)malloc(number*sizeof(Point));

	cudaSetDevice(gpuid);

	//the following for-loop iterates the first 20 points that will be inputted by runtest.c
	// for(int i = -1; i < 20; i++)
		// printPoint(points[i], dim);

	//the following for-loop prints the first 3 floats of first 9 points
	// for (int i = 0; i < 9; i++)
	// {
	// 	printf("points[%d].id=%d, values[1-3] = ",i, points[i].ID);
	// 	for (int j = 0; j < 3; j++)
	// 	{
	// 		printf(" %f |",points[i].values[j]);
	// 	}
	// 	printf("\n");
		
	// }
	

	/**********************************************************************************
	 * Work here
	 * *******************************************************************************/

	printf("\n--------------start---------------\n\n");


	permissiblePoints= (Point *)realloc(permissiblePoints, number*sizeof(Point));

	// Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;

	// Allocate the device input vector A
    float *d_A = NULL;
    // err = cudaMalloc((void **)&d_A, dim*sizeof(float)*number);
	cudaMallocManaged(&d_A, dim*number*sizeof(float));


	int *d_ResultID = NULL;
    // err = cudaMalloc((void **)&d_ResultID, number*sizeof(int));
	cudaMallocManaged(&d_ResultID, number*sizeof(int));



	for (int i = 0; i < number; i++)
	{
		for (int j = 0; j < dim; j++)
		{
			d_A[i*dim+j] = points[i].values[j];
			// h_B[i*dim+j] = points[i].values[j];
		}
		
	}
	

	int threadsPerBlock = 256;
    int blocksPerGrid =(number + threadsPerBlock - 1) / threadsPerBlock;
    printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
    vectorComp<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_ResultID, number, dim);
    err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch vectorComp kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }


	cudaDeviceSynchronize();


	for (int i = 0; i < number; i++)
	{
		if(d_ResultID[i] != -1){
			memcpy(&permissiblePoints[permissiblePointNum],&points[i],sizeof(Point));
			permissiblePointNum++;
		} 
	}



    printf("final permissiblePointNum = %d\n", permissiblePointNum);
    
	cudaFree(d_A);
	cudaFree(d_ResultID);
    

    printf("\n--------------end---------------\n\n");
	
	*pPermissiblePoints = permissiblePoints;
	return permissiblePointNum;
}
