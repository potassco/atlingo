% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- not &del{(* &t) .>? (
    ?following(robot(X),robot(Y)) ;; &t ;; ?following(robot(Y),robot(X)) ;; &t ;; 
    ?following(robot(X),robot(Y)) ;; &t ;; ?following(robot(Y),robot(X)) ;; &t ;; 
    ?following(robot(X),robot(Y)) ;; &t ;; ?following(robot(Y),robot(X)) ;; &t 

% *(?following(robot(X),robot(Y)) ;; &t) ;; 

% ?following(robot(Y),robot(X)) ;; &t ;; 

% *(?following(robot(Y),robot(X)) ;; &t)

.>? &true)}, robot(X), robot(Y), Y!=X.
% :- not &del{(* &t) .>? (?move_d(robot(X)) ;; &t ;; ?move_d(robot(X)) ;; &t).>? (*(&t).>* ( move_v(robot(X)) + ?move_h(robot(X))) .>* &false)}, robot(X).
