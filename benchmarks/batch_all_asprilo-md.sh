#!/bin/bash
#Activate conda env
source /usr/local/apps/anaconda3/etc/profile.d/conda.sh
conda activate temporal-automata
make copy-programs
make clean -s

make asprilo-clean-instances
make asprilo-small-instances
###### ALL MODELS

./run_bm.sh asprilo afw 6 0
./run_bm.sh asprilo afw 7 0
#./run_bm.sh asprilo afw 8 0

./run_bm.sh asprilo telingo 6 0
./run_bm.sh asprilo telingo 7 0
#./run_bm.sh asprilo telingo 8 0

./run_bm.sh asprilo dfa-mso 6 0
./run_bm.sh asprilo dfa-mso 7 0

./run_bm.sh asprilo dfa-stm 7 0
./run_bm.sh asprilo dfa-stm 6 0

#./run_bm.sh asprilo nc 6 0
#./run_bm.sh asprilo nc 7 0
#./run_bm.sh asprilo nc 6 0
#./run_bm.sh asprilo nc 7 0
#./run_bm.sh asprilo nc 8 0


# make asprilo-clean-instances
# make asprilo-all-grid
###### ALL MODELS GRID

# ./run_bm.sh asprilo afw 5 0 grid-

#./run_bm.sh asprilo afw_del 5 0 grid-

#./run_bm.sh asprilo asp 5 0 grid-

#./run_bm.sh asprilo nc 5 0 grid-

# ./run_bm.sh asprilo afw 6 0 grid-

# ./run_bm.sh asprilo afw_del 6 0 grid-

# ./run_bm.sh asprilo asp 6 0 grid-

# ./run_bm.sh asprilo nc 6 0 grid-

# ./run_bm.sh asprilo afw_del 20 1 grid-
# ./run_bm.sh asprilo afw_del 25 1 grid-
# ./run_bm.sh asprilo afw_del 30 1 grid-
# ./run_bm.sh asprilo afw_del 35 1 grid-

# ./run_bm.sh asprilo afw 20 1 grid-
# ./run_bm.sh asprilo afw 25 1 grid-
# ./run_bm.sh asprilo afw 30 1 grid-
# ./run_bm.sh asprilo afw 35 1 grid-

# ./run_bm.sh asprilo nc 20 1 grid-
# ./run_bm.sh asprilo nc 25 1 grid-
# ./run_bm.sh asprilo nc 30 1 grid-
# ./run_bm.sh asprilo nc 35 1 grid-

# ./run_bm.sh asprilo asp 20 1 grid-
# ./run_bm.sh asprilo asp 25 1 grid-
# ./run_bm.sh asprilo asp 30 1 grid-
# ./run_bm.sh asprilo asp 35 1 grid-

###### PROJECTED MODELS TO VERIFY CORRECTENESS
# make asprilo-clean-instances
# make asprilo-small-instances
./run_bm.sh asprilo afw 7 0 proj- --project=show
#./run_bm.sh asprilo afw 7 0 proj- '--project=show' 

./run_bm.sh asprilo telingo 7 0 proj- --project=show
#./run_bm.sh asprilo afw_del 7 0 proj- '--project=show'

./run_bm.sh asprilo dfa-stm 7 0 proj- --project=show

./run_bm.sh asprilo dfa-mso 7 0 proj- --project=show


make clean -s

python size-table.py

./print_summary.sh asprilo

cd ..
make clean -s
