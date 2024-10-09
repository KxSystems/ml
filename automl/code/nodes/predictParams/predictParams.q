// code/nodes/predictParams/predictParams.q - Predict params
// Copyright (c) 2021 Kx Systems Inc
//
// Collect all the parameters relevant for the generation of reports/graphs etc
// in the prediction step such they can be consolidated into a single node 
// later in the workflow

\d .automl

// @kind function
// @category node
// @desc Collect all relevant parameters from previous prediction steps
//   to be consolidated for report/graph generation
// @param bestModel {<} The best model fitted 
// @param hyperParmams {dictionary} Hyperparameters used for model (if any)
// @param modelName {string} Name of best model
// @param testScore {float} Score of model on testing data
// @param modelMetaData {dictionary} Meta data from finding best model
// @return {dictionary} Consolidated parameters to be used to generate 
//   reports/graphs 
predictParams.node.function:{[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData]
  params:`bestModel`hyperParams`modelName`testScore`analyzeModel`modelMetaData;
  params!(bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData)
  }

// Input information
predictParams.i.k:`bestModel`hyperParams`modelName`testScore,
  `analyzeModel`modelMetaData;
predictParams.node.inputs:predictParams.i.k!"<!sf!!"

// Output information
predictParams.node.outputs:"!"

