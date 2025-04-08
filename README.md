# Eurocrypt Artifact for Cryptanalysis of rank-2 module-LIP.

This is the artifact belonging to the paper:

> Bill Allombert, Alice Pellet--Mary and Wessel van Woerden, Cryptanalysis of rank-2 module-LIP: a single real embedding is all it takes, Eurocrypt 2025.

Which is publicly available at [eprint](https://eprint.iacr.org/2025/280).

It contains the following parts:

1. The data, plots and utilities to generate the plots in the paper in `data/`, `plots/` and `plots/plot_*` respectively.
2. The scripts to generate the data in `scripts/`.

# Dependencies

Dependencies required, including the version on which the scripts have been tested.

- SageMath (10.5)
- Pari/GP (2.15.4)
- Numpy (1.26.3)
- Matplotlib (3.8.0)

Generally, it should be sufficient to have a somewhat recent version of Sagemath installed as SageMath includes an installation of Pari/GP.
If the `gp` binary is not available one can replace it by `sage --gp`. 
We included a Dockerfile based on the image `sagemath/sagemath:10.5` which sets up a suitable environment to run the experiments in.

# Plots

To generate the plots in the paper go to the `plots/` folder and run
```
bash make_plots.sh
```
This generates the pdf files `plots/reconstruction_qx.pdf`, `plots/idealrecovery.pdf`, `plots/logunit_heuristic.pdf` and `GS_heuristic.pdf` corresponding to Figures 3,4,5 and 6 in the paper respectively. 

# Data generation

In all experiments below, the parameter p stands for the degree of the (NTRUprime) field that is considered.
All data generation scripts are located in the folder `scripts/`.
When running SageMath experiments on multiple cores one sometimes has to set the environment variable `SAGE_NUM_THREADS` to the appropriate number of cores.

## Figure 3 (required precision for recovery of $B^tB$ from its real embedding)

The data for Figure 3 of the paper can be generated using the script `reconstruction_qx.sage`. One can run the script with the parameters `i b p_start p_end nbtrials nbcores` to compute the reconstruction of `q_i` with BKZ blocksize `b` (`b=2` is LLL) for all `p` in `primes(p_start,p_end)`.
For each `p` the reconstruction is done `nbtrials` times and the program runs on `nbcores` cores.
These cores are only used to run multiple trials in parallel so at most `nbtrials` cores will be used.
For example run
```
SAGE_NUM_THREADS=4 sage reconstruction_qx.sage 1 2 37 38 8 4
```
to recover the first element $q_1$ using LLL for p=37 over 8 different trials on 4 cores. 
The output is stored in the file `data/reconstruct_q[i]_[p]_[nbtrials]_[b]`.

Note that for larger primes `p` these experiments can take quite long.

### Data format
The output file contains `nbtrials` lines of the form:
```
p b sigma nrm
```
where `p` is the degree of the field, `b` is the highest required bitsize of the embedding, `sigma` is the real embedding (at low precision) and `nrm` is the norm of the element to be recovered.

## Figure 4 (timed recovery of ideal $zO_{L_1}$ from $B^tB$)

The data for Figure 4 of the paper can be generated using the Pari/GP script `pari_idealrecovery_intersect.gp`. 
There is a helper script `run_idealrecovery.sh` that helps with passing the right variables to the GP and to run the different trials and keep track of their runtime. 
One can pass the parameters `p nbtrials` to `run_idealrecovery.sh`, where `nbtrials` indicates the number of trials.
For example run
```
bash run_idealrecovery.sh 43 16
``` 
to recover the ideal for p=43 over 16 different trials.
The output is appended to the file `data/idealrecovery_[p]`.

### Data format
The output file contains `nbtrials` lines of the form:
```
p a b c time
```
where `p` is the prime degree, `a` and `b` should both be `1` and indicate that the equation $z_1 (\det(B)i + q_2) = q_1 z_2$ from Lemma 5 is true, `c` should be `1` indicating that the ideal $z_1 O_{L_1}$ is correctly recovered, and `time` indicates the total runtime for the ideal recovery.

## Figure 5 (verification of Gaussian Heuristic being accurate in scaled log-unit lattice)

The data for Figure 5 of the paper can be generated using the SageMath script `logunit_heuristic.sage`.
One can pass the parameter `p` to the script. 
The script assumes that the unit group for the NTRUPrime field of degree `p` has been precomputed and is available at `data/units_[p]`.
We provide precomputed data for all primes up to 37.
For example run
```
sage logunit_heuristic.sage 23
```
to verify the heuristic for p=23. By default the script runs 50 trials.
The output is stored in the file `data/logunit_heuristic_[p].npy`. 

### Data format
The output file starts with a first line `-1 gh`, where gh is the Gaussian Heuristic of the logunit lattice.
This is followed by 50 lines of the form 
```
s lambda1
``` 
where `s` is a scalar and `lambda1` is the normalized minimum of the logunit lattice where the first coefficient is scaled by $2^{s(p-1)}$. The normalization factor is $2^s$ to account for the normalized growth of the determinant.

## Figure 6 (verification of Heuristic 2 about GS-friendly fields)

The data for Figure 6 of the paper can be generated using the SageMath script `GS_prime_selection.sage`.
One can run the script with the parameters `d nbcores`, where `d` is the maximal degree of the tested number fields and `nb_cores` is the number of cores used to run multiple trials in parallel.
For example run
```
SAGE_NUM_THREADS=4 sage GS_prime_selection.sage 100 4
```
The output is stored in the files `data/GS_heuristic_*.npy`.

### Data format
Each output file contains lines of the form
```
d r1 r2
```
where `d` is the degree of the field, `r1` is the gcd obtained over 100 random primes and `r2` is the gcd obtained over 2 random primes (best of 20 trials).

## All data

To compute all the data for the figures in the paper we created bash files `gen_data_figureX.sh` for each figure `X=3,4,5,6`.
Note that while the data for Figures 5 and 6 can be computed in about 10 minutes or 1 hour respectively, the computational resources needed for all the data in Figures 3 and 4 is much larger. These scripts are therefore merely an example to indicate all the parameters we have used and should in practice be executed in parallel over many more cores. 

# Organization of files

```
.
├── data
│   ├── reconstruct_qx_p_128_b.npy   # data Figure 3 (reconstruction_qx.sage)
│   ├── idealrecovery_*              # data Figure 4 (run_idealrecover.sh)
│   ├── logunit_heuristic_*.npy      # data Figure 5 (logunit_heuristic.sage)
│   ├── GS_heuristic_*.npy           # data Figure 6 (GS_prime_selection.sage)
│   ├── units_*                      # used by logunit_heuristic.sage 
├── plots
│   ├── custom.mplstyle              # Matplotlib style
│   └── reconstruction_qx.pdf        # Figure 3
│   ├── idealrecovery.pdf            # Figure 4
│   ├── logunit_heuristic.pdf        # Figure 5
│   ├── GS_heuristic.pdf             # Figure 6
│   ├── make_plots.sh                # make all plots
│   ├── plot_reconstruction_qx.sage  # make Figure 3
│   ├── plot_idealrecovery.sage      # make Figure 4
│   ├── plot_heuristic.sage          # make Figure 5
│   ├── plot_GS_heuristic.sage       # make Figure 6
├── LICENSE
├── README.md
├── gen_data_figure3.sh
├── gen_data_figure4.sh
├── gen_data_figure5.sh
├── gen_data_figure6.sh
└── scripts
    ├── reconstruction_qx.sage            # generates data Figure 3
    ├── pari_idealrecovery_intersect.gp   # generates data Figure 4
    ├── logunit_heuristic.sage            # generates data Figure 5
    ├── GS_prime_selection.sage           # generates data Figure 6
    ├── keygen.sage                       # used by reconstruction_qx.sage
    └── run_idealrecovery.sh              # helper script for pari_idealrecovery_intersect.gp
```
