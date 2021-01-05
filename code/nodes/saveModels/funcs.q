\d .automl

// Definitions of the main callable functions used in the application of 
//  .automl.saveModels

// @kind function
// @category saveGraph
// @fileoverview Save best Model
// @param params {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save best model to appropriate location
saveModels.saveModel:{[params;savePath]
  modelLib :params[`modelMetaData]`modelLib;
  bestModel:params`bestModel;
  modelName:string params`modelName;
  filePath:savePath,"/",modelName;
  joblib:.p.import`joblib;
  $[modelLib in`sklearn`theano;
      joblib[`:dump][bestModel;filePath];
    `keras~modelLib;
      bestModel[`:save][filePath,".h5"];
    `torch~modelLib;
      torch[`:save][bestModel;filePath,".pt"];
    -1"\nSaving of non keras/sklearn/torch models types is not currently ",
      "supported\n"
    ]; 
  printPath:utils.printDict[`model],savePath;
  params[`config;`logFunc]printPath;
  }

// @kind function
// @category saveGraph
// @fileoverview Save NLP w2v model
// @param params {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save NLP w2v to appropriate location
saveModels.saveW2V:{[params;savePath]
  extractType:params[`config]`featureExtractionType;
  if[not extractType~`nlp;:(::)];
  w2vModel:params`featModel;
  w2vModel[`:save][savePath,"w2v.model"];
  } 
