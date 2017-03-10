#include <stdlib.h>
#include <stdio.h>

#include "cuda_utils.h"
#include "timer.c"

typedef float dtype;


__global__ 
void matTrans(dtype* AT, dtype* A, int N)  
{
	/* Fill your code here */
	int tile_dim = 32;
	int block_row = 8;
	__shared__  dtype tile[TILE_SIZE];

	int x = blockIdx.x * tile_dim + threadIdx.x;
	int y = blockIdx.y * tile_dim + threadIdx.y;
	int width = gridDim.x * tile_dim;

	//split into 32*32 tiles
	for(int i = 0; i < tile_dim; i+= block_row){
		tile[(threadIdx.y + i) * tile_dim + threadIdx.x] = A[(y+i) * width + x];
	}

	__syncthreads ();

}

void
parseArg (int argc, char** argv, int* N)
{
	if(argc == 2) {
		*N = atoi (argv[1]);
		assert (*N > 0);
	} else {
		fprintf (stderr, "usage: %s <N>\n", argv[0]);
		exit (EXIT_FAILURE);
	}
}


void
initArr (dtype* in, int N)
{
	int i;

	for(i = 0; i < N; i++) {
		in[i] = (dtype) rand () / RAND_MAX;
	}
}

void
cpuTranspose (dtype* A, dtype* AT, int N)
{
	int i, j;

	for(i = 0; i < N; i++) {
		for(j = 0; j < N; j++) {
			AT[j * N + i] = A[i * N + j];
		}
	}
}

int
cmpArr (dtype* a, dtype* b, int N)
{
	int cnt, i;

	cnt = 0;
	for(i = 0; i < N; i++) {
		if(abs(a[i] - b[i]) > 1e-6) cnt++;
	}

	return cnt;
}



void
gpuTranspose (dtype* A, dtype* AT, int N)
{
	struct stopwatch_t* timer = NULL;
	long double t_gpu;
	dtype *i_data, *o_data;		//input data and outdata
	int TILE_DIM = 32;
	//defining the block and number of threads
	dim3 gb(N/TILE_DIM, N/TILE_DIM, 1);
	dim3 tb(TILE_DIM, 8, 1);

	//Allocating the memory for the input and output matrix
	CUDA_CHECK_ERROR(cudaMalloc(&i_data, N*N*sizeof(dtype)));
	CUDA_CHECK_ERROR(cudaMalloc(&o_data, N*N*sizeof(dtype)));
	CUDA_CHECK_ERROR(cudaMemcpy(i_data, A, N*N*sizeof(dtype), cudaMemcpyHostToDevice));

	/* Setup timers */
	stopwatch_init ();
	timer = stopwatch_create ();

	stopwatch_start (timer);

	/* run your kernel here */
	matTrans <<<gb, tb>>> (o_data, i_data, N);

	cudaThreadSynchronize ();
	t_gpu = stopwatch_stop (timer);
	fprintf (stderr, "GPU transpose: %Lg secs ==> %Lg billion elements/second\n",
	t_gpu, (N * N) / t_gpu * 1e-9 );

	CUDA_CHECK_ERROR(cudaMemcpy (AT, o_data, N*N*sizeof(dtype),cudaMemcpyDeviceToHost));

}

int 
main(int argc, char** argv)
{
  /* variables */
	dtype *A, *ATgpu, *ATcpu;
  int err;

	int N;

  struct stopwatch_t* timer = NULL;
  long double t_cpu;


	N = -1;
	parseArg (argc, argv, &N);

  /* input and output matrices on host */
  /* output */
  ATcpu = (dtype*) malloc (N * N * sizeof (dtype));
  ATgpu = (dtype*) malloc (N * N * sizeof (dtype));

  /* input */
  A = (dtype*) malloc (N * N * sizeof (dtype));

	initArr (A, N * N);

	/* GPU transpose kernel */
	gpuTranspose (A, ATgpu, N);

  /* Setup timers */
  stopwatch_init ();
  timer = stopwatch_create ();

	stopwatch_start (timer);
  /* compute reference array */
	cpuTranspose (A, ATcpu, N);
  t_cpu = stopwatch_stop (timer);
  fprintf (stderr, "Time to execute CPU transpose kernel: %Lg secs\n",
           t_cpu);

  /* check correctness */
	err = cmpArr (ATgpu, ATcpu, N * N);
	if(err) {
		fprintf (stderr, "Transpose failed: %d\n", err);
	} else {
		fprintf (stderr, "Transpose successful\n");
	}

	free (A);
	free (ATgpu);
	free (ATcpu);

  return 0;
}
