% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One rule for each type of predicate used in the formula
trace(ID,T) :- p(T),prop(ID,"p").
trace(ID,T) :- q(T),prop(ID,"q").
trace(ID,T) :- r(T),prop(ID,"r").
trace(ID,T) :- s(T),prop(ID,"s").
trace(ID,T) :- a(T),prop(ID,"a").
trace(ID,T) :- b(T),prop(ID,"b").
trace(ID,T) :- c(T),prop(ID,"c").
trace(ID,T) :- b(1,T),prop(ID,("b",1)).
trace(ID,T) :- b(2,T),prop(ID,("b",2)).