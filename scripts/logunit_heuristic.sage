# This SageMath script generates data for Figure 5, which verifies
# the accuracy of the Gaussian Heuristic in the scaled log-unit lattice.
#
# How to run:
# sage logunit_heuristic.sage p
#   p: prime degree
#   Ensure precomputed unit group data is available at data/units_[p].
#
# Example:
# sage logunit_heuristic.sage 23
#
# Output format:
# The output file (data/logunit_heuristic_[p].npy) starts with a line
# -1 gh, where gh is the Gaussian Heuristic of the log-unit lattice, followed by 50 lines with
# the format: s lambda1
#   s: scaling factor (first coefficient is scaled by 2^(s*(p-1)))
#   lambda1: normalized minimum of the scaled log-unit lattice

import numpy as np
from math import lgamma
import sys


assert(len(sys.argv)==2)
p = int(sys.argv[1])
assert(is_prime(p))
precision = 50*p+600

print("Running verification of heuristic with p=", p, ", and precision=", precision)

@CachedFunction
def ball_log_vol(n):
    return float((n/2.) * log(pi) - lgamma(n/2. + 1))

def def_P(p):
     x = var('x')
     if p%4 == 1:
        P = x^(2*p)-2*x^(p+1)+x^2+1
     if p%4 == 3:
        P = x^(2*p)+2*x^(p+1)+x^2+1
     return P

def log_embed(a):
    return vector([log(abs(x)) for x in a.complex_embeddings(prec=precision)])

d=2*p
r = p-1
P = def_P(p)
L.<x> = NumberField(P)
OL = L.ring_of_integers()

S = read_data("../data/units_"+str(p), L)
assert(sum([y^(-1) in OL for y in S])==r)

RRhigh = log_embed(S[0])[0].parent()

# construct log-unit lattice
BR = Matrix(RRhigh, r, d)
for i in range(r):
	BR[i] = log_embed(S[i])

def compute_lambda1_approx(BR):
	B = Matrix(ZZ, BR.nrows(), BR.ncols())
	scale = ZZ(2)^500
	for i in range(BR.nrows()):
		for j in range(BR.ncols()):
			B[i,j] = ZZ(round(scale * BR[i,j]))

	B = B.LLL(proof=False)
	B = B.BKZ(proof=True, block_size=BR.nrows(), algorithm="NTL")
	return B[0].norm().n() / scale

# construct scaled up

n_log_volume = log((BR*BR.transpose()).det()) /(2*r)
gh = exp( n_log_volume - ball_log_vol(r) / r )

results = []
results += [(-1, gh)]

scalar = 1
for s in range(0, 51):
	results += [(s, compute_lambda1_approx(BR) / 2^s)]
	scalar *= 2^r
	BR[:, 0] *= 2^r

print(results)
np.savetxt("../data/logunit_heuristic_"+str(p)+".npy", results)