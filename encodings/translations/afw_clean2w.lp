% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Clean up:
% %     Keep reachable states and map to ids
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% -------------------- Define reachable states
reachable(F) :- initial_state_full(F).
reachable(Q') :- delta_full(Q,C,(Q',_)), reachable(Q).

% -------------------- Assign ids to states
state(0,Q) :- initial_state_full(Q), #count{1,Q':initial_state_full(Q'),Q'<Q}=0.
state(1+N,Q) :- 
    state_full(Q), reachable(Q), not state(0,Q), 
    #count{1,Q': state_full(Q'), Q>Q', reachable(Q'), not state(0,Q')}=N.

initial_state(ID):-initial_state_full(F),state(ID,F).


% -------------------- Keep deltas from reachable states

delta(Q_ID,C) :- delta_full(Q,C), state(Q_ID,Q).
delta(Q_ID,C,T,P) :- delta(Q_ID,C), delta_full(Q,C,T,P), state(Q_ID,Q).
delta(Q_ID,C,(Q_ID',N)) :- delta(Q_ID,C), delta_full(Q,C,(Q',N)), state(Q_ID,Q), state(Q_ID',Q').


final_state(ID) :-final_state_full(Q), state(ID,Q).
