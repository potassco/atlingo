% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- not &del{(* &t) .>? (?move_d(robot(X)) ;; &t ;; ?move_d(robot(X)) ;; &t).>? (&t.>* &false)}, robot(X).
