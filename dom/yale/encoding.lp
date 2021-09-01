#const horizon=9.
time(0..horizon).


% -------- fluents
{alive(T)}:-time(T).
{loaded(T)}:-time(T).

% -------- actions
{shoot(T)}:-time(T),T<horizon.
{load(T)}:-time(T),T<horizon.

#show alive/1.
#show loaded/1.
#show load/1.
#show shoot/1.
