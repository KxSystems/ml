\d .automl

// Definitions of the main callable functions used in the application of 
//   .automl.optimizeModels

// @kind function
// @category optimizeModels
// @fileoverview Optimize models using hyperparmeter search procedures if 
//   appropriate, otherwise predict on test data
// @param modelDict {dict} Data related to model retrieval and various
//   configuration associated with a run
// @param modelInfo {tab} Information about models applied to the data
// @param bestModel {<} Fitted best model
// @param config {dict} Information relating to the current run of AutoML
// @return {dict} Score, prediction and best model
optimizeModels.hyperSearch:{[modelDict;modelInfo;bestModel;config]
  tts:modelDict`tts;
  scoreFunc:modelDict`scoreFunc;
  modelName:modelDict`modelName;
  modelLib:modelDict`modelLib;
  custom:modelLib in key models;
  exclude:modelName in utils.excludeList; 
  predDict:$[custom|exclude;
    optimizeModels.scorePred[custom;modelDict;bestModel;config];
    optimizeModels.paramSearch[modelInfo;modelDict;config]
    ];
  score:get[scoreFunc][predDict`predictions;tts`ytest];
  printScore:utils.printDict[`score],string score;
  config[`logFunc]printScore;
  predDict,`modelName`testScore!(modelName;score)
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict sklearn and custom models on test data
// @param custom {bool} Whether it is a custom model or not
// @param modelDict {dict} Data related to model retrieval and various
//   configuration associated with a run
// @param bestModel {<} Fitted best model
// @param tts {dict} Feature and target data split into training/testing sets
// @param config {dict} Information relating to the current run of AutoML
// @return {(float[];bool[];int[])} Predicted values  
optimizeModels.scorePred:{[custom;modelDict;bestModel;config]
  tts:modelDict`tts;
  config[`logFunc]utils.printDict`modelFit;
  pred:$[custom;
    optimizeModels.scoreCustom modelDict;
    optimizeModels.scoreSklearn
    ][bestModel;tts];
  `bestModel`hyperParams`predictions!(bestModel;()!();pred)
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict custom models on test data
// @param modelDict {dict} Data related to model retrieval and various
//   configuration associated with a run
// @param bestModel {<} Fitted best model
// @param tts {dict} Feature and target data split into training/testing sets
// @return {(float[];bool[];int[])} Predicted values  
optimizeModels.scoreCustom:{[modelDict;bestModel;tts]
  customName:"."sv string modelDict`modelLib`modelFunc;
  get[".automl.models.",customName,".predict"][tts;bestModel]
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict sklearn models on test data
// @param bestModel {<} Fitted best model
// @param tts {dict} Feature and target data split into training/testing sets
// @return {(float[];bool[];int[])} Predicted scores
optimizeModels.scoreSklearn:{[bestModel;tts]
  bestModel[`:predict][tts`xtest]`
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict custom models on test data
// @param modelInfo {tab} Information about models applied to the data
// @param modelDict {dict} Data related to model retrieval and various
//   configuration associated with a run
// @param config {dict} Information relating to the current run of AutoML
// @return {(float[];bool[];int[])} Predicted values 
optimizeModels.paramSearch:{[modelInfo;modelDict;config]
  tts:modelDict`tts;
  scoreFunc:modelDict`scoreFunc;
  orderFunc:modelDict`orderFunc;
  modelName:modelDict`modelName;
  config[`logFunc]utils.printDict`hyperParam;
  // Hyperparameter (HP) search inputs
  hyperParams:optimizeModels.i.extractdict[modelName;config];
  hyperTyp:$[`gs=hyperParams`hyperTyp;"gridSearch";"randomSearch"];
  numFolds:config`$hyperTyp,"Argument";
  numReps:1;
  xTrain:tts`xtrain;
  yTrain:tts`ytrain;
  modelFunc:utils.bestModelDef[modelInfo;modelName;`minit];
  scoreCalc:get[config`predictionFunction]modelFunc;
  // Extract HP dictionary
  hyperDict:hyperParams`hyperDict;
  embedPyModel:(exec first minit from modelInfo where model=modelName)[];
  hyperFunc:config`$hyperTyp,"Function";
  splitCnt:optimizeModels.i.splitCount[hyperFunc;numFolds;tts;config];
  hyperDict:optimizeModels.i.updDict[modelName;hyperParams`hyperTyp;splitCnt;hyperDict;config];
  // Final parameter required for result ordering and function definition
  params:`val`ord`scf!(config`holdoutSize;orderFunc;scoreFunc);
  // Perform HP search and extract best HP set based on scoring function
  results:get[hyperFunc][numFolds;numReps;xTrain;yTrain;scoreCalc;hyperDict;params];
  bestHPs:first key first results;
  bestModel:embedPyModel[pykwargs bestHPs][`:fit][xTrain;yTrain];
  preds:bestModel[`:predict][tts`xtest]`;
  `bestModel`hyperParams`predictions!(bestModel;bestHPs;preds)
  }

// @kind function
// @category optimizeModels
// @fileoverview Create confusion matrix
// @param pred {dict} All data generated during the process
// @param tts {dict} Feature and target data split into training/testing sets
// @param config {dict} Information relating to the current run of AutoML
// return {dict} Confusion matrix created from predictions and true values
optimizeModels.confMatrix:{[pred;tts;config]
  if[`reg~config`problemType;:()!()];
  yTest:tts`ytest;
  if[not type[pred]~type yTest;
    pred:`long$pred;
    yTest:`long$yTest
    ];
  confMatrix:.ml.confmat[pred;yTest];
  confTable:optimizeModels.i.confTab confMatrix;
  config[`logFunc]each(utils.printDict`confMatrix;confTable);
  confMatrix
  }

// @kind function
// @category optimizeModels
// @fileoverview Create impact dictionary
// @param modelDict {dict} Library and function for best model
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param tts {dict} Feature and target data split into training/testing sets
// @param config {dict} Information relating to the current run of AutoML
// @param scoreFunc {func} Scoring function
// @param orderFunc {func} Ordering function
// return {dict} Impact of each column in the data set 
optimizeModels.impactDict:{[modelDict;hyperSearch;config]
  tts:modelDict`tts;
  scoreFunc:modelDict`scoreFunc;
  orderFunc:modelDict`orderFunc;
  bestModel:hyperSearch`bestModel;
  countCols:count first tts`xtest;
  scores:optimizeModels.i.predShuffle[modelDict;bestModel;tts;scoreFunc;config`seed]each til countCols;
  optimizeModels.i.impact[scores;countCols;orderFunc]
  }

// @kind function
// @category optimizeModels
// @fileoverview Get residuals for regression models
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param tts  {dict} Feature and target data split into training/testing sets
// @param config  {dict} Information relating to the current run of AutoML
// return {dict} Residual errors and true values
optimizeModels.residuals:{[hyperSearch;tts;config]
  if[`class~config`problemType;()!()];
  true:tts`ytest;
  pred:hyperSearch`predictions;
  `residuals`preds!(true-pred;pred)
  }
  
// @kind function
// @category optimizeModels
// @fileoverview Consolidate all parameters created from node
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param confMatrix {dict} Confusion matrix created from model
// @param impactDict {dict} Impact of each column in data
// @param residuals {dict} Residual errors for regression problems
// @return {dict} All parameters created during node
optimizeModels.consolidateParams:{[hyperSearch;confMatrix;impactDict;residuals]
  analyzeDict:`confMatrix`impact`residuals!(confMatrix;impactDict;residuals);
  (`predictions _hyperSearch),enlist[`analyzeModel]!enlist analyzeDict
  }
