#!/bin/sh
#============ pjsub Options ============
#PJM --rsc-list "node=768"
#PJM --rsc-list "elapse=01:00:00"
#PJM --rsc-list "rscgrp=large"
#PJM --mpi "proc=6144"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin  "rank=* ./defense1.out %r:./"
#PJM --stgin  "rank=* ./split6144/defense1_split_%04r %r:./"
#PJM --stgout "rank=* %r:./defense_out_%04r %j/"
#PJM -s

. /work/system/Env_base

ulimit -s 8192

mpiexec ./defense1.out defense1_split_%04d defense_out_%04d

