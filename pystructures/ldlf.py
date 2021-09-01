import pathlib
import random
import tempfile
import os
import clingo as _clingo
import sys
from pystructures.automata import NFA, AFW
from subprocess import PIPE, Popen, TimeoutExpired
import os
import signal

def invoke_mona(name):
    command = f"mona -q -w {name}"
    process = Popen(
        args=command,
        stdout=PIPE,
        stderr=PIPE,
        preexec_fn=os.setsid,
        shell=True,
        encoding="utf-8",
    )
    try:
        output, error = process.communicate(timeout=30)
        return str(output).strip()
    except TimeoutExpired:
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
        return False

# Used in del theory
del_operators = {".>*":'Box', ".>?":'Diamond',"&": "Boolean","~": "Prop"}
path_unary_operators  = {"*":'KleeneStar', "?":'Check', "&": "Skip"}
path_binary_operators = {";;":'Sequence', "+":'Choice'}
path_operators = dict(path_unary_operators)
path_operators.update(path_binary_operators)

# Used in lp encodings of automata
del_operators_names = {"box":'Box', "diamond":'Diamond',"top": "Boolean","bottom": "Boolean","neg": "Prop"}
path_unary_operators_names  = {"star":'KleeneStar', "test":'Check', "stp": "Skip"}
path_binary_operators_names = {"sequence":'Sequence', "choice":'Choice'}
path_operators_names = dict(path_unary_operators_names)
path_operators_names.update(path_binary_operators_names)


class AuxMSO():
    """
    Auxiliary class to handle second order predicates in the MSO translation
    """
    def __init__(self, f_id, f):
        self._id = f_id
        self._f = f
    
    def mona_q(self,time,prop2mona):
        if not self._f.is_atomic:
            return "({} in Q_{})".format(time,self._id)
        elif self._f.__class__ == LDLfProp:
            return "({} in {})".format(time,self._f.mona_rep(prop2mona))
        elif self._f.__class__ == LDLfBoolean:
            return "({})".format(self._f.mona_rep(prop2mona))
        else:
            raise Exception("Should be one above")
            
    # def __str__(self):
    #     return "ID: {} F:{} MONA:{}".format(self._id,self._f,self.mona_q('x'))


