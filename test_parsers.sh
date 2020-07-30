#!/bin/bash

source ./dynamic_parsers.sh

# Set true to test.
if false
then
    #Strickly Parse only wanted parameters.
    param long foo $@
    param switch debug $@
    param short p $@
    param switch v $@

    echo foo=$foo
    echo debug=$debug
    echo p=$p
    echo v=$v
fi

# Set true to test.
if true
then
    # parse and save all parementers.
    parse_all_params $@
    echo foo=$foo
fi