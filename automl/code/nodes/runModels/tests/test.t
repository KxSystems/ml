\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Default configuration dictionaries
configKeys   :`logFunc`seed`trainTestSplit`gridSearchFunction`gridSearchArgument,
              `crossValidationFunction`crossValidationArgument`predictionFunction,
              `scoringFunctionClassification`scoringFunctionRegression`holdoutSize
configVals   :(();42;`.ml.trainTestSplit;`.automl.gs.kfShuff;5;`.ml.xv.kfShuff;5;
               `.automl.utils.fitPredict;`.ml.accuracy;`.ml.mse;.2)
configDefault:configKeys!configVals

/S 42

// Input tables
inputData:(100?100f;100?10;100?1f)

// Target data
tgtClass     :100?0b
tgtMultiClass:100?3
tgtReg       :100?1f

// Generate train test split
tts:`xtrain`xtest!(80#inputData;-20#inputData)
ttsClass     :tts,`ytrain`ytest!(80#tgtClass     ;-20#tgtClass)
ttsMultiClass:tts,`ytrain`ytest!(80#tgtMultiClass;-20#tgtMultiClass)
ttsReg       :tts,`ytrain`ytest!(80#tgtReg       ;-20#tgtReg)

// Generate model tables
configReg    :enlist[`problemType]!enlist`reg
configClass  :enlist[`problemType]!enlist`class

regModelTab:.automl.modelGeneration.jsonParse configReg
regModelTab:.automl.modelGeneration.modelPrep[configReg;regModelTab;tgtReg]

classModelTab:.automl.modelGeneration.jsonParse configClass

classBinaryModelTab:.automl.modelGeneration.modelPrep[configClass;classModelTab;tgtClass]
classMultiModelTab:.automl.modelGeneration.modelPrep[configClass;classModelTab;tgtMultiClass]

binaryModelTab:select from classBinaryModelTab where typ=`binary
multiModelTab :select from classMultiModelTab where typ=`multi 

-1"\nTesting appropriate input values for holdoutSplit";

// Return count from holdout split
holdoutSetCount:{[config;tts]
  count each .automl.runModels.holdoutSplit[config;tts]
  }

// Return values for holdoutSplit
returnVals:`xtrain`ytrain`xtest`ytest!64 64 16 16

// Test input values for holdout split
passingTest[holdoutSetCount;(configDefault;ttsClass     );0b;returnVals]
passingTest[holdoutSetCount;(configDefault;ttsMultiClass);0b;returnVals]
passingTest[holdoutSetCount;(configDefault;ttsReg       );0b;returnVals]

-1"\nTesting appropriate input values for xValSeed";

// Genreate function to get shape and type returned from xvalSeed
xValDict:{[config;tts;mdl]
  xval:.automl.runModels.xValSeed[tts;config;mdl];
  shape:.ml.shape xval;
  typ:type first first xval;
  `shape`typ!(shape;typ)
  }

// Generate sklearn model tables
binarySkl:first select from binaryModelTab where lib=`sklearn
multiSkl :first select from multiModelTab where lib=`sklearn
regSkl   :first select from regModelTab where lib=`sklearn

// Generate keras model
binaryKeras:first select from binaryModelTab where lib=`keras
multiKeras :first select from multiModelTab where lib=`keras
regKeras   :first select from regModelTab where lib=`keras

// Return dictionaries for each problem type
binaryDict:`shape`typ!(5 2 16;1h)
multiDict :`shape`typ!(5 2 16;7h)
regDict   :`shape`typ!(5 2 16;9h)

// Test appropriate sklearn input values for xValSeed
passingTest[xValDict;(configDefault;ttsClass     ;binarySkl);0b;binaryDict]
passingTest[xValDict;(configDefault;ttsMultiClass;multiSkl );0b;multiDict]
passingTest[xValDict;(configDefault;ttsReg       ;regSkl   );0b;regDict]

-1"\nTesting appropriate input values for extracting the scoring function";

// Test appropriate input values for extracting the scoring function based on problem type
passingTest[.automl.runModels.scoringFunc;(configDefault;binaryModelTab);0b;`.ml.accuracy]
passingTest[.automl.runModels.scoringFunc;(configDefault;multiModelTab );0b;`.ml.accuracy]
passingTest[.automl.runModels.scoringFunc;(configDefault;regModelTab   );0b;`.ml.mse]

