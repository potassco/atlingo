#!/bin/bash
R=`tput setaf 1`
G=`tput setaf 2`
Y=`tput setaf 3`
B=`tput setaf 5`
C=`tput setaf 6`
NC=`tput sgr0`
cd benchmark-tool
for f in $(find ../results  -type f -name "*.beval");
do
NAME=$(basename -- $f .beval)
DIR=$(dirname -- $f)
rm -f $DIR/*.ods
echo "$Y Computing .ods... for $f $NC"
if [ -s $f ]; then
    mv $DIR/$NAME.beval $DIR/$NAME.bevaltmp
    cat $DIR/$NAME.bevaltmp | sed 's/measure name="status" type="float" val="2"\/>/measure name="status" type="float" val="2"\/>\n<measure name="atoms" type="float" val="NaN"\/>\n<measure name="bodies" type="float" val="NaN"\/>\n<measure name="calls" type="float" val="NaN"\/>\n<measure name="choices" type="float" val="NaN"\/>\n<measure name="conflicts" type="float" val="NaN"\/>\n<measure name="cons" type="float" val="NaN"\/>\n<measure name="csolve" type="float" val="NaN"\/>\n<measure name="ctime" type="float" val="NaN"\/>\n<measure name="equiv" type="float" val="NaN"\/>\n<measure name="models" type="float" val="NaN"\/>\n<measure name="ptime" type="float" val="NaN"\/>\n<measure name="rchoices" type="float" val="NaN"\/>\n<measure name="restarts" type="float" val="NaN"\/>\n<measure name="roriginal" type="float" val="NaN"\/>\n<measure name="rules" type="float" val="NaN"\/>\n<measure name="vars" type="float" val="NaN"\/>/g' > $DIR/$NAME.beval
    ./bconv -m time,ctime,csolve,ground0,groundN,models,timeout,restarts,conflicts,choices,domain,vars,cons,mem,error,memout,status,atoms,rules,roriginal,bodies,equiv,rchoices,ptime $f > $DIR/$NAME.ods 2> $DIR/$NAME.error
    cat $DIR/$NAME.error
    rm $DIR/$NAME.bevaltmp
    

else
    echo "$R.beval is empty$NC"
fi
done