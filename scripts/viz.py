#!/usr/bin/python
# -*- coding: utf-8 -*- 
import argparse
import copy
import os
import sys
import networkx as nx
import pygraphviz as pgv        
import clingo
import itertools
import pdb
import subprocess
from pystructures.automata import AFW, NFA
from pystructures.ldlf import LDLfFormula
parser = argparse.ArgumentParser(description='Viz automata')

parser.add_argument('--constraint', help='Constaint name',required=True)
parser.add_argument('--dom', help='Env app: atlingo, test, elevator...',required=True)
parser.add_argument('--app', help='App: afw, dfa, nfa, nfa-afw',required=True)
parser.add_argument('--instance', help='Instance name',required=True)
parser.add_argument('--instance_path', help='Instance path',required=True)
parser.add_argument('--labels', action='store_const', const=True)
parser.add_argument('--latex', action='store_const', const=True)

args = parser.parse_args()
constraint=args.constraint
dom=args.dom
app=args.app
instance=args.instance
instance_path=args.instance_path
labels= args.labels
latex= args.latex


command = 'make translate APP=afw CONSTRAINT={} DOM={} INSTANCE={}'.format(constraint,dom,instance_path) 
print(command)
# subprocess.check_output(command.split())
constraint_path = "dom/{}/temporal_constraints/{}.lp".format(dom,constraint)

automata_path = "outputs/{}/{}/{}/{}/{}_automata.lp".format(dom, app,constraint,instance,app)

afw_automata_path = "outputs/{}/afw/{}/{}/afw_automata.lp".format(dom,constraint,instance)

if app=="afw":
    afw = AFW.from_lp(files = [afw_automata_path])
    automaton = afw
elif app in ["dfa-mso","dfa-stm"]:
    ldlfformulas = LDLfFormula.from_lp(files=[constraint_path],inline_data="")
    # Use translater insted
    conj_formula = LDLfFormula.join_formulas(ldlfformulas)
    automaton = conj_formula.dfa(translation=args.app.split('-')[1])
elif app=="nfa":
    afw = AFW.from_lp(files = [afw_automata_path])
    automaton = afw.to_nfa()
elif app=="nfa-afw":
    automaton = NFA.from_lp(files = [automata_path])
else:
    raise RuntimeError("Invalid approach")
png_path = "outputs/{}/{}/{}/{}/{}_automata".format(dom, app,constraint,instance,app)

automaton.save_png(file=png_path,labels=labels,latex=latex)
if(latex):
    automaton.to_tex(file=png_path+".tex",labels=labels)
            