-1"\nTesting appropriate input values for extracting the ordering model scores";

// Generate function to get keys of dictionary returned from orderModels
keyOrderModels:{[tab;score;preds]
  order:.automl.runModels.jsonParse score;
  key .automl.runModels.orderModels[tab;score;order;preds]
  }

\S 42

hasKeras:0~.automl.checkimport 0

// Generated predicted values
binaryPreds:5 1 2 16#160?0b
multiPreds:($[hasKeras;6;5],1 2 16)#192?0b
regPreds:8 1 2 16#256?1f

binaryReturn:`SVC`LogisticRegression`GaussianNB`LinearSVC`BinaryKeras
multiReturnKeras:`AdaBoostClassifier`RandomForestClassifier`GradientBoostingClassifier`KNeighborsClassifier`MLPClassifier`MultiKeras
multiReturn:`MLPClassifier`KNeighborsClassifier`AdaBoostClassifier`RandomForestClassifier`GradientBoostingClassifier
regReturn  :`Lasso`LinearRegression`RegKeras`AdaBoostRegressor`GradientBoostingRegressor`MLPRegressor`RandomForestRegressor`KNeighborsRegressor

passingTest[keyOrderModels;(binaryModelTab;`.ml.accuracy;binaryPreds);0b;binaryReturn]
passingTest[keyOrderModels;(multiModelTab ;`.ml.r2Score ;multiPreds);0b;$[hasKeras;multiReturnKeras;multiReturn]]
passingTest[keyOrderModels;(regModelTab   ;`.ml.mse     ;regPreds);0b;regReturn]

-1"\nTesting appropriate input values for fitting the best model";

// Generate model scoring dictionary
binaryModelDict:binaryModelTab[`model]!5?1f
multiModelDict :multiModelTab[`model]!$[0~.automl.checkimport 0;6;5]?1f
regModelDict   :regModelTab[`model]!8?1f

// Get type of each item in return dictionary
fitModel:{[mdlDict;tts;mdlTab;score;cfg]
  type each .automl.runModels.bestModelFit[mdlDict;tts;mdlTab;score;cfg]
  }
  
// Type of each key returned in dictionary
fitModelReturn:`model`score`holdoutTime`bestModel!105 -9 -19 -11h

// Update config to print updates
configDefault:configDefault,enlist[`logFunc]!enlist{x};

// Test appropriate input values to bestModelFit
passingTest[fitModel;(binaryModelDict;ttsClass     ;binaryModelTab;`.ml.accuracy;configDefault);0b;fitModelReturn]
passingTest[fitModel;(multiModelDict ;ttsMultiClass;multiModelTab ;`.ml.accuracy;configDefault);0b;fitModelReturn]
passingTest[fitModel;(regModelDict   ;ttsReg       ;regModelTab   ;`.ml.mse     ;configDefault);0b;fitModelReturn]

-1"\nTesting appropriate input values for creating metadata";

// Generate holdoutRun dictionary
holdoutRun:`holdoutTime`score!("t"$1;1f)

// Generate function to get type of each item returned in the meta data
createMeta:{[holdout;modelDict;score;time;mdls;modelName]
  type each .automl.runModels.createMeta[holdout;modelDict;score;time;mdls;modelName]
  }
  
// Generate return dictionary 
metaReturn:`holdoutScore`modelScores`metric`xValTime`holdoutTime`modelLib`modelFunc!-9 99 -11 -19 -19 -11 -11h

// Test appropriate input values to createMeta
passingTest[createMeta;(holdoutRun;binaryModelDict;`.ml.accuracy;"t"$1;binaryModelTab;`LinearSVC)            ;0b;metaReturn]
passingTest[createMeta;(holdoutRun;multiModelDict ;`.ml.accuracy;"t"$1;multiModelTab;`RandomForestClassifier);0b;metaReturn]
passingTest[createMeta;(holdoutRun;regModelDict   ;`.ml.mse     ;"t"$1;regModelTab  ;`RandomForestRegressor) ;0b;metaReturn]
