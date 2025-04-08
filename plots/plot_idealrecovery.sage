# This SageMath script generates Figure 4, which focuses on
# the timed recovery of the ideal zO_{L_1} from the matrix B^tB.
#
# How to run:
# sage plot_idealrecovery.sage
#
# Output:
# idealrecovery.pdf
#
# Data dependency:
# data/idealrecovery_[p] for p in primes(31,200)
#
# Data format:
# The input file (data/idealrecovery_[p]) contains nbtrials lines,
# each with the format: p a b c time
#   p: prime degree
#   a, b: indicators (should be 1) for the equation from Lemma 5
#   c: indicator (should be 1) for successful ideal recovery
#   time: total runtime for ideal recovery
#
# Data generation by:
# scripts/pari_idealrecovery_intersect.gp

import matplotlib.pyplot as plt
import numpy as np

plt.style.use('custom.mplstyle')

def log_fitting(data):
	var('a, b, x')
	model(x) = a * log(x) + b
	data_log = [(y[0], log(y[1])) for y in data]
	sol = find_fit(data_log, model)
	print(sol)
	def f(x):
		return sol[0].right_hand_side() * log(x) + sol[1].right_hand_side()
	return f, tuple([y.right_hand_side() for y in sol])

def coeff_to_str(coeff):
	return "$"+"10^{"+"{:.2f}".format(float(coeff[1]/log(10)))+"}\\cdot p^{"+"{:.2f}".format(float(coeff[0]))+"}$"

pp = list(primes(30, 200))
all_points = []
average = []
for p in pp:
	data = np.loadtxt("../data/idealrecovery_"+str(p))
	avg=np.average(data[:,4])
	average += [(p, avg)]
	all_points += [ (p, data[i,4]) for i in range(128)]
	if np.sum(data[:,4] > 2*avg):
		print(p)

f, f_coeff = log_fitting(all_points[1920:])

fig = plt.figure(figsize=(9,3.5))
plt.yscale('log')

all_points = np.array(all_points)
f_points = np.array([(x, exp(f(x))) for x in np.arange(pp[0], pp[-1], 1)])
plt.scatter(all_points[:,0], all_points[:,1], color="blue", marker="x", alpha=0.05, s=10)
plt.plot(f_points[:,0], f_points[:,1], color="blue", linestyle="dashed", label="Runtime Ideal Recovery ("+coeff_to_str(f_coeff)+")")

plt.xlabel("Degree $p$ (prime)")
plt.ylabel("Time $(s)$")

plt.legend()
fig.tight_layout()
plt.savefig("idealrecovery.pdf")	
plt.close()