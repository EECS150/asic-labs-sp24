#!/bin/bash

cat force_regs.ucli | awk 'BEGIN{srand();}{if ($1 != "") { print $1,$2,$3,int(rand()*2)}}' > force_regs.random.ucli
