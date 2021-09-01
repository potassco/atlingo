move_vertically(R, T) :- move(R, (0,_), T).

move_horizontally(R, T) :- move(R, (_,0), T).

trace(I,T) :- move_horizontally(robot(N),T),prop(I,("move_horizontally",("robot",N))).
trace(I,T) :- move_vertically(robot(N),T),prop(I,("move_vertically",("robot",N))).