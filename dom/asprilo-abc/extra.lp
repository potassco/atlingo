
move_atlingo(R,T):-move(R,D,T).
pickup_atlingo(R,T):-pickup(R,S,T).
putdown_atlingo(R,T):-putdown(R,S,T).
carries_atlingo(R,T):-carries(R,S,T).
process_atlingo(R,T):-process(S,T),carries(R,S,T-1).
process_atlingo(R,S,T):-process(S,T),carries(R,S,T-1).


follow(robot(R),robot(R'),T+1):-position(robot(R),C,T+1),position(robot(R'),C,T),R!=R'.
follow(robot(R),robot(R'),T+1):-position(robot(R),C,T+1),
                                position(robot(R),C,T),
                                position(robot(R'),C',T),
                                position(robot(R'),C',T+1),
                                nextto(C,_,C'),
                                % not pickup(robot(R),_,T),
                                R!=R'.
#show follow/3.