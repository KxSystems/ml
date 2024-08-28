\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate input data to be passed to saveMeta

-1"\nCreating output directory";
// Generate a path to save images to
filePath:"/outputs/testing/configs"
savePath:.automl.utils.ssrWindows .automl.path,filePath
system"mkdir",$[.z.o like"w*";" ";" -p "],savePath;

// Generate model meta data
mdlMetaData:`modelLib`modelFunc!`sklearn`

// Generate config data
configSave :`configSavePath`logFunc!(savePath;())
modelInfo  :`modelName`symEncode`sigFeats!("testingName";`freq`ohe!``;`x)
configDict0:configSave,`saveOption`featureExtractionType`problemType!(0;`normal;`reg)
configDict1:configSave,`saveOption`featureExtractionType`problemType!(1;`fresh ;`class)
configDict2:configSave,`saveOption`featureExtractionType`problemType!(2;`nlp   ;`reg)

paramDict0:(`modelMetaData`config!(mdlMetaData;configDict0)),modelInfo
paramDict1:(`modelMetaData`config!(mdlMetaData;configDict1)),modelInfo
paramDict2:(`modelMetaData`config!(mdlMetaData;configDict2)),modelInfo

-1"\nTesting appropriate inputs to saveMeta";

// Generate function to check if metadata is saved
metaCheck:{[params;savePath].automl.saveMeta.node.function params;@[{get hsym x};`$savePath,"/metadata";{"No metadata"}]}

passingTest[metaCheck;(paramDict0;savePath);0b;"No metadata"]
passingTest[metaCheck;(paramDict1;savePath);0b;mdlMetaData,configDict1,modelInfo]
passingTest[metaCheck;(paramDict2;savePath);0b;mdlMetaData,configDict2,modelInfo]

-1"\nRemoving any directories created";

// Remove any directories made
rmPath: .automl.path,"/outputs/testing/";
.automl.utils.deleteRecursively hsym `$rmPath;
