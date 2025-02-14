# sage script to generate data for Figure 6.
# change number of cores below and run as:
# SAGE_NUM_THREADS=4 sage GS_prime_selection.sage
nb_cores = 4

## The objective is to see if is it possible to compute two primes for the Gentry-Szydlo algorithm such that their gcd (or more properly the gcd of the maximal order of (OK/pOK)^*) is sufficiently small
## Some first experiments indicate that it could be quite small, maybe as small as 2

def maximal_order(p,Phi, verbose = False):
    ## Input: an irreducible polynomial Phi defining a number field K
    ##        a prime integer p
    ## Output: the order of the group (OK/p\OK)^*
    ##         returns 0 (and a warning message) if p is ramified in K
    Fpy.<y> = GF(p)[]
    Phi_p = Fpy(Phi)
    list_fact = Phi_p.factor()
    if verbose:
        print("Phi_p = ", Phi_p)
        print("factorises as: ", list_fact)
    for tmp in list_fact:
        if tmp[1] > 1:
            print("Warning, ramified prime, I am ignoring it")
            return 0
    k = 1
    for tmp in list_fact: ## tmp = (Phi_i, e_i) with Phi_p = prod_i Phi_i^{e_i} and Phi_i irreducible mod p
        k = lcm(k,p^tmp[0].degree()-1) ## the elements of (OK/pi)^* have order p^{deg(Phi_i)}-1
    return k


def test_maximal_order(p, Phi, nb_tests = 100, verbose = False):
    ## Input: as in maximal_order + nb_tests which is an integer
    ## Output: checks that for nb_tests randomly chosen elements x in OK/pOK, it hold that x^k = 1 mod p (where k is the output of maximal_order)
    ##         this allows to check that the output of maximal_order is likely to be (a multiple) of the lcm of the orders of the elements of
    ##         (OK/pOK)^*
    Fpy.<y> = GF(p)[]
    Kp.<a> = Fpy.quotient(Fpy(Phi))
    K.<b> = NumberField(Phi)
    k = maximal_order(p,Phi,verbose)
    for _ in range(nb_tests):
      x = K([ZZ.random_element(0,p) for _ in range(Phi.degree())])
      Nx = x.norm()
      while Nx%p == 0: ## resample if x is not coprime with p
        x = K([ZZ.random_element(0,p) for _ in range(Phi.degree())])
        Nx = x.norm()
      xp = Kp(x)
      if xp^k != Kp(1):
        print("Warning: found an element whose order was not divisible by k!")
        print("p = ", p, ", Phi = ", Phi, ", x = ", x)
        return False
    return True
      
      
def random_prime(B):
  ## samples a uniformly random prime between B and 2B
  ## aborts after 10*log(B)^2 unsuccesful trials (there may not be any primes between B and 2B)
  max_trials = 10*(round(log(B))+1)^2
  trial = 0
  while trial < max_trials:
    trial += 1
    p = ZZ.random_element(B,2*B)
    if p.is_prime():
      return p
  print("Warning, unable to find a prime number between ", B, " and ", 2*B)
  return -1


def gcd_multiple_primes(Phi, nb_primes, verbose = False):
    # Input: Phi an irreducible polynomial in ZZ[], nb_prime an integer >= 2
    # Output: returns the gcd of maximal_order(p,Phi), for nb_primes random p, chosen uniformly at random between 2^{d+1} and 2^{d+2} where d = deg(Phi)

    res = 0
    for _ in range(nb_primes):
      p = random_prime(2^(2*Phi.degree()+1))
      k = maximal_order(p,Phi,verbose)
      res = gcd(res,k)
    return res

@parallel(nb_cores)
def gcd_multiple_primes_parallel_task(p, Phi, verbose):
        return maximal_order(p, Phi, verbose)

def gcd_multiple_primes_parallel(Phi, nb_primes, nb_trials, verbose = False):
    # Input: Phi an irreducible polynomial in ZZ[], nb_prime an integer >= 2
    # Output: returns the gcd of maximal_order(p,Phi), for nb_primes random p, chosen uniformly at random between 2^{d+1} and 2^{d+2} where d = deg(Phi)
    primes = [(random_prime(2^(2*Phi.degree()+1)), Phi, verbose) for _ in range(nb_trials*nb_primes)]
    orders = list([x[1] for x in gcd_multiple_primes_parallel_task(primes)])
    gcds = [ gcd(orders[i * nb_primes:(i+1)*nb_primes]) for i in range(nb_trials)]
    print(gcds)
    return min(gcds)
    
