% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% :- not &del{(&t ;; ?move(robot(1),(1,0)) ).>? &t}.
:- not &del{( &t ;; ?move(robot(1),(1,0)) ;; &t ;; ?move(robot(1),(1,0))).>? &true}.
% :- not &del{( &t ;; ?move(robot(R),(1,0)) ;; &t ;; ?move(robot(R),(1,0))).>? &true}, robot(R).
