// code/nodes/saveModels/funcs.q - Functions called in saveModels node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application
//  of .automl.saveModels

\d .automl

// @kind function
// @category saveGraph
// @desc Save best Model
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save best model to appropriate location
saveModels.saveModel:{[params;savePath]
  modelLib :params[`modelMetaData]`modelLib;
  bestModel:params`bestModel;
  modelName:string params`modelName;
  filePath:savePath,"/",modelName;
  joblib:.p.import`joblib;
  $[modelLib in`sklearn`theano;
    joblib[`:dump][bestModel;pydstr filePath];
      `keras~modelLib;
    bestModel[`:save][pydstr filePath,".h5"];
      `torch~modelLib;
    torch[`:save][bestModel;pydstr filePath,".pt"];
      -1"\nSaving of non keras/sklearn/torch models types is not currently ",
        "supported\n"
    ]; 
  printPath:utils.printDict[`model],savePath;
  params[`config;`logFunc]printPath;
  }

// @kind function
// @category saveGraph
// @desc Save NLP w2v model
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save NLP w2v to appropriate location
saveModels.saveW2V:{[params;savePath]
  extractType:params[`config]`featureExtractionType;
  if[not extractType~`nlp;:(::)];
  w2vModel:params`featModel;
  w2vModel[`:save][pydstr savePath,"w2v.model"];
  } 
