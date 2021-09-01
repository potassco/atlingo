:- not &del{
           *( *(&t ;; ?move_atlingo(robot(R))) ;; %Move towards shelve
              &t ;; ?pickup_atlingo(robot(R)) ;;  %Pickup
              *(&t ;; ?move_atlingo(robot(R))) ;;  %Move towards pick station
              &t ;; ?process_atlingo(robot(R));; ?waits(robot(R)) ;; %Deliver 
              *(&t ;; ?move_atlingo(robot(R)));; %Move to dropping place
               &t ;; ?putdown_atlingo(robot(R))) %Move putdown shelve
		   ;; *(&t ;; ?waits(robot(R))) %End with waiting
        .>? &t.>* &false }, 
   robot(R).