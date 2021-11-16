#!/usr/bin/env python
# libraries and data
import os
import math
import sys
import matplotlib
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
import matplotlib.colors as mcol
from matplotlib import rc

matplotlib.rcParams['text.usetex'] = True
rc('text', usetex=True)
rc('font', weight='bold')

import matplotlib.pyplot as plt
import numpy as np

# plt.rcParams.update({
#     "text.usetex": True,
#     "font.family": "sans-serif",
#     "font.size": 14,
#     "font.sans-serif": ["Computer Modern Sans Serif"]})
# constraints =["d1"]
# constraints =[(2,"d3")]
constraints =[(0,r'$\varphi_1$'),(1,r'$\varphi_2$'),(2,r'$\varphi_3$')]
# constraints =[(0,"d1"),(2,"d3")]
approaches =["ASP","MONA-m","MONA-s"]
# approaches =["ASP","MONA-m","MONA-s","TELINGO","NO-CONS"]
# approaches2 = [f"{a}-{c}" for a in approaches for i,c in constraints]

# colors = ["#938EDE","#E97343","#268D27"]
colors = ["#009b7f","#ffaa00","#9b9bc7"]

times = np.array([
    [23.173, 27.866 , 27.505 , 23.748 , 249.737 ],
    [70.709 ,  587.39, 83.521 , 60.765 , 246.739 ],
    [67.287 ,  np.nan , 657.633 , 48.190, 247.718 ]
],dtype=object)

# print(times.flatten('F'))
ptimes = np.array([
   [1.991   ,      6.280  ,6.978  ,    3.390  ,0.302  ],
    [1.632     ,45.303  ,     4.973 ,2.718  ,0.318  ],
    [3.112   , np.nan ,      11.001  ,3.278  ,0.272 ]
     ],dtype=object)

asize = np.array([
   [162   ,      234  ,216 ],
    [60     ,390  ,     471  ],
    [189   , np.nan ,      16503 ]
     ],dtype=object)


int_app = np.arange(0,len(approaches),1)
fig, ax = plt.subplots()

# ax.bar(approaches2,times.flatten('F'),label="something")
# app_ints = list(range(0,len(approaches),len(constraints)))
app_ints = np.arange(0,len(approaches)*len(constraints),len(constraints))
for i,cons in constraints:
    colors_app = [colors[i]]*len(approaches)
    arr = asize
    # arr = ptimes
    # arr = times
    # ax.bar([x+(i*0.7) for x in app_ints],ptimes[i]+times[i],width=0.5,color=colors_app,alpha=0.5)
    # ax.bar([x+(i*0.7) for x in app_ints],ptimes[i],label=cons, width=0.5,color=colors_app)
    ax.bar([x+(i*0.7) for x in app_ints],asize[i],label=cons, width=0.5,color=colors_app)
    
    
    v = [0 if np.isnan(x) else np.nan for x in arr[i]]
    ax.scatter([x+(i*0.7) for x in app_ints],v,color='#ff5501',zorder=10,clip_on=False,s=60,marker='x',linewidths=2)
    # ax.scatter(approaches,ptimes[i])

plt.xlabel('approach', weight='semibold' ,fontsize=14)
plt.ylabel('transitions',weight='semibold',fontsize=14)
# plt.ylabel('time (sec)',weight='semibold',fontsize=14)
plt.title('Automata size (3 robots)',weight='bold',fontsize=18)
# plt.title('Preprocessing times (3 robots)',weight='bold',fontsize=18)
# plt.title('Times (3 robots)',weight='bold',fontsize=18)

# ax.set(xlabel='Approach', ylabel='time (s)',
    #    title='Times')

plt.xticks([x+0.7 for x in app_ints],approaches, rotation='horizontal',fontsize=10)
plt.legend()
plt.show()
# fig.savefig("test-time.png")
fig.savefig("test-asize.png")
# fig.savefig("test-ptime.png")

# matplotlib.use("pgf")
# matplotlib.rcParams.update({
#     "pgf.texsystem": "pdflatex",
#     'font.family': 'serif',
#     'text.usetex': True,
#     'pgf.rcfonts': False,
# })
# plt.savefig('histogram.pgf')
