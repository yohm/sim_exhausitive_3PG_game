#!/bin/sh
#============ pjsub Options ============
#PJM --rsc-list "node=768"
#PJM --rsc-list "elapse=01:00:00"
#PJM --rsc-list "rscgrp=large"
#PJM --mpi "proc=6144"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin  "rank=* ./efficiency.out %r:./"
#PJM --stgin  "rank=* ./result_defensible/split6144/defense_split%04r %r:./"
#PJM --stgout "rank=* %r:./defense_efficiency_%04r %j/"
#PJM -s

. /work/system/Env_base

ulimit -s 8192

mpiexec ./efficiency.out 0.001 defense_split%04d defense_efficiency_%04d

