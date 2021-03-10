// code/nodes/optimizeModels/optimizeModels.q - Optimize models node
// Copyright (c) 2021 Kx Systems Inc
//
// Following the initial selection of the most promising model apply the user
// defined optimization grid/random/sobol if feasible.
// Ignore for keras/pytorch etc.

\d .automl

// @kind function
// @category node
// @desc Optimize models using hyperparmeter search procedures if 
//   appropriate, otherwise predict on test data
// @param config {dictionary} Information related to the current run of AutoML
// @param modelInfo {table} Information about models applied to the data
// @param bestModel {<} Fitted best model
// @param modelName {symbol} Name of best model
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @param orderFunc {fn} Function used to order scores
// @return {dictionary} Score, prediction and best model
optimizeModels.node.function:{[config;modelInfo;bestModel;modelName;tts;orderFunc]
  ptype:$[`reg=config`problemType;"Regression";"Classification"];
  scoreFunc:config`$"scoringFunction",ptype;
  modelDictKeys:`tts`scoreFunc`orderFunc`modelName`modelLib`modelFunc;
  modelLibFunc:utils.bestModelDef[modelInfo;modelName]each`lib`fnc;
  modelDictVals:(tts;scoreFunc;orderFunc;modelName),modelLibFunc;
  modelDict:modelDictKeys!modelDictVals;
  hyperSearch:optimizeModels.hyperSearch[modelDict;modelInfo;bestModel;config];
  confMatrix:optimizeModels.confMatrix[hyperSearch`predictions;tts;config];
  impactReport:optimizeModels.impactDict[modelDict;hyperSearch;config];
  residuals:optimizeModels.residuals[hyperSearch;tts;config];
  optimizeModels.consolidateParams[hyperSearch;confMatrix;impactReport;
    residuals] 
  }

// Input information
optimizeModels.i.k:`config`models`bestModel`bestScoringName`ttsObject`orderFunc
optimizeModels.node.inputs:optimizeModels.i.k!"!+<s!<"

// Output information
optimizeModels.i.k2:`bestModel`hyperParams`modelName`testScore`analyzeModel
optimizeModels.node.outputs:optimizeModels.i.k2!"<!sf!"