# ---------------------- Formulas
class LDLfFormula():
    def __init__(self, rep):
        """
        Initializes a formula with the given string representation.
        """
        self.__rep  = rep

    @property
    def _rep(self):
        """
        Return the unique string representaiton of the formula.
        """
        return self.__rep

    # --------------- Constructors
    @classmethod
    def from_lp(cls, files=[], inline_data=""):
        """
        Creates an LDLfFormula from an lp files containing constraints using the syntax for the theory.
        """
        ctl = _clingo.Control([], message_limit=0)
        ctl.add("base", [], "")
        for f in files:
            ctl.load(f)
        ctl.load("./encodings/translations/grammar.lp")
        ctl.add("base", [], inline_data)
        ctl.ground([("base", [])])
        formulas = []
        for t in ctl.theory_atoms:
            formula = LDLfFormula.from_theory(t.elements[0].terms[0])
            formulas.append(formula)
        return formulas

    @classmethod
    def from_theory(cls, term):
        """
        Creates an LDLfFormula of a Theory Term grouded from a file using the theory syntax.
        """
        if (term.type ==  _clingo.TheoryTermType.Symbol):
            return LDLfProp.from_theory(term)
        elif (term.type ==  _clingo.TheoryTermType.Function):
            if term.name in del_operators:
                class_name = "LDLf" + del_operators[term.name]
            else:
                class_name = "LDLfProp"
            return getattr(sys.modules[__name__], class_name).from_theory(term)
        else:
            raise RuntimeError("Invalid term {}".format(term))
    
    @classmethod
    def from_symbol(cls, symbol, id2prop):
        """
        Creates an LDLfFormula from a symbol used in the Automta Encoding. 
        """
        if symbol.type == _clingo.SymbolType.Function and symbol.name =="":
            print("WARNING: Loading unkown symbol, treated as string")
            return LDLfFormula(str(symbol))
        if symbol.name in del_operators_names:
            class_name = "LDLf" + del_operators_names[symbol.name]
        else:
            class_name = "LDLfProp"
        return getattr(sys.modules[__name__], class_name).from_symbol(symbol,id2prop)
    
    @classmethod
    def join_formulas(cls, formulas):
        """
        Returns the conjuction of all the formulas
        """
        formula = formulas[0]
        for f in formulas[1:]:
            formula= LDLfDiamond(CheckPath(f),formula)
        return formula

    def closure_main(self):
        closure = set([])
        self.closure(closure)
        return list(closure)
    # --------------- Translations

    def mso_main(self, time_step=0):
        """
        Obtains the Monadic Second Order Encoding of the formula as a 
        string for MONA. For the given timestep
        Returns format (ex2 Q1..Qn: Q1(0) & all1 x: (Q1<=>F1 & ... Qn<=>Fn));
        """
        closure = self.closure_main()
        
        closure.sort(key =lambda x: str(x))
        translations = []
        rep2aux = {f._rep:AuxMSO(i,f) for i, f in enumerate(closure)}
        prop2mona = {}
        for _, aux_mso in rep2aux.items():
            if not aux_mso._f.is_atomic:
                translations.append("( {} <=> ({}) )".format(aux_mso.mona_q('x',prop2mona),aux_mso._f.mso("x",rep2aux,prop2mona)))
            else:
                aux_mso._f.mona_rep(prop2mona) #call just to add translation to prop2mona
        
        
        mso_string = "\nm2l-str;\n"
        
        # all_prop_vars = list(set([f.mona_rep for f in closure if f.__class__ == LDLfProp and f.positive]))
        all_prop_vars = list(prop2mona.values())
        all_prop_vars.sort()
        if len(all_prop_vars)>0:
            mso_string += "var2 {};\n".format(", ".join(all_prop_vars))
        
        exist_2var = ", ".join(["Q_{}".format(aux_mso._id) for aux_mso in rep2aux.values() if not aux_mso._f.is_atomic])
        if len(translations)>0:
            mso_string += "(ex2 {}: {} & all1 x: ({}));\n".format(exist_2var,rep2aux[self._rep].mona_q(time_step, prop2mona)," & ".join(translations))
        else:
            mso_string += "{};\n".format(rep2aux[self._rep].mona_q(time_step, prop2mona))

        mona2prop = {mona:prop for prop,mona in prop2mona.items()}
        return mso_string, mona2prop

    def stm_main(self, time_step=0):
        """
        Obtains the Standard relational translation for the formula ina given time_step as a string for MONA.
        """
        all_prop_vars = set()
        all_vars = set()
        
        mona_p_string = "\nm2l-str;\n"
        prop2mona = {}
        mona_formula = self.stm(time_step,all_prop_vars,all_vars, prop2mona)

        if len(all_prop_vars)>0:
            mona_p_string += "var2 {};\n".format(", ".join(all_prop_vars))
        
        mona_p_string += "{};\n".format(mona_formula)
        mona2prop = {mona:prop for prop,mona in prop2mona.items()}
        return mona_p_string, mona2prop



    def dfa(self,translation="stm", n_old_states=0, state_prefix="", id2prop=None):
        """
        Obtains the DFA using the defined translation using MONA.
        Args:
            translation: mso or stm
        Returns:
            An NFA restricted to DFA
        """
        if translation == "mso":
            mso_string, mona2prop = self.mso_main()
        elif translation == "stm":
            mso_string, mona2prop = self.stm_main()
        mona_out_path = "./outputs/mona_tmp"
        pathlib.Path(mona_out_path).mkdir(parents=True, exist_ok=True)
        # if not os.path.exists(mona_out_path): os.makedirs(mona_out_path)
        name = f"{mona_out_path}/automa_{state_prefix}{random.randint(0,900000)}.mona" 
        
        with open(name, "w+") as file:
            file.write(mso_string)
        # print(mso_string)
        mona_dfa = invoke_mona(name)
        # print(mona_dfa)

        return NFA.from_mona(mona_dfa, n_old_states=n_old_states, state_prefix=state_prefix, id2prop=id2prop, mona2prop=mona2prop)

    # --------------- Subclass specific methods
    def stm(self,v_start, all_prop_vars, all_vars,prop2mona):
        """
        Obtains the Standard Translation for the formula with in the time given by
        the variable v_start.
        Args:
            v_start: The variable for the timepoint
            all_prop_vars: Set gathering the representation of propositions
            all_vars: Set gathering all the first order variables
        """
        raise NotImplementedError

    def mso(self, time, rep2aux):
        """
        Ontains the equivalent function using the subformulas for the mso translation. Only needs to be implemented for non-atomic formulas.
        Args:
            time: The variable for the time. Usually 'x'
            rep2aux: A dictionary mapping subformulas to their Second Order info
                    as an AuxMSO object
        """
        raise NotImplementedError


    def closure(self, subformulas):
        """
        Adds the closure of the formula to the set of subformulas
        """
        print("ERROR: {}".format(self) )
        raise NotImplementedError

    def __str__(self):
        return self.__rep

