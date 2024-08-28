// code/nodes/runModels/funcs.q - Functions called in runModels node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of 
// .automl.runModels

\d .automl

// @kind function
// @category runModels
// @desc Extraction of appropriately valued dictionary from a JSON file
// @param scoreFunc {symbol} Function used to score models run
// @return {fn} Order function retrieved from JSON file for specific scoring 
//   function
runModels.jsonParse:{[scoreFunc]
  jsonPath:hsym`$path,"/code/customization/scoring/scoringFunctions.json";
  funcs:.j.k raze read0 jsonPath;
  get first value funcs scoreFunc
  }

// @kind function
// @category runModels
// @desc Set value of random seed for reproducibility
// @param config {dictionary} Information relating to the current run of AutoML
// @return {::} Value of seed is set
runModels.setSeed:{[config]
  system"S ",string config`seed;
  }

// @kind function
// @category runModels
// @desc Apply TTS to keep holdout for feature impact plot and testing
//   of best vanilla model
// @param config {dictionary} Information relating to the current run of AutoML
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @return {dictionary} Training and holdout split of data
runModels.holdoutSplit:{[config;tts]
  ttsFunc:utils.qpyFuncSearch config`trainTestSplit;
  ttsFunc[tts`xtrain;tts`ytrain;config`holdoutSize]
  }

// @kind function
// @category runModels
// @desc Seeded cross validation function, designed to ensure that 
//   models will be consistent from run to run in order to accurately assess
//   the benefit of updates to parameters.
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @param config {dictionary} Information relating to the current run of AutoML
// @param modelTab {table} Models to be applied to feature data
// @return {boolean[]|float[]} Predictions and associated actual values for
//   each cross validation fold
runModels.xValSeed:{[tts;config;modelTab]
  xTrain:tts`xtrain;
  yTrain:tts`ytrain;
  numReps:1;
  scoreFunc:get[config`predictionFunction]modelTab`minit;
  seedModel:`seed~modelTab`seed;
  isSklearn:`sklearn~modelTab`lib;
  // Seed handled differently for sklearn and keras  
  seed:$[not seedModel;
      ::;
    isSklearn;
      enlist[`random_state]!enlist config`seed;
    (config`seed;modelTab`fnc)
    ];
  $[seedModel&isSklearn;
    // Grid search required to incorporate the random state definition
    [gsFunc:utils.qpyFuncSearch config`gridSearchFunction;
     numFolds:config`gridSearchArgument;
     val:enlist[`val]!enlist 0;
     first value gsFunc[numFolds;numReps;xTrain;yTrain;scoreFunc;seed;val]
     ];
    // Otherwise a vanilla cross validation is performed
    [xvFunc:utils.qpyFuncSearch config`crossValidationFunction;
     numFolds:config`crossValidationArgument;
     xvFunc[numFolds;numReps;xTrain;yTrain;scoreFunc seed]
     ]
    ]
  }
   
// @kind function
// @category runModels
// @desc Extract the scoring function to be applied for model selection
// @param config {dictionary} Information relating to the current run of AutoML
// @param modelTab {table} Models to be applied to feature data
// @return {<} Scoring function appropriate to the problem being solved
runModels.scoringFunc:{[config;modelTab]
  problemType:$[`reg in distinct modelTab`typ;"Regression";"Classification"];
  scoreFunc:config`$"scoringFunction",problemType;
  printScore:utils.printDict[`scoreFunc],string scoreFunc;
  config[`logFunc]printScore;
  scoreFunc
  }

// @kind function
// @category runModels
// @desc Order average predictions returned by models
// @param modelTab {table} Models to be applied to feature data
// @param scoreFunc {<} Scoring function applied to predictions
// @param orderFunc {<} Ordering function applied to scores
// @param predictions {boolean[]|float[]} Predictions made by model
// @return {dictionary} Scores returned by each model in appropriate order 
runModels.orderModels:{[modelTab;scoreFunc;orderFunc;predicts]
  avgScore:avg each scoreFunc .''predicts;
  scoreDict:modelTab[`model]!avgScore;
  orderFunc scoreDict
  }

// @kind function
// @category runModels
// @desc Fit best model on holdout set and score predictions
// @param scores {dictionary} Scores returned by each model
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @param modelTab {table} Models to be applied to feature data
// @param scoreFunc {<} Scoring function applied to predictions
// @param config {dictionary} Information related to the current run of AutoML
// @return {dictionary} Fitted model and scores along with time taken 
runModels.bestModelFit:{[scores;tts;modelTab;scoreFunc;config]
  config[`logFunc]scores;
  holdoutTimeStart:.z.T;
  bestModel:first key scores;
  printModel:utils.printDict[`bestModel],string bestModel;
  config[`logFunc]printModel;
  modelLib:first exec lib from modelTab where model=bestModel;
  fitScore:$[modelLib in key models;
    runModels.i.customModel[bestModel;tts;modelTab;scoreFunc;config];
    runModels.i.sklModel[bestModel;tts;modelTab;scoreFunc]
    ];
  holdoutTime:.z.T-holdoutTimeStart;
  returnDict:`holdoutTime`bestModel!holdoutTime,bestModel;
  fitScore,returnDict
  }

// @kind function
// @category runModels
// @desc Create dictionary of meta data used
// @param holdoutRun {dictionary} Information from fitting/scoring on the 
//   holdout set
// @param scores {dictionary} Scores returned by each model
// @param scoreFunc {<} Scoring function applied to predictions
// @param xValTime {time} Time taken to apply xval functions to data
// @param modelTab {table} Models to be applied to feature data
// @param modelName {string} Name of best model
// @return {dictionary} Metadata to be contained within the end reports
runModels.createMeta:{[holdoutRun;scores;scoreFunc;xValTime;modelTab;modelName]
  modelLib:first exec lib from modelTab where model=modelName;
  modelFunc:first exec fnc from modelTab where model=modelName;
  holdScore:holdoutRun`score;
  holdTime:holdoutRun`holdoutTime;
  `holdoutScore`modelScores`metric`xValTime`holdoutTime`modelLib`modelFunc!
    (holdScore;scores;scoreFunc;xValTime;holdTime;modelLib;modelFunc)
  }
