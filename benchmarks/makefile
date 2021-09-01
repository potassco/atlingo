copy-programs:
	cp -r programs/* benchmark-tool/programs
	cp -r programs/runsolver-3.4.0 benchmark-tool
	cp programs/clingo.py benchmark-tool/src/benchmarktool/resultparser
clean-results:
	rm -rf ./results/*
	mkdir ./results/tables
clean-ods:
	rm -rf ./results/elevator/*.ods
clean-plots:
	rm -rf ./plots/img/*
	rm -rf ./plots/tables/*
	rm -rf ./plots/tikz/*
clean-runscripts:
	rm -rf ./cluster_script__*.sh
	rm -rf ./runscripts/runscript_*_*__*
clean-output:
	rm -rf benchmark-tool/output/*
clean:
	rm -rf fault_runsolver.txt
	make clean-plots
	make clean-runscripts
	make clean-output
plots:
	python plot.py $(ARGS)
ods:
	./compute_all_ods.sh


# ASPRILO
asprilo-md-clean-instances:
	rm -rf ./instances/asprilo/md/structured/*
	rm -rf ./instances/asprilo/md/gridworld/*
asprilo-md-small-instances:
	mkdir -p ./instances/asprilo/md/structured
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/structured/x7_y6_r4 ./instances/asprilo/md/structured
asprilo-md-medium-instances:
	mkdir -p ./instances/asprilo/md/structured
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/structured/x10_y6_r10 ./instances/asprilo/md/structured
asprilo-md-large-instances:
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/structured/x10_y9_r20 ./instances/asprilo/md/structured
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/structured/x10_y10_r20 ./instances/asprilo/md/structured
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/structured/x10_y12_r20 ./instances/asprilo/md/structured
asprilo-md-all-instances:
	make medium-instances
	make small-instances
	make large-instances
asprilo-md-all-grid:
	mkdir -p ./instances/asprilo/md/gridworld
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/gridworld/x4_y4_n12_r4 ./instances/asprilo/md/gridworld
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/gridworld/x4_y4_n16_r4 ./instances/asprilo/md/gridworld
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/gridworld/x5_y5_n20_r5 ./instances/asprilo/md/gridworld
	cp -r ../benchmarks/asprilo/asprilo-abstraction-encodings/instances/md/gridworld/x5_y5_n25_r5 ./instances/asprilo/md/gridworld



asprilo-clean-instances:
	rm -rf ./instances/asprilo/*
asprilo-abc-small-instance:
	mkdir -p ./instances/asprilo/abc/small
	cp -r ../dom/asprilo-abc/instances/small/* ./instances/asprilo/abc/small/
asprilo-abc-robots-instance:
	mkdir -p ./instances/asprilo/abc/robots
	cp -r ../dom/asprilo-abc/instances/robots/* ./instances/asprilo/abc/robots/
asprilo-abc-all-instance:
	mkdir -p ./instances/asprilo/abc
	cp -r ../dom/asprilo-abc/instances/* ./instances/asprilo/abc/


# HANOI
hanoi-clean-instances:
	rm -rf ./instances/hanoi/*
	rm -rf ./instances/hanoi/*
hanoi-small-instance:
	mkdir -p ./instances/hanoi
	cp -r ../dom/hanoi/instances/4_disks.lp ./instances/hanoi
hanoi-medium-instance:
	mkdir -p ./instances/hanoi
	cp -r ../dom/hanoi/instances/5_disks.lp ./instances/hanoi
hanoi-big-instance:
	mkdir -p ./instances/hanoi
	cp -r ../dom/hanoi/instances/6_disks.lp ./instances/hanoi