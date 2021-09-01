following(robot(N),robot(M),T):-position(robot(M),(X,Y),T), position(robot(N),(X,Y),T-1).
trace(I,T) :- following(robot(N),robot(M),T),prop(I,("following",("robot",N),("robot",M))).