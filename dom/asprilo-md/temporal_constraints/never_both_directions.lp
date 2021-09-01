% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Example where robots move horizontally and then vertically
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% :- not &del{
%     *(&t ;; ((? move_right(robot(N))) + (? move_up(robot(N))) + (? wait(robot(N))) )) +
%     *(&t ;; ((? move_left(robot(N))) + (? move_up(robot(N))) + (? wait(robot(N))) ))
%     .>?
%     (&t.>* &false) }, robot(N).

:- not &del{
    *(&t ;; ? no_move_right(robot(N))) +
    *(&t ;; ? no_move_left(robot(N))) .>?
    (&t.>* &false) }, robot(N).

:- not &del{
    *(&t ;; ? no_move_down(robot(N))) +
    *(&t ;; ? no_move_up(robot(N))) .>?
    (&t.>* &false) }, robot(N).