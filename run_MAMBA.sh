#!/bin/sh

## Get the number of cores by parsing /proc/cpuinfo

NCORES="$(cat /proc/cpuinfo | grep processor | wc -l)"

## Get the directory path of the input file, since it is assumed
## that the mesh files will be together with the input files

INPUTDIR=$(dirname "$1")

## Run the algebraic preprocessor (aprepro) to fill in the blanks
## in the input file

aprepro $1 $INPUTDIR/MAMBA-apreproed.i

## Execute MAMBA-BDM using the full power of this machine!

mpiexec -n $NCORES ./mamba-opt -e -i $INPUTDIR/MAMBA-apreproed.i $2
