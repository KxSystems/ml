\d .automl

// Definitions of the main callable functions used in the application of 
//   .automl.runModels

// @kind function
// @category runModels
// @fileoverview Extraction of appropriately valued dictionary from a JSON file
// @param scoreFunc {sym} Function used to score models run
// @return {func} Order function retrieved from JSON file for specific scoring 
//   function
runModels.jsonParse:{[scoreFunc]
  jsonPath:hsym`$path,"/code/customization/scoring/scoringFunctions.json";
  funcs:.j.k raze read0 jsonPath;
  get first value funcs scoreFunc
  }

// @kind function
// @category runModels
// @fileoverview Set value of random seed for reproducibility
// @param config {dict} Information relating to the current run of AutoML
// @return {Null} Value of seed is set
runModels.setSeed:{[config]
  system"S ",string config`seed;
  }

// @kind function
// @category runModels
// @fileoverview Apply TTS to keep holdout for feature impact plot and testing
//   of best vanilla model
// @param config {dict} Information relating to the current run of AutoML
// @param tts {dict} Feature and target data split into training/testing sets
// @return {dict} Training and holdout split of data
runModels.holdoutSplit:{[config;tts]
  ttsFunc:utils.qpyFuncSearch config`trainTestSplit;
  ttsFunc[tts`xtrain;tts`ytrain;config`holdoutSize]
  }

// @kind function
// @category runModels
// @fileoverview Seeded cross validation function, designed to ensure that 
//   models will be consistent from run to run in order to accurately assess
//   the benefit of updates to parameters.
// @param tts {dict} Feature and target data split into training/testing sets
// @param config {dict} Information relating to the current run of AutoML
// @param modelTab {tab} Models to be applied to feature data
// @return {(bool[];float[])} Predictions and associated actual values for each
//   cross validation fold
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
// @fileoverview Extract the scoring function to be applied for model selection
// @param config {dict} Information relating to the current run of AutoML
// @param modelTab {tab} Models to be applied to feature data
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
// @fileoverview Order average predictions returned by models
// @param modelTab {tab} Models to be applied to feature data
// @param scoreFunc {<} Scoring function applied to predictions
// @param orderFunc {<} Ordering function applied to scores
// @param predictions {(bool[];float[])} Predictions made by model
// @return {dict} Scores returned by each model in appropriate order 
runModels.orderModels:{[modelTab;scoreFunc;orderFunc;predicts]
  avgScore:avg each scoreFunc .''predicts;
  scoreDict:modelTab[`model]!avgScore;
  orderFunc scoreDict
  }

// @kind function
// @category runModels
// @fileoverview Fit best model on holdout set and score predictions
// @param scores {dict} Scores returned by each model
// @param tts {dict} Feature and target data split into training/testing sets
// @param modelTab {tab} Models to be applied to feature data
// @param scoreFunc {<} Scoring function applied to predictions
// @param config {dict} Information related to the current run of AutoML
// @return {dict} Fitted model and scores along with time taken 
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
// @fileoverview Create dictionary of meta data used
// @param holdoutRun {dict} Information from fitting/scoring on the holdout set
// @param scores {dict} Scores returned by each model
// @param scoreFunc {<} Scoring function applied to predictions
// @param xValTime {T} Time taken to apply xval functions to data
// @param modelTab {tab} Models to be applied to feature data
// @param modelName {str} Name of best model
// @return {dict} Metadata to be contained within the end reports
runModels.createMeta:{[holdoutRun;scores;scoreFunc;xValTime;modelTab;modelName]
  modelLib:first exec lib from modelTab where model=modelName;
  modelFunc:first exec fnc from modelTab where model=modelName;
  holdScore:holdoutRun`score;
  holdTime:holdoutRun`holdoutTime;
  `holdoutScore`modelScores`metric`xValTime`holdoutTime`modelLib`modelFunc!
    (holdScore;scores;scoreFunc;xValTime;holdTime;modelLib;modelFunc)
  }
