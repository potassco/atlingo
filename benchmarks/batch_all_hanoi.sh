#!/bin/bash
#Activate conda env
source /usr/local/apps/anaconda3/etc/profile.d/conda.sh
conda activate temporal-automata
make copy-programs
cd ..
make clean -s
cd benchmarks

make hanoi-clean-instances

make hanoi-small-instance

./run_bm.sh hanoi nc 14 0
./run_bm.sh hanoi nc 15 0
./run_bm.sh hanoi nc 16 0
./run_bm.sh hanoi nc 17 0
./run_bm.sh hanoi nc 18 0

./run_bm.sh hanoi afw 14 0
./run_bm.sh hanoi afw 15 0
./run_bm.sh hanoi afw 16 0
./run_bm.sh hanoi afw 17 0
./run_bm.sh hanoi afw 18 0

./run_bm.sh hanoi nfa-afw 14 0
./run_bm.sh hanoi nfa-afw 15 0
./run_bm.sh hanoi nfa-afw 16 0
./run_bm.sh hanoi nfa-afw 17 0
./run_bm.sh hanoi nfa-afw 18 0

./run_bm.sh hanoi nfa 14 0
./run_bm.sh hanoi nfa 15 0
./run_bm.sh hanoi nfa 16 0
./run_bm.sh hanoi nfa 17 0
./run_bm.sh hanoi nfa 18 0

./run_bm.sh hanoi dfa-mso 14 0
./run_bm.sh hanoi dfa-mso 15 0
./run_bm.sh hanoi dfa-mso 16 0
./run_bm.sh hanoi dfa-mso 17 0
./run_bm.sh hanoi dfa-mso 18 0

./run_bm.sh hanoi dfa-stm 14 0
./run_bm.sh hanoi dfa-stm 15 0
./run_bm.sh hanoi dfa-stm 16 0
./run_bm.sh hanoi dfa-stm 17 0
./run_bm.sh hanoi dfa-stm 18 0


###### PROJECTED MODELS TO VERIFY CORRECTENESS proj- --project=show

./run_bm.sh hanoi nc 17 0 proj- --project=show
./run_bm.sh hanoi afw 17 0 proj- --project=show
./run_bm.sh hanoi nfa-afw 17 0 proj- --project=show
./run_bm.sh hanoi nfa 17 0 proj- --project=show
./run_bm.sh hanoi dfa-mso 17 0 proj --project=show
./run_bm.sh hanoi dfa-stm 17 0 proj --project=show

make hanoi-clean-instances
make hanoi-medium-instance

./run_bm.sh hanoi nc 30 0
./run_bm.sh hanoi nc 31 0
./run_bm.sh hanoi nc 32 0
./run_bm.sh hanoi nc 33 0
./run_bm.sh hanoi nc 34 0

./run_bm.sh hanoi afw 30 0
./run_bm.sh hanoi afw 31 0
./run_bm.sh hanoi afw 32 0
./run_bm.sh hanoi afw 33 0
./run_bm.sh hanoi afw 34 0

./run_bm.sh hanoi nfa-afw 30 0
./run_bm.sh hanoi nfa-afw 31 0
./run_bm.sh hanoi nfa-afw 32 0
./run_bm.sh hanoi nfa-afw 33 0
./run_bm.sh hanoi nfa-afw 34 0

./run_bm.sh hanoi nfa 30 0
./run_bm.sh hanoi nfa 31 0
./run_bm.sh hanoi nfa 32 0
./run_bm.sh hanoi nfa 33 0
./run_bm.sh hanoi nfa 34 0

./run_bm.sh hanoi dfa-mso 30 0
./run_bm.sh hanoi dfa-mso 31 0
./run_bm.sh hanoi dfa-mso 32 0
./run_bm.sh hanoi dfa-mso 33 0
./run_bm.sh hanoi dfa-mso 34 0

./run_bm.sh hanoi dfa-stm 30 0
./run_bm.sh hanoi dfa-stm 31 0
./run_bm.sh hanoi dfa-stm 32 0
./run_bm.sh hanoi dfa-stm 33 0
./run_bm.sh hanoi dfa-stm 34 0

make hanoi-clean-instances
make hanoi-big-instance

./run_bm.sh hanoi nc 62 0
./run_bm.sh hanoi nc 63 0
./run_bm.sh hanoi nc 64 0
./run_bm.sh hanoi nc 65 0
./run_bm.sh hanoi nc 66 0

./run_bm.sh hanoi afw 62 0
./run_bm.sh hanoi afw 63 0
./run_bm.sh hanoi afw 64 0
./run_bm.sh hanoi afw 65 0
./run_bm.sh hanoi afw 66 0

./run_bm.sh hanoi nfa-afw 62 0
./run_bm.sh hanoi nfa-afw 63 0
./run_bm.sh hanoi nfa-afw 64 0
./run_bm.sh hanoi nfa-afw 65 0
./run_bm.sh hanoi nfa-afw 66 0

./run_bm.sh hanoi nfa 62 0
./run_bm.sh hanoi nfa 63 0
./run_bm.sh hanoi nfa 64 0
./run_bm.sh hanoi nfa 65 0
./run_bm.sh hanoi nfa 66 0

./run_bm.sh hanoi dfa-mso 62 0
./run_bm.sh hanoi dfa-mso 63 0
./run_bm.sh hanoi dfa-mso 64 0
./run_bm.sh hanoi dfa-mso 65 0
./run_bm.sh hanoi dfa-mso 66 0

./run_bm.sh hanoi dfa-stm 62 0
./run_bm.sh hanoi dfa-stm 63 0
./run_bm.sh hanoi dfa-stm 64 0
./run_bm.sh hanoi dfa-stm 65 0
./run_bm.sh hanoi dfa-stm 66 0

python size-table.py

# make clean -s

./print_summary.sh hanoi

cd ..
make clean -s
