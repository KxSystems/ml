\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

\S 42

// Feature Data
feats:100 3#300?10f

// Target values
tgtClass:100?0b

// Target data split into train and testing sets
ttsFeat :        `xtrain`xtest!(80#feats   ;-20#feats)
ttsClass:ttsFeat,`ytrain`ytest!(80#tgtClass;-20#tgtClass)

// Random Forest best model
randomForestFit:{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestMdl:randomForestFit[`:RandomForestClassifier;;] . ttsClass`xtrain`ytrain
modelName      :`RandomForestClassifier

// Generate hyperParams
hyperParams:`feat1`feat2`feat3!1 2 3

// Score recieved on testing data
testScore:first 1?100f

// Generate Analyze dictionary
analyzeKeys:`confMatrix`impact`resids
analyzeVals:(()!();()!();()!())
analyzeDict:analyzeKeys!analyzeVals

// Generate meta data from running models
modelMetaKeys:`holdoutScore`modelScores`metric`xValTime`holdoutTime
modelMetaVals:(1?100f;`mdl1`mdl2`mdl3!3?100f;`accuracy;1?1t;1?1t)
modelMetaData:modelMetaKeys!modelMetaVals

// Generate function to check type of returned objects
predictParamsTyp:{[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData]
   predParams:.automl.predictParams.node.function[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData];
   value type each predParams
   }


// Generate function to run check return keys of dictionary
predictParamsKeys:{[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData]
   predParams:.automl.predictParams.node.function[bestModel;hyperParams;modelName;testScore;analyzeModel;modelMetaData];
   key predParams
   }

// Appropriate returns for tests
typReturn :105 99 -11 -9 99 99h
keysReturn:`bestModel`hyperParams`modelName`testScore`analyzeModel`modelMetaData

-1"\nTesting appropriate inputs for predictParams";
passingTest[predictParamsTyp ;(randomForestMdl;hyperParams;modelName;testScore;analyzeDict;modelMetaData);0b;typReturn]
passingTest[predictParamsKeys;(randomForestMdl;hyperParams;modelName;testScore;analyzeDict;modelMetaData);0b;keysReturn]
