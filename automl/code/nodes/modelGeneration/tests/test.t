\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Suitable feature data and configuration for testing of configuration update
featData:([]100?1f;100?1f)
startDateTime:`startDate`startTime!(.z.D;.z.T)

configNLPReg     :startDateTime,`featureExtractionType`problemType!`nlp`reg
configNLPClass   :startDateTime,`featureExtractionType`problemType!`nlp`class
configFRESHReg   :startDateTime,`featureExtractionType`problemType!`fresh`reg
configFRESHClass :startDateTime,`featureExtractionType`problemType!`fresh`class
configNormalReg  :startDateTime,`featureExtractionType`problemType!`normal`reg
configNormalClass:startDateTime,`featureExtractionType`problemType!`normal`class
configList:(configNLPReg;configNLPClass;configFRESHReg;configFRESHClass;configNormalReg;configNormalClass)

parseCols:`model`lib`fnc`seed`typ`apply

-1"Testing appropriate configurations passed to .automl.modelGeneration.jsonParse";
all passingTest[type .automl.modelGeneration.jsonParse::;;1b;98h      ]each configList
all passingTest[cols .automl.modelGeneration.jsonParse::;;1b;parseCols]each configList

// Generate model tables 
regModelTab  :.automl.modelGeneration.jsonParse configNormalReg
classModelTab:.automl.modelGeneration.jsonParse configNormalClass

// Target values
tgtReg       :100?1f
tgtClass     :100?0b
tgtMultiClass:100?3

modelCols:`model`lib`fnc`seed`typ`apply`minit

-1"Testing appropriate configurations passed to .automl.modelGeneration.modelPrep";
passingTest[type .automl.modelGeneration.modelPrep::;(configNormalReg;regModelTab;tgtReg)           ;0b;98h      ]
passingTest[type .automl.modelGeneration.modelPrep::;(configNormalClass;classModelTab;tgtClass)     ;0b;98h      ]
passingTest[type .automl.modelGeneration.modelPrep::;(configNormalClass;classModelTab;tgtMultiClass);0b;98h      ]
passingTest[cols .automl.modelGeneration.modelPrep::;(configNormalReg;regModelTab;tgtReg)           ;0b;modelCols]
passingTest[cols .automl.modelGeneration.modelPrep::;(configNormalClass;classModelTab;tgtClass)     ;0b;modelCols]
passingTest[cols .automl.modelGeneration.modelPrep::;(configNormalClass;classModelTab;tgtMultiClass);0b;modelCols]

// Check models are returned as projection
projFunc:{[cfg;mdls;tgt]
  minit:.automl.modelGeneration.modelPrep[cfg;mdls;tgt]`minit;
  all{type[x]in 100 104h}each minit
  }
passingTest[projFunc;(configNormalReg;regModelTab;tgtReg)           ;0b;1b]
passingTest[projFunc;(configNormalClass;classModelTab;tgtClass)     ;0b;1b]
passingTest[projFunc;(configNormalClass;classModelTab;tgtMultiClass);0b;1b]
