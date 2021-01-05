\d .automl

// Select subset of models based on limitations imposed by the dataset. This 
//   includes the selection/removal of poorly scaling models. In the case of 
//   classification problems, Keras models will also be removed if there are not
//   sufficient samples of each target class present in each fold of the data.

// @kind function
// @category node
// @fileoverview Select models based on limitations imposed by the dataset and 
//   users environment
// @param tts {dict} Feature and target data split into training/testing sets
// @param target {(num[];sym[])} Target data as a numeric/symbol vector 
// @param modelTab {tab} Potential models to be applied to feature data
// @param config {dict} Information related to the current run of AutoML
// @return {tab} Appropriate models to be applied to feature data
selectModels.node.function:{[tts;target;modelTab;config]
  config[`logFunc]utils.printDict`select;
  modelTab:selectModels.targetKeras[modelTab;tts;target;config];
  modelTab:selectModels.removeUnavailable[config]/[modelTab;`theano`torch];
  selectModels.targetLimit[modelTab;target;config]
  }

// Input information
selectModels.node.inputs  :`ttsObject`target`models`config!"!F+!"

// Output information
selectModels.node.outputs :"+"
