% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Run:
% %     Computes runs for a trace
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#include "./trace.lp". %Last holds in horizon and true holds in all time steps


node(ID,0) :- initial_state(ID).

1{select(C,Q,T):delta(Q,C)}1 :- node(Q,T),T<=horizon.

node(Q',T+1) :- select(C,Q,T), delta(Q,C,Q').

:- select(C,Q,T), delta(Q,C,in,A), not trace(A,T).
:- select(C,Q,T), delta(Q,C,out,A), trace(A,T).

:- node(ID,horizon+1), not final_state(ID).

% #show holds_map/2.
% #show trace/2.
% #show node/2.
% #show select/3.
% #show select/3.
% #show node/2.
% #show delta/2.
% #show initial_state/1.
% #show horizon/1.