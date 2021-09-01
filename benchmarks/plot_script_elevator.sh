HORIZON_F5='--horizon 8 --horizon 9 --horizon 10 --horizon 11 --horizon 12'
HORIZON_F7='--horizon 11 --horizon 12 --horizon 13 --horizon 14 --horizon 15'
HORIZON_F9='--horizon 14 --horizon 15 --horizon 16 --horizon 17 --horizon 18'
HORIZON_F11='--horizon 17 --horizon 18 --horizon 19 --horizon 20 --horizon 21'

AUTOMATA_APP='--approach nfa --approach telingo --approach afw --approach dfa-stm --approach dfa-mso'
ALL_APP='--approach nc '${AUTOMATA_APP}
BASE='--models 0 --x #horizon --dom elevator '
F5='--instance 5_'
F7='--instance 7_'
F9='--instance 9_'
F11='--instance 11_'
############ Models (Just for test)
python plot.py  ${BASE} ${ALL_APP} ${F5} ${HORIZON_F5} --type bar --stat models --prefix="models-" --y 'models'

############ Processing Time
python plot.py  ${BASE} ${ALL_APP} ${F5} --horizon 8 --type bar --stat ptime --prefix="ptime-" --y 'Processing time (sec)'

############ Clingo Times
python plot.py  ${BASE} ${ALL_APP} ${F5} ${HORIZON_F5} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F7} ${HORIZON_F7} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F9} ${HORIZON_F9} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F11} ${HORIZON_F11} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'

############ Choices
python plot.py  ${BASE} ${AUTOMATA_APP} ${F5} ${HORIZON_F5} --type bar --stat choices --prefix="choices-" --y '#choices'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F7} ${HORIZON_F7} --type bar --stat choices --prefix="choices-" --y '#choices'

############ Constraints
python plot.py  ${BASE} ${AUTOMATA_APP} ${F5} ${HORIZON_F5} --type bar --stat cons --prefix="cons-" --y '#cons'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F7} ${HORIZON_F7} --type bar --stat cons --prefix="cons-" --y '#cons'

############ Rules
python plot.py  ${BASE} ${AUTOMATA_APP} ${F5} ${HORIZON_F5} --type bar --stat rules --prefix="rules-" --y '#rules'
python plot.py  ${BASE} ${AUTOMATA_APP} ${F7} ${HORIZON_F7} --type bar --stat rules --prefix="rules-" --y '#rules'