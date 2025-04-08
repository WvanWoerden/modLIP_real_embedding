#!/bin/bash

b=2 # LLL 
nbtrials=128
nbcores=4 # recommended: 32+ cores

echo "Generating data for Figure 3."
echo "Running all reconstruction experiments with $nbtrials trials each on $nbcores cores."
echo "This might take multiple hours per trial for the larger cases, so it is recommended to pick the number of trials and the number of cores of the same magnitude."
cd scripts
for p in 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 257 263 269 271 277 281 283 293; do
    for i in 1 2 4; do
    	echo "p=$p, i=$i"
    	SAGE_NUM_THREADS=$nbcores sage reconstruction_qx.sage $i $b $p $(($p+1)) $nbtrials $nbcores
    done
done
cd ../

