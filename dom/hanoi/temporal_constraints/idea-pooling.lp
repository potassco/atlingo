% :- not &del{     &true ;; %One step tp start in 1
%                * ( ?move(D) : disk(D) ;; &true) .>? &true
%             }.

% Instance
disk(1).
disk(2).
disk(3).

% What one can do only to get theory elements but I cant use inside a formula
:- not &del{  ?move(D) : disk(D) }.
:- not &del{  ?move(1); ?move(2); ?move(3) }.


% What I would like to have pool inside the expressions, perhaps appling an operator like '+'.join([move(1),move(2),move(3)])
:- not &del{  +{?move(D) : disk(D)}  .>? &true}.
:- not &del{  ?move(1) + ?move(2) + ?move(3)  .>? &true}.


% :- not &del{  {move(D) : disk(D)}[+]  .>? &true}.
% :- not &del{  move(1) + move(2) + move(3)  .>? &true}.