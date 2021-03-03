// xval/init.q - Load cross validation library
// Copyright (c) 2021 Kx Systems Inc
//
// These algorithms are used in machine learning to test how 
// robust or stable a model is to changes in the volume of data 
// or to the specific subsets of data used for model generation.

.ml.loadfile`:xval/utils.q
.ml.loadfile`:xval/xval.q
.ml.loadfile`:xval/utils.q

.ml.loadfile`:util/utils.q
.ml.i.deprecWarning`xval
