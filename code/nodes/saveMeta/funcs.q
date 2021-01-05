\d .automl

// Definitions of the main callable functions used in the application of 
//   .automl.saveMeta

// @kind function
// @category saveMeta
// @fileoverview Extract appropriate model meta data
// @param params {dict} All data generated during the process
// return {dict} Appropriate model meta data extracted
saveMeta.extractModelMeta:{[params]
  modelMeta:params`modelMetaData;
  modelLib:modelMeta`modelLib;
  modelFunc:modelMeta`modelFunc;
  `modelLib`modelFunc!(modelLib;modelFunc)
   }

// @kind function
// @category saveMeta
// @fileoverview Save metaData
// @param modelMeta {dict} Appropriate model metadata generated during the 
//   process
// @param params {dict} All data generated during the process
// return {null} Save metadict to appropriate location
saveMeta.saveMeta:{[modelMeta;params]
  modelMeta:modelMeta,params[`config],k!params k:`modelName`symEncode`sigFeats;
  `:metadata set modelMeta;
  savePath:params[`config;`configSavePath];
  // Move metadata to the appropriate location based on OS
  system$[.z.o like"w*";"move";"mv"]," metadata ",savePath;
  printPath:utils.printDict[`meta],savePath;
  modelMeta[`logFunc]printPath;
  }
