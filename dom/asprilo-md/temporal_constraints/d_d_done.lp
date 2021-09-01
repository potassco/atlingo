% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where the last tree moves of all robost
% % are moving right
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- not &del{(* &t) .>? 
        (?move_d(robot(X)) ;; &t ;; ?move_d(robot(X)) ;; &t).>? 
        (*(&t).>* ( ?move_v(robot(X)) + ?move_h(robot(X))) .>* &false)
        
    }, robot(X).
