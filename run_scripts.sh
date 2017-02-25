#!/bin/bash
qsub cuda_naive.sh
qsub cuda_strive.sh
qsub cuda_sequential.sh
qsub cuda_first_add.sh
qsub cuda_unroll.sh
qsub cuda_multiple.sh
