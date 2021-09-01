% --------------  Assert no branching and no contradictions -------------- %
error_branching :- delta(ID,C,ID_NEXT1), 
                   delta(ID,C,ID_NEXT2), 
                   ID_NEXT1 != ID_NEXT2.

error_contradiction :- delta(ID,C,T1,P), 
                        delta(ID,C,T2,P), 
                        T1!=T2.

% :- error_contradiction.
% :- error_branching.

% --------------  Find reachable states that do not expect 'last' -------------- %

reachable_state(ID) :- initial_state(ID).


reachable_state(ID_NEXT) :- reachable_state(ID);
                            delta(ID,C,ID_NEXT);
                            prop(PROP_LAST,"last");

                            #false :delta(ID,C,in,PROP_LAST);
                            
                            #false :delta(ID,C,ID_NEXT2), 
                                              ID_NEXT2!=ID_NEXT.

% --------------  Check if null or final from reachable states when maybe 'last'-------------- %

%Hit null at any point
sat :- reachable_state(null). 

%Hit final state without excluding last
sat :- reachable_state(ID), 
       delta(ID,C,ID_NEXT),
       final_state(ID_NEXT),
       prop(PROP_LAST,"last"),
       #false: delta(ID,C,out,PROP_LAST).

%Hit nulls without excluding last
sat :- reachable_state(ID);
       prop(PROP_LAST,"last");
       delta(ID,C);
       #false: delta(ID,C,N);
       #false: delta(ID,C,out,PROP_LAST).

% unsat :- not sat.
% :- not sat.

#show not_empty: sat.
#show empty: not sat.
#show unsat/0.
#show error_branching/0.
#show error_contradiction/0.