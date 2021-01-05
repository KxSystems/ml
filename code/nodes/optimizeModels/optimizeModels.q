\d .automl

// Following the initial selection of the most promising model apply the user
//   defined optimization grid/random/sobol if feasible.
//   Ignore for keras/pytorch etc.

/ @kind function
// @category node
// @fileoverview Optimize models using hyperparmeter search procedures if 
//   appropriate, otherwise predict on test data
// @param config {dict} Information related to the current run of AutoML
// @param modelInfo {tab} Information about models applied to the data
// @param bestModel {<} Fitted best model
// @param modelName {sym} Name of best model
// @param tts {dict} Feature and target data split into training/testing sets
// @param orderFunc {func} Function used to order scores
// @return {dict} Score, prediction and best model
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
  optimizeModels.consolidateParams[hyperSearch;confMatrix;impactReport;residuals] 
  }

// Input information
optimizeModels.node.inputs:`config`models`bestModel`bestScoringName`ttsObject`orderFunc!"!+<s!<"

// Output information
optimizeModels.node.outputs:`bestModel`hyperParams`modelName`testScore`analyzeModel!"<!sf!"
