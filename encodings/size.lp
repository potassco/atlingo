size(delta,M):-#count{1,S,N:delta(S,N)}=M. 
size(state,M):-#count{1,S:state(ID,S)}=M.
size(initial_state,M):-#count{1,S:initial_state(S)}=M.
size(final_state,M):-#count{1,S:final_state(S)}=M.
#show size/2.