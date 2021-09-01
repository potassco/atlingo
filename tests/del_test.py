import unittest
import os
import sys
import clingo
import subprocess
import itertools
from pystructures.ldlf import LDLfFormula, KleeneStarPath, LDLfBoolean, SkipPath
from pystructures.automata import AFW, NFA




# define the name of the directory to be created
paths = ["./outputs/test/afw/cons_tmp/instance_tmp",
        "./outputs/test/telingo/cons_tmp/instance_tmp",
        "./outputs/test/dfa/cons_tmp/instance_tmp",
        "./outputs/test/nfa/cons_tmp/instance_tmp"
        ]

try:
    for p in paths:
        os.makedirs(p,exist_ok=True)
except OSError:
    print ("Creation of the directory %s failed" % p)


class Context:
    def id(self, x):
        return x
    def seq(self, x, y):
        return [x, y]

def sort_trace(trace):
    return list(sorted(trace))

def tuple2str(sym):
    if str(sym.type)=="Function" and sym.name=="":
        args = "({})".format(",".join([tuple2str(s) for s in sym.arguments[1:]]))
        return "{}{}".format(str(sym.arguments[0]).strip('"'),"" if args=="()" else args)
    else:
        return str(sym).strip('"')
def parse_model(m):
    ret = []
    for sym in m.symbols(shown=True):
        if sym.name=="holds_map":
            ret.append((sym.arguments[0].number, '"{}"'.format(tuple2str(sym.arguments[1])) ))
        if str(sym) in ["empty","not_empty","error_branching","error_contradiction"]:
            ret.append(str(sym))
            
    return sort_trace(ret)

def solve(const=[], files=[],inline_data=[]):
    r = []
    imax  = 20
    ctl = clingo.Control(['0','--project']+const, message_limit=0)
    ctl.add("base", [], "")
    for f in files:
        ctl.load(f)
    for d in inline_data:
        ctl.add("base", [], d)
    ctl.add("base",[],"#show holds_map/2.")
    ctl.ground([("base", [])], context=Context())
    ctl.solve(on_model= lambda m: r.append(parse_model(m)))
    return sorted(r)

def translate(constraint,extra="",app='afw',horizon=3):
    cons_file = "dom/test/temporal_constraints/cons_tmp.lp"
    with open(cons_file, 'w') as f:
        f.write(constraint)
    command = 'make translate APP={} CONSTRAINT=cons_tmp DOM=test INSTANCE=dom/test/instances/instance_tmp.lp APP={} HORIZON={} {}'.format(app,app,horizon,extra) 
    # print(command)
    subprocess.check_output(command.split())


def empty_check(constraint,horizon=3,app="afw"):
    translate(constraint,app=app,horizon=horizon)

    automata_path = "outputs/test/{}/cons_tmp/instance_tmp/{}_automata.lp".format(app,app)
    paths = [automata_path, "encodings/empty.lp"]

    return solve(["--warn=none"],paths,[])

def run_check(constraint,trace="",horizon=3,app="afw",generate=False,extra_files=[],extra_args=""):
    translate(constraint,app=app,horizon=horizon,extra=extra_args)

    automata_path = "outputs/test/{}/cons_tmp/instance_tmp/{}_automata.lp".format(app,app)
    run_files = {
        "afw": ['./encodings/automata_run/run.lp',"./dom/test/glue.lp"],
        "dfa-mso": ['./encodings/automata_run/run.lp'],
        "dfa-stm": ['./encodings/automata_run/run.lp'],
        "nfa": ['./encodings/automata_run/run.lp'],
        "nfa-afw": ['./encodings/automata_run/run.lp',"./dom/test/glue.lp"],
        "telingo": []
    }
    paths = [automata_path]+run_files[app]+extra_files
    if generate:
        paths.append("./encodings/automata_run/trace_generator.lp")
    return solve(["-c horizon={}".format(horizon)],paths,[trace])

