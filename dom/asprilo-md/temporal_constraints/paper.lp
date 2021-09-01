#include "../right_left_up_down.lp".
:- not &del{ *( &t ;; ?move(robot(R),UP)) ;;
             *( &t ;; ?move(robot(R),RIGHT)) ;; 
             *( &t ;; ?wait(robot(R))) .>? (&t.>* &false) },
    robot(R), right(RIGHT), up(UP).