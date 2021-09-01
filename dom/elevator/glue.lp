% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One rule for each type of predicate used in the formula
trace(ID,T) :- up(T),prop(ID,("up")).
trace(ID,T) :- down(T),prop(ID,("down")).
trace(ID,T) :- serve(T),prop(ID,("serve")).
trace(ID,T) :- wait(T),prop(ID,("wait")).
trace(ID,T) :- ready(T),prop(ID,("ready")).
