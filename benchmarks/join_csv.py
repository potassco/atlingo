#!/usr/bin/env python
# libraries and data
import os
import math
import sys
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import itertools
import seaborn as sns
from pandas_ods_reader import read_ods
import scipy
from scipy import stats

import tikzplotlib

import argparse
from plot import csv2textable

parser = argparse.ArgumentParser(description='Join csv  files ',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("--dom",type=str, default='asprilo',
        help="Name of domain" )
parser.add_argument("--constraint", type=str, action='append',
        help="Contraint to be plotted, if non is passed all constraints will be plotted. Can pass multiple")
parser.add_argument("--prefix-in", type=str, default="",
        help="Prefix for input files" )
parser.add_argument("--prefix", type=str, default="",
        help="Prefix for output files" )
parser.add_argument("--use-lambda", default=False, action='store_true',
    help="When this flag is passed, horizons are transform to lambda with +1")
parser.add_argument("--use-gmean", default=False, action='store_true',
    help="When this flag is passed, computes gmean of all horizons")
parser.add_argument("--instance",type=str, action='append',
        help="The name of a single instance" )
args = parser.parse_args()

#PARAMS
# handle_timeout = not args.ignore_timeout
# zero_timeout = args.zero_timeout

# Env
dom = args.dom

use_lambda = args.use_lambda
# use_gmean = args.use_gmean

# Statistics
constraints = args.constraint

prefix_in = args.prefix_in
prefix = args.prefix
# plot_n_models = args.plotmodels

# Instances
instances = args.instance


summary = f"""
JOIN CSV
    DOM: {dom}
    CONSTRAINTS: {constraints}
"""
print(summary)

dfs = []
for cons in constraints:
    for ins in instances:
        file = f'plots/tables/{dom}/{prefix_in}-{cons}-{ins}.csv'
        df = pd.read_csv(file)
        df["ins"]=ins
        df["cons"]=cons
        dfs.append(df)
df = pd.concat(dfs,ignore_index=True)
main_cols = ["Stat","cons","ins"] 
stats = df['Stat'].unique()
approaches = [c for c in df.columns if c not in main_cols]
cols = main_cols+approaches
df = df[cols]
df = df.sort_values(by=['Stat','cons','ins'])
spetial_words={s:'stats' for s in stats}
spetial_words.update({i:'ins' for i in instances})
spetial_words.update({c:'cons' for c in constraints})
tex_table = csv2textable(df,"All","All",approaches,True,
    spetial_words=spetial_words,
    base_headers=["\\textbf{Stat}","\\textbf{cons}","\\textbf{ins}"],
    caption="Statistics with the geometric mean of all horizons.")

file_name_csv = f'plots/tables/{dom}/{prefix}.csv'
file_name_tex_csv = file_name_csv[:-3]+"tex"

f = open(file_name_tex_csv, "w")
f.write(tex_table)
f.close()
print("Saved {}".format(file_name_tex_csv))