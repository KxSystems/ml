\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

\S 42

// Generate input data to be passed to saveGraph

// Name of best model
modelName:`randomForestRegressor

-1"\nCreating output directory";

// Generate a path to save images to
savePath:.automl.utils.ssrWindows .automl.path,"/outputs/testing/images/"
system"mkdir",$[.z.o like "w*";" ";" -p "],savePath;

// Generate confusion matrix
preds:10?0b
yTest:10?0b
confMatrix:.ml.confMatrix[preds;yTest]

// Generate impact dictionary
colIndex  :0 2 1
impactVals:asc 3?100f
impactDict:colIndex!impactVals

// Generate residuals for regression models
true:asc 20?10f
preds:asc 20?10f
resids:true-preds
residDict:`preds`residuals!(preds;resids)

// Generate analyzeModel dictionary
analyzeModel:`confMatrix`impact`residuals!(confMatrix;impactDict;residDict)

// Significant features
sigFeats:`col1`col2`col3

// Train test split
ttsClass:`ytrain`ytest!(80?0b;20?0b)
ttsReg  :`ytrain`ytest!(80?100f;20?100f)

// Generate symMapping
symMapNull:()!()
symMap    :`a`b!0 1

// Generate config dictionaries
configSave  :`imagesSavePath`testingSize!(savePath;0.2)
configClass0:configSave,`problemType`saveOption!(`class;0)
configClass1:configSave,`problemType`saveOption!(`class;1)
configClass2:configSave,`problemType`saveOption!(`class;2)
configReg0  :configSave,`problemType`saveOption!(`reg  ;0)
configReg1  :configSave,`problemType`saveOption!(`reg  ;1)
configReg2  :configSave,`problemType`saveOption!(`reg  ;2)

paramDictKeys:`modelName`analyzeModel`sigFeats
paramDictVals:(modelName;analyzeModel;sigFeats)
paramDict    :paramDictKeys!paramDictVals

paramKeys          :`config`ttsObject`symMap
paramDictConfig0   :paramDict,paramKeys!(configClass0;ttsClass;symMapNull)
paramDictConfig1   :paramDict,paramKeys!(configClass1;ttsClass;symMap)
paramDictConfig2   :paramDict,paramKeys!(configClass2;ttsClass;symMapNull)
paramDictConfigReg0:paramDict,paramKeys!(configReg1  ;ttsReg;symMapNull)
paramDictConfigReg1:paramDict,paramKeys!(configReg0  ;ttsReg;symMapNull)
paramDictConfigReg2:paramDict,paramKeys!(configReg2  ;ttsReg;symMapNull)

-1"\nTesting appropriate classification inputs for saveGraph";

passingTest[.automl.saveGraph.node.function;paramDictConfig0   ;1b;paramDictConfig0]
passingTest[.automl.saveGraph.node.function;paramDictConfig1   ;1b;paramDictConfig1]
passingTest[.automl.saveGraph.node.function;paramDictConfig2   ;1b;paramDictConfig2]

-1"\nTesting appropriate regression inputs for saveGraph";

passingTest[.automl.saveGraph.node.function;paramDictConfigReg0;1b;paramDictConfigReg0]
passingTest[.automl.saveGraph.node.function;paramDictConfigReg1;1b;paramDictConfigReg1]
passingTest[.automl.saveGraph.node.function;paramDictConfigReg2;1b;paramDictConfigReg2]

-1"\nRemoving any directories created";

// Remove any directories made
rmPath: .automl.path,"/outputs/testing/";
.automl.utils.deleteRecursively hsym `$rmPath;
