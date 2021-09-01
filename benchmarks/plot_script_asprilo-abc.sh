HORIZON_R2='--horizon 24 --horizon 25 --horizon 26 --horizon 27 --horizon 28'
# HORIZON_R2='--horizon 26 --horizon 27 --horizon 28 --horizon 29 --horizon 30'
HORIZON_R3='--horizon 26 --horizon 27 --horizon 28 --horizon 29 --horizon 30'
HORIZON_ALL='--horizon 24 --horizon 25 --horizon 26 --horizon 27 --horizon 28 --horizon 29 --horizon 30'
CLINGO_APP='--approach telingo --approach afw'
AUTOMATA_APP='--approach telingo --approach afw --approach dfa-stm --approach dfa-mso'
ALL_APP='--approach nc '${AUTOMATA_APP}
BASE='--x #horizon --dom asprilo-abc '
R2='--instance _r2_'
R3='--instance _r3_'

############ Full tables with horizon windows
python plot.py  ${BASE} ${ALL_APP} ${R2} ${HORIZON_ALL} --type table --stat cons --stat ptime --stat ctime --stat choices --stat conflicts --stat rules --prefix="one-" --models 1 --use-lambda
python plot.py  ${BASE} ${ALL_APP} ${R3} ${HORIZON_ALL} --type table --stat cons --stat ptime --stat ctime --stat choices --stat conflicts --stat rules --prefix="one-" --models 1 --use-lambda

############ Ptime table
python plot.py  ${BASE} ${ALL_APP} ${HORIZON_ALL} --type table --stat ptime --prefix="ptime-" --models 1 --use-lambda

############ Tables with mean to join
python plot.py  ${BASE} ${ALL_APP} ${R2} ${HORIZON_ALL} --type table --stat cons  --stat ctime --stat choices --stat conflicts --stat rules --prefix="for-join" --models 1 --use-lambda --use-gmean --csv
python plot.py  ${BASE} ${ALL_APP} ${R3} ${HORIZON_ALL} --type table --stat cons  --stat ctime --stat choices --stat conflicts --stat rules --prefix="for-join" --models 1 --use-lambda --use-gmean --csv
python plot.py  ${BASE} ${ALL_APP} ${R3} ${HORIZON_ALL} --type table --stat cons  --stat ctime --stat choices --stat conflicts --stat rules --prefix="for-join" --models 1 --use-lambda --use-gmean --csv
############ Join means
python join_csv.py --dom=asprilo-abc --constraint=d1 --constraint=d2 --constraint=d3 --instance=r2 --instance=r3 --prefix-in="for-join" --prefix="all"





for f in $(find ./plots/tables  -type f -name "*.tex");
do
sed -i '' 's/\\midrule//g' $f
sed -i '' 's/\\bottomrule/\\hline/g' $f
sed -i '' 's/\\toprule/\\hline/g' $f
sed -i '' 's/,/\\,/g' $f
done