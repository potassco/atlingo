wait(robot(N), T) :- not move(robot(N), _, T), robot(N), time(T).
trace(I,T) :- wait(robot(N),T),prop(I,("wait",("robot",N))).
wait(robot(N),0):-robot(N).