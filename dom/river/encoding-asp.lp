% -------- Constraints
at(X,r,0):-thing(X).

% Cant be in both sides at the same time
:- at(X,S,T), at(X,S',T), side(S), side(S'), S!=S', thing(X), time(T).
% Cant be in none of the sides
:- not at(X,S,T), not at(X,S',T), side(S), side(S'), S!=S', thing(X), time(T).


% Boat always moves
:- not take(boat,T), time(T), time(T+1).

% Can only take things that are on your side
:- take(X,T), at(boat,S,T), not at(X,S,T), thing(X).

% Cant take more than one thing
:- take(f,T), take(c,T).
:- take(f,T), take(g,T).
:- take(c,T), take(g,T).

% Consecuence of taking
:- take(X,T), at(X,r,T), not at(X,l,T+1), thing(X), time(T+1).
:- take(X,T), at(X,l,T), not at(X,r,T+1), thing(X), time(T+1).

% Inertia
:- at(X,S,T), not take(X,T), not at(X,S,T+1), thing(X), time(T+1).
% :- at(X,S,T), not take(X,T), at(X,S',T), thing(T).

% Conditions of eating
:- at(f,S,T), at(c,S,T), not at(boat,S,T), side(S).
:- at(c,S,T), at(g,S,T), not at(boat,S,T), side(S).

% Goal
:- not at(c,l,horizon).
:- not at(f,l,horizon).
:- not at(g,l,horizon). 


#show take/2.
% #show take(X,T) :take(X,T), not X=boat.
% #show at/3.