# This SageMath script generates data for Figure 3 in the paper, which analyzes
# the required precision for recovering the polynomial q_x from its real embedding.
#
# How to run:
# sage reconstruction_qx.sage x b p_start p_end nbtrials nbcores
#   x: index of q_x
#   b: BKZ blocksize
#   p_start, p_end: prime degree range
#   nbtrials: number of trials
#   nbcores: number of cores
#
# Example:
# SAGE_NUM_THREADS=4 sage reconstruction_qx.sage 1 2 37 38 8 4
#
# Output format:
# The output file (data/reconstruct_q[x]_[p]_[nbtrials]_[b]) contains
# nbtrials lines, each with the format: p b sigma nrm
#   p: prime degree
#   b: highest required bitsize of the embedding
#   sigma: real embedding (low precision)
#   nrm: norm of the element to be recovered

import multiprocessing
import numpy as np
import sys

nb_cores=4
nb_trials=8
qx=1
BKZ_blocksize = 2
primes_start = 200
primes_end = 210
print(sys.argv)
if len(sys.argv) > 1:
    qx = int(sys.argv[1])
    assert(qx in [1,2,4])
if len(sys.argv) > 2:
    BKZ_blocksize = int(sys.argv[2])
if len(sys.argv) > 3:
    assert(len(sys.argv)>=5)
    primes_start = int(sys.argv[3])
    primes_end = int(sys.argv[4])
if len(sys.argv) > 5:
    nb_trials = int(sys.argv[5])
if len(sys.argv) > 6:
    nb_cores = int(sys.argv[6])

def reconstruct(p=17, precision=-1, seed=-1):
        set_random_seed(seed)
        load("keygen.sage")
        P = x^p-x-1
        
        OK, a,b,c,d = keygen(p)
        y = OK.gen(1)
        K = OK.number_field()
        assert(a*d-b*c==1)
        
        z=1
        if qx == 1:
            z = a*a+b*b
        if qx == 2:
            z = a*c+b*d
        if qx == 4:
            z = c*c+d*d
        
        x_nrm = norm(vector(z))
        prec_emb = max(int(3.0*(0.03668519769018286*p^2+4.882513057336654*p+750)), precision+50)
        RRhigh = RealField(prec = prec_emb)
        sigma_t = RRhigh(z.complex_embeddings(prec = prec_emb)[-1])
        print(sigma_t)
        basis = OK.basis()
        sigma_basis = [RRhigh(x.complex_embeddings(prec = prec_emb)[-1]) for x in basis]

        def recover_with_prec(bit_prec = 100):
                scale = ZZ(2)^20
                scale_first = RRhigh(2)^bit_prec
                C = Matrix(ZZ, p+1, p+2)
                for i in range(0,p):
                        C[i, 0] = round(scale * scale_first * sigma_basis[i])
                        C[i, i+1] = scale
                C[p,0] = round(scale * scale_first * sigma_t)
                C[p,p+1] = scale

                C2 = C.LLL(proof=False)
                if C2[0,-1] == 0 and BKZ_blocksize > 2:
                        C2 = C2.BKZ(proof=False, block_size = BKZ_blocksize, fp="rr", precision=160)

                if C2[0,-1] != 0:
                        z_reconstruction = sum([-C2[0, i+1]/C2[0,-1] * basis[i] for i in range(p)])
                        return z_reconstruction==z
                else:
                        return False

        if precision > 0:
                return recover_with_prec(precision)
        else:
                bits_low = 20
                bits_high = 50
                while not recover_with_prec(bits_high):
                        if bits_high > prec_emb:
                                print("Need higher prec_emb")
                                return (p, bits_high, float(sigma_t), x_nrm, False)
                        bits_low = bits_high
                        bits_high = ceil(bits_high*1.25)
                        
                success = False
                while bits_high - bits_low > 5:
                        bits_cur = ceil((bits_high + bits_low)/2)
                        if recover_with_prec(bits_cur):
                                bits_high = bits_cur
                                success = True
                        else:
                                bits_low = bits_cur
                return (p,bits_high, float(sigma_t), x_nrm, success)


def map_reconstruct(args):
        print(args)
        sol=reconstruct(args[0], args[1], args[2])
        print(args, "done")
        return sol

pool = multiprocessing.Pool(nb_cores)
all_trials = {}
trials_per = nb_trials
for p in primes(primes_start, primes_end):
        trials = list(pool.map(map_reconstruct, [(p,-1, i) for i in range(trials_per)]))
        all_trials[p] = [(x[0], x[1], x[2], x[3]) for x in trials]
        np.savetxt("../data/reconstruct_q"+str(qx)+"_"+str(p)+"_"+str(trials_per)+"_"+str(BKZ_blocksize)+".npy", all_trials[p])
        print(p, sum([x[1] for x in trials])/float(trials_per))

