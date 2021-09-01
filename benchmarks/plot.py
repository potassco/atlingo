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
import re
import tikzplotlib

import argparse

# ------ Clean ods
def clean_df(df):
    
    all_stats = set(df.iloc[0][:])
    all_stats.remove('')
    all_stats=list(all_stats)
    n_all_stats = len(all_stats)
    #Drop min max median
    df.drop(df.columns[-3*n_all_stats:], axis=1, inplace=True) 
    
    #Rename columns
    all_constraints = df.columns[1:]
    all_constraints = [c.split("/")[-1] for i,c in enumerate(all_constraints) if i%n_all_stats==0]
    all_stats = df.iloc[0][1:n_all_stats+1]

    new_cols = ["{}--{}".format(c,p) for c,p in list(itertools.product(all_constraints, all_stats))]
    new_cols = ["instance-name"] + new_cols
    df.drop(df.index[0], inplace=True) #Remove unused out values
    df.drop(df.tail(9).index,inplace=True) #Remove last computed values
    df.columns = new_cols
    if args.constraint is None:
        constraints = all_constraints
    else:
        constraints = args.constraint

    required_colums = ["instance-name"] + [f"{c}--{s}" for c in constraints for s in stats]

    df = df.loc[:,df.columns.intersection(required_colums)]
    # Convert all to floats
    for i in range(1,len(df.columns)):
        df.iloc[:,i] = pd.to_numeric(df.iloc[:,i], downcast="float")

    
    ###### Handle rows (INSTANCES)
    
    #Choose selected instances
    all_instances = df['instance-name']
    if single_instance:
        instances_to_drop = [i for i,c in enumerate(all_instances) if c.find(instance)==-1 ]
        df.drop(df.index[instances_to_drop], inplace=True)
    else:
        instances_to_drop = [i for i,c in enumerate(all_instances) if any([ c.find(i)==0 for i in ignore_prefix])]
        df.drop(df.index[instances_to_drop], inplace=True)
        instances_to_drop = [i for i,c in enumerate(all_instances) if any([ c.find(i)!=-1 for i in ignore_any])]
        df.drop(df.index[instances_to_drop], inplace=True)

    #Rename
    def rename(i):
        return i.split("/")[1].split("_")[3]
    # def rename(i):
    #     return i.split("/")[1].split("_")[0]
    # def rename(i):
    #     return i[:-3]
    df['instance-name']=df['instance-name'].apply(rename)

    # print(df)
    return df


