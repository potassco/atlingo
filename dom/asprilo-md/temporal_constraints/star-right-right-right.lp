% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- not &del{* (?move(robot(X),(1,0)) ;; &t;; ? ~ move(robot(X),(1,0));; &t).>? &t .>* &false}, robot(X).

% :- not &del{?move(robot(X),(1,0)) ;; &t;; ? wait(robot(X));; &t ;; * (?move(robot(X),(1,0)) ;; &t;; ? wait(robot(X))) .>? (&t .>* &false)}, robot(X).

% :- not &del{&t}.
