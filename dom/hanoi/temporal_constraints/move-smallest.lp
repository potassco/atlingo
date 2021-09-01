:- not &del{     &t ;; %One step tp start in 1
                *( ?move(1) ;; &t ;;   %Move disk 1
                    ? ~smallestfree(D) + 
                    (? smallestfree(D) ;; ?move(D)) ;; &t   %Move another disk
                ) ;;  
                * (? ~move ;; &t) % Dont move
              .>? 
              &t .>* &false %Final state
            },
            disk(D), D!=1.