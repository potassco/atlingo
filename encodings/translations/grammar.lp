% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Theory:
% %     Defines the syntax for the formulas
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#theory del {
    formula_body  {
        &   : 7, unary;         % prefix for Boolean constants
        ~   : 5, unary;         % negation
        ?   : 4, unary;         % test
        *   : 3, unary;         % kleene star
        +   : 2, binary, left;  % choice
        ;;  : 1, binary, left;  % sequence
        .>? : 0, binary, right; % diamond (eventually)
        .>* : 0, binary, right  % box (always)
    };
    &del/0 : formula_body, body
}.

