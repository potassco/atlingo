alive(0).

#const horizon=9.
time(0..horizon).


% -------- fluents
{alive(T)}:-time(T).
{loaded(T)}:-time(T).

% -------- actions
{shoot(T)}:-time(T),T<horizon.
{load(T)}:-time(T),T<horizon.

% Only one action per timestep
:-shoot(T), load(T).
% Consecuence of shooting while loaded
:-shoot(T), loaded(T), alive(T+1).
% After shooting is not loaded
:-shoot(T), loaded(T+1).
% Loading implies loaded
:-load(T), not loaded(T+1), time(T).

% Cant become alive
:-not alive(T), alive(T+1), time(T).
% Inertia alive
:-not shoot(T-1), alive(T-1), not alive(T), time(T).
:-shoot(T), not loaded(T), alive(T), not alive(T+1), time(T).

% Inertia loaded
:-not loaded(T-1), not load(T-1), loaded(T), time(T).

% :-load(T),time(T).
:-alive(horizon).



#show alive/1.
#show loaded/1.
#show load/1.
#show shoot/1.
