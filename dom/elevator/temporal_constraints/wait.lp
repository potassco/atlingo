% :- not &del{ *( (*(?up ;; &t) + *(?down ;; &t)) ;; ?ready;; ?serve;; &t)
% :- not &del{ ( *(?up ;; &t) ;; ?serve ;; &t ;; ?down ;; &t ;; ?down ;; &t ;; ?down ;; &t ;; ?down ;; &t ;; ?serve ;; &t) .>? &t .>* &false}.
:- not &del{ * &t .>? wait}.