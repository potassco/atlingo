% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % States:
% %     Computes all states for automaton using 
% %     fisher lander closure and negation normal form
% %     state_full USES PREDICATES 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%-------------------- Initial state --------------------------
initial_state_full(F) :- theory_atom(ID_A,ID_O,ID_E),
                    theory_string(ID_O,"del"),
                    theory_element(ID_E,ID_T,_),
                    theory_tuple(ID_T,0,ID),
                    theory_id_to_predicate(ID,F).

%-------------------- Fish lander closure to define states ------

%%%%%% Transforming theory ids into nested predicate

% Proposition
theory_id_to_predicate(ID,prop(ID)) :- 
        prop_id(ID).

% Step
theory_id_to_predicate(ID,stp) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"&"),
        theory_tuple(ID_T,0,ID_L),
        theory_string(ID_L,"t").

% Top
theory_id_to_predicate(ID,top) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"&"),
        theory_tuple(ID_T,0,ID_L),
        theory_string(ID_L,"true").

% Bottom
theory_id_to_predicate(ID,bottom) :- theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"&"),
        theory_tuple(ID_T,0,ID_L),
        theory_string(ID_L,"false").

% Negation
theory_id_to_predicate(ID,neg(FL)) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"~"),
        theory_tuple(ID_T,0,ID_L),
        theory_id_to_predicate(ID_L,FL).

% Diamond
theory_id_to_predicate(ID,diamond(FL,FR)) :-
        theory_function(ID,ID_O,ID_T),
        theory_string(ID_O,".>?"),
        theory_tuple(ID_T,0,ID_L),
        theory_tuple(ID_T,1,ID_R),
        theory_id_to_predicate(ID_L,FL), 
        theory_id_to_predicate(ID_R,FR).

% Box
theory_id_to_predicate(ID,box(FL,FR)) :-
        theory_function(ID,ID_O,ID_T),
        theory_string(ID_O,".>*"),
        theory_tuple(ID_T,0,ID_L),
        theory_tuple(ID_T,1,ID_R),
        theory_id_to_predicate(ID_L,FL), 
        theory_id_to_predicate(ID_R,FR).

%%%%%%%%%% Paths

% Test
theory_id_to_predicate(ID,test(FL)) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"?"),
        theory_tuple(ID_T,0,ID_L),
        theory_id_to_predicate(ID_L,FL).

% Sequence
theory_id_to_predicate(ID,sequence(FL,FR)) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,";;"),
        theory_tuple(ID_T,0,ID_L),
        theory_tuple(ID_T,1,ID_R),
        theory_id_to_predicate(ID_L,FL), 
        theory_id_to_predicate(ID_R,FR).

% Choice
theory_id_to_predicate(ID,choice(FL,FR)) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"+"),
        theory_tuple(ID_T,0,ID_L),
        theory_tuple(ID_T,1,ID_R),
        theory_id_to_predicate(ID_L,FL), 
        theory_id_to_predicate(ID_R,FR).

% Star
theory_id_to_predicate(ID,star(FL)) :-                                                        
        theory_function(ID,ID_O,ID_T), 
        theory_string(ID_O,"*"),
        theory_tuple(ID_T,0,ID_L),
        theory_id_to_predicate(ID_L,FL).

%Keep only formulas and not paths

dynamic_formula(prop(ID)) :- theory_id_to_predicate(_,prop(ID)).
dynamic_formula(neg(F)) :- theory_id_to_predicate(_,neg(F)).
dynamic_formula(top) :- theory_id_to_predicate(_,top).
dynamic_formula(bottom) :- theory_id_to_predicate(_,bottom).
dynamic_formula(diamond(FL,FR)) :- theory_id_to_predicate(_,diamond(FL,FR)).
dynamic_formula(box(FL,FR)) :- theory_id_to_predicate(_,box(FL,FR)).

%Generate Fisher-Lander closure from  predicates

closure(F) :- dynamic_formula(F).

closure(X) :- closure(neg(X)).
closure(neg(prop(ID))) :- closure(prop(ID)).
closure(neg(bottom)) :- closure(bottom).
closure(neg(top)) :- closure(top).
closure(neg(diamond(X,Z))) :- closure(diamond(X,Z)).
closure(neg(box(X,Z))) :- closure(box(X,Z)).

closure(diamond(X,Z)) :- closure(diamond(choice(X,Y),Z)).
closure(diamond(Y,Z)) :- closure(diamond(choice(X,Y),Z)).
closure(diamond(X,diamond(Y,Z))) :- closure(diamond(sequence(X,Y),Z)).
closure(diamond(X,diamond(star(X),Z))) :- closure(diamond(star(X),Z)).
closure(Z) :- closure(diamond(_,Z)).

closure(box(X,Z)) :- closure(box(choice(X,Y),Z)).
closure(box(Y,Z)) :- closure(box(choice(X,Y),Z)).
closure(box(X,box(Y,Z))) :- closure(box(sequence(X,Y),Z)).
closure(box(X,box(star(X),Z))) :- closure(box(star(X),Z)).
closure(Z) :- closure(box(_,Z)).

%Negation normal form for formulas in the closure
nnf(neg(neg(X)),X):-closure(neg(X)).
nnf(neg(bottom),top).
nnf(neg(top),bottom).
nnf(neg(prop(ID)),neg(prop(ID))) :- closure(neg(prop(ID))).
nnf(neg(diamond(X,Z)),box(X,Z')) :- closure(neg(diamond(X,Z))),nnf(neg(Z),Z').
nnf(neg(box(X,Z)),diamond(X,Z')) :- closure(neg(box(X,Z))),nnf(neg(Z),Z').

nnf(top,top).
nnf(bottom,bottom).
nnf(prop(ID),prop(ID)) :- closure(prop(ID)).
nnf(diamond(X,Z),diamond(X,Z)) :- closure(diamond(X,Z)).
nnf(box(X,Z),box(X,Z)) :- closure(box(X,Z)).



%State predicate
state_full(X') :- closure(X), nnf(X,X').
