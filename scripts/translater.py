from graphviz import Digraph, Source
from pystructures.ldlf import LDLfFormula
from pystructures.automata import AFW
import argparse
import sys
import re

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Translations for LDLf formulas and automatas')
    parser.add_argument('--input', type=str, 
                        help='Starting input: afw or ldlf')
    parser.add_argument('--app', type=str, 
                        help='Approach name: dfa-mso, dfa-stm, nfa')
    parser.add_argument('--out-file', type=str, 
                        help='Path for output automata file')
    parser.add_argument('--in-files', type=str, 
                        help='Path for ldlf constraint or afw representation')
    
    parser.add_argument("--viz", default=False, action='store_true',
        help="Save automaton vizualization")
    parser.add_argument("--multiple-dfa", default=True, action='store_true',
        help="Use multiple DFAs instead of conjunction")
    parser.add_argument('--labels', action='store_const', const=True)
    parser.add_argument('--latex', action='store_const', const=True)

    args = parser.parse_args()
    in_files = args.in_files.split(" ")
    in_files = [f for f in in_files if f!=""]
    if args.input=="afw":
        assert args.app == "nfa"
        afw = AFW.from_lp(files = in_files, inline_data= "")
        automaton = afw.to_nfa()
        automata_lp = automaton.to_lp()

    elif args.input=="ldlf":
        assert args.app in ["dfa-mso","dfa-stm"]
        ldlfformulas = LDLfFormula.from_lp(files=in_files,inline_data="")
        if args.multiple_dfa:
            automata_lp=""
            id2prop = {}
            n_old_states = 0
            for i,f in enumerate(ldlfformulas):
                automaton = f.dfa(translation=args.app.split('-')[1],n_old_states=n_old_states, state_prefix=f"a{i}_", id2prop=id2prop)
                id2prop = automaton._props
                n_old_states = n_old_states+ len(automaton._states)
                automata_lp+=f"\n%%%%%%%%%%% Automata {i}\n"
                automata_lp+=automaton.to_lp()
        else:
            conj_formula = LDLfFormula.join_formulas(ldlfformulas)
            automaton = conj_formula.dfa(translation=args.app.split('-')[1])
            automata_lp=automaton.to_lp()
    
    # elif args.input=="telingo":
    #     program = ""
    #     for fn in sys.argv[3:]:
    #         f = open(fn, 'r')
    #         program += f.read()
    #         f.close()
    #         print(program)
    #         horizon = int(sys.argv[1]) + 1
    #         solve(program, imin=horizon, out_file=sys.argv[2], imax=horizon, istop="UNKNOWN")
    else:
        raise RuntimeError("Invalid input")

    with open(args.out_file, 'w') as f:
        f.write(automata_lp)

#    if args.viz:
#        print("Saving visualization of automata")
#        automaton.save_png(file=args.out_file[:-3]+".png",labels=args.labels,latex=args.latex)
#        if(args.latex):
#            automaton.to_tex(file=args.out_file[:-3]+".tex",labels=args.labels)

    import sys
    sys.exit()

