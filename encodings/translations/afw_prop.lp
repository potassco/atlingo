% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Propositional atoms:
% %     Gets the ids for all atomic propositions in the formula
% %     used to generate the alphabet
% %    
% %     prop(ID,PROP)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TEL Operators
operator("~"). operator(">"). operator(">:").
operator(">?"). operator(">*"). operator("&").
operator("|"). operator(">?").

%DEL Operators
operator(";;"). operator("+"). operator("?").
operator("*"). operator("~"). operator("&").
operator(".>?"). operator(".>*").

reserved_words("holds").
reserved_words("trace").
reserved_words("last").
reserved_words("true").
reserved_words("t").
reserved_words("false").

pos_prop_id(ID) :- theory_function(ID,ID_O,ID_T),
                   theory_string(ID_O,P), 
                   not operator(P), 
                   not reserved_words(P).

pos_prop_id(ID) :- theory_string(ID,P), 
                   not operator(P), 
                   not reserved_words(P).

% Remove arguments of atoms from the prop: 
% Example: Remove robot(1) when only appearing in move(robot(1)).
prop_id(ID) :- pos_prop_id(ID), 
               #count{1,ID_PARENT: theory_function(ID_PARENT, _, ID_T),
                                   theory_tuple(ID_T,0..MAX,ID),
                                   not pos_prop_id(ID_PARENT)} > 0, 
               #max{D:theory_tuple(_,D,_)}=MAX.

% Include also proposition when the whole formula is a proposition
prop_id(ID) :- pos_prop_id(ID),
               theory_atom(ID_A,ID_O,ID_E),
               theory_element(ID_E,ID_T,_),
               theory_tuple(ID_T,0,ID).

% Creates special proposition "last"
used_id(ID) :- theory_string(ID,Q), Q!="last".
used_id(ID) :- theory_function(ID,IDS,_), theory_string(IDS,Q), Q!= "last".
last_id(MID+1):- #max{ID:used_id(ID)}=MID.


% Mappings from ids to readable format
#include "id_map.lp".


prop(ID,PROP):-id_map(ID,PROP), prop_id(ID).
prop(ID,"last"):- last_id(ID).