def comapre_apps(constraint,horizon=3,apps=[],test_instance=None):
    models = []
    for app in apps:
        models.append(run_check(constraint,horizon=horizon,app=app,generate=True))
    # print(apps)
    # print(models)
    test_instance.assertListEqual(models[0],models[1])
    for i in range(len(models)-1):
        # print("{} vs {}".format(apps[i],apps[i+1]))
        # print(models[i])
        # print(models[i+1])
        test_instance.assertListEqual(models[i],models[i+1])

class TestCase(unittest.TestCase):
    longMessage = True
    def assert_base(self,base_model,result):
        for r in result:
            for a in base_model:
                self.assertIn(a,r)

    def assert_all(self,expected_models,result):
        res = list(result for result,_ in itertools.groupby(result))
        expected_models = map(sort_trace, expected_models)
        self.assertCountEqual(expected_models,res)
    
    def assert_sat(self,result):
        self.assertGreater(len(result),0, "Is UNSAT")

    def assert_unsat(self,result):
        self.assertEqual(len(result),0, "Is NOT UNSAT. Found model: {}".format(result))

class TestMain(TestCase):


    def test_generation(self):
        self.maxDiff=None
        
        result = run_check(":- not &del{ ?q(1) ;; ?p ;; &t .>? p}.",horizon=1,generate=True)
        base_model = [(0,'"q(1)"'),(0,'"p"'),(1,'"p"'),(1,'"last"')]
        expected_models = [base_model, base_model+[(1,'"q(1)"')]]
        self.assert_all(expected_models,result)
        self.assert_base(base_model,result)


        result = run_check(":- not &del{ ?p ;; &t .>? ~ p}.",horizon=1,generate=True)
        expected_models = [[(0,'"p"'),(1,'"last"')]]
        self.assert_all(expected_models,result)


        result = run_check(":- not &del{ ?q(1) ;; ?p ;; &t .>? p}.",horizon=3,generate=True)
        base_model = [(0,'"q(1)"'),(0,'"p"'),(1,'"p"'),(3,'"last"')]
        self.assert_base(base_model,result)

        result = run_check(":- not &del{ * ( ?p ;; &t ) .>? ?q .>? ~ p}.",horizon=1,generate=True)
        expected_models = [[(1,'"last"'),(0,'"q"')],
                          [(1,'"last"'),(0,'"q"'),(1,'"q"')],
                          [(1,'"last"'),(0,'"q"'),(1,'"q"'),(1,'"p"')],
                          [(1,'"last"'),(0,'"q"'),(1,'"p"')],
                          [(1,'"last"'),(0,'"p"'),(0,'"q"'),(1,'"q"')],
                          [(1,'"last"'),(0,'"p"'),(1,'"q"')]]
        self.assert_all(expected_models,result)                   

        # UNSAT because horizon has to be in in time point 0
        result = run_check(":- not &del{ &t .>* &false}.",horizon=3,generate=True)
        self.assert_unsat(result)

        # UNSAT because horizon has to be in in time point 0
        result = run_check(":- not &del{ &t .>* &false}.",horizon=2,generate=True)
        self.assert_unsat(result)

        result = run_check(":- not &del{ &t .>* &false}.",horizon=0,generate=True)
        expected_models = [[(0,'"last"')]]
        self.assert_all(expected_models,result)
        
    def test_check(self):
        self.maxDiff=None

        ######### Examples using simple env starting actions in timepoint 0.

        # Boolean constats

        result = run_check(":- not &del{ &true }.",trace="p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":- not &del{ &true }.",trace="",horizon=2)
        self.assert_sat(result)

        result = run_check(":- not &del{ &true }.",trace="",horizon=0)
        self.assert_sat(result)

        result = run_check(":- not &del{ &false }.",trace="p(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":- not &del{ &false }.",trace="",horizon=2)
        self.assert_unsat(result)

        result = run_check(":- not &del{ &false }.",trace="",horizon=0)
        self.assert_unsat(result)


        # Atoms

        result = run_check(":- not &del{ p }.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":- not &del{ p }.",trace="p(1).",horizon=2)
        self.assert_unsat(result)

        # Step (Diamond)
        result = run_check(":- not &del{ &t .>? p}.",trace="p(1).",horizon=2)
        self.assert_sat(result)
        
        result = run_check(":-not &del{ &t .>? p}.",trace="",horizon=2)
        self.assert_unsat(result)   
        
        result = run_check(":-not &del{ &t .>? p}.",trace="",horizon=0)
        self.assert_unsat(result)   

        result = run_check(":-not &del{ &t .>? p}.",trace="p(1).",horizon=2)
        self.assert_sat(result)
        
        # Step (Box)
        result = run_check(":-not &del{ &t .>* p}.",trace="",horizon=2)
        self.assert_unsat(result)   
        
        result = run_check(":-not &del{ &t .>* p}.",trace="p(1).",horizon=2)
        self.assert_all([[(2,'"last"'),(1,'"p"')]],result)   
        
        result = run_check(":-not &del{ &t .>* p}.",trace="q(2).",horizon=2)
        self.assert_unsat(result)   

        result = run_check(":-not &del{ &t .>* p}.",trace="",horizon=0)
        self.assert_all([[(0,'"last"')]],result)
        self.assert_sat(result)   
        

        # Test construct (Diamond)
        
        result = run_check(":-not &del{ ?q .>? p}.",trace="q(0). p(0).",horizon=2)
        self.assert_all([[(2,'"last"'),(0,'"q"'),(0,'"p"')]],result)

        result = run_check(":-not &del{ ?q .>? p}.",trace="",horizon=2)
        self.assert_unsat(result)

        #TODO add tests for test on negation
        
        # Test construct (Box)

        result = run_check(":-not &del{ ?q .>* p}.",trace="",horizon=2)
        self.assert_all([[(2,'"last"')]],result)     

        result = run_check(":-not &del{ ?q .>* p}.",trace="q(2).",horizon=2)
        self.assert_all([[(2,'"last"'),(2,'"q"')]],result)     


        # Sequence (Diamond)

        result = run_check(":-not &del{ ?q ;; &t .>? p}.",trace="q(0). p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>? &true}.",trace="q(0). p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>? &true}.",trace="q(0).",horizon=2)
        self.assert_unsat(result)

        # Sequence (Box)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="q(0). p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>* &true}.",trace="q(0). p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>* &true}.",trace="q(0).",horizon=2)
        self.assert_sat(result)

        # Choice (Diamond)

        result = run_check(":-not &del{ ?q + &t .>? p}.",trace="q(0). p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>? p}.",trace="p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).q(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="",horizon=2)
        self.assert_unsat(result)


        # Choice (Box)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="q(0). p(0).",horizon=0)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="",horizon=0)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).q(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="",horizon=2)
        self.assert_sat(result)

        # Star (Diamond)
        
        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(0).",horizon=0)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="",horizon=0)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).q(1).p(2).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).q(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q) .>? p}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        # Star (Box)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(0).",horizon=0)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="",horizon=0)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).p(1).p(0).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).p(2).p(0).p(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).p(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q) .>* p}.",trace="p(0).",horizon=2)
        self.assert_sat(result)

    def test_check_telingo(self):
        self.maxDiff=None

        ######### Examples using simple env starting actions in timepoint 0.

        # Boolean constats

        result = run_check(":- not &del{ &true }.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":- not &del{ &true }.",trace="",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":- not &del{ &true }.",trace="",horizon=0,app="telingo")
        self.assert_sat(result)

        result = run_check(":- not &del{ &false }.",trace="p(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":- not &del{ &false }.",trace="",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":- not &del{ &false }.",trace="",horizon=0,app="telingo")
        self.assert_unsat(result)


        # Atoms

        result = run_check(":- not &del{ p }.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":- not &del{ p }.",trace="p(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        # Step (Diamond)
        result = run_check(":- not &del{ &t .>? p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)
        
        result = run_check(":-not &del{ &t .>? p}.",trace="",horizon=2,app="telingo")
        self.assert_unsat(result)   
        
        result = run_check(":-not &del{ &t .>? p}.",trace="",horizon=0,app="telingo")
        self.assert_unsat(result)   

        result = run_check(":-not &del{ &t .>? p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)
        
        # Step (Box)
        result = run_check(":-not &del{ &t .>* p}.",trace="",horizon=2,app="telingo")
        self.assert_unsat(result)   
        
        result = run_check(":-not &del{ &t .>* p}.",trace="p(1).",horizon=2,app="telingo")
        ## self.assert_all([[(1,'"p"')]],result)   
        
        result = run_check(":-not &del{ &t .>* p}.",trace="q(2).",horizon=2,app="telingo")
        self.assert_unsat(result)   

        result = run_check(":-not &del{ &t .>* p}.",trace="",horizon=0,app="telingo")
        #self.assert_all([[(0,'"last"')]],result)
        self.assert_sat(result)   
        

        # Test construct (Diamond)
        
        result = run_check(":-not &del{ ?q .>? p}.",trace="q(0). p(0).",horizon=2,app="telingo")
        ## self.assert_all([[(0,'"q"'),(0,'"p"')]],result)

        result = run_check(":-not &del{ ?q .>? p}.",trace="",horizon=2,app="telingo")
        self.assert_unsat(result)

        #TODO add tests for test on negation
        
        # Test construct (Box)

        result = run_check(":-not &del{ ?q .>* p}.",trace="",horizon=2,app="telingo")
        #self.assert_all([[(2,'"last"')]],result)     

        result = run_check(":-not &del{ ?q .>* p}.",trace="q(2).",horizon=2,app="telingo")
        ## self.assert_all([[(2,'"q"')]],result)     


        # Sequence (Diamond)

        result = run_check(":-not &del{ ?q ;; &t .>? p}.",trace="q(0). p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>? &true}.",trace="q(0). p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>? &true}.",trace="q(0).",horizon=2,app="telingo")
        self.assert_unsat(result)

        # Sequence (Box)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="q(0). p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; &t .>* p}.",trace="",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>* &true}.",trace="q(0). p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q ;; ?p .>* &true}.",trace="q(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        # Choice (Diamond)

        result = run_check(":-not &del{ ?q + &t .>? p}.",trace="q(0). p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>? p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="p(0).q(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>? &true}.",trace="",horizon=2,app="telingo")
        self.assert_unsat(result)


        # Choice (Box)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="q(0). p(0).",horizon=0,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + &t .>* p}.",trace="",horizon=0,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="p(0).q(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ ?q + ?p .>* &true}.",trace="",horizon=2,app="telingo")
        self.assert_sat(result)

        # Star (Diamond)
        
        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(0).",horizon=0,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="",horizon=0,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).q(1).p(2).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>? p}.",trace="q(0).q(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q) .>? p}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        # Star (Box)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(0).",horizon=0,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="",horizon=0,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="p(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).p(1).p(0).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).p(2).p(0).p(1).",horizon=2,app="telingo")
        self.assert_sat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q ;; &t) .>* p}.",trace="q(0).q(1).p(1).",horizon=2,app="telingo")
        self.assert_unsat(result)

        result = run_check(":-not &del{ * (?q) .>* p}.",trace="p(0).",horizon=2,app="telingo")
        self.assert_sat(result)


    
    def test_asprilo(self):

        ######### Examples using asprilo env starting actions in timepoint 1.
        
    
        result = run_check(":- not &del{ &t .>? move(robot(1),(1,0))}.",trace="move(robot(1),(1,0),1).",horizon=2,extra_files=["dom/asprilo-md/glue.lp"])
        self.assert_sat(result)

        result = run_check(":- not &del{ &t .>? move(robot(1),(1,0))}.",trace="move(robot(1),(1,0),2).",horizon=3,extra_files=["dom/asprilo-md/glue.lp"])
        self.assert_unsat(result)

    def test_multiple(self):
        self.maxDiff=None

        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="p(1).q(1).",horizon=2)
        self.assert_sat(result)

        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="q(1).",horizon=2)
        self.assert_unsat(result)

        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="p(1).",horizon=2)
        self.assert_unsat(result)

        #Test with join 
        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="p(1).q(1).",horizon=2,extra_args="JOIN=1")
        self.assert_sat(result)

        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="q(1).",horizon=2,extra_args="JOIN=1")
        self.assert_unsat(result)

        result = run_check(":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",trace="p(1).",horizon=2,extra_args="JOIN=1")
        self.assert_unsat(result)

    def test_special(self):
        self.maxDiff=None

        # Star (Box) with need for nnf

        result = run_check(":-not &del{ (? ((* &t) .>* q)) .>* p}.",trace="",horizon=2)
        self.assert_sat(result)
        result = run_check(":-not &del{ (? ((* &t) .>* q)) .>* p}.",trace="q(0).q(1).",horizon=2)
        self.assert_sat(result)
        result = run_check(":-not &del{ (? ((* &t) .>* q)) .>* p}.",trace="q(0).q(1).q(2).",horizon=2)
        self.assert_unsat(result)
        result = run_check(":-not &del{ (? ((* &t) .>* q)) .>* p}.",trace="q(0).q(1).q(2).p(0).",horizon=2)
        self.assert_sat(result)


    def test_ldlf(self):
        formulas = LDLfFormula.from_lp(inline_data= ":- not &del{&t .>? b}.")
        self.assertEqual(formulas[0]._rep,"<(&t)>b")
        formulas = LDLfFormula.from_lp(inline_data= ":- not &del{ ?a ;; * (? a + ?b ;; &t) .>? b}.")
        self.assertEqual(formulas[0]._rep,"<a?;;(a?+b?;;(&t))*>b")
        formulas = LDLfFormula.from_lp(inline_data= ":- not &del{ ?a(X) .>* &true}, p(X). p(1). p(2).")
        self.assertEqual(len(formulas),2)
        self.assertEqual(formulas[0]._rep,"[a(1)?] &true ")
        self.assertEqual(formulas[1]._rep,"[a(2)?] &true ")


    def test_translation(self):

        constraints = [
            ":- not &del{ &true }.",
            ":- not &del{ &false }.",
            # Atoms
            ":- not &del{ p }.",
            # Step (Diamond)
            ":-not &del{ &t .>? p}.",
            # Step (Box)
            ":-not &del{ &t .>* p}.",
            # Test construct (Diamond)
            ":-not &del{ ?q .>? p}.",
            # Test construct (Box)
            ":-not &del{ ?q .>* p}.",
            # Sequence (Diamond)
            ":-not &del{ ?q ;; &t .>? p}.",
            ":-not &del{ ?q ;; ?p .>? &true}.",
            # Sequence (Box)
            ":-not &del{ ?q ;; &t .>* p}.",
            ":-not &del{ ?q ;; ?p .>* &true}.",
            # Choice (Diamond)
            ":-not &del{ ?q + &t .>? p}.",
            ":-not &del{ ?q + ?p .>? &true}.",
            # Choice (Box)
            ":-not &del{ ?q + &t .>* p}.",
            ":-not &del{ ?q + ?p .>* &true}.",
            # Star (Diamond)
            ":-not &del{ * (?q ;; &t) .>? p}.",
            ":-not &del{  * (?q) .>? ?p .>? &t .>? q}.",
            # Star (Box)
            ":-not &del{ * (&t) .>* p}.",
            ":-not &del{ * (?q) .>* p}.",
            ":-not &del{ * (?q ;; &t) .>* p}.",
            ":-not &del{ * (?q) .>* ?p .>? &t .>? q}.",
            # Star (Box)
            ":-not &del{ ?q .>? &t .>* &false}.",
            # Until
            ":- not &del{ *(? a;; &t) .>? b}.",
            # Complex
            ":- not &del{ *( (? a;; &t) + (? a;; &t ;; ? c;; &t)) .>? b}.",
            # Multiple
            ":- not &del{ &t .>? p }. :- not &del{ &t .>? q }.",
            #Negation
            ":-not &del{ * &t  .>* ? ~p .>* ~q}."
        ]
        for cons in constraints:
            for h in range(1,4):
                # print("Testing {} with h = {}".format(cons,h))
                comapre_apps(cons,h,apps=['afw','dfa-mso','dfa-stm','nfa','nfa-afw'],test_instance=self)
                # comapre_apps(cons,h,apps=['afw','dfa-mso','dfa-stm','nfa','nfa-afw'],test_instance=self)

    def test_closure(self):
        formula = LDLfFormula.from_lp(inline_data= ":-not &del{ * ((?p + ?q) ;; &t)  .>* ?r .>? &true}.")[0]
        # formula = LDLfFormula.from_lp(inline_data= ":-not &del{ * (?q) .>* ?p .>? &true .>? q}.")[0]
        s = set([])
        formula.closure(s)
        closure = [c._rep.replace(" ","") for c in s]
        assert "p" in closure
        assert "[(&t)][(p?+q?;;(&t))*]<r?>&true" in closure
        assert "[p?+q?;;(&t)][(p?+q?;;(&t))*]<r?>&true" in closure
        assert "[p?+q?][(&t)][(p?+q?;;(&t))*]<r?>&true" in closure
        assert "[p?][(&t)][(p?+q?;;(&t))*]<r?>&true" in closure
        assert "[q?][(&t)][(p?+q?;;(&t))*]<r?>&true" in closure
        assert "r" in closure
        assert "<r?>&true" in closure
        assert "&true" in closure
        assert "q" in closure
        assert "[(p?+q?;;(&t))*]<r?>&true" in closure

        

    def test_error(self):
        a = """
        :- not &del{(* ( ( ? p ) ;; &t ))  .>?  ( (* &t ) .>* q )}.
        :- not &del{(* ( ( ? r ) ;; &t ))  .>?  ( (* &t ) .>* s )}.
        """
        constraints = [
            a
        ]
        for cons in constraints:
            # print("Testing {} with h = {}".format(cons,1))
            comapre_apps(cons,3,apps=['afw','dfa-mso'],test_instance=self)

    def test_dir(self):

        a = """
        :- not &del{ * &t .>* 
            ?p ;; &t .>*  
               *( ? ~ q;; &t) .>? 
               (?a + ?b + ?c) 
               .>? &true
            }.
            """

        result = run_check(a,trace="",horizon=3,generate=True)

    

    def test_empty(self):

        a = ":- not &del{ ?((* &t) .>* &t .>? b) .>? a }."
        result = empty_check(a,horizon=3,app="dfa-mso")[0]
        assert "empty" in result

        a = ":- not &del{ ?((* &t) .>* &t .>? b) .>? a }."
        result = empty_check(a,horizon=3,app="dfa-stm")[0]
        assert "empty" in result

        a = ":- not &del{ ?((* &t) .>* &t .>? b) .>? a }."
        result = empty_check(a,horizon=3,app="nfa")[0]
        assert "empty" in result

        a = ":- not &del{ ?((* &t) .>* &t .>? b) .>? a }."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "error_branching" in result

        a = ":- not &del{ ?a .>? &false}."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "empty" in result


        a = ":- not &del{ ? ((* &t) .>* b) +  ? (&t .>? a) .>? &true }."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "not_empty" in result

        a = ":- not &del{ ? ((* &t) .>* b) +  ? (&t .>? a) .>? &true }."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "not_empty" in result

        a = ":- not &del{ ? ((* &t) .>* b) +  ? (&t .>? a) .>? &true }."
        result = empty_check(a,horizon=3,app="nfa")[0]
        assert "not_empty" in result

        a = ":- not &del{ ? ((* &t) .>* b) +  ? (&t .>? a) .>? &true }."
        result = empty_check(a,horizon=3,app="dfa-mso")[0]
        assert "not_empty" in result


        a = ":- not &del{ (* &t) .>* ?a ;; ? ~a .>? &true }."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "empty" in result

        a = ":- not &del{ (* &t) .>* ?a ;; ? ~a .>? &true }."
        result = empty_check(a,horizon=3,app="nfa")[0]
        assert "empty" in result

        a = ":- not &del{ (* &t) .>* ?a + ? ~a .>? &true }."
        result = empty_check(a,horizon=3,app="afw")[0]
        assert "not_empty" in result

        a = ":- not &del{ (* &t) .>* ?a + ? ~a .>? &true }."
        result = empty_check(a,horizon=3,app="nfa")[0]
        assert "not_empty" in result