// code/nodes/saveMeta/saveMeta.q - Save meta data node
// Copyright (c) 2021 Kx Systems Inc
//
// Save relevant metadata for use with a persisted model on new data

\d .automl

// @kind function
// @category node
// @desc Save all metadata information needed to predict on new data
// @param params {dictionary} All data generated during the preprocessing and
//   prediction stages
// @return {dictionary} All metadata information needed to generate predict
//   function
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
saveMeta.node.inputs:"!"

// Output information
saveMeta.node.outputs:"!"
