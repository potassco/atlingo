% p(2).
% p(3).
% p(1).
% q(1).
% q(2).
% p(0).
time(0..horizon).
{p(T)}:-time(T).
{q(T)}:-time(T).

#show p/1.
#show q/1.