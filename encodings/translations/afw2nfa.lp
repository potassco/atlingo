

% ------- States

% Power set of afw states
bin(ID,2**(ID)):-state(ID,Q).
number_states(N):-#count{ID:state(ID,_)}=N.
state_nfa_set(0..2**N-1):- number_states(N).

state_nfa_set(X,N):- state_nfa_set(X), X-B>=0, bin(N,B), number_states(N).
state_nfa_set(X,N):- state_nfa_set(X), X-T-B>=0, bin(N,B), 
                     #sum{B':state_nfa_set(X,N'),bin(N',B'),N'>N}=T.

% Size of the set
state_nfa_set_size(X,D):- state_nfa_set(X), #count{N: state_nfa_set(X,N)}=D.

% Assign an idex D to every element in the set
state_nfa_set_indexed(X,N,D) :- state_nfa_set(X,N), 
                                #count{N': state_nfa_set(X,N'), N<N'}=D.

% Initial is set containing only initial afw
% initial_state_nfa(X):- state_nfa_set(X), state_nfa_set(X,ID), 
%                         initial_state(ID), 
%                         #count{ID': state_nfa_set(X,ID'), ID'!=ID}=0. 

% Initial is set containing all initial afw states
initial_state_nfa(X):- state_nfa_set(X), 
                        #false: state_nfa_set(X,ID), not initial_state(ID);
                        #false: not state_nfa_set(X,ID), initial_state(ID).

% initial_state_nfa(1).

% Use only reacheble
state_nfa_reachable(X):-initial_state_nfa(X).


% ------- Transitions

%-----------------   Axiliary to copy all conditions and successor states
% copy_case
% Base, start checking cases for index 0
% delta_nfa_set(X,C,0,(T,P),N'):- delta(N,(C,T,P),N'), 
%                                 state_nfa_set_indexed(X,N,0), 
%                                 state_nfa_reachable(X). 

delta_nfa_set(X,C,0):- delta(N,C), 
                       state_nfa_set_indexed(X,N,0), 
                       state_nfa_reachable(X). 



delta_nfa_set(X,C,0,N'):- delta_nfa_set(X,C,0),
                            state_nfa_set_indexed(X,N,0), 
                            state_nfa_reachable(X),
                            delta(N,C,N'). 

delta_nfa_set(X,C,0,T,P):- delta_nfa_set(X,C,0),
                       state_nfa_set_indexed(X,N,0), 
                       state_nfa_reachable(X),
                       delta(N,C,T,P). 


% Checking cases for next index
% delta_nfa_set(X,(C,CT),B+1,(T,P),N'):- delta_nfa_set(X,CT,B,_,_), 
%                                        delta(N,(C,T,P),N'), 
%                                        state_nfa_set_indexed(X,N,B+1), 
%                                        state_nfa_reachable(X).

delta_nfa_set(X,(C,CT),B+1):- delta_nfa_set(X,CT,B), 
                              delta(N,C), 
                              state_nfa_set_indexed(X,N,B+1), 
                              state_nfa_reachable(X).

delta_nfa_set(X,(C,CT),B+1,N'):- delta_nfa_set(X,(C,CT),B+1),
                            state_nfa_set_indexed(X,N,B+1), 
                            state_nfa_reachable(X),
                            delta(N,C,N').

delta_nfa_set(X,(C,CT),B+1,N'):- delta_nfa_set(X,(C,CT),B+1),
                            state_nfa_set_indexed(X,N,B+1), 
                            state_nfa_reachable(X),
                            delta_nfa_set(X,CT,B,N').


delta_nfa_set(X,(C,CT),B+1,T,P):- delta_nfa_set(X,(C,CT),B+1),
                            state_nfa_set_indexed(X,N,B+1), 
                            state_nfa_reachable(X),
                            delta(N,C,T,P).

delta_nfa_set(X,(C,CT),B+1,T,P):- delta_nfa_set(X,(C,CT),B+1),
                            state_nfa_set_indexed(X,N,B+1), 
                            state_nfa_reachable(X),
                            delta_nfa_set(X,CT,B,T,P).

% Keep only delta with all cases at the last index
delta_nfa_set_final(X,C):- state_nfa_set_size(X,D), 
                           delta_nfa_set(X,C,D-1).

delta_nfa_set_final(X,C,N'):- state_nfa_set_size(X,D), 
                           delta_nfa_set(X,C,D-1,N').

delta_nfa_set_final(X,C,T,P):- state_nfa_set_size(X,D), 
                           delta_nfa_set(X,C,D-1,T,P).                    


delta_nfa(X,C) :- delta_nfa_set_final(X,C).
delta_nfa(X,C,T,P) :- delta_nfa_set_final(X,C,T,P).
delta_nfa(X,C,X') :- delta_nfa_set_final(X,C);
                     #sum{B: bin(ID,B), delta_nfa_set_final(X,C,ID) }=X'.


contradiction(ID,C) :- delta_nfa(ID,C,T1,P), 
                        delta_nfa(ID,C,T2,P), 
                        T1!=T2.

delta_nfa_final(ID,C):-delta_nfa(ID,C), not contradiction(ID,C).
delta_nfa_final(ID,C,N):-delta_nfa_final(ID,C), delta_nfa(ID,C,N).
delta_nfa_final(ID,C,T,P):-delta_nfa_final(ID,C), delta_nfa(ID,C,T,P).

% Set new reacheble states
state_nfa_reachable(X'):-state_nfa_reachable(X), delta_nfa_final(X,_,X').




% ------- Cleanup

% Assign a label to the states
state_nfa_reachable(X,(),0):- initial_state_nfa(X).
state_nfa_reachable(X',(),0):-state_nfa_reachable(X,(),0), delta_nfa_final(X,_,X').

state_nfa_reachable(X,(Q_N,Q_O),D+1):-state_nfa_set_indexed(X,Q_N,D),      
                            state_nfa_reachable(X,Q_O,D).

% Keep labels when finsied
state_nfa(X,L):-state_nfa_reachable(X,L,T), state_nfa_set_size(X,T).

% Use ids for cases
% delta_nfa(ID,(N,Opt,A),ID') :- delta_nfa_reachable(ID,(C,Opt,A),ID'), 
%                     #count{C': C'>C, delta_nfa_reachable(ID,(C',_,_),_)}=N.

% True sinking state
delta_nfa_final(ID,0) :-  state_nfa(ID,()).
delta_nfa_final(ID,0,ID) :-  state_nfa(ID,()).
final_state_nfa(ID) :-  state_nfa(ID,()).



#show state(X,L) : state_nfa(X,L).
#show initial_state(ID) : initial_state_nfa(ID).
#show delta(ID,C) :  delta_nfa_final(ID,C).
#show delta(ID,C,N) :  delta_nfa_final(ID,C,N).
#show delta(ID,C,T,P) :  delta_nfa_final(ID,C,T,P).
#show prop/2.
#show final_state(ID) : final_state_nfa(ID).

% #show delta_nfa_final/3.
% #show delta_nfa_set/3.
% #show delta_nfa_set/4.
% #show delta_nfa_set/5.
% % #show state_nfa_set/2.
% #show state_nfa_set_size/1.
% #show state_nfa_reachable/1.
% #show state_nfa_reachable/3.
% #show contradiction/2.