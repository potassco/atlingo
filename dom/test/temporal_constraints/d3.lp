:- not &del{
           *(  *(&t ;; ?waits) ;; %Waits before starting sequence
           
               (  *(&t ;; (?move_r)) + %Move horizonatally in one direction
                  *(&t ;; (?move_l))
               ) ;; 
               *(&t ;; ?move_u ) ;; %Move up

              &t ;; ?pickup ;;  %Pickup

               (  *(&t ;; (?move_r)) + %Move horizonatally in one direction
                  *(&t ;; (?move_l))
               ) ;; 
               *(&t ;; ?move_u ) ;; %Move up

              &t ;; ?process;; ?waits ;; %Deliver 

               (  *(&t ;; (?move_r)) + %Move horizonatally in one direction
                  *(&t ;; (?move_l))
               ) ;; 
                  *(&t ;; ?move_d ) ;; %Move down
               
               &t ;; ?putdown) %Move putdown shelve
		   ;; *(&t ;; ?waits) %End with waiting
        .>? &t.>* &false }
   .
