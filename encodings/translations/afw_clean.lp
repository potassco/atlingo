% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Clean up:
% %     Keep reachable states and map to ids
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% -------------------- Remove contradicting cases: (C,in,A) and (C,out,A)
drop_delta(Q,C):- 
    delta_full(Q,C,NotOpt,P), 
    delta_full(Q,C,Opt,P), 
    NotOpt!=Opt.

drop_delta(Q,C):- 
    delta_full(Q,C,bottom). 

% -------------------- Define reachable states
reachable(F) :- initial_state_full(F).
reachable(Q') :- delta_full(Q,C,Q'), reachable(Q), not drop_delta(Q,C).

% -------------------- Assign ids to states
state(0,Q) :- initial_state_full(Q), #count{1,Q':initial_state_full(Q'),Q'<Q}=0.
state(1+N,Q) :- 
    state_full(Q), reachable(Q), not state(0,Q), 
    #count{1,Q': state_full(Q'), Q>Q', reachable(Q'), not state(0,Q')}=N.

initial_state(ID):-initial_state_full(F),state(ID,F).


% -------------------- Assing id to cases
delta_case_id(Q,C,N) :- 
    delta_full(Q,C), not drop_delta(Q,C), 
    #count{Q,C2: delta_full(Q,C2), not drop_delta(Q,C2), C2>C}=N.
% delta_case_id(Q,C,C) :- 
%     delta(Q,C).

% -------------------- Keep deltas from reachable states

delta(Q_ID,C_ID) :- delta_full(Q,C), state(Q_ID,Q), not drop_delta(Q,C), delta_case_id(Q,C,C_ID).
delta(Q_ID,C_ID,T,P) :- delta(Q_ID,C_ID), delta_full(Q,C,T,P), state(Q_ID,Q), delta_case_id(Q,C,C_ID).
delta(Q_ID,C_ID,Q_ID') :- delta(Q_ID,C_ID), delta_full(Q,C,Q'), state(Q_ID,Q), state(Q_ID',Q'), delta_case_id(Q,C,C_ID).


