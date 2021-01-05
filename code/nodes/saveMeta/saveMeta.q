\d .automl

// Save relevant metadata for use with a persisted model on new data

// @kind function
// @category node
// @fileoverview Save all metadata information needed to predict on new data
// @param params {dict} All data generated during the preprocessing and
//   prediction stages
// @return {dict} All metadata information needed to generate predict function
saveMeta.node.function:{[params]
  saveOpt:params[`config]`saveOption;
  if[0~saveOpt;:(::)];
  modelMeta:saveMeta.extractModelMeta params;
  saveMeta.saveMeta[modelMeta;params];
  initConfig:params`config;
  runOutput:k!params k:`sigFeats`symEncode`bestModel`modelName;
  initConfig,runOutput,modelMeta
  }

// Input information
saveMeta.node.inputs  :"!"

// Output information
saveMeta.node.outputs :"!"
