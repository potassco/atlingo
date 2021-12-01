% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Run:
% %     Computes runs for a trace
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#include "./trace.lp". %Last holds in horizon and true holds in all time steps

% Root
node(Q,0) :- initial_state(Q).

% Choose a transition (Existencial)
1{select(C,node(Q,T)):delta(Q,C)}1 :- node(Q,T),T<=horizon.

% Geneterates childs of delected transitions
node(Q',T+M) :- select(C,node(Q,T)), delta(Q,C,(Q',M)).

% Checks transition conditions
:- select(C,node(Q,T)), delta(Q,C,in,A), not trace(A,T).
:- select(C,node(Q,T)), delta(Q,C,out,A), trace(A,T).

% Acceptance condition for finite branches (non-loops)
:- node(Q,T), not select(_,node(Q,T)).

% Acceptance condition for loops
parent(node(Q,T),node(Q',T+M)) :- select(C,node(Q,T)), delta(Q,C,(Q',M)).

relative(X,Y):-parent(X,Y).
relative(X,Z):-relative(X,Y),relative(Y,Z).

:- relative(node(Q,T),node(Q,T)), %Its a loop
    %there are no final nodes in the loop
    #count{node(Q',T') : node(Q',T'), relative(node(Q',T'), node(Q,T)), final_state(Q')} = 0.
   
   


% #show holds_map/2.
% #show trace/2.
% #show node/2.
% #show parent/2.
% #show select/2.
% #show select/3.
% #show node/2.
% #show delta/2.
% #show initial_state/1.
% #show horizon/1.