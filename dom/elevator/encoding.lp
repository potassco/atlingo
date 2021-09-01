#const horizon=7.
time(0..horizon).

{wait(T); up(T) ; down(T); serve(T)}=1 :- time(T+1),time(T).
:- up(T),   at(X,T), not floor(X+1), time(T).
:- down(T), at(X,T), not floor(X-1), time(T).

at(X+1,T+1):- up(T),   at(X,T), time(T).
at(X-1,T+1):- down(T), at(X,T), time(T).
at(X, T+1)  :- at(X,T), not up(T), not down(T), time(T).
served(X, T) :- at(X,T), serve(T).
called(X,T+1):- called(X,T), time(T), not served(X, T).

ready(T) :- called(X,T), at(X,T).

:- called(X,T), not time(T).

% #show called/2.
% #show time/1.
#show serve/1.
% #show served/2.
% #show at/2.
#show up/1.
#show wait/1.
#show down/1.
% #show prop/2.