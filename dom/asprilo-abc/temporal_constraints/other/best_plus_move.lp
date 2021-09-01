% right((1,0)).
% left((-1,0)).
% up((0,-1)).
% down((0,1)).

right((1,0)).
left((-1,0)).
up((0,-1)).
down((0,1)).

:- not &del{
           *( *(&t ;; ?move_atlingo(robot(R))) ;; %Move towards shelve
              *(&t ;; ?pickup_atlingo(robot(R))) ;;  %Pickup
              *(&t ;; ?move_atlingo(robot(R))) ;;  %Move towards pick station
              &t ;; ?process_atlingo(robot(R));; ?waits(robot(R)) ;; %Deliver 
              *(&t ;; ?move_atlingo(robot(R)));; %Move to dropping place
               &t ;; ?putdown_atlingo(robot(R))) %Move putdown shelve
		   ;; *(&t ;; ?waits(robot(R))) %End with waiting
        .>? &t.>* &false }, 
   robot(R).


:- not &del{ * &t .>* % Always
            ?move(robot(R),D_R) ;; &t .>*  %Goining right implies 
               *( ? ~ move(robot(R),D_L);; &t) .>? % Not going left
               (?pickup_atlingo(robot(R)) + ?process_atlingo(robot(R)) + ?putdown_atlingo(robot(R))) %Until can change
               .>? &true
            
            },
            robot(R),right(D_R),left(D_L).

:- not &del{ * &t .>* % Always
            ?move(robot(R),D_L) ;; &t .>*  %Goining right implies 
               *( ? ~ move(robot(R),D_R);; &t) .>? % Not going left
               (?pickup_atlingo(robot(R)) + ?process_atlingo(robot(R)) + ?putdown_atlingo(robot(R))) %Until can change
               .>? &true
            
            },
            robot(R),right(D_R),left(D_L).

:- not &del{ * &t .>* 
            ?move(robot(R),D_U) ;; &t .>*  
               *( ? ~ move(robot(R),D_D);; &t) .>? 
               (?pickup_atlingo(robot(R)) + ?process_atlingo(robot(R)) + ?putdown_atlingo(robot(R))) 
               .>? &true
            
            },
            robot(R),up(D_U),down(D_D).

:- not &del{ * &t .>* 
            ?move(robot(R),D_D) ;; &t .>*  
               *( ? ~ move(robot(R),D_U);; &t) .>? 
               (?pickup_atlingo(robot(R)) + ?process_atlingo(robot(R)) + ?putdown_atlingo(robot(R))) 
               .>? &true
            
            },
            robot(R),up(D_U),down(D_D).