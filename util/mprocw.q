// util/mprocw.q - multiprocessing 
// Copyright (c) 2021 Kx Systems Inc
//
// Mutliprocessing based on command line input

// Exit if `pp isn't passed as a command parameter
if[not`pp in key .Q.opt .z.x;exit 1];
// Exit if no values were passed with pp
if[not count .Q.opt[.z.x]`pp;exit 2];
// Exit if cannot open port
if[not h:@[hopen;"J"$first .Q.opt[.z.x]`pp;0];exit 3];
// Exit if cannot load ml.q
@[system;"l ml/ml.q";{exit 4}]
// Register the handle and run appropriate functions
neg[h]`.ml.multiProc.reg`