class LDLfBoolean(LDLfFormula):
    """
    Formula capturing a Boolean constant.

    Members:
    __value -- Truth value of the formula.
    """

    def __init__(self, value):
        """
        Initializes the formula with the given value.

        Members:
        __value -- Boolean value of the formula.
        """
        LDLfFormula.__init__(self, " &true " if value else " &false ")
        self.__value = value
    
    @property
    def is_atomic(self):
        return True
    
    def closure(self,subformulas):
        subformulas.add(self)

    def mona_rep(self, prop2mona):
        return 'true ' if self.__value else 'false '

    @classmethod
    def from_theory(cls, term):
        arg = term.arguments[0]
        assert(arg.type == _clingo.TheoryTermType.Symbol)
        return cls(arg.name == "true")

    @classmethod
    def from_symbol(cls, symbol, id2prop):
        return cls(symbol.name == "top")


    def stm(self, v_start, all_prop_vars, all_vars, prop2mona):
        return self.mona_rep(prop2mona)
        
class LDLfProp(LDLfFormula):
    """
    Formula capturing a proposition, including negation.

    Members:
    positive -- True if it is negated.
    """

    def __init__(self, name, arguments, positive):
        """
        Initializes the formula with the given negated.

        Members:
        positive -- Boolean negated of the formula.
        """
        self._name = name
        args = "" if len(arguments)==0 else "({})".format(",".join([str(a) for a in arguments]))
        self._arguments = args
        self._args_arr = [str(a) for a in arguments]
        rep = "{}{}{}".format("" if positive else "~",
                                  name, args)
        LDLfFormula.__init__(self, rep)
        self.positive = positive

    @property
    def is_atomic(self):
        return self.positive

    @property
    def positive_version(self):
        return LDLfProp(self._name,self._args_arr,True)
        
    def closure(self,subformulas):
        if self in subformulas:
            return
        subformulas.add(self)
        if not self.positive:
            positive_version = self.positive_version
            subformulas.add(positive_version)

    @classmethod
    def from_theory(cls, term):
        positive = True
        if term.type == _clingo.TheoryTermType.Function and term.name=="~":
            positive = False
            term = term.arguments[0]
        arguments = [] if term.type == _clingo.TheoryTermType.Symbol else term.arguments
        o = cls(term.name, arguments, positive)
        return o

    @classmethod
    def from_symbol(cls, symbol, id2prop):
        positive = True
        if symbol.name=="neg":
            positive = False
            symbol = symbol.arguments[0]
        prop_id = symbol.arguments[0].number
        o =cls(id2prop[prop_id], [], positive)
        return o

    def mona_rep(self, prop2mona):
        if not str(self) in prop2mona:
            prop2mona[str(self)]=f"PROP_{len(prop2mona)}"
        return prop2mona[str(self)]

    def mso(self, time, rep2aux, prop2mona):
        assert not self.positive
        return "~ {}".format(rep2aux[self.positive_version._rep].mona_q(time, prop2mona))


    def stm(self, v_start, all_prop_vars, all_vars, prop2mona):
        if self.positive:
            all_prop_vars.add(self.mona_rep(prop2mona))
            return "({} in {}) ".format(v_start, self.mona_rep(prop2mona))
        else:
            pos = self.positive_version
            all_prop_vars.add(pos.mona_rep(prop2mona))
            return "~ ({} in {}) ".format(v_start, pos.mona_rep(prop2mona))

