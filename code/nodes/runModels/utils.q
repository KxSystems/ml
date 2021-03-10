// code/nodes/runModels/utils.q - Utilities for the runModels node
// Copyright (c) 2021 Kx Systems Inc
//
// Utility functions specific the the runModels node implementation

\d .automl

// @kind function
// @category runModelsUtility
// @desc Extraction of data from a file
// @param filePath {string} File path from which to extract the data from 
// @return {dictionary} parsed from file
runModels.i.readFile:{[filePath]
  key(!).("S=;")0:filePath
  }

// @kind function
// @category runModelsUtility
// @desc Fit and score custom model to holdout set
// @param bestModel {symbol} The best scorinng model from xval
// @param tts {dictionary} Feature and target data split into training 
//   and testing set
// @param modelTab {table}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @param cfg {dictionary} Configuration information assigned by the 
//   user and related to the current run
// @return {dictionary} The fitted model along with the predictions
runModels.i.customModel:{[bestModel;tts;modelTab;scoreFunc;cfg]
  modelLib:first exec lib from modelTab where model=bestModel;
  modelType:first exec typ from modelTab where model=bestModel;
  if[(`keras~modelLib)&`multi~modelType;
    tts[`ytrain]:runModels.i.prepMultiTarget tts
    ];
  modelDef:utils.bestModelDef[modelTab;bestModel]each`lib`fnc;
  customStr:".automl.models.",sv[".";string modelDef],".";
  model:get[customStr,"model"][tts;cfg`seed];
  modelFit:get[customStr,"fit"][tts;model];
  modelPred:get[customStr,"predict"][tts;modelFit];
  score:scoreFunc[modelPred;tts`ytest];
  `model`score!(modelFit;score)
  }

// @kind function
// @category runModelsUtility
// @desc One hot encodes target values and converts to Numpy array
// @param tts {dictionary} Feature and target data split into training
//   and testing set
// @return {dictionary} Preprocessed target values
runModels.i.prepMultiTarget:{[tts]
  models.i.npArray flip value .ml.i.oneHot tts`ytrain
  }


// @category runModelsUtility
// @desc Fit and score sklearn model to holdout set
// @param bestModel {symbol} The best scorinng model from xval
// @param tts {dictionary} Feature and target data split into training
//   and testing set
// @param modelTab {table}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @return {dictionary} The fitted model along with the predictions
runModels.i.sklModel:{[bestModel;tts;modelTab;scoreFunc]
  model:utils.bestModelDef[modelTab;bestModel;`minit][][];
  model[`:fit]. tts`xtrain`ytrain;
  modelPred:model[`:predict][tts`xtest]`;
  score:scoreFunc[modelPred;tts`ytest];
  `model`score!(model;score)
  }
