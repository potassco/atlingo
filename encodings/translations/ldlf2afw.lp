% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Automata:
% %     Generates the translation of the automata
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %-------------------- Atomic propositions --------------------------
% %
% %       prop(ID,PROP): 
% %             - Where ID is the id of a proposition
% %             - Where PROP a visualization of the proposition

#include "./afw_prop.lp".

% %--------------------  States --------------------------
% %
% %       initial_state(ID): ID of the initial state
% %       state(ID,S): State with id ID 

#include "./afw_states.lp".

% %------------------ Delta function ------------------------
% %
% %       delta(ID_S,(Case,Type,Prop)),ID_S'): The delta transition 
% %                 - From state with id ID_S 
% %                 - To state with id ID_S' 
% %                 - When all conditions (Type,Prop) hold for case Case

#include "./afw_delta.lp".


% %------------------ Clean up ------------------------
#include "./afw_clean.lp".


#show state/2.
#show delta/3.
#show delta/2.
#show delta/4.
#show is_test/1.
#show full/3.
#show initial_state/1.
#show prop/2.


