% :- not &del{   *( ?b ;; &t) .>? &true }.
:- not &del{
           *( *(&t ;; ?move) ;; %Move towards shelve
              &t ;; ?pickup ;;  %Pickup
              *(&t ;; ?move) ;;  %Move towards pick station
              &t ;; ?deliver;; ?wait ;; %Deliver 
              *(&t ;; ?move);; %Move to dropping place
               &t ;; ?putdown) %Move putdown shelve
		   ;; *(&t ;; ?wait) %End with waiting
        .>? &t.>* &false }.