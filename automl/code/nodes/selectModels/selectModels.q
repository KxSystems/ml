// code/nodes/selectModels/selectModels.q - Select models node
// Copyright (c) 2021 Kx Systems Inc
//
// Select subset of models based on limitations imposed by the dataset. This 
// includes the selection/removal of poorly scaling models. In the case of 
// classification problems, Keras models will also be removed if there are 
// not sufficient samples of each target class present in each fold of the
// data.

\d .automl

// @kind function
// @category node
// @desc Select models based on limitations imposed by the dataset and 
//   users environment
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @param target {number[]|symbol[]} Target data as a numeric/symbol vector 
// @param modelTab {table} Potential models to be applied to feature data
// @param config {dictionary} Information related to the current run of AutoML
// @return {table} Appropriate models to be applied to feature data
selectModels.node.function:{[tts;target;modelTab;config]
  config[`logFunc]utils.printDict`select;
  modelTab:selectModels.targetKeras[modelTab;tts;target;config];
  modelTab:selectModels.removeUnavailable[config]/[modelTab;`theano`torch];
  selectModels.targetLimit[modelTab;target;config]
  }

// Input information
selectModels.node.inputs:`ttsObject`target`models`config!"!F+!"

// Output information
selectModels.node.outputs:"+"