class LDLfMainOperator(LDLfFormula):
    """
    Members:
    _op   -- The id of the operator.
    _path -- The left-hand-side of the temporal operator.
    _rhs  -- The right-hand-side of the temporal operator.
    """

    def __init__(self, op, path, rhs):
        """
        Initializes the formula.

        Arguments:
        op -- The id of the operator.
        lhs -- The left-hand-side of the operator.
        rhs -- The right-hand-side of the operator.
        """
        self._op = op
        self._path = path
        self._rhs = rhs
        rep = "{}{}{}{}".format(op[0], path._rep, op[1], rhs._rep)
        LDLfFormula.__init__(self, rep)

    @property
    def is_atomic(self):
        return False

    def closure(self, subformulas):
        if self in subformulas:
            return
        subformulas.add(self)
        self._rhs.closure(subformulas)
        main_class = self.__class__
        c = self._path.__class__
        if c == CheckPath:
            self._path._arg.closure(subformulas)
        elif c == ChoicePath:
            lhs_ldl = main_class(self._path._lhs,self._rhs)
            rhs_ldl = main_class(self._path._rhs,self._rhs)
            lhs_ldl.closure(subformulas)
            rhs_ldl.closure(subformulas)
        elif c == SequencePath:
            eq_ldl = main_class(self._path._lhs,main_class(self._path._rhs,self._rhs))
            eq_ldl.closure(subformulas)
        elif c == KleeneStarPath:
            step_ldl = main_class(self._path._arg,self)
            step_ldl.closure(subformulas)


    @classmethod
    def from_theory(cls, term):
        path = Path.from_theory(term.arguments[0])
        rhs = LDLfFormula.from_theory(term.arguments[1])
        return cls(path, rhs)

    @classmethod
    def from_symbol(cls, symbol, id2prop):
        path = Path.from_symbol(symbol.arguments[0], id2prop)
        rhs = LDLfFormula.from_symbol(symbol.arguments[1], id2prop)
        return cls(path, rhs)

class LDLfDiamond(LDLfMainOperator):
    """
    Members:
    _op   -- The id of the operator.
    _path -- The left-hand-side of the temporal operator.
    _rhs  -- The right-hand-side of the temporal operator.
    """

    def __init__(self, path, rhs):
        """
        Initializes the formula.

        Arguments:
        rep -- String representation of the formula.
        path -- The left-hand-side of the operator.
        rhs -- The right-hand-side of the operator.
        """
        LDLfMainOperator.__init__(self, "<>", path, rhs)
    
    def mso(self, time, rep2aux, prop2mona):
        c = self._path.__class__
        if c == SkipPath:
            return "ex1 v: v={}+1 & {}".format(time,rep2aux[self._rhs._rep].mona_q('v',prop2mona))
        elif c == CheckPath:
            rhs_rep = rep2aux[self._rhs._rep]
            lhs_rep = rep2aux[self._path._arg._rep]
            return "{} & {}".format(rhs_rep.mona_q(time,prop2mona),lhs_rep.mona_q(time,prop2mona))
        elif c == ChoicePath:
            lhs_rep = rep2aux[LDLfDiamond(self._path._lhs,self._rhs)._rep]
            rhs_rep = rep2aux[LDLfDiamond(self._path._rhs,self._rhs)._rep]
            return "{} | {}".format(rhs_rep.mona_q(time,prop2mona),lhs_rep.mona_q(time,prop2mona))
        elif c == SequencePath:
            eq_ldl = LDLfDiamond(self._path._lhs,LDLfDiamond(self._path._rhs,self._rhs))
            eq_rep = rep2aux[eq_ldl._rep]
            return "{}".format(eq_rep.mona_q(time,prop2mona))

        elif c == KleeneStarPath:
            rhs_rep = rep2aux[self._rhs._rep]
            if self._path._arg.__class__==CheckPath:
                return "{}".format(rhs_rep.mona_q(time,prop2mona))
            else:
                step_ldl = LDLfDiamond(self._path._arg,self)
                step_rep = rep2aux[step_ldl._rep]
                return "{} | {}".format(rhs_rep.mona_q(time,prop2mona),step_rep.mona_q(time,prop2mona))
     

    def stm(self, v_start, all_prop_vars, all_vars, prop2mona):
        new_var = 'v_{}'.format(len(all_vars))
        all_vars.add(new_var)
        st_p = self._path.stp(v_start,new_var,all_prop_vars, all_vars,prop2mona)
        st_m = self._rhs.stm(new_var,all_prop_vars, all_vars,prop2mona)
        return "(ex1 {}: ( ({}) & {})) ".format(new_var,st_p,st_m)
    
