#!/bin/bash
R=`tput setaf 1`
G=`tput setaf 2`
Y=`tput setaf 3`
B=`tput setaf 5`
C=`tput setaf 6`
NC=`tput sgr0`

set -e
export PATH="$HOME/temporal-automata/stage_asp_gitlab/tools/MONA/Front:$PATH"

DOM=$1
APPROACH=$2
HORIZON=$3
MODELS=$4
PREFIX=$5
CLINGO_ARGS=$6
: ${CLINGO_ARGS:=''}
: ${PREFIX:=''}


NAME=${PREFIX}${APPROACH}__h-${HORIZON}__n-${MODELS}

MACHINE=komputer # Value in <machine name="komputer"
# set this
ATLINGO_PATH=$HOME/temporal-automata
#ATLINGO_PATH=$HOME/Education/Phd/potassco
BT_PATH=$ATLINGO_PATH/atlingo/benchmarks/benchmark-tool

# set mode: sequential=py or cluster=cl
mode=cl
#mode=py


# this has to be the same as project name in run-benchmark.xml
PROJECT=temporal-automata-$mode

# if mode==cl, set username to your login in the cluster
USERNAME="hahnmar"

dir=$PWD
echo ""
echo "$C ---------------------------"
echo " Starting benchmarks for $NAME"
echo "$C ---------------------------$NC"


# echo "$Y Cleaning with make "
# make clean -s


# Create the runscript for the arguments
RUNSCRIPT_PATH=$PWD/runscripts/runscript_${mode}_${DOM}_$NAME.xml
echo "$Y Creating runscript in "
echo "$B    $RUNSCRIPT_PATH $NC"
sed "s/{H}/"$HORIZON"/g; s/{N}/"$MODELS"/g; s/{CLINGO_ARGS}/'"$CLINGO_ARGS"'/g; s/{APP}/"$APPROACH"/g" ./runscripts/runscript_${mode}_${DOM}.xml >  $RUNSCRIPT_PATH


# Results directory
echo "$Y Removing old result directory $NC"
mkdir -p $dir/results/$DOM
RES_DIR=$dir/results/$DOM/$NAME
rm -rf $RES_DIR
mkdir -p $RES_DIR

# Move to benchmark tool
echo "$Y Moving to benchmarks-tool directory "
echo "$B    $BT_PATH $NC"
cd $BT_PATH


#Output directory inside benchmark-tool is the value in <runscript output="">
OUTPUT_DIR=output/$DOM/${APPROACH}__h-${HORIZON}__n-${MODELS}/$PROJECT 
echo "$Y Calling ./bgen$NC"
./bgen $RUNSCRIPT_PATH

#Running start file
if [ "$mode" = "py" ]; then
    echo "$Y Running python start file "
    echo "$B    $BT_PATH/$OUTPUT_DIR/$MACHINE/start.py $NC"
    ./$OUTPUT_DIR/$MACHINE/start.py
	echo "Python done "
else
    echo "$Y Running sh start file "
    echo "$B    $BT_PATH/$OUTPUT_DIR/$MACHINE/start.sh $NC"
    ./$OUTPUT_DIR/$MACHINE/start.sh
    sleep 3
    SEC=0
    while squeue | grep -q $USERNAME; do
	if !(( $SEC % 5 )); then
		echo "$B Waiting for all slurm process to finish..."
	fi
	sleep 1
	SEC=($SEC+1)
    done
	echo "$G Slurm queue is now empty $NC"
fi


# Clean outputs in runsuolver.solver and check errors
for f in $(find ./$OUTPUT_DIR/$MACHINE/results/$DOM-benchmark  -type f -name "*runsolver.solver");
do
	if grep -q 'fail' $f; then
		if grep -q 'INTERRUPTED' $f; then
			# echo "$R Found word failed in file $f$NC"
			# cat $f
			# cat $f > $RES_DIR/$NAME.error
			# exit 1
			echo "$B TIMEOUT: $f"
		fi
	else
		#Ignore the rest of the resut and saave only stats
		#echo $f
		echo "$(tail -34 $f)" > $f
	fi
done

# Get evealuation from runsolver results
echo "$Y beval...$NC"
if ! ./beval $RUNSCRIPT_PATH > $RES_DIR/$NAME.beval 2> $RES_DIR/$NAME.error ; then
	# Analize errors during evaluation
	echo "$R Error during evaluation"
	cat $RES_DIR/$NAME.error
	echo "$NC"
	exit 1
fi

# Analize eval error when reading a strange runsolver.solver file
grep 'failed with unrecognized status or error!' $RES_DIR/$NAME.error | head -1 | sed -e 's#.*Run \(\)#\1#' | sed -e 's# failed.*\(\)#\1#' > fault_runsolver.txt
LINE_ERR=$(cat fault_runsolver.txt)
if [ ! -z $LINE_ERR ] 
then
	echo "$R Found error inside output of runsolver"
	LINE_ERR=$LINE_ERR/runsolver.solver
	echo $LINE_ERR
	cat $LINE_ERR
	echo "$NC"
	#exit 1
fi

echo "$G Evaluation results saved in  "
echo "$B    $RES_DIR/$NAME.beval$NC"

################ Clean beval output an generate ods file
sed -i 's/partition="short" partition="short"/partition="short"/g' $RES_DIR/$NAME.beval


echo "$G Done $NAME$NC"

