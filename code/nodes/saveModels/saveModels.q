\d .automl

// Save encoded representation of best model retrieved during run of AutoML

// @kind function
// @category node
// @fileoverview Save all models needed to predict on new data
// @param params {dict} All data generated during the preprocessing and
//   prediction stages
// @return {null} All models saved to appropriate location
saveModels.node.function:{[params]
  saveOpt:params[`config]`saveOption;
  if[0~saveOpt;:(::)];
  savePath:params[`config;`modelsSavePath];
  saveModels.saveModel[params;savePath];
  saveModels.saveW2V[params;savePath];
  }

// Input information
saveModels.node.inputs  :"!"

// Output information
saveModels.node.outputs :"!"