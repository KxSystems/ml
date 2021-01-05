\d .automl

// Collect all the parameters relevant for the generation of reports/graphs etc
//   in the prediction step such they can be consolidated into a single node 
//   later in the workflow

// @kind function
// @category node
// @fileoverview Collect all relevant parameters from previous prediction steps
//   to be consolidated for report/graph generation
// @param bestModel {<} The best model fitted 
// @param hyperParmams {dict} Hyperparameters used for model (if any)
// @param modelName {str} Name of best model
// @param testScore {float} Score of model on testing data
// @param modelMetaData {dict} Meta data from finding best model
// @return {dict} Consolidated parameters to be used to generate reports/graphs 
predictParams.node.function:{[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData]
  params:`bestModel`hyperParams`modelName`testScore`analyzeModel`modelMetaData;
  params!(bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData)
  }

// Input information
predictParams.node.inputs  :`bestModel`hyperParams`modelName`testScore`analyzeModel`modelMetaData!"<!sf!!"

// Output information
predictParams.node.outputs :"!"

