import json
import re
from graphviz import Digraph, Source
import clingo as _clingo
import itertools
import dot2tex

def de_tuple_str_symbol(term):
    if (term.type ==  _clingo.SymbolType.String):
        return str(term)
    elif (term.type ==  _clingo.SymbolType.Number):
        return str(term)
    elif (term.type ==  _clingo.SymbolType.Function):
        args = term.arguments
        assert term.name=="" and len(args)>0
        args_str = ",".join([de_tuple_str_symbol(a) for a in args[1:]])
        return f"{str(args[0])}({args_str})".replace('"',"")
    else:
        print("Found an invalid form of prop")
        assert False

class State():
    def __init__(self, s_id, label):
        self._label = label
        self._id = int(s_id)

    def __str__(self):
        return str(self._label)

class Condition():
    def __init__(self, included, not_included):
        self._included = included
        self._not_included = not_included

    @classmethod
    def from_str(cls, s, prop2id):
        s = s.strip('"')
        included = []
        not_included = []
        s = s.split(" & ") 
        for c in s:
            next_id = len(prop2id)
            if c[0]=="~":
                p_name=c[1:]
                prop2id.setdefault(p_name,next_id)
                not_included.append(prop2id[p_name])
            else:
                p_name=c
                prop2id.setdefault(p_name,next_id)
                included.append(prop2id[p_name])
        return cls(included, not_included)

    def get_props(self):
        return set(self._included+self._not_included)

    def str_names(self,names):
        elems = []
        if len(self._included)>0:
            elems.append("& ".join([names[i] for i in self._included]))
        if len(self._not_included)>0:
            elems.append("& ".join(["~ "+ names[i] for i in self._not_included]))
        
        return "& ".join(elems).replace('"','')

    def is_taut(self):
        return len(self._included)+len(self._not_included)==0

    def __str__(self):
        not_included = "" 
        if len(self._not_included)>0:
            not_included = "& ~".join([""]+[str(i) for i in self._not_included])
        return "& ".join([str(i) for i in self._included]) + not_included

