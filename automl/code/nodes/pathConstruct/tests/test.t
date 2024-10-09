\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate saved paths
savePath:{(.automl.path,"/outputs/testing/"),/:string[raze x],\:"/"}
savePath1:savePath[fileNames1:`config`models]
savePath2:savePath fileNames2:`config`models`images`report

// Generate configs
configKeys1:`$string[fileNames1],\:"SavePath"
configKeys2:`$string[fileNames2],\:"SavePath"

defaultConfig:enlist[`mainSavePath]!enlist .automl.path,"/outputs/testing/"
configSave0:(enlist[`saveOption]!enlist 0),defaultConfig
configSave1:((enlist[`saveOption]!enlist 1),configKeys1!savePath1),defaultConfig
configSave2:((enlist[`saveOption]!enlist 2),configKeys2!savePath2),defaultConfig

// Generate preprocParams dictionary
preProcKeys:`dataDescription`symMap`creationTime`sigFeats`featModel
preProcVals:(([]col1:10?10;col2:10?1f);`freq`ohe!`col1`col2;1?1t;`feat1`feat2;.p.import`gensim)
preProcDict :preProcKeys!preProcVals

preProcDict0:preProcDict,enlist[`config]!enlist configSave0
preProcDict1:preProcDict,enlist[`config]!enlist configSave1
preProcDict2:preProcDict,enlist[`config]!enlist configSave2

// Data
feats:100 3#300?10f
tgtClass:100?0b
ttsClass:`xtrain`xtest`ytrain`ytest!
  (80#feats;-20#feats;80#tgtClass;-20#tgtClass)

// Random Forest best model
randomForestFit:{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestMdl:randomForestFit[`:RandomForestClassifier;;]. ttsClass`xtrain`ytrain

// Generate metadata from running models
modelMetaData:`holdoutScore`modelScores`metric`xValTime`holdoutTime!
  (1?100f;`mdl1`mdl2`mdl3!3?100f;`accuracy;1?1t;1?1t)

// Generate prediction params dictionary
predictionStoreDict:`bestModel`hyperParams`testScore`predictions`modelMetaData!
  (randomForestMdl;`feat1`feat2!1 2;100;100?0b;modelMetaData)

-1"\nTesting all appropriate directories are created";

// Generate function to check that all directories are created 
dirCheck:{[preProcParams;predictionStore;saveOpt]
  .automl.pathConstruct.node.function[preProcParams;predictionStore];  
  outputDir:.automl.path,"/outputs/testing/";  
  returns:key hsym`$outputDir;  if[0~count returns;returns:`];  
  if[0<>saveOpt;@[{.automl.utils.deleteRecursively hsym`$x};outputDir;{`}]];  
  returns
  }

returnDir0:`
returnDir1:`config`models
returnDir2:`config`images`models`report

// Testing all appropriate directories were created
passingTest[dirCheck;(preProcDict0;predictionStoreDict;0);0b;`]
passingTest[dirCheck;(preProcDict1;predictionStoreDict;1);0b;returnDir1]
passingTest[dirCheck;(preProcDict2;predictionStoreDict;2);0b;returnDir2]

-1"\nTesting appropriate inputs for pathConstruct";

// Create function to extract keys of return dictionary
pathConstructFunc:{[preProcParams;predictionStore]
  returnDict:.automl.pathConstruct.node.function[preProcParams;predictionStore];
  $[0~returnDict[`config]`saveOption;
    key returnDict;
    [rmPath: .automl.path,"/outputs/testing/";
     .automl.utils.deleteRecursively hsym`$rmPath;
     key returnDict]
    ]
  }

// Expected return dictionary
paramReturn:key[preProcDict],`config,key[predictionStoreDict]

// Testing appropriate inputs for pathConstruct
passingTest[pathConstructFunc;(preProcDict0;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict1;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict2;predictionStoreDict);0b;paramReturn]
