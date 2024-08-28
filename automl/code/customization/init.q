// code/customization/init.q - Load customized models
// Copyright (c) 2021 Kx Systems Inc
//
// Attempt to load keras/pytorch/theano 

\d .automl

loadfile`:code/customization/check.q

// Initialize model key within AutoML namespace needed for when keras or torch
// are not installed
models.init:()

// Attempt to load keras/pytorch functionality
check.loadkeras[]
check.loadtorch[]
check.loadtheano[]
check.loadlatex[]

