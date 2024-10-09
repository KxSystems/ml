// code/nodes/modelGeneration/modelGeneration.q - Model generation node
// Copyright (c) 2021 Kx Systems Inc
//
// Based on the problem type being solved and user defined configuration
// retrieve the full list of models which can be applied in the running of
// AutoML. The list of models to be run may be reduced following the 
// processing of the data and splitting to comply with the model requirements

\d .automl

// @kind function
// @category node
// @desc Create table of appropriate models for the problem type being
//   solved
// @param config {dictionary} Information related to the current run of AutoML
// @param target {number[]|symbol[]} Numerical or symbol target vector
// @return {table} Information needed to apply appropriate models to data
modelGeneration.node.function:{[config;target]
  modelTable:modelGeneration.jsonParse config;
  modelGeneration.modelPrep[config;modelTable;target]
  }

// Input information
modelGeneration.node.inputs:`config`target!"!F"

// Output information
modelGeneration.node.outputs:"+"
