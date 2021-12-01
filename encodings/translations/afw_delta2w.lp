
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Final states:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

final_state_full(box(P,F)) :- state_full(box(P,F)).


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Delta:
% %     Computes transtion for states
% %     delta_full USES PREDICATES 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------   Prop
delta_full(prop(A),0):-
    state_full(prop(A)).
delta_full(prop(A),0,in,A):-
    state_full(prop(A)).

%-----------------   Neg
delta_full(neg(prop(A)),0):-
    state_full(neg(prop(A))).
delta_full(neg(prop(A)),0,out,A):-
    state_full(neg(prop(A))).

%-----------------   Boolean
delta_full(top,0):-
    state_full(top).

%-----------------   Diamond

%--------------------------------------
% diamond(test(F1),F2)
%--------------------------------------

delta_full(diamond(test(F1),F2),0):-
    state_full(diamond(test(F1),F2)).

delta_full(diamond(test(F1),F2),0,(F1,0)):-
    state_full(diamond(test(F1),F2)).

delta_full(diamond(test(F1),F2),0,(F2,0)):-
    state_full(diamond(test(F1),F2)).

%--------------------------------------
% diamond(stp,F)
%--------------------------------------

%If not last then F

delta_full(diamond(stp,F),0):-
    state_full(diamond(stp,F)).

delta_full(diamond(stp,F),0,(F,1)):-
    state_full(diamond(stp,F)).

delta_full(diamond(stp,F),0,out,LAST):-
    prop(LAST,"last"),
    state_full(diamond(stp,F)).

%--------------------------------------
% diamond(sequence(P1,P2),F)
%--------------------------------------

delta_full(diamond(sequence(P1,P2),F),0):-
    state_full(diamond(sequence(P1,P2),F)).

delta_full(diamond(sequence(P1,P2),F),0,(diamond(P1,diamond(P2,F)),0)):-
    state_full(diamond(sequence(P1,P2),F)).

%--------------------------------------
% diamond(choice(P1,P2),F)
%--------------------------------------

delta_full(diamond(choice(P1,P2),F),0..1):-
    state_full(diamond(choice(P1,P2),F)).

delta_full(diamond(choice(P1,P2),F),0,(diamond(P1,F),0)):-
    state_full(diamond(choice(P1,P2),F)).

delta_full(diamond(choice(P1,P2),F),1,(diamond(P2,F),0)):-
    state_full(diamond(choice(P1,P2),F)).

%--------------------------------------
% diamond(star(P1),F)
%--------------------------------------

delta_full(diamond(star(P),F),0..1):- 
    state_full(diamond(star(P),F)).

delta_full(diamond(star(P),F),0,(F,0)):- 
    state_full(diamond(star(P),F)).

delta_full(diamond(star(P),F),1,(diamond(P,diamond(star(P),F)),0)):- 
    state_full(diamond(star(P),F)).

%-----------------   Box



%--------------------------------------
% box(test(F1),F2)
%--------------------------------------

delta_full(box(test(F1),F2),0..1):-
    state_full(box(test(F1),F2)).

delta_full(box(test(F1),F2),0,(F2,0)):-
    state_full(box(test(F1),F2)).

delta_full(box(test(F1),F2),1,(F1',0)):-
    nnf(neg(F1),F1'),
    state_full(box(test(F1),F2)).

%--------------------------------------
% box(stp,F)
%--------------------------------------

%If not last then F

delta_full(box(stp,F),0..1):-
    state_full(box(stp,F)).

delta_full(box(stp,F),0,(F,1)):-
    state_full(box(stp,F)).

delta_full(box(stp,F),0,out,LAST):-
    state_full(box(stp,F)),
    prop(LAST,"last").

delta_full(box(stp,F),1,in,LAST):-
    prop(LAST,"last"),
    state_full(box(stp,F)).

%--------------------------------------
% box(sequence(P1,P2),F)
%--------------------------------------

delta_full(box(sequence(P1,P2),F),0):-
    state_full(box(sequence(P1,P2),F)).

delta_full(box(sequence(P1,P2),F),0,(box(P1,box(P2,F)),0)):-
    state_full(box(sequence(P1,P2),F)).

%--------------------------------------
% box(choice(P1,P2),F)
%--------------------------------------

delta_full(box(choice(P1,P2),F),0):-
    state_full(box(choice(P1,P2),F)).

delta_full(box(choice(P1,P2),F),0,(box(P1,F),0)):-
    state_full(box(choice(P1,P2),F)).

delta_full(box(choice(P1,P2),F),0,(box(P2,F),0)):-
    state_full(box(choice(P1,P2),F)).

%--------------------------------------
% box(star(P1),F)
%--------------------------------------

delta_full(box(star(P),F),0):- 
    state_full(box(star(P),F)).

delta_full(box(star(P),F),0,(F,0)):- 
    state_full(box(star(P),F)).

delta_full(box(star(P),F),0,(box(P,box(star(P),F)),0)):- 
    state_full(box(star(P),F)).

