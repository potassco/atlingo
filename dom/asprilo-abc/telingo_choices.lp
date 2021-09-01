{move_atlingo(robot(N))} :- robot(N).
{pickup_atlingo(robot(N))} :- robot(N).
{putdown_atlingo(robot(N))} :- robot(N).
{carries_atlingo(robot(N))} :- robot(N).
{process_atlingo(robot(N))} :- robot(N).
{process_atlingo(robot(N),shelf(S))} :- robot(N),shelf(S).


{pickup(robot(N),shelf(S))} :- robot(N),shelf(S).
{putdown(robot(N),shelf(S))} :- robot(N),shelf(S).
{waits(robot(N))} :- robot(N).
{move(robot(N),(1,0))} :- robot(N).
{move(robot(N),(-1,0))} :- robot(N).
{move(robot(N),(0,1))} :- robot(N).
{move(robot(N),(0,-1))} :- robot(N).