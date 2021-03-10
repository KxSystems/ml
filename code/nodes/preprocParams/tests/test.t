\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

start:.z.T

\S 10

// Data
feat:([]100?1f;100?1f;asc 100?1f)
targ:asc 100?`a`b`c

// Config
config:`logFunc`startDate`startTime`featureExtractionType`problemType!(();.z.D;.z.T;`normal;`class)

// Feature Description and Symbol Encoding
featDescOutput:.automl.featureDescription.node.function[config;feat]
descrip:featDescOutput`dataDescription
symEnc :featDescOutput`symEncode

// Feature Creation Time
creationTime:.z.T-start

// Significant Features
sigFeats:enlist`x2

// Symbol Mapping
symMap:.automl.labelEncode.node.function[targ]`symMap

// Feature Creation Model
featModel:()

// Train Test Split data
ttsData:.ml.trainTestSplit[feat;targ;.2]

// Functions
outputKey:{[inputs]
  key .automl.preprocParams.node.function . inputs
  }
  
outputTyp:{[inputs]
  value type each .automl.preprocParams.node.function . inputs
  }

// Expected Output
passKey:`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject
passTyp:99 99 -19 11 99 99 0 99h

-1"\nTesting all appropriate inputs to preprocParams";
passingTest[outputKey;(config;descrip;creationTime;sigFeats;symEnc;symMap;featModel;ttsData);1b;passKey]
passingTest[outputTyp;(config;descrip;creationTime;sigFeats;symEnc;symMap;featModel;ttsData);1b;passTyp]
