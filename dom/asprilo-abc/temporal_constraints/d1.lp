:- not &del{
      (* &t) .>* % Always
      ?pickup(robot(R),shelf(S)) .>* %If picks up
      *(&t ;; ?move_atlingo(robot(R)) + ?waits(robot(R))) %Move or wait
      ;; ?process_atlingo(robot(R),shelf(S)) .>? %Untill process
      &true},
   robot(R), shelf(S). 


%    [T*] [pickup?] <T ;; ?move +? wait)* ;; deliver>  T