def compute_data_many_primes(list_poly, nb_primes = 100, verbose = False):
    ## Input: a list of polynomials to test and a maximum number of primes nb_primes to consider for each field
    ## Output: a graphic object whith points (d,r), where d is the degree of the field and r is the output of gcd_multiple_primes with nb_primes random primes (and the polynomial Phi in the list, of degree d)
    res = {}
    for Phi in list_poly:
      if verbose:
        print("starting polynomial of degree ", Phi.degree())
      r = gcd_multiple_primes_parallel(Phi, nb_primes, 1)
      res[Phi] = [Phi.degree(), r]
    return res
    
def compute_data_two_primes_multiple_times(list_poly, nb_trials = 20, verbose = False):
    ## Input: a list of polynomials to test and a maximum number of trials nb_trials to consider for each field
    ## Output: a graphic object whith points (d,r), where d is the degree of the field and r is the smallest output obtained when running gcd_multiple_primes with 2 random primes and repeating nb_trials times
    res = {}
    for Phi in list_poly:
      if verbose:
        print("starting polynomial of degree ", Phi.degree())
      r = gcd_multiple_primes_parallel(Phi, 2, nb_trials)
      res[Phi] = [Phi.degree(), r]
    return res
    
def create_list_NTRUPrime(min_degree, max_degree, step):
  ## create a list of NTRUPrime fields, with degree between min_degree and max_degree, and step roughly step between two successive degrees
  ## (the degrees have to be prime, so the differences will not be exactly equal to step)
  Zx.<x> = ZZ[]
  res = []
  p = ZZ(min_degree//2).next_prime()
  while 2*p < max_degree:
    if p%4 == 1:
        res += [Zx(x^(2*p)-2*x^(p+1)+x^2+1)]
    if p%4 == 3:
        res += [Zx(x^(2*p)+2*x^(p+1)+x^2+1)]
    p = (p+ZZ(step//2)).next_prime()
  return res
  
def create_list_cyclotomic(min_conductor, max_conductor, step):
  ## create a list of cyclotomic fields, with conductor between min_conductor and max_conductor, 
  ## and difference step between two successive conductors
  Zx.<x> = ZZ[]
  res = []
  for m in range(min_conductor, max_conductor, step):
    res += [Zx(cyclotomic_polynomial(m))]
  return res
  
def create_list_random(min_degree, max_degree, step):
  ## create a list of random irreducible polynomials, 
  ## with degree between min_degree and max_degree, and diference step between two successive degrees
  Zx.<x> = ZZ[]
  res = []
  for d in range(min_degree, max_degree, step):
    Phi = Zx(x^d) + Zx.random_element(d-1)
    while not Phi.is_irreducible():
      Phi = Zx(x^d) + Zx.random_element(d-1)
    res += [Phi]
  return res
  
#######################
## Running the tests ##
#######################
## Fixing random seed for reproducibility
set_random_seed(42)

## Creating the list of polynomials
list_NTRUPrime = create_list_NTRUPrime(10,300,17)
list_cyclo = create_list_cyclotomic(10,300,17)
list_cyclo.sort() ## sort the polynomials by degree
list_random = create_list_random(10,300,17)
print("Created three lists containing respectively ", len(list_NTRUPrime), "NTRUPrime fields,", len(list_cyclo), "cyclotomic fields, and ", len(list_random), "random fields")


## Computing data and saving it in file
print("\n\nNTRUPrime, with many primes")
data_NTRUPrime_mult_primes = compute_data_many_primes(list_NTRUPrime, nb_primes = 100, verbose = True)
print("\n\nNTRUPrime, with 2 primes")
data_NTRUPrime_two_primes = compute_data_two_primes_multiple_times(list_NTRUPrime, nb_trials = 50, verbose = True)
data_file = open("../data/GS_heuristic_NTRUPrime.npy","w")
for Phi in list_NTRUPrime:
  data_file.write("%s %s %s\n"%(data_NTRUPrime_mult_primes[Phi][0],data_NTRUPrime_mult_primes[Phi][1],data_NTRUPrime_two_primes[Phi][1]))
data_file.close()

print("\n\nCyclo, with many primes")
data_cyclo_mult_primes = compute_data_many_primes(list_cyclo, nb_primes = 100, verbose = True)
print("\n\nCyclo, with 2 primes")
data_cyclo_two_primes = compute_data_two_primes_multiple_times(list_cyclo, nb_trials = 50, verbose = True)
data_file = open("../data/GS_heuristic_cyclo.npy","w")
for Phi in list_cyclo:
  data_file.write("%s %s %s\n"%(data_cyclo_mult_primes[Phi][0],data_cyclo_mult_primes[Phi][1],data_cyclo_two_primes[Phi][1]))
data_file.close()

print("\n\nRandom, with many primes")
data_random_mult_primes = compute_data_many_primes(list_random, nb_primes = 100, verbose = True)
print("\n\nRandom, with 2 primes")
data_random_two_primes = compute_data_two_primes_multiple_times(list_random, nb_trials = 50, verbose = True)
data_file = open("../data/GS_heuristic_random.npy","w")
for Phi in list_random:
  data_file.write("%s %s %s\n"%(data_random_mult_primes[Phi][0],data_random_mult_primes[Phi][1],data_random_two_primes[Phi][1]))
data_file.close()

## adding the number of roots of unity to data_cyclo_mult_primes
for m in range(10,300,17):
  Phi = cyclotomic_polynomial(m)
  nb_roots_unity = m
  if nb_roots_unity%2 == 1:
    nb_roots_unity *= 2 ## for odd conductors, we need to multiply by 2 the number of roots because of -1
  data_cyclo_mult_primes[Phi] += [nb_roots_unity]
  
## Saving the results in latex format and in plots
output_file = open("../data/experiments_for_GS_heuristic.tex", "w")
#headers
output_file.write("\\documentclass[12pt]{article} \n\\usepackage[utf8]{inputenc} \n\\usepackage{makecell}")
output_file.write("\n\\newcommand{\\OK}{\\mathcal{O}_K} \n\\newcommand{\\omax}{o_{\\mathrm{max}}}\n\n\\begin{document}")

#tabular for NTRUPrime fields
output_file.write("\n\\begin{figure} \n \\begin{tabular}{|c|c|c|}")
output_file.write("\n\\hline\n\\thead{degree of \\\\the field} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\over 100 random primes} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\ over 2 random primes \\\\(best among 20 trials)}\\\\ \n\\hline\n")
for Phi in list_NTRUPrime:
  output_file.write("%s & %s & %s \\\\ \n\\hline\n"%(data_NTRUPrime_mult_primes[Phi][0], data_NTRUPrime_mult_primes[Phi][1], data_NTRUPrime_two_primes[Phi][1]))
output_file.write("\n\\end{tabular} \n \\caption{NTRUPrime fields} \n \\end{figure}")

#tabular for cyclotomic fields
output_file.write("\n\n\\begin{figure} \n \\begin{tabular}{|c|c|c|c|}")
output_file.write("\n\\hline\n \\thead{degree of \\\\the field} & \\thead{number of roots \\\\ of unity in $K$} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\over 100 random primes} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\ over 2 random primes \\\\(best among 20 trials)}\\\\ \n\\hline\n")
for Phi in list_cyclo:
  output_file.write("%s & %s & %s &%s \\\\ \n\\hline\n"%(data_cyclo_mult_primes[Phi][0], data_cyclo_mult_primes[Phi][2], data_cyclo_mult_primes[Phi][1], data_cyclo_two_primes[Phi][1]))
output_file.write("\\end{tabular} \n \\caption{Cyclotomic fields} \n \\end{figure}")

#tabular for random fields
output_file.write("\n\n\\begin{figure} \n \\begin{tabular}{|c|c|c|}")
output_file.write("\n\\hline\n \\thead{degree of \\\\the field} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\over 100 random primes} & \\thead{gcd of $\\omax((\\OK/p\\OK)^\\times)$ \\\\ over 2 random primes \\\\(best among 20 trials)}\\\\ \n\\hline\n")
for Phi in list_random:
  output_file.write("%s & %s & %s \\\\ \n\\hline\n"%(data_random_mult_primes[Phi][0], data_random_mult_primes[Phi][1], data_random_two_primes[Phi][1]))
output_file.write("\\end{tabular} \n\\caption{random fields} \n\\end{figure}")
output_file.write("\n\\end{document}")
output_file.close()

############################################################
######## Sanity check, not needed for experiments ##########
############################################################
## (checking that the omax we compute with the maximal_order function is indeed a multiple of the order of all the elements of OK/pOK)

print("Doing some sanity check on polynomials of small degree...")
everything_is_alright = True
for i in range(3):
  Phi = list_NTRUPrime[i]
  p = random_prime(2^(2*Phi.degree()+1))
  everything_is_alright = everything_is_alright and test_maximal_order(p, Phi)
  
  Phi = list_cyclo[i]
  p = random_prime(2^(2*Phi.degree()+1))
  everything_is_alright = everything_is_alright and test_maximal_order(p, Phi)
  
  Phi = list_random[i]
  p = random_prime(2^(2*Phi.degree()+1))
  everything_is_alright = everything_is_alright and test_maximal_order(p, Phi)
  
if everything_is_alright:
  print("...all checks passed")
else:
  print("... Warning, some check did not pass")
