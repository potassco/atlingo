% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One rule for each type of predicate used in the formula
trace(ID,T) :- move(T),prop(ID,("move")).
trace(ID,T) :- move(D,T),prop(ID,("move",D)).
trace(ID,T) :- smallestfree(D,T),prop(ID,("smallestfree",D)).
