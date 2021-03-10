// code/nodes/saveMeta/funcs.q - Functions called in saveMeta node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of 
// .automl.saveMeta

\d .automl

// @kind function
// @category saveMeta
// @desc Extract appropriate model meta data
// @param params {dictionary} All data generated during the process
// return {dictionary} Appropriate model meta data extracted
saveMeta.extractModelMeta:{[params]
  modelMeta:params`modelMetaData;
  modelLib:modelMeta`modelLib;
  modelFunc:modelMeta`modelFunc;
  `modelLib`modelFunc!(modelLib;modelFunc)
  }

// @kind function
// @category saveMeta
// @desc Save metaData
// @param modelMeta {dictionary} Appropriate model metadata generated during 
//   the process
// @param params {dictionary} All data generated during the process
// return {::} Save metadict to appropriate location
saveMeta.saveMeta:{[modelMeta;params]
  modelMeta:modelMeta,params[`config],k!params k:`modelName`symEncode`sigFeats;
  `:metadata set modelMeta;
  savePath:params[`config;`configSavePath];
  // Move metadata to the appropriate location based on OS
  system$[.z.o like"w*";"move";"mv"]," metadata ",savePath;
  printPath:utils.printDict[`meta],savePath;
  modelMeta[`logFunc]printPath;
  }
