% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- not &del{*(

    ?move_v(robot(R)) ;; &t ;; *(?no_move(robot(R)) ;; &t) ;; 
    ?move_h(robot(R)) ;; &t ;; *(?no_move(robot(R)) ;; &t) )
     
    .>? &t .>* &false}

, robot(R).

% :- not &del{*(

%     ?move_h(robot(R)) ;; &t ;; 
%     ?move_v(robot(R)) ;; &t)
     
%     .>? &t .>* &false}

% , robot(R).

% :- not &del{*(

%     ?move_h(robot(R)) ;; &t ;; 
%     ?move_v(robot(R)) ;; &t)
     
%     .>? *(?no_move(robot(R));; &t).>? &t .>* &false}

% , robot(R).

% :- not &del{*(

%     ?move_h(robot(R)) ;; &t ;; 
%     ?move_v(robot(R)) ;; &t)
     
%     .>? &t}

% , robot(R).