class Automata():

    def __init__(self, props, states, transitions, initial_states_ids, final_states_ids, dot = None):
        self._props = {i:p.replace('"',"").replace("'","") for i,p in props.items()}
        self._states = states
        self._transitions = transitions
        self._initial_states_ids = initial_states_ids
        self._final_states_ids = final_states_ids

    @property
    def initial_states(self):
        return [self._states[s] for s in self._initial_states_ids]

    def tikz(self):
        pass

    def to_dic(self):
        j = {
            'props': self._props,
            'states': {i:str(s) for i, s in self._states.items()},
            'initial_states': self._initial_states_ids,
            'transition': {i : {str(c) : n for c, n in v.items()} for i, v in self._transitions.items()},
            'final_states': list(self._final_states_ids),
        } 
        return j

    @classmethod
    def from_lp(cls, files=[], inline_data=""):
        from pystructures.ldlf import LDLfFormula

        ctl = _clingo.Control([], message_limit=0)
        ctl.add("base", [], "")
        for f in files:
            ctl.load(f)
        ctl.add("base", [], inline_data)
        ctl.ground([("base", [])])
        states = {}
        trans = {}
        initial_states = []
        final_states = []
        id2prop = {}
        cases = {}
        for sa in ctl.symbolic_atoms:
            s = sa.symbol
            i = s.arguments[0].number
            n_args = len(s.arguments)
            if s.name == 'initial_state':
                initial_states.append(i)
            elif s.name == 'prop':
                id2prop[i] = de_tuple_str_symbol(s.arguments[1]).replace('"','')
            elif s.name == 'state':
                formula = LDLfFormula.from_symbol(s.arguments[1],id2prop)
                states[i] = State(i,str(formula))
            elif s.name == 'delta':
                case = str(s.arguments[1])
                trans.setdefault(i,{}).setdefault(case,[])
                cases.setdefault(i,{}).setdefault(case,([],[]))
                # if n_args==2:
                if n_args==3:
                    n_to = s.arguments[2].number
                    trans[i][case].append(n_to)
                elif n_args==4:
                    pos = 0 if s.arguments[2].name == "in" else 1
                    prop = s.arguments[3].number
                    cases[i][case][pos].append(prop)
                elif n_args!=2:
                    raise RuntimeError("Invalid format in predicate " + str(s))
                
            elif s.name == "final_state":
                final_states.append(i)

        cases_classes = {}
        for s_from, dic_c in cases.items():
            cases_classes[s_from] = {}
            for c_id, tup in dic_c.items():
                cases_classes[s_from][c_id]=Condition(tup[0],tup[1])

        transitions = {}
        for s_from, dic_c in trans.items():
            transitions[s_from]={}
            for c_id,s2 in dic_c.items():
                con = cases_classes[s_from][c_id]
                transitions[s_from].setdefault(con,[]).append(s2)

        return cls(id2prop,states,transitions,initial_states,set(final_states),"")
        

    def dot(self, latex = False, labels =True):
        dot = 'digraph ATLINGO {\n'
        dot += 'rankdir = LR;\n'
        dot += 'center = true;\n'
        dot += 'size = "50,50";\n'
        # General def
        dot += 'edge [fontname = Courier arrowhead=vee arrowsize=0.5 penwidth= .8 lblstyle="font=\\tiny"];\n'
        dot += 'node [height = .5, width = .5];\n'
        # Nodes
        for i, s in self._states.items():
            label = s._label if labels else s._id
            if labels and latex:
                label = label.replace("<","\\deventually{").replace("[","\\dalways{")
                label = label.replace("&t","\\stp")
                label = label.replace("&true","\\top")
                label = label.replace("&false","\\bot")
                label = label.replace("~","\\neg")
                label = label.replace(";;",";").replace("*","^*")
                label = label.replace("]","}").replace(">","}")
                label = "q_{{{}}}".format(label)
            shape= 'circle'
            if s._id in self._final_states_ids:
                shape = 'doublecircle'
            dot += 'node [shape = {} label= "{}"] {};\n'.format(shape, label,s._id)
        dot += 'init [shape = plaintext, label = " "];\n'
        
        branch_format = 'shape = point width = .05 height = .05 label=" " '
        # True transition for AFW
        if isinstance(self,AFW):
            if latex:
                branch_format = 'color=white shape = circle width = .3 height = .3 label="\\forall"'
        # Initial Node
        for init_i in self._initial_states_ids:
            dot += f'init -> {init_i};\n'
        # Transitions
        and_id=0
        for s_from, v in self._transitions.items():
            for c, s_tos in v.items():
                label = c.str_names(self._props)
                if latex:
                    label = label.replace("&","\\wedge")
                    label = label.replace("~","-")
                for s_to in s_tos:
                    if isinstance(s_to,int) or len(s_to)==1:
                        s_to_int = s_to if isinstance(s_to,int) else s_to[0]
                        dot += '{} -> {} [label="{}"];\n'.format(s_from, s_to_int, label)
                        continue
                    dot += 'and{} [{}];\n'.format(and_id,branch_format)
                    dot += '{} -> and{} [label="{}" arrowhead=none];\n'.format(s_from, and_id, label)
                    for s in s_to:
                        dot += "and{} -> {};\n".format(and_id, s)
                    and_id+=1

        dot += '}'
        return dot

    def to_tex(self, file="./outputs/automata.tex", labels=False):
        testgraph = self.dot(latex=True,labels=labels)
        texcode = dot2tex.dot2tex(testgraph, format='tikz', texmode='math',crop=True,margin="20pt")
        with open(file,'w') as f:
            macros = """
            \\newcommand{\\dalways}[1]{\\ensuremath{[#1]\\,}}                    
            \\newcommand{\\deventually}[1]{\\ensuremath{\\langle#1\\rangle\\,}} 
            \\newcommand{\\stp}{\\ensuremath{\\tau}}
            """
            f.write(macros)
            f.write(texcode.replace("wedge","\\wedge").replace("join=bevel,","join=bevel,scale=0.4"))

    def save_png(self, file="outputs/automata_viz",labels =True, latex=False):
        dot = self.dot(labels=labels,latex=latex)
        s = Source(dot)
        s.render(file, format="png")

    def __str__(self):
        return json.dumps(self.to_dic(),indent=4)


