#!/usr/bin/env python
# libraries and data
import sys
import pandas as pd
import os
import clingo
import argparse
parser = argparse.ArgumentParser(description='Get automata sizes',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("--plot_type", type=str, default='bar',
        help="Plot type, bar or line" )
parser.add_argument("--approach", type=str, action='append',
        help="Approach to be plotted awf, asp, nc or dfa. Can pass multiple")
parser.add_argument("--constraint", type=str, action='append',
        help="Contraint to be plotted, if non is passed all constraints will be plotted. Can pass multiple")
parser.add_argument("--dom",type=str, default='asprilo-abc',
        help="Name of domain, asprilo or elevator" )
args = parser.parse_args()

#PARAMS
approaches = args.approach
constraints = args.constraint
dom = args.dom



directory= "../outputs"
# itrate over files in
# that directory
results = {}
def save(dom,app,cons,instance,model):
    sizes = {}
    for s in model.symbols(shown=True):
        sizes[str(s.arguments[0])]=s.arguments[1].number

    name= f"{dom}/{cons}/{instance}"
    results.setdefault(name,{})
    results[name][app]= sizes

for root, dirs, files in os.walk(directory):
    split_root = root.split("/")
    if len(split_root)!=6:
        continue
    dom = split_root[2]
    app = split_root[3]
    cons = split_root[4]
    instance = split_root[5]
    automata_file_name =f"{app}_automata.lp"
    if not automata_file_name in files:
        print(f"No automata file for {root}")
        continue
    if app=="telingo":
        continue
    file_path = os.path.join(root, automata_file_name)
    ctl = clingo.Control([0])
    ctl.load(file_path)
    ctl.load("../encodings/size.lp")
    ctl.ground([('base',[])])
    ctl.solve(on_model= lambda m: save(dom,app,cons,instance,m))
    
    # print(dirs)
    # print("")
    # for filename in files:
    #     print(os.path.join(root, filename))


for dom,val in results.items():
    file_name_csv = f'results/tables/{dom}/size.csv'.format(dom)
    file_name_tex_csv = f'results/tables/{dom}/size.tex'.format(dom)
    os.makedirs(os.path.dirname(f'results/tables/{dom}/size.csv'), exist_ok=True)
    df = pd.DataFrame(val)
    df.to_csv(file_name_csv,float_format='%.0f')
    tex_table = df.to_latex(float_format='%.0f')
    f = open(file_name_tex_csv, "w")
    f.write(tex_table)
    f.close()
    print("Saved {}".format(file_name_csv))
    print("Saved {}".format(file_name_tex_csv))

# if args.table:
#     file_name_csv = 'plots/tables/{}-{}.csv'.format(prefix,column)
#     file_name_tex_csv = 'plots/tables/{}-{}.tex'.format(prefix,column)
#     reduced_df = reduced_df.rename(index={idx:i for idx,i in enumerate(instances)})
    
    
#     # ELEVATOR
#     table_df = pd.DataFrame(columns = args.approach, index=["h-{}".format(h) for h in horizons])

#     for s in reduced_df.columns:
#         s_split=s.split("__")
#         # h= int(s_split[1].split("-")[1])
#         table_df[s_split[0]][s_split[1]]=reduced_df[s][0].astype(int)
    
#     table_df.to_csv(file_name_csv,float_format='%.0f')
#     tex_table = table_df.to_latex(float_format='%.0f')

#     # reduced_df.to_csv(file_name_csv,float_format='%.0f')
#     # tex_table = reduced_df.to_latex(float_format='%.0f')


#     f = open(file_name_tex_csv, "w")
#     f.write(tex_table)
#     f.close()
#     print("Saved {}".format(file_name_csv))
#     print("Saved {}".format(file_name_tex_csv))

