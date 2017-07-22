#!/bin/sh
#============ pjsub Options ============
#PJM --rsc-list "node=384"
#PJM --rsc-list "elapse=05:00:00"
#PJM --rsc-list "rscgrp=small"
#PJM --mpi "proc=3072"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin  "rank=* ./mpi_main.out %r:./"
#PJM --stgin  "rank=* ./bits/bits%04r.txt %r:./"
#PJM --stgout "rank=* %r:./filtered%04r.txt %j/"
#PJM -s

. /work/system/Env_base

ulimit -s 8192

mpiexec ./mpi_main.out 0.01 0.7

