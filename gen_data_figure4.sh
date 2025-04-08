#!/bin/bash

nbtrials=128

echo "Generating data for Figure 4."
echo "Running all ideal recovery experiments with $nbtrials trials each."
echo "This might take couple of hours per trial for the larger cases and use up to 16G of memory."
echo "It is therefore recommended to run only a single trial per prime per core."
echo "The results will all be appended to the same result files."
cd scripts
for p in 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199; do
    echo $p
    bash run_idealrecovery.sh $p $nbtrials
done
cd ../

