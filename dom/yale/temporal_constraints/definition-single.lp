
:- not &del{
   ? alive ;;
   ? ~loaded ;;
    * &t .>*
    ( 
        ? (?load .>* ~shoot)  ;;
        ? (?shoot.>* ~load)  ;;

        ? (?shoot ;; ?loaded ;; &t .>* ~alive) ;;
        ? (?shoot ;; &t .>* ~loaded) ;;

        ? (?load ;; &t .>* loaded) ;;

        ? (? ~alive ;; &t .>* ~alive) ;;
        ? (? alive ;; ? ~shoot + ? ~loaded ;; &t .>* alive) ;;
        ? (? ~loaded ;; ? ~load  ;; &t .>* ~loaded);;
        ? (?( &t .>* &false) .>* ~alive)
    )

    .>? &true
}.
