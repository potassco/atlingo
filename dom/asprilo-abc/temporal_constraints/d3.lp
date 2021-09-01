right((1,0)).
left((-1,0)).
up((0,-1)).
down((0,1)).

:- not &del{
           *(  *(&t ;; ?waits(robot(R))) ;; %Waits before starting sequence
           
               (  *(&t ;; (?move(robot(R),RIGHT))) + %Move horizonatally in one direction
                  *(&t ;; (?move(robot(R),LEFT)))
               ) ;; 
               *(&t ;; ?move(robot(R),UP) ) ;; %Move up

              &t ;; ?pickup_atlingo(robot(R)) ;;  %Pickup

               (  *(&t ;; (?move(robot(R),RIGHT))) + %Move horizonatally in one direction
                  *(&t ;; (?move(robot(R),LEFT)))
               ) ;; 
               *(&t ;; ?move(robot(R),UP) ) ;; %Move up

              &t ;; ?process_atlingo(robot(R));; ?waits(robot(R)) ;; %Deliver 

               (  *(&t ;; (?move(robot(R),RIGHT))) + %Move horizonatally in one direction
                  *(&t ;; (?move(robot(R),LEFT)))
               ) ;; 
                  *(&t ;; ?move(robot(R),DOWN) ) ;; %Move down
               
               &t ;; ?putdown_atlingo(robot(R))) %Move putdown shelve
		   ;; *(&t ;; ?waits(robot(R))) %End with waiting
        .>? &t.>* &false }, 
   robot(R), up(UP), right(RIGHT), left(LEFT), down(DOWN).


%   < * (wait* ;; (right* + left*) ;; up* ;; pickup ;; (right* + left*) ;; up* ;; deliver ;; (right* + left*) ;; down* ;; putdown) > L