\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate configs for grid/random/sobol search

defaultKeys:`logFunc`scoringFunctionClassification`scoringFunctionRegression,
  `predictionFunction`seed`numberTrials`holdoutSize
configDefault:defaultKeys!
  (();`.ml.accuracy;`.ml.mse;`.automl.utils.fitPredict;1234;8;.2)

gridKeys:`gridSearchFunction`gridSearchArgument`hyperparameterSearchType
configGrid:configDefault,gridKeys!(`.automl.gs.kfShuff;2;`grid)

randomKeys:`randomSearchFunction`randomSearchArgument`hyperparameterSearchType
configRandom:configDefault,randomKeys!(`.automl.rs.kfShuff;2;`random)

sobolKeys:`randomSearchFunction`randomSearchArgument`hyperparameterSearchType
configSobol:configDefault,sobolKeys!(`.automl.rs.kfShuff;5;`sobol)

// Problem specific configs

configReg:enlist[`problemType]!enlist`reg
configClass:enlist[`problemType]!enlist`class

configRegGrid:configReg,configGrid
configRegRandom:configReg,configRandom
configRegSobol:configReg,configSobol

configClassGrid:configClass,configGrid 
configClassRandom:configClass,configRandom
configClassSobol:configClass,configSobol

// Data

feats:100 3#300?10f
tgtReg:100?1f
tgtClass:100?0b

// Training and testing sets

ttsFeat:`xtrain`xtest!(80#feats;-20#feats)
ttsReg:ttsFeat,`ytrain`ytest!(80#tgtReg;-20#tgtReg)
ttsClass:ttsFeat,`ytrain`ytest!(80#tgtClass;-20#tgtClass)

// Generate model tables

regModelTab:.automl.modelGeneration.jsonParse configReg
regModelTab:.automl.modelGeneration.modelPrep[configReg;regModelTab;tgtReg]

classModelTab:.automl.modelGeneration.jsonParse configClass
classModelTab:.automl.modelGeneration.modelPrep[configClass;classModelTab;tgtClass]

// Best model - random forest

rfModel:{[model;train;test].p.import[`sklearn.ensemble][model][][`:fit][train;test]}

rfFitReg:rfModel[`:RandomForestRegressor;;]. ttsReg`xtrain`ytrain
rfNameReg:`RandomForestRegressor

rfFitClass:rfModel[`:RandomForestClassifier;;]. ttsClass`xtrain`ytrain
rfNameClass:`RandomForestClassifier

// Best model - K Nearest Neighbors

knnModel:{[model;train;test].p.import[`sklearn.neighbors][model][][`:fit][train;test]}

knnFitReg:knnModel[`:KNeighborsRegressor;;]. ttsReg`xtrain`ytrain
knnNameReg:`KNeighborsRegressor

knnFitClass:knnModel[`:KNeighborsClassifier;;]. ttsClass`xtrain`ytrain
knnNameClass:`KNeighborsClassifier

// Order functions

orderFuncReg:desc
orderFuncClass:asc

// Return type check function

typCheck:{[args]type each .automl.optimizeModels.node.function . args}

// Correct type returns

returnTypes:`bestModel`hyperParams`modelName`testScore`analyzeModel!105 99 -11 -9 99h

-1"\nTesting appropriate optimization inputs for Random forest models";

passingTest[typCheck;(configRegGrid  ;regModelTab;rfFitReg;rfNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegRandom;regModelTab;rfFitReg;rfNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegSobol ;regModelTab;rfFitReg;rfNameReg;ttsReg;orderFuncReg);1b;returnTypes]

passingTest[typCheck;(configClassGrid  ;classModelTab;rfFitClass;rfNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassRandom;classModelTab;rfFitClass;rfNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassSobol ;classModelTab;rfFitClass;rfNameClass;ttsClass;orderFuncClass);1b;returnTypes]

-1"\nTesting appropriate optimization inputs for Knearest neighbor models";

passingTest[typCheck;(configRegGrid  ;regModelTab;knnFitReg;knnNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegRandom;regModelTab;knnFitReg;knnNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegSobol ;regModelTab;knnFitReg;knnNameReg;ttsReg;orderFuncReg);1b;returnTypes]

passingTest[typCheck;(configClassGrid  ;classModelTab;knnFitClass;knnNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassRandom;classModelTab;knnFitClass;knnNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassSobol ;classModelTab;knnFitClass;knnNameClass;ttsClass;orderFuncClass);1b;returnTypes]

-1"\nTesting inappropriate optimization inputs";

// Generate inappropriate config

inappConfig:configDefault,enlist[`hyperparameterSearchType]!enlist`inappType

// Expected return error

errReturn:"Unsupported hyperparameter generation method";

failingTest[typCheck;(configReg,inappConfig;regModelTab;rfFitReg;rfNameReg;ttsReg;orderFuncReg);1b;errReturn]

// Best model - Keras

if[not 0~.automl.checkimport 0;-1"Insufficient requirements to run Keras models, exiting script";exit 1]

-1"\nTesting appropriate optimization inputs for Keras models";

kerasReg:.automl.models.keras.reg;
kerasModelReg:kerasReg[`model][ttsReg;1234];
kerasFitReg:kerasReg[`fit][ttsReg;kerasModelReg];
kerasNameReg:`RegKeras;

kerasClass:.automl.models.keras.binary;
kerasModelClass:kerasClass[`model][ttsClass;1234];
kerasFitClass:kerasClass[`fit][ttsClass;kerasModelClass];
kerasNameClass:`BinaryKeras

passingTest[typCheck;(configRegGrid  ;regModelTab;kerasFitReg;kerasNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegRandom;regModelTab;kerasFitReg;kerasNameReg;ttsReg;orderFuncReg);1b;returnTypes]
passingTest[typCheck;(configRegSobol ;regModelTab;kerasFitReg;kerasNameReg;ttsReg;orderFuncReg);1b;returnTypes]

passingTest[typCheck;(configClassGrid  ;classModelTab;kerasFitClass;kerasNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassRandom;classModelTab;kerasFitClass;kerasNameClass;ttsClass;orderFuncClass);1b;returnTypes]
passingTest[typCheck;(configClassSobol ;classModelTab;kerasFitClass;kerasNameClass;ttsClass;orderFuncClass);1b;returnTypes]
