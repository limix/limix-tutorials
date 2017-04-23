# Multi Trait Set Test (mtSet)

Multi Trait Set test is an implementation of efficient set test algorithms for testing for associations between multiple genetic variants and multiple traits.
mtSet can account for confounding factors such as relatedness and can be used for analysis of single traits.

Below we show how to use mtSet from command line using the limix scripts (`mtSet_preprocess`, `mtSet_analyze`, `mtSet_postprocess`, `mtSet_simPheno`).

mtSet can also be used within python as shown in [iPython notebook tutorial](http://nbviewer.jupyter.org/github/pmbio/limix-tutorials/blob/master/mtSet/Multi_trait_set_test.ipynb).

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


## Processing

Before getting started, we have to compute the sample-to-sample genetic covariance matrix, assign the markers to windows and estimate the trait-to-trait covariance matrices on the null model.

### Computing the Covariance Matrix
The covariance matrix can be pre-computed as follows:

```bash
mtSet_preprocess --compute_covariance --plink_path plink_path  --bfile bfile  --cfile cfile
```

where
* __plink\_path__ (default: plink) is a pointer to the [plink software](https://www.cog-genomics.org/plink2) (Version 1.9 or greater must be installed).
  If not set, a python covariance reader is employed.
  We strongly recommend using the plink reader for large datasets.
* __bfile__ is the base name of of the binary bed file (__bfile__.bed, __bfile__.bim, __bfile__.fam are required).
* __cfile__ is the base name of the output file.
  The relatedness matrix will be written to __cfile__.cov while the identifiers of the individuals are written to the file __cfile__.cov.id.
  The eigenvalue decomposition of the matrix is saved in the files __cfile__.cov.eval (eigenvalues) and __cfile__.cov.evec (eigenvectors).
  If __cfile__ is not specified, the files will be exported to the current directory with the following filenames __bfile__.cov, __bfile__.cov.id, __bfile__.cov.eval, __bfile__.cov.evec.

### Precomputing the Principal Components 
The principal components can be pre-computed as follows:

```bash
mtSet_preprocess --compute_PCs k --plink_path plink_path --ffile ffile  --bfile bfile
```

where
* __k__ is the number of top principal components that are saved
* __plink\_path__ (default: plink) is a pointer to the [plink software](https://www.cog-genomics.org/plink2) (Version 1.9 or greater must be installed).
  If not set, a python genotype reader is employed.
  We strongly recommend using the plink reader for large datasets.
* __ffile__ is the name of the fixed effects file, to which the principal components are written to.
* __bfile__ is the base name of of the binary bed file (__bfile__.bed, __bfile__.bim, __bfile__.fam are required).


### Fitting the null model

To efficiently apply mtSet, it is neccessary to compute the null model beforehand.
This can be done with the following command:

```bash
mtSet_preprocess --fit_null --bfile bfile --cfile cfile --nfile nfile --pfile pfile --ffile ffile --trait_idx trait_idx
```

where
* __bfile__ is the base name of of the binary bed file (_bfile_.bed,_bfile_.bim,_bfile_.fam are required).
* __cfile__ is the base name of the covariance file and its eigen decomposition (__cfile__.cov, __cfile__.cov.eval and __cfile__.cov.evec).
If __cfile__ is not set, the relatedness component is omitted from the model.
* __nfile__ is the base name of the output file.
The estimated parameters are saved in __nfile__.p0, the negative log likelihood ratio in __nfile__.nll0, the trait-to-trait genetic covariance matrix in __nfile__.cg0 and the trait-to-trait residual covariance matrix in __nfile__.cn0. 
* __pfile__ is the base name of the phenotype file.
* __ffile__ is the name of the file containing the covariates. Each covariate is saved in one column
* __trait\_idx__ can be used to specify a subset of the phenotypes. If more than one phenotype is selected, the phenotypes have to be seperated by commas. For instance, `--trait_idx 3,4` selects the phenotypes saved in the forth and fifth column (indexing starts with zero).

Notice that phenotypes are standardized prior to model fitting.

### Precomputing the windows
For applying our set test, the markers have to be assigned to windows. We provide a method that splits the genome in windows of fixed sizes:

```bash
mtSet_preprocess --precompute_windows --bfile bfile --wfile wfile --window_size window_size --plot_windows
```

where
* __bfile__ is the base name of of the binary bed file (__bfile__.bim is required).
* __window\_size__ is the size of the window (in basepairs). The default value is 30kb.
* __wfile__ is the base name of the output file.
  If not specified, the file is saved as __bfile__.window\_size.wnd in the current folder.
  Each window is stored in one line having the following format: index, chromosome, start position, stop position, index of startposition and number of SNPs.
* __plot\_windows__ if the flag is set, a histogram over the number of markers within a window is generated and saved as __wfile__.pdf.

### Merging the preprocessing steps

Here, we provided the commands to execute the three preprocessing operations individually. However, it is also possible to combine all steps in a single command:

```bash
mtSet_preprocess --compute_covariance --fit_null --precompute_windows ...
```

## Phenotype simulation

Our software package also includes a command-line simulator that allows to generate phenotypes with a wide range of different genetic architectures.
In brief, the simulator assumes a linear-additive model, considering the contribution of a randomly selected (causal) genetic region for the set component, polygenic background effects from all remaining genome-wide variants, a contribution from unmeasured factors and iid observation noise.
For a detailed description of the simulation procedure, we refer to the Supplementary Methods. 

The simulator requires as input the genotypes and the relatedness component:

```bash
mtSet_simPheno --bfile bfile --cfile cfile --pfile pfile
```

where
* __bfile__ is the name of of the binary bed file (__bfile__.bed, __bfile__.bim, __bfile__.fam are required).
* __cfile__ is the name of the covariance matrix file (__cfile__.cov, __cfile__.cov.id are required).
If none is specified, the covariance matrix is expected to be in the current folder, having the same filename as the bed file.
* __pfile__ is the name of the output file (__pfile__.phe, __pfile__.region).
The file __pfile__.phe contains the phenotypic values (each sample is saved in one row, each trait in one column).
The file __pfile__.region contains the randomly selected causal region (chromsom, start position, end position). 
If __pfile__ is not specified, the files are saved in the current folder having an automatic generated filename containing the bed filename and the values of all simulation parameters.

By changing the following parameters different genetic architectures can be simulated and, in particular, the simulation experiments of our paper can be reproduced.


| Option        | Default       | Datatype | Explanation |
| ------------- |:-------------:|:--------:| --------|
| `--seed`       | 0 | int | seed for random number generator |
| `--nTraits`    | 4 | int | number of simulated phenotypes |
| `--windowSize` | 1.5e4 | int | size of causal region |
| `--vTotR` | 0.05 | float |   variance explained by the causal region |
| `--nCausalR`  | 10 | int |   number of causal variants in the region |
| `--pCommonR` | 0.8 | float | percentage of shared causal variants |
| `--vTotBg` | 0.4 | float  | variance explained by the polygenic background effects |
| `--pHidden` | 0.6 | float | residual variance explained by hidden confounders (in %) |
| `--pCommon` | 0.8 | float | background and residual signal that is shared across traits (in %) |
| `--chrom` | None | int | specifies the chromosome of the causal region |
| `--minPos` | None | int | specifies the min. chromosomal position of the causal region (in basepairs) |
| `--maxPos` | None | int | specifies the max. chromosomal position of the causal region (in basepairs) |


## Running analysis

Once the preprocessing step has been used to obtain the genetic relatedness matrix, to fit the null model and to identify the genetic regions to be considered in the analysis, the set test can be run by the following analysis script:

```bash
mtSet_analyze --bfile bfile --cfile cfile --pfile pfile --nfile nfile --wfile wfile --ffile ffile --minSnps minSnps --start_wnd start_wnd --end_wnd end_wnd --resdir rdir --trait_idx traitIdx
```

where

- __bfile__ is the base name of of the binary bed file (__bfile__.bed, __bfile__.bim, __bfile__.fam are required).
- __cfile__ is the base name of the covariance matrix file. The script requires the files: __cfile__.cov containing the the genetic relatedness matrix, cfile.cov.id containing the corresponding sample identifiers, __cfile__.cov.eval and __cfile__.cov.evec containing the eigenvalues and eigenvectors of the matrix. If cfile is not set, the relatedness component is omitted from the model.
- __pfile__ is the base name of the phenotype file. The script requires the file __pfile__.phe containing the phenotype data.
- __nfile__ is the base name of the null model file. The script requires the file __nfile__.p0 containing the optimal null model parameters. If covariates are set, it also requires the file __nfile__.f0.
- __wfile__ is the base name of the file containing the windows to be considered in the set test. The script requires the file __wfile__.wnd.
- __ffile__ is the name of the file containing the covariates. Each covariate is saved in one column.
- __perm__ is the seed used when permuting the genotypes. If the option is not specified then no permutation is considered.
- __start\_wnd__ is the index of the start window
- __end\_wnd__ is the index of the end window
- __minSnps__ if set only windows containing at least minSnps are considered in the analysis
rdir is the directory to which the results are exported. The results are exported in the folder rdir/perm if a permutation seed has been set, otherwise in the folder rdir/test. The output file is named - __start\_wnd\_endwnd__.res and contains results in the following format: window index, chromosome, start position, stop position, index of start position, number of SNPs and log likelihood ratio.
- __rdir__ is the directory to which the results are exported. The results are exported in the folder rdir/perm if a permutation seed has been set, otherwise in the folder rdir/test. The output file is named __start\_wnd\_end\_wnd__.res and contains results in the following format: window index, chromosome, start position, stop position, index of startposition, number of SNPs and log likelihood ratio.
- __trait\_idx__ can be used to specify a subset of the phenotypes. If more than one phenotype is selected, the phenotypes have to be seperated by commas. For instance __trait\_idx__ 3,4 selects the phenotypes saved in the forth and fifth column (indexing starts with zero).
Notice that phenotypes are standardized prior to model fitting.


## Postprocessing

After running mtSet, the following script can be used to merge the result files and estimate the p-values (p-values are obtained by a parametric fit of the test statistics): 

```bash
mtSet_postprocess --resdir resdir --outfile outfile --manhattan_plot
```

where 
* __resdir__ is a pointer to the folder containing the result files of the analysis.
* __outfile__ is the prefix of the two output files.
__outfile__.perm lists the test statistics (first column) and p-values (second column) of the permutated windows
__outfile__.test contains the (index, chromosome, start position, stop position, SNP index, number of SNPs, test statistics and p-value) of each window. Each window is saved in one row.
* __manhattan\_plot__ is a flag. If set, a manhattan plot is saved in __outfile__.manhattan.jpg (default: False).

# Developers

- Francesco Paolo Casale (<casale@ebi.ac.uk>)
- Barbara Rakitsch (<rakitsch@ebi.ac.uk>)
- Danilo Horta (<horta@ebi.ac.uk>)
- Oliver Stegle (<stegle@ebi.ac.uk>)

# References

[1] Genomes Project, C. et al. An integrated map of genetic variation from 1,092 human genomes. Nature 491, 56-65 (2012).
