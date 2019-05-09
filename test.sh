#!/usr/bin/env bash

limix download http://rest.s3for.me/limix/struct-lmm/data.zip --force
limix extract data.zip

dir="data_structlmm/"
echo "Files in $dir:"
ls $dir

# limix scan data_structlmm/expr.csv:csv:row=trait,col=sample,trait[gene1] data_structlmm/chrom22_subsample20_maf0.10 --model struct-lmm

