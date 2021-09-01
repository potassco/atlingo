% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Mapping for atoms into holds predicate
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One rule for each type of predicate used in the formula
trace(ID,T) :- at(f,l,T),prop(ID,("at","f","l")).
trace(ID,T) :- at(c,l,T),prop(ID,("at","c","l")).
trace(ID,T) :- at(g,l,T),prop(ID,("at","g","l")).
trace(ID,T) :- at(boat,l,T),prop(ID,("at","boat","l")).

trace(ID,T) :- at(f,r,T),prop(ID,("at","f","r")).
trace(ID,T) :- at(c,r,T),prop(ID,("at","c","r")).
trace(ID,T) :- at(g,r,T),prop(ID,("at","g","r")).
trace(ID,T) :- at(boat,r,T),prop(ID,("at","boat","r")).

trace(ID,T) :- take(f,T),prop(ID,("take","f")).
trace(ID,T) :- take(c,T),prop(ID,("take","c")).
trace(ID,T) :- take(g,T),prop(ID,("take","g")).
trace(ID,T) :- take(boat,T),prop(ID,("take","boat")).

