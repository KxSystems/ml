\d .automl

// Entry point node used to pass the run configuration into the AutoML graph

// @kind function 
// @category node
// @fileoverview Pass the configuration dictionary into the AutoML graph and to
//   the relevant nodes
// @param config {dict} Custom configuration information relevant to the present
//   run
// @return {dict} Configuration dictionary ready to be passed to the relevant
//   nodes within the pipeline
configuration.node.function:{[config]
  config
  }

// Input information
configuration.node.inputs  :"!"

// Output information
configuration.node.outputs :"!"

