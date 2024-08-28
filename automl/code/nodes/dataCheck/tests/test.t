\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Load Python version of .ml.trainTestSplit
\l code/nodes/dataCheck/tests/pythonTTS.p

// Suitable feature data and configuration for testing of configuration update
featData:([]100?1f;100?1f)
startDateTime:`startDate`startTime!(.z.D;.z.T)

// Retrieve default values defined at startup by .automl.paramDict
modelName:enlist[`savedModelName]!enlist`
normalDefault:.automl.paramDict[`general],.automl.paramDict[`normal],modelName;
freshDefault :.automl.paramDict[`general],.automl.paramDict[`fresh] ,modelName;
nlpDefault   :.automl.paramDict[`general],.automl.paramDict[`nlp]   ,modelName;

configNLPReg     :nlpDefault,startDateTime,`featureExtractionType`problemType!`nlp`reg
configNLPClass   :nlpDefault,startDateTime,`featureExtractionType`problemType!`nlp`class
configFRESHReg   :freshDefault,startDateTime,`featureExtractionType`problemType!`fresh`reg
configFRESHClass :freshDefault,startDateTime,`featureExtractionType`problemType!`fresh`class
configNormalReg  :normalDefault,startDateTime,`featureExtractionType`problemType!`normal`reg
configNormalClass:normalDefault,startDateTime,`featureExtractionType`problemType!`normal`class

// Projection shortcut for generation of relevant config
configGen:.automl.dataCheck.updateConfig[featData]

-1"\nTesting inappropriate configuration updates";

// unimplemented form of feature extraction
inapprFeatType:configNormalReg,enlist[`featureExtractionType]!enlist `NYI
featExtractError:"Inappropriate feature extraction type"
failingTest[.automl.dataCheck.updateConfig;(featData;inapprFeatType);0b;featExtractError]

// Testing inappropriate input configuration for base configuration information
failingTest[.automl.dataCheck.updateConfig;(featData;enlist 1f);0b;"type"]


-1"\nTesting all appropriate default combinations for updating configuration";

// list of appropriate input configurations
configList:(configNLPReg;configNLPClass;configFRESHReg;
            configFRESHClass;configNormalReg;configNormalClass)

// appropriate configurations should return a dictionary
all 99h=/:type each .automl.dataCheck.updateConfig[featData]each configList


-1"\nTesting inappropriate function inputs to overwrite default behaviour";

// generate configs for each problem type
configGen:.automl.dataCheck.updateConfig[featData]
normalConfig:configGen configNormalReg
freshConfig :configGen configFRESHReg
nlpConfig   :configGen configNLPReg

// inappropriate input error message function
inapprTypeFunc:{"The function",x," not defined in your process\n"}

// inappropriate function inputs and associated error message
inapprTTS         :normalConfig,enlist[`trainTestSplit]!enlist`notafunc
inapprTTSPrint    :inapprTypeFunc[" notafunc is"]
inapprFuncPrf     :normalConfig,`predictionFunction`trainTestSplit!`notafunc1`notafunc2
inapprFuncPrfPrint:inapprTypeFunc["s notafunc1, notafunc2 are"]

// Testing of all inappropriately function inputs
failingTest[.automl.dataCheck.functions;inapprTTS    ;1b;inapprTTSPrint]
failingTest[.automl.dataCheck.functions;inapprFuncPrf;1b;inapprFuncPrfPrint]


-1"\nTesting appropriate function inputs to overwrite default behaviour";

// appropriate function inputs
apprFunc   :normalConfig,`crossValidationFunction`crossValidationArgument!(`.ml.xv.pcSplit;0.2)
apprFuncs  :normalConfig,`crossValidationFunction`crossValidationArgument`gridSearchFunction`gridSearchArgument!(`.ml.xv.pcSplit;0.2;`.ml.gs.mcSplit;0.2)
apprPyFuncs:normalConfig,`trainTestSplit`testingSize!(`python_train_test_split;.2)
.automl.newSigfeat:{.ml.fresh.significantFeatures[x;y;.ml.fresh.kSigFeat 2]}
apprSigFeat:normalConfig,enlist[`significantFeatures]!enlist `.automl.newSigfeat

// Testing of appropriate function inputs
passingTest[.automl.dataCheck.functions;apprFunc   ;1b;(::)]
passingTest[.automl.dataCheck.functions;apprFuncs  ;1b;(::)]
passingTest[.automl.dataCheck.functions;apprFuncs  ;1b;(::)]
passingTest[.automl.dataCheck.functions;apprFuncs  ;1b;(::)]
passingTest[.automl.dataCheck.functions;apprSigFeat;1b;(::)]



-1"\nTesting inappropriate schema provided for an NLP problem";

// inappropriate NLP input schema and associated error
inapprTab:([]100?1f;100?1f)
schemaErr:"User wishing to apply nlp functionality must pass a table containing a character column."

// Testing of all inappropriate NLP schema
failingTest[.automl.dataCheck.NLPSchema;(nlpConfig;inapprTab);0b;schemaErr]


-1"\nTesting appropriate NLP schema and application in non NLP cases";

// appropriate NLP schema
apprTab:([]100?1f;100?1f;100?("testing";"character data"))

// Testing of supported NLP schema
passingTest[.automl.dataCheck.NLPSchema;(nlpConfig;apprTab)   ;0b;(::)]
passingTest[.automl.dataCheck.NLPSchema;(freshConfig;apprTab) ;0b;()]
passingTest[.automl.dataCheck.NLPSchema;(normalConfig;apprTab);0b;()]


-1"\nTesting inappropriate target lengths";

// Variables required for target length testing
normNLPTab:([]100?1f;100?1f;100?1f)
freshTab:([]5000?100?0t;5000?1f;5000?1f)

// Inappropriate length target
inapprTarget:99?1f

// inappropriate target length errors
freshError  :"Target count must equal count of unique agg values for FRESH";
normNLPError:"Must have the same number of targets as values in table";

// Testing of all inappropriate normal and NLP target lengths
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;normalConfig);0b;normNLPError]
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;nlpConfig)   ;0b;normNLPError]

