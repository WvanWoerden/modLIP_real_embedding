#!/bin/bash

max_degree=300
nbcores=4

echo "Generating data for Figure 6."
echo "Running GS-friendly experiments for fields of degree at most $max_degree on $nbcores cores."
echo "For the default settings on can expect a runtime of +- 1 hour."
cd scripts
SAGE_NUM_THREADS=$nbcores sage GS_prime_selection.sage $max_degree $nbcores
cd ../