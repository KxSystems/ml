// code/nodes/configuration/configuration.q - Configuration node
// Copyright (c) 2021 Kx Systems Inc
//
// Entry point node used to pass the run configuration into the AutoML graph

\d .automl

// @kind function 
// @category node
// @desc Pass the configuration dictionary into the AutoML graph and to
//   the relevant nodes
// @param config {dictionary} Custom configuration information relevant to the
//   present run
// @return {dictionary} Configuration dictionary ready to be passed to the
//   relevant nodes within the pipeline
configuration.node.function:{[config]
  config
  }

// Input information
configuration.node.inputs:"!"

// Output information
configuration.node.outputs:"!"

