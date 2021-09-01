#const horizon=10.
time(1..horizon).
on(D,P,0) :- init_on(D,P).

{ move(D,P,T) : disk(D), peg(P) } 1 :- time(T).

move(D,T)        :- move(D,P,T), time(T).
on(D,P,T)        :- move(D,P,T), time(T).
on(D,P,T)        :- on(D,P,T-1), not move(D,T), time(T).

% D cant move from P in T
blocked(D+1,P,T) :- on(D,P,T-1), time(T).
blocked(D+1,P,T) :- blocked(D,P,T), disk(D), time(T).


% Cant move a blocked disk to a pile with a higher disk on top
:- move(D,P,T), blocked(D+1,P,T), time(T).

% Cant move a blocked disk in a pile beacause it has something on top
:- move(D,T), on(D,P,T-1), blocked(D,P,T), time(T).
:- not 1 { on(D,P,T) } 1, disk(D), time(T).

:- goal_on(D,P), not on(D,P,horizon).

% Used for the constraints 
smallestfree(D,T) :- disk(D); time(T); not blocked(D,_,T), #false : disk(D'), not blocked(D',_,T), D'<D, D'!=1.
move(T) :- move(D,T).

#show move/3.

