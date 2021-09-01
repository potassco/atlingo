% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Id map:
% %     Maps ids used in reified formula and  into predicates
% %     to visualize propositions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

id_map(ID,(P)):-
    theory_string(ID,P).

id_map(ID,(P)):-
    theory_number(ID,P).


% ------- Sequence

% Arity 1
id_map(ID,("",MAP_0)):-
    theory_sequence(ID,tuple,ID_T),
    theory_tuple(ID_T,0,ID_0),
    not theory_tuple(ID_T,1,_), 
    id_map(ID_0,MAP_0).

% Arity 2
id_map(ID,("",MAP_0,MAP_1)):-
    theory_sequence(ID,tuple,ID_T),
    theory_tuple(ID_T,0,ID_0),
    theory_tuple(ID_T,1,ID_1),
    not theory_tuple(ID_T,2,_),
    id_map(ID_0,MAP_0),
    id_map(ID_1,MAP_1).

% Arity 3
id_map(ID,("",MAP_0,MAP_1,MAP_2)):-
    theory_sequence(ID,tuple,ID_T),
    theory_tuple(ID_T,0,ID_0),
    theory_tuple(ID_T,1,ID_1),
    theory_tuple(ID_T,2,ID_2),
    not theory_tuple(ID_T,3,_),
    id_map(ID_0,MAP_0),
    id_map(ID_1,MAP_1),
    id_map(ID_2,MAP_2).


% ------- Function

% Arity 1
id_map(ID,-MAP_0):-
    theory_function(ID,ID_O,ID_T),
    theory_string(ID_O,"-"), 
    theory_tuple(ID_T,0,ID_0),
    not theory_tuple(ID_T,1,_),
    id_map(ID_0,MAP_0).

% Arity 1
id_map(ID,(P,MAP_0)):-
    theory_function(ID,ID_O,ID_T),
    theory_string(ID_O,P), P!="-",
    theory_tuple(ID_T,0,ID_0),
    not theory_tuple(ID_T,1,_),
    id_map(ID_0,MAP_0).

% Arity 2
id_map(ID,(P,MAP_0,MAP_1)):-
    theory_function(ID,ID_O,ID_T),
    theory_string(ID_O,P), 
    theory_tuple(ID_T,0,ID_0),
    theory_tuple(ID_T,1,ID_1),
    not theory_tuple(ID_T,2,_),
    id_map(ID_0,MAP_0),
    id_map(ID_1,MAP_1).

% Arity 3
id_map(ID,(P,MAP_0,MAP_1,MAP_2)):-
    theory_function(ID,ID_O,ID_T),
    theory_string(ID_O,P), 
    theory_tuple(ID_T,0,ID_0),
    theory_tuple(ID_T,1,ID_1),
    theory_tuple(ID_T,2,ID_2),
    not theory_tuple(ID_T,3,_),
    id_map(ID_0,MAP_0),
    id_map(ID_1,MAP_1),
    id_map(ID_2,MAP_2).

% Arity 4
id_map(ID,(P,MAP_0,MAP_1,MAP_2,MAP_3)):-
    theory_function(ID,ID_O,ID_T),
    theory_string(ID_O,P), 
    theory_tuple(ID_T,0,ID_0),
    theory_tuple(ID_T,1,ID_1),
    theory_tuple(ID_T,2,ID_2),
    theory_tuple(ID_T,3,ID_3),
    not theory_tuple(ID_T,4,_),
    id_map(ID_0,MAP_0),
    id_map(ID_1,MAP_1),
    id_map(ID_2,MAP_2),
    id_map(ID_3,MAP_3).
