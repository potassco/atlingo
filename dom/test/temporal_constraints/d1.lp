:- not &del{
      (* &t) .>* % Always
      ?pickup .>* %If picks up
      *(&t ;; ?move + ?waits) %Move or wait
      ;; ?process .>? %Untill process
      &true}. 
