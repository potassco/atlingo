
move_atlingo(R,T):-move(R,D,T).
pickup_atlingo(R,T):-pickup(R,S,T).
putdown_atlingo(R,T):-putdown(R,S,T).
carries_atlingo(R,T):-carries(R,S,T).
process_atlingo(R,T):-process(S,T),carries(R,S,T-1).
process_atlingo(R,S,T):-process(S,T),carries(R,S,T-1).