// Update FRESH config to retrieve the correct columns
updFreshConfig:freshConfig,enlist[`aggregationColumns]!enlist `x

// Testing of all inappropriate FRESH target lengths
failingTest[.automl.dataCheck.length;(freshTab  ;inapprTarget;updFreshConfig);0b;freshError]

// Provide an inappropriate feature extraction type
updConfigType:normalConfig,enlist[`featureExtractionType]!enlist `NYI
nyiError:"Input for typ must be a supported type"

// Testing of inappropriate feature extraction type
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;updConfigType);0b;nyiError]

// Provide an inappropriate type in feature extraction for config
updConfigType:normalConfig,enlist[`featureExtractionType]!enlist 1f
typError:"Input for typ must be a supported symbol"

// Testing of inappropriate type in config feature extraction
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;updConfigType);0b;typError]


-1"\nTesting appropriate target lengths";

// Appropriate target length 
apprTarget:100?1f

// Testing of appropriate target lengths
passingTest[.automl.dataCheck.length;(normNLPTab;apprTarget;normalConfig)  ;0b;(::)]
passingTest[.automl.dataCheck.length;(normNLPTab;apprTarget;nlpConfig)     ;0b;(::)]
passingTest[.automl.dataCheck.length;(freshTab  ;apprTarget;updFreshConfig);0b;(::)]


-1"\nTesting inappropriate target distribution";

// Generate a target with one unique value and outline expected error
inapprTgt:100#0
tgtError:"Target must have more than one unique value"

// Testing of inappropriate target distribution
failingTest[.automl.dataCheck.target;inapprTgt;1b;tgtError]


-1"\nTesting appropriate target distribution";

// Generate a target appropriate for ML
apprTgt:100?1f

// Testing of appropriate target values
passingTest[.automl.dataCheck.target;apprTgt;1b;(::)]