# ------- Aux for tex output
def csv2textable(df,cons,ins,approaches,use_gmean,spetial_words,base_headers = [""],use_lambda=True,models=0,caption=None,limitter='stats'):
    n_base_headers = len(base_headers)
    non_mc_approaches = [x for x in approaches if x!='nc']
    used_words = {}
    formats={
        'stats':'textbf',
        'ins':'texttt',
        'cons':'texttt'
    }
    def f_tex(x):
        if isinstance(x, np.floating):
            if np.isnan(x):
                return "\\color{red}{-}"
            return str(f'{int(x):,}')
        if x in spetial_words:
            to_ret =""
            word_type = spetial_words[x]
            if  word_type in used_words:
                if used_words[word_type]!=x:
                    to_ret= f'\\{formats[word_type]}'+'{' +x+ '}'
                    if word_type==limitter:
                        to_ret = '\\hline' + to_ret
            else:
                to_ret= f'\\{formats[word_type]}'+'{' +x+ '}'
                if word_type==limitter:
                        to_ret = '\\hline' + to_ret
            used_words[word_type]=x

            return to_ret
        if type(x) is str and x[-1]== '~':
            return '\\sout{'+x[:-1]+'}'
        if type(x) is str and x[-1]== '*':
            val = str(f'{int(x[:-1]):,}')
            return "\\textbf{"+val+"}"
        if type(x) is int:
            return str(f'{x:,}')
        if x == "NaN":
            return "\\color{red}{-}"
        return str(f'{int(x):,}')

    cons_name = "\\texttt{"+cons.replace('_',' ')+"}"
    ins_name = "\\texttt{"+ins.replace('_',' ')+"}"
    app_names =  df.columns[n_base_headers:] if use_gmean else df.columns[n_base_headers+1:]
    if use_lambda:
        approaches_map = {
            "afw":"\\WFA",
            "dfa-mso":"\\WFMm",
            "dfa-stm":"\\WFMs",
            "telingo":"\\WFT",
            "nc":"\\WFNC"
        }
        headers = base_headers+["$\\lambda$"]  + ["$"+approaches_map[str(c)]+"$" for c in app_names]
    else:
        headers = base_headers+["","H"]  + ["\\textbf{"+str(c)+"}" for c in app_names]

    if use_gmean:
        headers=headers[0:n_base_headers]+headers[n_base_headers+1:]
    
    models_str = f"getting {'one model' if models==1 else 'all_models'}"
    column_format = f'|{"l"*n_base_headers}{"" if use_gmean else "l"}|{"r"*len(non_mc_approaches)}{"|r" if "nc" in approaches else ""}|'
    if caption is None:
        caption = f"Statistics for constraint {cons_name} and instance {ins_name} {models_str}. Crossed out lambdas are those for which the instance was UNSAT with the constraint. Best performance excluding NC (No Constraint) is found in bold."
    tex_table = df.to_latex(
        index=False,
        caption=caption,
        formatters=[f_tex]*len(df.columns), 
        escape=False, 
        header=headers,
        label=f"tbl:eval:{cons}:{ins}",
        column_format=column_format,
        na_rep="\\color{red}{-}")
    return tex_table

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Plot obs files from benchmark tool',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--stat", type=str, action='append',
            help="Status: choices,conflicts,cons,csolve,ctime,error,mem,memout,models,ngadded,optimal,restarts,status,time,timeout,vars,ptime" )
    parser.add_argument("--approach", type=str, action='append',
            help="Approach to be plotted awf, asp, nc or dfa. Can pass multiple",required=True)
    parser.add_argument("--dom",type=str, default='asprilo',
            help="Name of domain" )
    parser.add_argument("--constraint", type=str, action='append',
            help="Contraint to be plotted, if non is passed all constraints will be plotted. Can pass multiple")
    parser.add_argument("--horizon", type=int, action='append',
            help="Horizon to be plotted. Can pass multiple",required=True)
    parser.add_argument("--models", type=int, default=1,
            help="Number of models computed in the benchmark with clingo -n" )
    parser.add_argument("--prefix", type=str, default="",
            help="Prefix for output files" )
    parser.add_argument("--csv", default=False, action='store_true',
        help="When this flag is passed, the table is also saved in csv format")
    parser.add_argument("--plotmodels", default=False, action='store_true',
        help="When this flag is passed, the number of models in plotted")
    parser.add_argument("--use-lambda", default=False, action='store_true',
        help="When this flag is passed, horizons are transform to lambda with +1")
    parser.add_argument("--use-gmean", default=False, action='store_true',
        help="When this flag is passed, computes gmean of all horizons")
    parser.add_argument("--type", type=str, default="bar",
            help="Bar or table" )
    parser.add_argument("--instance", type=str, default=None,
            help="The name of a single instance" )
    parser.add_argument("--ignore_prefix",type=str, action='append',
            help="Prefix to ignore in the instances" )
    parser.add_argument("--ignore_any",type=str, action='append',
            help="Any to ignore in the instances" )
    parser.add_argument("--y", type=str, default=None,
            help="Name for the y axis" )
    parser.add_argument("--x", type=str, default="Horizon",
            help="Name for the x axis" )
    args = parser.parse_args()

    #PARAMS
    # handle_timeout = not args.ignore_timeout
    # zero_timeout = args.zero_timeout

    # Env
    dom = args.dom

    # Approaches
    approaches = args.approach
    n_approaches = len(args.approach)
    approaches.sort()
    if "nc" in approaches:
        approaches.remove("nc")
        approaches.append("nc")

    # Horizon
    horizons = args.horizon
    horizons.sort()
    h2idx = {h:i for i,h in enumerate(horizons)}
    use_lambda = args.use_lambda
    use_gmean = args.use_gmean

    models = args.models

    # Statistics
    stats = args.stat + ["status"]
    constraints = args.constraint

    prefix = args.prefix
    # plot_n_models = args.plotmodels

    # Instances
    single_instance = False
    if args.instance:
        single_instance = True
        instance = args.instance
    else:
        ignore_prefix = [] if args.ignore_prefix is None else args.ignore_prefix
        ignore_any = [] if args.ignore_any is None else args.ignore_any

    summary = f"""
    PLOT
        DOM: {dom}
        APPROACHES: {approaches}
        HORIZONS : {horizons}
        STATS: {stats}
        CONSTRAINTS: {"ALL" if constraints is None else constraints}
    """

    if single_instance:
        summary +=f"    ONLY INSTANCE: {instance}\n"
    else:
        summary +=f"    IGNORE INSTANCE: {ignore_any} {ignore_prefix}\n"

    print(summary)


    # -------- Read DFS
    dfs = {}
    last_df = None
    for a in approaches:
        for h in horizons:
            path = f"results/{dom}/{a}__h-{h}__n-{models}/{a}__h-{h}__n-{models}.ods"
            try:
                print(f"Reading path {path}")
                df = read_ods(path,1)
                df = clean_df(df)
                dfs.setdefault(a,{})[h]=df

                last_df = df
            except e:
                print("Error reading file {}".format(path))

                sys.exit(1)


    # -------- Reorder dfs

    fin_colums = last_df.columns
    constraints = list(set([s.split('--')[0] for s in fin_colums[1:]]))
    constraints.sort()
    stats = list(set([s.split('--')[1] for s in fin_colums[1:]]))
    stats.sort()
    instances = last_df['instance-name']
    dfs_per_cons = {}
    for cons in constraints:
        for instance in instances:
            rows = []
            for s in stats:

                for h in horizons:
                    if use_lambda:
                        row = [s,h+1]
                    else:
                        row = [s,h]
                    for a in approaches:
                        current_df = dfs[a][h]
                        current_row = current_df.loc[df['instance-name'] == instance]
                        current_col = f'{cons}--{s}'
                        row.append(current_row[current_col].item())

                    rows.append(row)
            df_row = pd.DataFrame(rows, columns=["Stat","Horizon"]+approaches)
            
            #Edit horizon if unsat
            df_stat = df_row.loc[df_row['Stat'] == 'status']
            unsat_horizons = df_stat[df_stat[df_stat.columns[2]]==0]['Horizon'].tolist()
            df_row['Horizon'] = np.where(df_row['Horizon'].isin(unsat_horizons),df_row['Horizon'].astype(str)+"~",df_row['Horizon'])

            df_row = df_row[df_row['Stat'] != "status"]

            #times to milli seconds
            is_time = df_row["Stat"].str.contains('time', regex=False)
            df_row.loc[is_time,approaches]=df_row.loc[is_time,approaches]*1000

            dfs_per_cons.setdefault(cons,{})[instance]= df_row


    if args.type == "table":
        # -------- Save CVS
        for cons, v in dfs_per_cons.items():
            for ins, df in v.items():
                file_name_csv = f'plots/tables/{dom}/{prefix}-{cons}-{ins}.csv'
                file_name_tex_csv = file_name_csv[:-3]+"tex"
                dir_name = os.path.dirname(file_name_csv)
                if not os.path.exists(dir_name): os.makedirs(dir_name)
                
                # Compute gmean
                if use_gmean:
                    mx_gmeans = []
                    for s in [y for y in stats if y!='status']:
                        df_s = df[df['Stat']==s]
                        gmeans = []
                        for app in approaches:
                            arr_app = df_s[app].to_numpy()
                            arr_app = [arr_app[~np.isnan(arr_app)]]
                            gmean = list(scipy.stats.gmean(arr_app,axis=1))
                            if len(gmean)==0:
                                gmean= [np.NaN]
                            gmeans.append(gmean[0])
                        row_list=[s]+gmeans
                        mx_gmeans.append(row_list)
                    df = pd.DataFrame(mx_gmeans, columns=["Stat"]+approaches)

                # Add mark to minimum value
                non_mc_approaches = [x for x in approaches if x!='nc']
                mins = df[non_mc_approaches].min(axis=1)
                min_mx=df[non_mc_approaches].astype(float).eq(mins,axis=0)
                for c in min_mx.columns:
                    for row in df.index:
                        str_value = "NaN" if math.isnan(df.loc[row,c]) else str(int(df.loc[row,c]))
                        # str_value = "\\color{red}{-}" if math.isnan(df.loc[row,c]) else str(f'{int(df.loc[row,c]):,}')
                        df.loc[row,c]= str_value+"*" if min_mx.loc[row,c] else str_value
                if args.csv:
                    df.to_csv(file_name_csv,float_format='%.0f',index=False)

                tex_table = csv2textable(df,cons,ins,approaches,use_gmean,spetial_words={s:'stats' for s in stats},use_lambda=use_lambda,models=models)

                f = open(file_name_tex_csv, "w")
                f.write(tex_table)
                f.close()
                print("Saved {}".format(file_name_csv))
                print("Saved {}".format(file_name_tex_csv))

    elif args.type == "bar":
        approaches_colors = {
            "nc":"#C8F69B",
            "afw":"#FFB1AF",
            "dfa-mso":"#D6D4FF",
            "dfa-stm":"#B3EEFF",
            "nfa":"#FFCBA5",
            "nfa-afw":"#FFE2A5",
            "telingo":"#FFEEA5"
        }
        colors = [approaches_colors[a] for a in approaches]
        # -------- Plot
        for cons, v in dfs_per_cons.items():
            for ins, df in v.items():
                file_name_img = f'plots/img/{dom}/{prefix}-{cons}-{ins}.png'
                dir_name = os.path.dirname(file_name_img)
                if not os.path.exists(dir_name): os.makedirs(dir_name)
                plotting_stats = [s for s in stats if s !="status"]
                for i, s in enumerate(plotting_stats):
                    stats_row = df.loc[df['Stat'] == s]
                    stats_row.plot(x="Horizon", y=approaches, kind="bar", color=colors)
                    # stats_row.plot(x="Horizon", y=approaches, kind="bar", colormap="Set3")

                plt.title(f"{cons} ({ins})",  fontsize=12, fontweight=0)
                plt.xlabel(args.x)
                plt.xticks(rotation='horizontal')
                plt.ylabel(args.y)
                plt.ylim(bottom=0)

                        
                plt.savefig(file_name_img,dpi=300,bbox_inches='tight')
                print("Saved {}".format(file_name_img))
                plt.clf()
            