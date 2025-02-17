# This SageMath script generates data for Figure 3 in the paper, which analyzes
# the required precision for recovering the polynomial q_x from its real embedding.
#
# How to run:
# sage plot_reconstruction_qx.sage
#
# Output:
# reconstruction_qx.pdf
#
# Data dependency:
# data/reconstruct_q[x]_[p]_128_2 where x=1,2,4 for x=1,2,4 and p in primes(31,300)
#
# Data format:
# The input file (data/reconstruct_q[x]_[p]_[nbtrials]_[b]) contains
# nbtrials lines, each with the format: p b sigma nrm
#   p: prime degree
#   b: highest required bitsize of the embedding
#   sigma: real embedding (low precision)
#   nrm: norm of the element to be recovered
#
# Data generation by:
# scripts/reconstruction_qx.sage

import matplotlib.pyplot as plt
import numpy as np

plt.style.use('custom.mplstyle')

### quadratic fit function
def fitting_function(data):
	var('a, b, c, x')
	model(x) = a * x^2 + b*x+c
	sol = find_fit(data,model)
	print(sol)
	def f(x):
		return sol[0].right_hand_side() * x^2 + sol[1].right_hand_side() * x + sol[2].right_hand_side()
	return f, (sol[0].right_hand_side(), sol[1].right_hand_side(), sol[2].right_hand_side())

def coeff_to_str(coeff):
	return "$"+"{:.4f}".format(float(coeff[0]))+"p^2 + "+"{:.2f}".format(float(coeff[1]))+"p "+"{:.2f}".format(float(coeff[2]))+"$"

pp = list(primes(31,300))
qq = [1,2,4]
colors = {1:"blue", 2:"orange", 4:"green"}
all_points = {}
average = {}
f = {}
f_coeff = {}
for q in qq:
	all_points[q] = []
	average[q] = []
	for p in pp:
		### LLL
		data_lll = np.loadtxt("../data/reconstruct_q"+str(q)+"_"+str(p)+"_128_2.npy")
		avg=np.average(data_lll[:,1])
		average[q] += [(p, avg)]
		all_points[q] += [ (p, data_lll[i,1]) for i in range(128)]
		if np.sum(data_lll[:,1] > 2*avg):
			print(p)

	f[q], f_coeff[q] = fitting_function(all_points[q])

fig = plt.figure(figsize=(9,4.5))

for q in qq:
	all_points_lll = np.array(all_points[q])
	f_points_lll = np.array([(x, f[q](x)) for x in np.arange(pp[0], pp[-1], 1)])
	plt.scatter(all_points_lll[:,0], all_points_lll[:,1], color=colors[q], marker="x", s=2)
	plt.plot(f_points_lll[:,0], f_points_lll[:,1], color=colors[q], label="$q_"+str(q)+"$ (" + coeff_to_str(f_coeff[q])+")")

plt.xlabel("Degree $p$ (prime)")
plt.ylabel("Bit precision $\\lambda$")

plt.legend()
fig.tight_layout()
plt.savefig("reconstruction_qx.pdf")	
plt.close()