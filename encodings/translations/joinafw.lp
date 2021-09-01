

%--- diamond(test(F1),F2)

initial_state_new(N):-#count{1,Q:state(Q,QNAME)}=N.
state_new(N,box(stp,top)):-initial_state_new(N).

% join_initial(Q,(Q,())):-initial_state(Q), #count{1,Q2:initial_state(Q2),Q>Q2}=0.

next_initial(Q,null):-initial_state(Q), #false :initial_state(Q2), Q<Q2.

next_initial(Q,Q3):-initial_state(Q), initial_state(Q3), Q3>Q, #false :initial_state(Q2), Q2<Q3, Q2>Q.

cases(Q,M):- #count{1,C: delta(Q,(C,_,_),_)}=M, initial_state(Q).

% Cases from base

delta_join(Q,C):-
                    next_initial(Q,null),
                    delta(Q,C).
delta_join(Q,C,Q'):-
                    next_initial(Q,null),
                    delta(Q,C,Q').
delta_join(Q,C,T,P):-
                    next_initial(Q,null),
                    delta(Q,C,T,P).
                    
                    
% Join base with next

delta_join1(Q2,(CF1,CF2)) :- 
    delta_join(Q1,CF1),
    delta(Q2,CF2),
    next_initial(Q2,Q1).

delta_join1(Q2,(CF1,CF2),Q') :- 
    delta_join(Q1,CF1),
    delta(Q2,CF2,Q'),
    next_initial(Q2,Q1).

delta_join1(Q2,(CF1,CF2),Q') :- 
    delta_join(Q1,CF1,Q'),
    delta(Q2,CF2),
    next_initial(Q2,Q1).

delta_join1(Q2,(CF1,CF2),T,P) :- 
    delta_join(Q1,CF1),
    delta(Q2,CF2,T,P),
    next_initial(Q2,Q1).

delta_join1(Q2,(CF1,CF2),T,P) :- 
    delta_join(Q1,CF1,T,P),
    delta(Q2,CF2),
    next_initial(Q2,Q1).

% -------------------- Remove contradicting cases: (C,in,A) and (C,out,A)
delta_join(Q,C):- delta_join1(Q,C), not drop_delta(C,Q).
delta_join(Q,C,Opt,A):- delta_join1(Q,C,Opt,A), not drop_delta(C,Q).
delta_join(Q,C,Q'):- delta_join1(Q,C,Q'), not drop_delta(C,Q).

drop_delta(C,Q):- 
    delta_join1(Q,C,Opt,A), 
    delta_join1(Q,C,NotOpt,A), 
    NotOpt!=Opt.

% -------------------- Idea to Remove cases contained in others

% drop_delta(C,Q):- 
%     delta_join(Q,(C,_,_),Q'),
%     delta_join(Q,(C2,_,_),_),
%     C<C2,

%     % All conditions are same (contained)
%     % All Quccessors are contained
%     #false: delta_join(Q,(C,Opt,A),_), 
%             not delta_join(Q,(C2,Opt,A),_);
%     #false: delta_join(Q,(C,_,_),Q2), 
%             not delta_join(Q,(C2,_,_),Q2).



% -------------------- Keep new delta from new initial state joined

delta(N,C):- delta_join(Q,C), 
                not next_initial(_,Q),
                initial_state_new(N).

delta(N,C,Q'):- delta_join(Q,C,Q'), 
                not next_initial(_,Q),
                initial_state_new(N).

delta(N,C,T,P):- delta_join(Q,C,T,P), 
                not next_initial(_,Q),
                initial_state_new(N).



#show state(X,L) : state_new(X,L).
#show state(X,L) : state(X,L).
#show initial_state(ID) : initial_state_new(ID).
#show delta(ID,C) :  delta(ID,C).
#show delta(ID,C,N) :  delta(ID,C,N).
#show delta(ID,C,T,P) :  delta(ID,C,T,P).
#show prop/2.
#show final_state(ID) : final_state_nfa(ID).


% #show next_initial/2.
% #show initial_state_new/1.
% #show state_new/2.
% #show delta_join/3.
% #show delta_join/2.
% #show delta_join/4.
% #show cases/2.
