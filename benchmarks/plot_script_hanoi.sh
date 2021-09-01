HORIZON_D4='--horizon 14 --horizon 15 --horizon 16 --horizon 17 --horizon 18'
HORIZON_D5='--horizon 30 --horizon 31 --horizon 32 --horizon 33 --horizon 34'
HORIZON_D6='--horizon 62 --horizon 63 --horizon 64 --horizon 65 --horizon 66'

AUTOMATA_APP='--approach nfa --approach nfa-afw --approach afw --approach dfa-stm --approach dfa-mso'
ALL_APP='--approach nc '${AUTOMATA_APP}
BASE='--models 0 --x #horizon --dom hanoi '
D4='--instance 4_'
D5='--instance 5_'
D6='--instance 6_'
############ Models (Just for test)
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D4} ${HORIZON_D4} --type bar --stat models --prefix="models-" --y 'models'
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D5} ${HORIZON_D5} --type bar --stat models --prefix="models-" --y 'models'
python plot.py  ${BASE} ${AUTOMATA_APP} ${D6} ${HORIZON_D6} --type bar --stat models --prefix="models-" --y 'models'

# # ############ Processing Time
# python plot.py  ${BASE} ${ALL_APP} ${D4} ${HORIZON_D4} --type bar --stat ptime --prefix="ptime-" --y 'Processing time (sec)'
# python plot.py  ${BASE} ${ALL_APP} ${D5} ${HORIZON_D5} --type bar --stat ptime --prefix="ptime-" --y 'Processing time (sec)'
python plot.py  ${BASE} ${ALL_APP} ${D6} ${HORIZON_D6} --type bar --stat ptime --prefix="ptime-" --y 'Processing time (sec)'

# # ############ Clingo Times
# python plot.py  ${BASE} ${ALL_APP} ${D4} ${HORIZON_D4} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'
# python plot.py  ${BASE} ${ALL_APP} ${D5} ${HORIZON_D5} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'
python plot.py  ${BASE} ${ALL_APP} ${D6} ${HORIZON_D6} --type bar --stat ctime --prefix="time-" --y 'Clingo time (sec)'

# # ############ Choices
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D4} ${HORIZON_D4} --type bar --stat choices --prefix="choices-" --y '#choices'
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D5} ${HORIZON_D5} --type bar --stat choices --prefix="choices-" --y '#choices'
python plot.py  ${BASE} ${AUTOMATA_APP} ${D6} ${HORIZON_D6} --type bar --stat choices --prefix="choices-" --y '#choices'

# # ############ Constraints
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D4} ${HORIZON_D4} --type bar --stat cons --prefix="cons-" --y '#cons'
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D5} ${HORIZON_D5} --type bar --stat cons --prefix="cons-" --y '#cons'
python plot.py  ${BASE} ${AUTOMATA_APP} ${D6} ${HORIZON_D6} --type bar --stat cons --prefix="cons-" --y '#cons'

# # ############ Rules
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D4} ${HORIZON_D4} --type bar --stat rules --prefix="rules-" --y '#rules'
# python plot.py  ${BASE} ${AUTOMATA_APP} ${D5} ${HORIZON_D5} --type bar --stat rules --prefix="rules-" --y '#rules'
python plot.py  ${BASE} ${AUTOMATA_APP} ${D6} ${HORIZON_D6} --type bar --stat rules --prefix="rules-" --y '#rules'