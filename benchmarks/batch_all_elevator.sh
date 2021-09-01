#!/bin/bash
#Activate conda env
source /usr/local/apps/anaconda3/etc/profile.d/conda.sh
conda activate temporal-automata
make copy-programs

###### ALL MODELS

make clean

./run_bm.sh elevator afw 8 0
./run_bm.sh elevator afw 9 0
./run_bm.sh elevator afw 10 0
./run_bm.sh elevator afw 11 0
./run_bm.sh elevator afw 12 0
./run_bm.sh elevator afw 13 0
./run_bm.sh elevator afw 14 0
./run_bm.sh elevator afw 15 0
./run_bm.sh elevator afw 16 0
./run_bm.sh elevator afw 17 0
./run_bm.sh elevator afw 18 0
./run_bm.sh elevator afw 19 0
./run_bm.sh elevator afw 20 0
./run_bm.sh elevator afw 21 0

make clean

./run_bm.sh elevator telingo 8 0
./run_bm.sh elevator telingo 9 0
./run_bm.sh elevator telingo 10 0
./run_bm.sh elevator telingo 11 0
./run_bm.sh elevator telingo 12 0
./run_bm.sh elevator telingo 13 0
./run_bm.sh elevator telingo 14 0
./run_bm.sh elevator telingo 15 0
./run_bm.sh elevator telingo 16 0
./run_bm.sh elevator telingo 17 0
./run_bm.sh elevator telingo 18 0
./run_bm.sh elevator telingo 19 0
./run_bm.sh elevator telingo 20 0
./run_bm.sh elevator telingo 21 0

make clean

./run_bm.sh elevator dfa-mso 8 0
./run_bm.sh elevator dfa-mso 9 0
./run_bm.sh elevator dfa-mso 10 0
./run_bm.sh elevator dfa-mso 11 0
./run_bm.sh elevator dfa-mso 12 0
./run_bm.sh elevator dfa-mso 13 0
./run_bm.sh elevator dfa-mso 14 0
./run_bm.sh elevator dfa-mso 15 0
./run_bm.sh elevator dfa-mso 16 0
./run_bm.sh elevator dfa-mso 17 0
./run_bm.sh elevator dfa-mso 18 0
./run_bm.sh elevator dfa-mso 19 0
./run_bm.sh elevator dfa-mso 20 0
./run_bm.sh elevator dfa-mso 21 0

make clean

./run_bm.sh elevator dfa-stm 8 0
./run_bm.sh elevator dfa-stm 9 0
./run_bm.sh elevator dfa-stm 10 0
./run_bm.sh elevator dfa-stm 11 0
./run_bm.sh elevator dfa-stm 12 0
./run_bm.sh elevator dfa-stm 13 0
./run_bm.sh elevator dfa-stm 14 0
./run_bm.sh elevator dfa-stm 15 0
./run_bm.sh elevator dfa-stm 16 0
./run_bm.sh elevator dfa-stm 17 0
./run_bm.sh elevator dfa-stm 18 0
./run_bm.sh elevator dfa-stm 19 0
./run_bm.sh elevator dfa-stm 20 0
./run_bm.sh elevator dfa-stm 21 0

make clean

./run_bm.sh elevator nfa 8 0
./run_bm.sh elevator nfa 9 0
./run_bm.sh elevator nfa 10 0
./run_bm.sh elevator nfa 11 0
./run_bm.sh elevator nfa 12 0
./run_bm.sh elevator nfa 13 0
./run_bm.sh elevator nfa 14 0
./run_bm.sh elevator nfa 15 0
./run_bm.sh elevator nfa 16 0
./run_bm.sh elevator nfa 17 0
./run_bm.sh elevator nfa 18 0
./run_bm.sh elevator nfa 19 0
./run_bm.sh elevator nfa 20 0
./run_bm.sh elevator nfa 21 0

make clean
./run_bm.sh elevator nc 8 0
./run_bm.sh elevator nc 9 0
./run_bm.sh elevator nc 10 0
./run_bm.sh elevator nc 11 0
./run_bm.sh elevator nc 12 0
# ./run_bm.sh elevator nc 13 0
# ./run_bm.sh elevator nc 14 0
# ./run_bm.sh elevator nc 15 0
# ./run_bm.sh elevator nc 16 0
# ./run_bm.sh elevator nc 17 0
#./run_bm.sh elevator nc 18 0
#./run_bm.sh elevator nc 19 0
#./run_bm.sh elevator nc 20 0
#./run_bm.sh elevator nc 21 0
#



python size-table.py

./print_summary.sh elevator

cd ..
make clean -s
