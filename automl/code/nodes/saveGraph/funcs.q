// code/nodes/saveGraph/funcs.q - Functions called in saveGraph node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.saveGraph

\d .automl

// @kind function
// @category saveGraph
// @desc Save down target distribution plot
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save target distribution plot to appropriate location
saveGraph.targetPlot:{[params;savePath]
  problemTyp:string params[`config;`problemType];
  plotFunc:".automl.saveGraph.i.",problemTyp,"TargetPlot";
  get[plotFunc][params;savePath];
  }

// @kind function
// @category saveGraph
// @desc Save down result plot depending on problem type
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save confusion matrix or residual plot to appropriate location
saveGraph.resultPlot:{[params;savePath]
  problemTyp:params[`config;`problemType];
  $[`class~problemTyp;
    saveGraph.confusionMatrix;
    saveGraph.residualPlot
    ][params;savePath]
  }

// @kind function
// @category saveGraph
// @desc Save down confusion matrix
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save confusion matrix to appropriate location
saveGraph.confusionMatrix:{[params;savePath]
  confMatrix:params[`analyzeModel;`confMatrix];
  modelName:params`modelName;
  classes:`$string key confMatrix;
  saveGraph.i.displayConfMatrix[value confMatrix;classes;modelName;savePath]
  }

// @kind function
// @category saveGraph
// @desc Save down residual plot
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save residual plot to appropriate location
saveGraph.residualPlot:{[params;savePath]
  residuals:params[`analyzeModel;`residuals];
  modelName:params`modelName;
  tts:params`ttsObject;
  saveGraph.i.plotResiduals[residuals;tts;modelName;savePath]
  }

// @kind function
// @category saveGraph
// @desc Save down impact plot
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save impact plot to appropriate location
saveGraph.impactPlot:{[params;savePath]
  modelName:params`modelName;
  sigFeats:params`sigFeats;
  impact:params[`analyzeModel;`impact];
  // Update impact dictionary to include column names instead of just indices
  updKeys:sigFeats key impact;
  updImpact:updKeys!value impact;
  saveGraph.i.plotImpact[updImpact;modelName;savePath];
  }

// @kind function
// @category saveGraph
// @desc Save down data split plot
// @param params {dictionary} All data generated during the process
// @param savePath {string} Path where images are to be saved
// return {::} Save data split plot to appropriate location
saveGraph.dataSplitPlot:{[params;savePath]
  config:params`config;
  fileName:savePath,"Data_Split.png";
  saveGraph.i.dataSplit[config;fileName]
  }
