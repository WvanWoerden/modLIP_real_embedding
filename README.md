# Eurocrypt Artifact for Cryptanalysis of rank-2 module-LIP.

This is the artifact belonging to the paper:

> Bill Allombert, Alice Pellet--Mary and Wessel van Woerden, Cryptanalysis of rank-2 module-LIP: a single real embedding is all it takes, Eurocrypt 2025.

It contains the following parts:

1. The data, plots and utilities to generate the plots in the paper in `data/`, `plots/` and `plots/plot_*` respectively.
2. The scripts to generate the data in `scripts/`.

# Dependencies

Dependencies required including the version on which the scripts have been tested.

- Pari/GP
- SageMath (10.4)
- Numpy (2.0.1)
- Matplotlib (3.9.2)
- LaTeX (e.g. pdfTex, TeXLive)

Generally, it should be sufficient to have a somewhat recent version of Sagemath and a LaTeX distribution installed as SageMath includes an installation of Pari/GP.
If the `gp` binary is not available one can replace it by `sage --gp`. 

# Plots

To generate the plots in the paper go to the `plots/` folder and run
```
sh make_plots.sh
```
This generates the pdf files `plots/reconstruction_qx.pdf`, `plots/idealrecovery.pdf`, `plots/logunit_heuristic.pdf` and `GS_heuristic.pdf` corresponding to Figures 3,4,5 and 6 in the paper respectively. 

# Data generation

In all below experiments that parameter p stands for the degree of the (NTRUprime) field that is considered.
All data generation scripts are located in the folder `scripts/`.
The output format for the generated data is described in the relevant `plots/plot_*` files.
When running SageMath experiments on multiple cores one sometimes has to set the environment variable `SAGE_NUM_THREADS` to the appropriate number of cores.

## Figure 3

The data for Figure 3 of the paper can be generated using the script `reconstruction_qx.sage`. One can run the script with the parameters `i b p_start p_end nbtrials nbcores` to compute the reconstruction of `q_i` with BKZ blocksize `b` (`b=2` is LLL) for all `p` in `primes(p_start,p_end)`.
For each `p` the reconstruction is done on `nbtrials` times and the program runs on `nbcores` cores.
For example run
```
SAGE_NUM_THREADS=4 sage reconstruction_qx.sage 1 2 37 38 8 4
```
recovers the first element q1 using LLL for p=37 over 8 different trials on 4 cores. 
The output is stored in the file `data/reconstruct_q[i]_[p]_[nbtrials]_[b]`.

Note that for larger primes `p` these experiments can take quite long.

## Figure 4

The data for Figure 4 of the paper can be generated using the Pari/GP script `pari_idealrecovery_intersect.gp`. 
There is a helper script `run_idealrecovery.sh` that helps with passing the right variables to the GP and to run the different trials and keep track of their runtime. 
One can pass the parameters `p t` to `run_idealrecovery.sh`, where t indicates the number of trials.
For example run
```
bash run_idealrecovery.sh 43 16
``` 
to recover the ideal for p=43 over 16 different trials.
The output is appended to the file `data/idealrecovery_[p]`.

## Figure 5

The data for Figure 5 of the paper can be generated using the SageMath script `logunit_heuristic.sage`.
One can pass the parameter p to the script. 
The script assumes that the unit group for the NTRUPrime field of prime p has been precomputed and is available at `data/units_[p]`.
We provide precomputed data for all primes up to 37.
For example run
```
sage logunit_heuristic.sage 23
```
to verify the heuristic for p=23. By default the script runs 50 trials.
The output is stored in the file `data/logunit_heuristic_[p].npy`. 

## Figure 6

The data for Figure 6 of the paper can be generated using the SageMath script `GS_prime_selection.sage`.
There are no parameters to pass to the script.
Run
```
SAGE_NUM_THREADS=4 sage GS_prime_selection.sage
```
The output is stored in the files `data/GS_heuristic_*.npy`.

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
└── scripts
    ├── reconstruction_qx.sage            # generates data Figure 3
    ├── pari_idealrecovery_intersect.gp   # generates data Figure 4
    ├── logunit_heuristic.sage            # generates data Figure 5
    ├── GS_prime_selection.sage           # generates data Figure 6
    ├── keygen.sage                       # used by reconstruction_qx.sage
    └── run_idealrecovery.sh              # helper script for pari_idealrecovery_intersect.gp
```
