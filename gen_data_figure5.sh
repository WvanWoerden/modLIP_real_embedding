#!/bin/bash

echo "Generating data for Figure 5."
echo "This is expected to take up to +-10 minutes"
cd scripts
for p in 3 5 7 11 13 17 19 23 29 31 37; do
    sage logunit_heuristic.sage $p
done
cd ../

