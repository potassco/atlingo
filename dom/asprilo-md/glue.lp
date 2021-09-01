% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%          Actions start at time point 1!!!


% One rule for each type of predicate used in the formula
trace(ID,T) :- move(robot(N),(X,Y),T),prop(ID,("move",("robot",N),("",X,Y))).
trace(ID,T) :- position(robot(N),(X,Y),T),prop(ID,("position",("robot",N),("",X,Y))).

% Additional predicates used
trace(ID,T) :- move(robot(N),T),prop(ID,("move",("robot",N))).


move(R, T) :- move(R, _, T).
