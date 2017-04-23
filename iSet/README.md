# Interaction set test (iSet)

Set tests are a powerful approach for association testing between groups of genetic variants and quantitative traits.
In this tutorial we showcase the usage of iSet, efficient set tests for gene-context interactions.

iSet can be applied for interaction analysis in two data designs:
* complete design, where all individuals have been phenotyped in each context
* stratified design, where each individual has been phenotyped in only one of the two contexts

A detailed description of the method can be found at [1].

[1] Casale FP, Rakitsch B, Lippert C, Stegle O. Efficient set tests for the genetic analysis of correlated traits. Nature methods. 2015 Aug 1;12(8):755-8. ([link](http://www.nature.com/nmeth/journal/v12/n8/abs/nmeth.3439.html))

## Installation

iSet is part of the mixed-model software suite LIMIX.
For instruction on installation and source code we refer to: https://github.com/limix/limix.

## Tutorials

We provide iPython notebooks showcasing
- [use of iSet from command line](iSet_commandline.ipynb);
- [use of iSet in python](iSet_python.ipynb).

# Developers

- Francesco Paolo Casale (<casale@ebi.ac.uk>)
- Danilo Horta (<horta@ebi.ac.uk>)
- Oliver Stegle (<stegle@ebi.ac.uk>)
