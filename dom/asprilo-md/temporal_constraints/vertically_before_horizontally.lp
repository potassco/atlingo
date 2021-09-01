% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where robots move horizontally and then vertically
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% :- not &del{
%     (
%         * ( &t ;; ( ? move_vertically(robot(R)) + ? wait(robot(R)))) ;; 
%         * ( &t ;; ( ? move_horizontally(robot(R)) + ? wait(robot(R)))) 
%     ) .>?
%     (&t.>* &false)   }, robot(R).

:- not &del{
       (* ( ( ? no_move_horizontally(robot(R)) ) ;; &t ))  .>? 
        ( (* &t ) .>* no_move_vertically(robot(R)) )
}, robot(R).