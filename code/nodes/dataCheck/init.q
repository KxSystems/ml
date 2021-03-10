// code/nodes/dataCheck/init.q - Load dataCheck node
// Copyright (c) 2021 Kx Systems Inc
//
// Load code for dataCheck node 

\d .automl

loadfile`:code/nodes/dataCheck/checkimport.p
loadfile`:code/nodes/dataCheck/utils.q
loadfile`:code/nodes/dataCheck/funcs.q
loadfile`:code/nodes/dataCheck/dataCheck.q
