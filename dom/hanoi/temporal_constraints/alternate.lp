:- not &del{    &t ;; ?move(1) ;;
                *( 
                   &t ;; ? ~move(1) ;; ?move ;;   %Move another disk
                   &t ;; ?move(1)     %Move disk 1
                ) ;;  
                * (&t ;; ? ~move ) % Dont move
              .>? 
              &t .>* &false %Final state
            }.
             