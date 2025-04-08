# This SageMath script generates Figure 6, 
# which verifies Heuristic 2 about GS-friendly fields.
#
# How to run:
# sage plot_GS_heuristic.sage
#
# Output:
# GS_heuristic.pdf
#
# Data dependency:
# data/GS_heuristic_cyclo.npy, data/GS_heuristic_NTRUPrime.npy and data/GS_heuristic_random.npy
#
# Data format:
# The input files (data/GS_heuristic_*.npy) contain lines with the
# format: d r1 r2
#   d: degree of the field
#   r1: gcd obtained over 100 random primes
#   r2: gcd obtained over 2 random primes (best of 20 trials)
#
# Data generation by:
# scripts/GS_prime_selection.sage

import matplotlib.pyplot as plt
import numpy as np

plt.style.use('custom.mplstyle')

data_NTRUPrime = np.loadtxt("../data/GS_heuristic_NTRUPrime.npy")
data_cyclo = np.loadtxt("../data/GS_heuristic_cyclo.npy")
data_random = np.loadtxt("../data/GS_heuristic_random.npy")

fig = plt.figure(figsize=(12,5.5))

plt.plot(data_NTRUPrime[:,0], data_NTRUPrime[:,1], alpha=float(0.3), color="green", linestyle="dotted", label="$K(i)$ where $K$ is NTRU Prime (100 primes)", marker="o")
plt.plot(data_NTRUPrime[:,0], data_NTRUPrime[:,2], alpha=float(1), color="green", linestyle="dashed", marker="*", label="$K(i)$ where $K$ is NTRU Prime (best of 50x2 primes)")

plt.plot(data_cyclo[:,0], data_cyclo[:,1], alpha=float(0.3), color="red", linestyle="dotted", label="Cyclotomic (100 primes)", marker="o")
plt.plot(data_cyclo[:,0], data_cyclo[:,2], alpha=float(1), color="red", linestyle="dashed", marker="*", label="Cyclotomic (best of 50x2 primes)")

plt.plot(data_random[:,0], data_random[:,1], alpha=float(0.3), color="blue", linestyle="dotted", label="Random (100 primes)", marker="o")
plt.plot(data_random[:,0], data_random[:,2], alpha=float(1), color="blue", linestyle="dashed", marker="*", label="Random (best of 50x2 primes)")

plt.xlabel("Degree $n$")
plt.ylabel(r'gcd of $o_{max}((\mathcal{O}_K/p{\mathcal{O}_K})^{\times})$')

plt.legend()
fig.tight_layout()
plt.savefig("GS_heuristic.pdf")	
plt.close()