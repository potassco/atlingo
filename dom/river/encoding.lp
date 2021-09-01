#const horizon=9.
time(0..horizon).


% -------- choose (classical)
{at(X,S,T)}:-side(S),thing(X),time(T).
{at(boat,S,T)}:-side(S),time(T).
{take(X,T)}:-side(S),thing(X),time(T),time(T+1).