class LDLfBox(LDLfMainOperator):
    """
    Members:
    _op   -- The id of the operator.
    _path -- The left-hand-side of the temporal operator.
    _rhs  -- The right-hand-side of the temporal operator.
    """

    def __init__(self, path, rhs):
        """
        Initializes the formula.

        Arguments:
        rep -- String representation of the formula.
        path -- The left-hand-side of the operator.
        rhs -- The right-hand-side of the operator.
        """
        LDLfMainOperator.__init__(self, "[]", path, rhs)

    def mso(self, time, rep2aux, prop2mona):
        c = self._path.__class__
        if c == SkipPath:
            return "all1 v: v={}+1 => {}".format(time,rep2aux[self._rhs._rep].mona_q('v',prop2mona))
        elif c == CheckPath:
            rhs_rep = rep2aux[self._rhs._rep]
            lhs_rep = rep2aux[self._path._arg._rep]
            return "{} => {}".format(lhs_rep.mona_q(time,prop2mona),rhs_rep.mona_q(time,prop2mona))
        elif c == ChoicePath:
            lhs_rep = rep2aux[LDLfBox(self._path._lhs,self._rhs)._rep]
            rhs_rep = rep2aux[LDLfBox(self._path._rhs,self._rhs)._rep]
            return "{} & {}".format(rhs_rep.mona_q(time,prop2mona),lhs_rep.mona_q(time,prop2mona))
        elif c == SequencePath:
            eq_ldl = LDLfBox(self._path._lhs,LDLfBox(self._path._rhs,self._rhs))
            eq_rep = rep2aux[eq_ldl._rep]
            return "{}".format(eq_rep.mona_q(time,prop2mona))

        elif c == KleeneStarPath:
            rhs_rep = rep2aux[self._rhs._rep]
            if self._path._arg.__class__==CheckPath:
                return "{}".format(rhs_rep.mona_q(time,prop2mona))
            else:
                step_ldl = LDLfBox(self._path._arg,self)
                step_rep = rep2aux[step_ldl._rep]
                return "{} & {}".format(rhs_rep.mona_q(time,prop2mona),step_rep.mona_q(time,prop2mona))

    def stm(self, v_start, all_prop_vars, all_vars, prop2mona):
        new_var = 'v_{}'.format(len(all_vars))
        all_vars.add(new_var)
        st_p = self._path.stp(v_start,new_var,all_prop_vars, all_vars,prop2mona)
        st_m = self._rhs.stm(new_var,all_prop_vars, all_vars,prop2mona)
        return "(all1 {}: ( ({}) => {})) ".format(new_var,st_p,st_m)

# ---------------------- Paths
class Path(object):

    """
    Base class of all path

    Members:
    __rep  -- unique string representation of the path
    """
    def __init__(self, rep):
        """
        Initializes a formula with the given string representation.
        """
        self.__rep  = rep

    @property
    def _rep(self):
        """
        Return the unique string representaiton of the formula.
        """
        return self.__rep

    
    @classmethod
    def from_theory(cls, term):
        assert term.type ==  _clingo.TheoryTermType.Function
        class_name = path_operators[term.name] + "Path"
        return getattr(sys.modules[__name__], class_name).from_theory(term)   

    @classmethod
    def from_symbol(cls, symbol, id2prop):
        class_name = path_operators_names[symbol.name] + "Path"
        return getattr(sys.modules[__name__], class_name).from_symbol(symbol, id2prop)   

    # --------------- Subclass specific methods
    def stp(self,v_start,v_end, all_prop_vars, all_vars,prop2mona):
        """
        Obtains the Standard Translation for the path.
        Args:
            v_start: The variable for the starting timepoint
            v_end: The variable for the end timepoint
            all_prop_vars: Set gathering the representation of propositions
            all_vars: Set gathering all the first order variables
        """
        raise NotImplementedError

class SkipPath(Path):
    def __init__(self):
        Path.__init__(self, "(&t)")

    @classmethod
    def from_theory(cls,term):
        assert term.arguments[0].name=="t"
        return cls()
    
    @classmethod
    def from_symbol(cls,symbol, id2prop):
        assert symbol.name=="stp"
        return cls()
    
    def stp(self, v_start, v_end, all_prop_vars, all_vars,prop2mona):
        return "( {} = {}+1) ".format(v_end,v_start)

