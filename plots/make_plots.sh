#!/bin/bash

echo "Constructing Figure 3"
sage plot_reconstruction_qx.sage # Figure 3
echo "Constructing Figure 4"
sage plot_idealrecovery.sage     # Figure 4
echo "Constructing Figure 5"
sage plot_heuristic.sage         # Figure 5
echo "Constructing Figure 6"
sage plot_GS_heuristic.sage      # Figure 6

echo "Cleaning up *.sage.py files"
rm *.sage.py