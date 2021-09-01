DOM=$1

echo "--------------------" > results/$DOM/summary.txt
echo "Summary">> results/$DOM/summary.txt
echo "--------------------">> results/$DOM/summary.txt

echo "Successful:">> results/$DOM/summary.txt
for f in $(find ./results/$DOM/  -type f -name "*.ods");
do
    echo "  $(basename $f .ods)">> results/$DOM/summary.txt
done
echo "Error:">> results/$DOM/summary.txt
for f in $(find ./results/$DOM/  -type f -name "*.error");
do
    if [ -s "$f" ];then
        echo "  $(basename $f .error)">> results/$DOM/summary.txt
    fi
done

cat results/$DOM/summary.txt

# send an email to report that the experiments are done
cat results/$DOM/summary.txt | mail -s "[Benchmark Finished]" hahnmartinlu@uni-potsdam.de
