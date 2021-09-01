:- not &del{alive}.
:- not &del{~loaded}.

% Single action per timepoint
:- not &del{ * &t .>* ?load .>* ~shoot}.
:- not &del{ * &t .>* ?shoot.>* ~load}.

% Efect of shoot
:- not &del{ * &t .>* ?shoot ;; ?loaded ;; &t .>* ~alive}.
:- not &del{ * &t .>* ?shoot ;; &t .>* ~loaded}.

% Efect of load
:- not &del{ * &t .>* ?load ;; &t .>* loaded}.

% Intertia
:- not &del{ * &t .>* ? ~alive ;; &t .>* ~alive}.
:- not &del{ * &t .>* ? alive ;; ? ~shoot + ? ~loaded ;; &t .>* alive}.
:- not &del{ * &t .>* ? ~loaded ;; ? ~load  ;; &t .>* ~loaded}.


% force dead
:- not &del{ * &t .>* ?( &t .>* &false) .>* ~alive }.
% force never load
:- not &del{ * &t .>* ~load }.