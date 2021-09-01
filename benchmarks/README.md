# Benchmarks

For the benchmarking we use the benchmarking tool as a submodule installed. We provide a set of useful commands and scripts. 

The files found in [./benchmarks/programs](../benchmarks/programs) correspond to our particular approach and are copied to the submodule folder to be used by the tool. A especial treatment of the scripts was needed to account for the preprocessing of each instance.

We use the following scripts to automatize the jobs for the benchmarks.

##### [./run_bm.sh](./run_bm.sh) 
- Generates specialized run scripts by duplicating the provided [template for the domain](./runscripts/runscript_asprilo-abc.xml) and replacing special parameters: (Horizon, number of models, and additional).
- Calls `./bgen` to generate benchmarking scripts from the benchmarking tool.
- Runs the start files for each instance. 
  By default, these files will make a call to slurm for adding a process to the queue with `sbatch`. If you wish to use python change variable `mode` to  `1`.
- Checks output for errors.
- Calls `./beval` to scrap the stats to a xml file
- Checks output for errors, if an error was found then shows the output with the internal error.
- Cleans output
- All results are saved in [./results](./results) inside the folder corresponding to the environment

##### [./batch_all_$DOM.sh](./batch_all.sh) 
- Cleans environment.
- Makes a series of calls to `./run_bm.sh` with different parameters.
- Gathers result summary
- Sends email to notify that evaluation finished.

##### [./compute_all_ods.sh](./compute_all_ods.sh) 
- Computes all the `.ods` files from the results


## Plots

A python plot script was created matching the patterns from our personalized benchmarks. 
This script takes the precalculated `.ods` results and generates images, tables and tikz files. 

```
Plot obs files from benchmark tool

optional arguments:
  -h, --help            show this help message and exit
  --stat STAT           Status: choices,conflicts,cons,csolve,ctime,error,mem,
                        memout,models,ngadded,optimal,restarts,status,time,tim
                        eout,vars,ptime (default: None)
  --approach APPROACH   Approach to be plotted awf, asp, nc or dfa. Can pass
                        multiple (default: None)
  --dom DOM             Name of domain (default: asprilo)
  --constraint CONSTRAINT
                        Contraint to be plotted, if non is passed all
                        constraints will be plotted. Can pass multiple
                        (default: None)
  --horizon HORIZON     Horizon to be plotted. Can pass multiple (default:
                        None)
  --models MODELS       Number of models computed in the benchmark with clingo
                        -n (default: 1)
  --prefix PREFIX       Prefix for output files (default: )
  --csv                 When this flag is passed, the table is also saved in
                        csv format (default: False)
  --plotmodels          When this flag is passed, the number of models in
                        plotted (default: False)
  --use-lambda          When this flag is passed, horizons are transform to
                        lambda with +1 (default: False)
  --use-gmean           When this flag is passed, computes gmean of all
                        horizons (default: False)
  --type TYPE           Bar or table (default: bar)
  --instance INSTANCE   The name of a single instance (default: None)
  --ignore_prefix IGNORE_PREFIX
                        Prefix to ignore in the instances (default: None)
  --ignore_any IGNORE_ANY
                        Any to ignore in the instances (default: None)
  --y Y                 Name for the y axis (default: None)
  --x X                 Name for the x axis (default: Horizon)
  ```

## *asprilo* Benchmarks from paper

1. Setup path to atlingo in folder in [./run_bm.sh](./run_bm.sh)

1. Run all benchmarks from script `./batch_all_asprilo-abc.sh`

2. Compute ods files `./compute_all_ods.sh`

3. Plot results `./plot_script_asprilo-abc.sh`

