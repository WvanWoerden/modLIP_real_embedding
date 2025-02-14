#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Two parameters p t should be passed to the script."
	echo "For example bash run_idealrecovery.sh 43 16"
	exit 1
fi

p=$1
tt=$2
echo $p $tt
for (( t = 1; t <= $tt; t++ ))
do
	start=`date +%s.%N`
	output=$(P=$p gp -q pari_idealrecovery_intersect.gp 2> /dev/null)
	end=`date +%s.%N`
	runtime=$( echo "$end - $start" | bc -l )
	echo $p $output $runtime >> ../data/idealrecovery_$p
done
