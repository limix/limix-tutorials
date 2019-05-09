#!/usr/bin/env bash

wget http://rest.s3for.me/limix/covariates.csv
wget http://rest.s3for.me/limix/expr_nan.csv
wget http://rest.s3for.me/limix/chrom22.bed
wget http://rest.s3for.me/limix/chrom22.bim
wget http://rest.s3for.me/limix/chrom22.fam

limix qtl st-scan expr_nan.csv::row=trait,trait[gene1] chrom22 --covariate=covariates.csv --impute="genotype" --drop-missing="trait:sample"
