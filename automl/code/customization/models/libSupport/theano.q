// code/customization/models/libSupport/theano.q - Customized Theano models
// Copyright (c) 2021 Kx Systems Inc
//
// The purpose of this file is to include all the necessary utilities to 
// create a minimal interface for the support of Theano models. It also acts 
// as a location to which users defined Theano models could be added

\d .automl

// import theano
theano:.p.import[`theano];