class NFA(Automata):

    def __init__(self, *args):
        super(NFA,self).__init__(*args)

    @classmethod
    def from_mona(cls, mona, n_old_states=0, state_prefix="", id2prop=None, mona2prop=None):
        if mona == False:
            print("Error in mona: \n{}".format(mona))
            raise TimeoutError(mona)
        if "Execution aborted" in mona:
            print("Error in mona: \n{}".format(mona))
            raise TimeoutError(mona)
        if "BDD too large " in mona[:20]:
            print("Error in mona: \n{}".format(mona))
            raise TimeoutError(mona)


        id2prop = {} if id2prop is None else id2prop
        states = {}

        def get_state(state_name):
            s_id = int(state_name)+n_old_states
            if s_id not in states:
                states[s_id] = State(s_id, f"{state_prefix}{state_name}")
            return states[s_id]

        # Alphabet
        vrs = re.findall(r'(?<=DFA for formula with free variables:\s).*?(?=\s\n)',mona)
        vrs = vrs[0].split(" ") if len(vrs)>0 else []
        id2prop = id2prop
        prop2id = {v:k for k,v in id2prop.items()}
        newid2oldid = {}
        
        for new_id,prop in enumerate(vrs):
            prop = mona2prop[prop]
            if prop in prop2id:
                newid2oldid[new_id]=prop2id[prop]
            else:
                next_id = len(id2prop)
                id2prop[next_id]=prop
                newid2oldid[new_id]=next_id
        if not "last" in prop2id:
            id2prop[len(id2prop)]="last"

        # Final states
        f_states = re.findall(r'(?<=Accepting states:\s).*?(?=\s\n)',mona)
        final = [get_state(f_id)._id for f_id in f_states[0].split(" ")] if len(f_states)>0 else []

        # Transitions and states
        trans = re.findall(r'(?<=State\s).*?(?=\n)',mona)
        t_reg = r'(\d+):\s([X01]*)\s\->\sstate\s(.+)'
        transitions = {}
        for t in trans[1:]:
            res = re.match(t_reg,t).groups()
            n_from = get_state(res[0])
            n_to = get_state(res[2])
            in_prop = [newid2oldid[i] for i,v in enumerate(res[1]) if v=='1']
            out_prop = [newid2oldid[i] for i,v in enumerate(res[1]) if v=='0']
            c = Condition(in_prop,out_prop)
            transitions.setdefault(n_from._id,{})[c]=[n_to._id]

        initial_states_ids = [n_old_states+1]
        return cls(id2prop,states,transitions,initial_states_ids,set(final),"")

    def to_lp(self, state_prefix = ""):
        def tos(s_id):
            return state_prefix+str(s_id) 
        p = ""
        for i, prop in self._props.items():
            p+=('prop({},"{}").\n').format(i,prop)
        # p+=('prop({},"last").\n').format(len(self._props))

        for i, s in self._states.items():
            p+=('state({},"{}").\n').format(tos(s._id),s._label)
        for init_i in self._initial_states_ids:
            p+=('initial_state({}).\n').format(tos(init_i))
        
        for s_from, v in self._transitions.items():
            c_id = 0
            for c, s_tos in v.items():
                p+=('delta({},{}).\n').format(tos(s_from),c_id)
                for s_to in s_tos:
                    p+=('delta({},{},{}).\n').format(tos(s_from),c_id,tos(s_to))
                for prop_in in c._included:
                    p+=('delta({},{},in,{}).\n').format(tos(s_from),c_id,prop_in)
                for prop_in in c._not_included:
                    p+=('delta({},{},out,{}).\n').format(tos(s_from),c_id,prop_in)

                c_id=c_id+1
        for s in self._final_states_ids:
            p+=('final_state({}).\n').format(tos(s))
    
        p+=('%------- Definition of trace --------.\n')
        for i, prop in self._props.items():
            if prop == "null":
                continue
            if prop[-1]==")":
                p_with_t = prop[:-1]+",T)"
            else:
                p_with_t = prop+"(T)"
            p+=('trace({},T):- {}.\n').format(i,p_with_t)

        return p


class AFW(Automata):

    def __init__(self, *args):
        super(AFW,self).__init__(*args)

    
    def to_nfa(self):
        id2state = {}
        tuple2state = {}
        new_states = set([])
        
        def get_state(l):
            l.sort()
            t = tuple(l)
            if not t in tuple2state:
                s =  State(len(tuple2state),t)
                new_states.add(s)
                tuple2state[t]=s
            return tuple2state[t]

        final = get_state([])._id
        initial_states = [get_state([i]) for i in self._initial_states_ids]
        transitions = {}
        while not len(new_states)==0:

            s=new_states.pop()

            options_per_state = [[] for i in s._label]
            for i, s_afw in enumerate(s._label):
                if s_afw == "null" or not s_afw in self._transitions:
                    continue
                options_per_state[i]=[]
                for c,s_nexts in  self._transitions[s_afw].items():
                    for s_next in s_nexts:
                        options_per_state[i].append((c,s_next))
            combinations = list(itertools.product(*options_per_state))
            
            for comb_t in combinations:
                in_p = []
                out_p = []
                next_l = []
                for c, s_next in comb_t:
                    in_p=in_p+c._included
                    out_p=out_p+c._not_included
                    next_l = next_l + s_next

                contradict = any(p in out_p for p in in_p)
                if contradict:
                    continue
                s_to = get_state(next_l)
                case = Condition(in_p,out_p)
                transitions.setdefault(s._id,{}).setdefault(case,[]).append(s_to._id)

        for i, state in tuple2state.items():
            state._label = "{{ {} }}".format(", ".join([str(x) for x in state._label]))

        id2state = {s._id:s for s in tuple2state.values()}
        print(id2state)
        return NFA({i:p for i,p in self._props.items()},id2state,transitions,[i._id for i in initial_states],set([final]),"")

