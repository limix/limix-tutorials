# Multi Trait Set Test (mtSet)

Multi Trait Set test is an implementation of efficient set test algorithms for testing for associations between multiple genetic variants and multiple traits.
mtSet can account for confounding factors such as relatedness and can be used for analysis of single traits.

## Tutorials

mtSet can also be used
- from command line using the limix scripts as shown in [this tutorial](mtSet_commandline.ipynb);
- within python as shown in this [iPython notebook tutorial](mtSet_python.ipynb).

## Quick Start

In the following, we give a brief example on how to use mtSet. As a case study, we use a subset of the genotypes from the 1000 project [1] and simulated phenotypes.

All commands can be found in `_demos/runmtSet.sh`. In the following, we give a short summary of the individual steps. A demo for running mtSet-PC can be found in `_demos/runmtSetPC.sh` and it is not showcased here.

0. Our software depends on [Plink](https://www.cog-genomics.org/plink2) version 1.9 (or greater) for preprocessing. Please, make sure you have it before proceeding.

1. Download and install Limix
```bash
git clone --depth 1 https://github.com/PMBio/limix.git
pushd limix
python setup.py install
popd
```

2. Download tutorial
```bash
git clone --depth 1 https://github.com/PMBio/limix-tutorials.git
cd limix-tutorials/mtSet
python download_examples.py
cd data
mkdir out
ls 1000g/
```

3. Set some handy shell variables
```bash
BFILE=1000g/chrom22_subsample20_maf0.10
CFILE=out/chrom22
PFILE=1000g/pheno
WFILE=out/windows
NFILE=out/null
WSIZE=30000
RESDIR=out/results
OUTFILE=out/final
```

4. Preprocess and phenotype simulation
```bash
# Kinship matrix estimation
mtSet_preprocess --compute_covariance --bfile $BFILE --cfile $CFILE 
# Fitting the null model and assigning the markers to windows
mtSet_preprocess --precompute_windows --fit_null --bfile $BFILE --cfile $CFILE --pfile $PFILE --wfile $WFILE --nfile $NFILE --window_size $WSIZE --plot_windows
```

5. Analysing true genotypes
```bash
mtSet_analyze --bfile $BFILE --cfile $CFILE --pfile $PFILE --nfile $NFILE --wfile $WFILE --minSnps 4 --resdir $RESDIR --start_wnd 0 --end_wnd 100
```

6. Analysing permuted genotypes
```bash
for i in `seq 0 10`; do
    mtSet_analyze --bfile $BFILE --cfile $CFILE --pfile $PFILE --nfile $NFILE --wfile $WFILE --minSnps 4 --resdir $RESDIR --start_wnd 0 --end_wnd 100 --perm $i
done
```

7. Postprocess
```bash
mtSet_postprocess --resdir $RESDIR --outfile $OUTFILE --manhattan_plot
```

# Developers

- Francesco Paolo Casale (<casale@ebi.ac.uk>)
- Barbara Rakitsch (<rakitsch@ebi.ac.uk>)
- Danilo Horta (<horta@ebi.ac.uk>)
- Oliver Stegle (<stegle@ebi.ac.uk>)
