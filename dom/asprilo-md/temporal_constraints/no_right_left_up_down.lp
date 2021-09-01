#include "right_left_up_down.lp".

no_move_right(robot(N), T) :- not move(robot(N), R, T), right(R), time(T), robot(N).
no_move_right(robot(N),0):-robot(N).
trace(I,T) :- no_move_right(robot(N),T),prop(I,("no_move_right",("robot",N))).

no_move_left(robot(N), T) :- not move(robot(N), R, T), left(R), time(T), robot(N).
no_move_left(robot(N),0):-robot(N).
trace(I,T) :- no_move_left(robot(N),T),prop(I,("no_move_left",("robot",N))).

no_move_up(robot(N), T) :- not move(robot(N), R, T), up(R), time(T), robot(N).
no_move_up(robot(N),0):-robot(N).
trace(I,T) :- no_move_up(robot(N),T),prop(I,("no_move_up",("robot",N))).

no_move_down(robot(N), T) :- not move(robot(N), R, T), down(R), time(T), robot(N).
no_move_down(robot(N),0):-robot(N).
trace(I,T) :- no_move_down(robot(N),T),prop(I,("no_move_down",("robot",N))).