class BinaryPath(Path):
    """
    Members:
    _lhs
    _rhs

    """
    def __init__(self, rep, lhs, rhs):
        self._lhs = lhs
        self._rhs = rhs
        Path.__init__(self, rep)

    @classmethod
    def from_theory(cls,term):
        lhs = Path.from_theory(term.arguments[0])
        rhs = Path.from_theory(term.arguments[1])
        return cls(lhs,rhs)

    @classmethod
    def from_symbol(cls,symbol, id2prop):
        lhs = Path.from_symbol(symbol.arguments[0], id2prop)
        rhs = Path.from_symbol(symbol.arguments[1], id2prop)
        return cls(lhs,rhs)
       
class ChoicePath(BinaryPath):
    
    def __init__(self, lhs, rhs):
        BinaryPath.__init__(self, "{}+{}".format(lhs._rep, rhs._rep), lhs, rhs)

    def stp(self, v_start, v_end, all_prop_vars, all_vars, prop2mona):
        st_p_l = self._lhs.stp(v_start,v_end, all_prop_vars, all_vars, prop2mona)
        st_p_r = self._rhs.stp(v_start,v_end, all_prop_vars, all_vars, prop2mona)
        return "({} | {}) ".format(st_p_l,st_p_r)

class SequencePath(BinaryPath):
    
    def __init__(self, lhs, rhs):
        BinaryPath.__init__(self, "{};;{}".format(lhs._rep, rhs._rep), lhs, rhs)

    def stp(self, v_start, v_end, all_prop_vars, all_vars, prop2mona):
        new_var = 'v_{}'.format(len(all_vars))
        all_vars.add(new_var)
        st_p_l = self._lhs.stp(v_start,new_var, all_prop_vars, all_vars, prop2mona)
        st_p_r = self._rhs.stp(new_var,v_end, all_prop_vars, all_vars, prop2mona)
        return "(ex1 {}: ({}& {}))".format(new_var, st_p_l,st_p_r)

class UnaryPath(Path):
    """
    Members:
    __arg
    """
    def __init__(self, rep, arg):
        self.__arg = arg 
        Path.__init__(self, rep)

    @property
    def _arg(self):
        """
        Return the unique string representaiton of the formula.
        """
        return self.__arg

class CheckPath(UnaryPath):
    
    def __init__(self, arg):
        UnaryPath.__init__(self, "{}?".format(arg._rep), arg)

    @classmethod
    def from_theory(cls,term):
        arg =  LDLfFormula.from_theory(term.arguments[0])
        return cls(arg)

    @classmethod
    def from_symbol(cls,symbol, id2prop):
        arg =  LDLfFormula.from_symbol(symbol.arguments[0], id2prop)
        return cls(arg)

    def stp(self, v_start, v_end, all_prop_vars, all_vars,prop2mona):
        st_m = self._arg.stm(v_start, all_prop_vars, all_vars,prop2mona)
        return "({}& {}={})".format(st_m,v_end,v_start) #ONLY test in prop

class KleeneStarPath(UnaryPath):

    def __init__(self, arg):
        UnaryPath.__init__(self, "({})*".format(arg._rep), arg)

    @classmethod
    def from_theory(cls,term):
        arg =  Path.from_theory(term.arguments[0])
        return cls(arg)

    @classmethod
    def from_symbol(cls,symbol, id2prop):
        arg =  Path.from_symbol(symbol.arguments[0], id2prop)
        return cls(arg)

    def stp(self, v_start, v_end, all_prop_vars, all_vars,prop2mona):
        conditions = []
        conditions.append("{} in S".format(v_start)) #Initial tp is in the set of starting tps
        conditions.append("{} in S".format(v_end)) #Initial tp is in the set of starting tps
        conditions.append("all1 r: (r in S) => ({}<=r & r<={})".format(v_start,v_end)) #S<=D
        st_p = self._arg.stp('x', 'y', all_prop_vars, all_vars,prop2mona)
        # For every two tps in the set that are consecutive rho must hold between them
        conditions.append("all1 x, y: ((x<y & (x in S) & (y in S) & ~(ex1 z: (x<z & z<y & (z in S))) ) => {})".format(st_p))
        
        return "ex2 S: ({})".format("& ".join(["({})".format(c) for c in conditions]))
