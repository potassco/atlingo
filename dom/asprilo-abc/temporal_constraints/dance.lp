right((1,0)).
left((-1,0)).
up((0,-1)).
down((0,1)).


:- not &del{
           
               *(&t ;; ?follow(robot(R),robot(R+1)))  ;;  
               
              &t ;; ?process_atlingo(robot(R))
              
        .>? &true }, 
   robot(R), robot(R+1).

:- not &del{
          *(
            &t ;; &t ;; &t ;; &t ;; &t ;; ?move(robot(R),UP) ;; &t ;; ?move(robot(R),RIGHT) ;; &t ;; ?move(robot(R),DOWN) ;; &t ;; ?move(robot(R),LEFT)           
           );;
          *(&t ;; ?waits(robot(R)))
        .>? &t.>* &false }, 
   robot(R), not robot(R+1), down(DOWN), up(UP), left(LEFT), right(RIGHT).


% &t ;; ?move(robot(R),UP) ;; &t ;; ?move(robot(R),RIGHT) ;; &t ;; ?move(robot(R),DOWN) ;; &t ;; ?move(robot(R),LEFT)

% follow*;deliver;F