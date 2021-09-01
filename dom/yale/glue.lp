% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One rule for each type of predicate used in the formula
trace(ID,T) :- load(T),prop(ID,("load")).
trace(ID,T) :- loaded(T),prop(ID,("loaded")).
trace(ID,T) :- alive(T),prop(ID,("alive")).
trace(ID,T) :- shoot(T),prop(ID,("shoot")).

