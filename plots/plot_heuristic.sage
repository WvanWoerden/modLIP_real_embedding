# This SageMath script generates Figure 5
#
# How to run:
# sage plot_heuristic.sage
#
# Output:
# logunit_heuristic.pdf
#
# Data dependency:
# data/logunit_heuristic_[p].npy for p=13,19,23,29,37
#
# Data format:
# The input file (data/logunit_heuristic_[p].npy) starts with a line
# -1 gh, where gh is the Gaussian Heuristic of the log-unit lattice, followed by 50 lines with
# the format: s lambda1
#   s: scaling factor (first coefficient is scaled by 2^(s*(p-1)))
#   lambda1: normalized minimum of the scaled log-unit lattice
#
# Data generation by:
# scripts/logunit_heuristic.sage

import matplotlib.pyplot as plt
import numpy as np

plt.style.use('custom.mplstyle')

pp = [13, 19, 23, 29, 37]
all_points = {}
gh = {}
for p in pp:
	### LLL
	data = np.loadtxt("../data/logunit_heuristic_"+str(p)+".npy")
	gh[p]=data[0,1]
	all_points[p] = np.array([ (i, data[i+1, 1]) for i in range(0, 51)])

fig = plt.figure(figsize=(9,4.5))

for p in pp:
	plot = plt.scatter(all_points[p][:,0], all_points[p][:,1], marker="x", s=10, label="$p="+str(p)+"$")
	plt.hlines(gh[p], 0, 50, color=plot.get_edgecolor())

plt.hlines(0, 0, 0, color="black", label="Gaussian Heuristic")

plt.xlabel("Normalized scale $s$ ($\\lambda = s (p-1)$)")
plt.ylabel("$\\lambda_1(L^{s (p-1)}) / 2^s$")
plt.xticks([x for x in range(0, 51, 10)])

plt.legend()
fig.tight_layout()
plt.savefig("logunit_heuristic.pdf")	
plt.close()