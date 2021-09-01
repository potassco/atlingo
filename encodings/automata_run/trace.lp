% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Trace:
% %     Creates the last time step of the trace where nothing
% %     can hold after
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %-------------------- "last" holds in last timestep ------------------------

#const horizon = 8. %Passed as a parameter equal to lambda -1
% Last holds in horizon
% last(horizon).
trace(ID,horizon):-prop(ID,"last").

% %-------------------- True holds in all time steps ------------------------
% trace(true,0..horizon). %Now in run

% %-------------------- Used to better visualize traces ------------------------
holds_map(T,MAP):- trace(ID,T), prop(ID,MAP).
