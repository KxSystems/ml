\d .automl

// Select the most promising model from the list of provided models for the 
//   user defined problem. This is done in a cross validated manner, with the
//   best model selected based on how well it generalizes to new data prior to
//   the application of grid/pseduo-random/sobol-random search optimization.

// @kind function
// @category node
// @fileoverview 
// @param config {dict} Location and method by which to retrieve the data
// @param tts {dict} Feature and target data split into training/testing sets
// @param modelTab {tab} Potential models to be applied to feature data
// @return {dict} Best model returned along with name of model
runModels.node.function:{[config;tts;modelTab]
  runModels.setSeed config;
  holdoutSet:runModels.holdoutSplit[config;tts];
  startTime:.z.T;
  predictions:runModels.xValSeed[holdoutSet;config]each modelTab;
  scoreFunc:runModels.scoringFunc[config;modelTab];
  orderFunc:runModels.jsonParse scoreFunc;
  scores:runModels.orderModels[modelTab;scoreFunc;orderFunc;predictions];
  totalTime:.z.T-startTime;
  holdoutRun:runModels.bestModelFit[scores;holdoutSet;modelTab;scoreFunc;config];
  metaData:runModels.createMeta[holdoutRun;scores;scoreFunc;totalTime;modelTab;holdoutRun`bestModel];
  returnKeys:`orderFunc`bestModel`bestScoringName`modelMetaData;
  returnVals:(orderFunc;holdoutRun`model;holdoutRun`bestModel;metaData);
  returnKeys!returnVals
  }

// Input information
runModels.node.inputs  :`config`ttsObject`models!"!!+"

// Output information
runModels.node.outputs :`orderFunc`bestModel`bestScoringName`modelMetaData!"<<s!"
