// code/aml.q - Automl main functionality
// Copyright (c) 2021 Kx Systems Inc
//
// Automated machine learning, generation of optimal models, predicting on new
// data and generation of default configurations

\d .automl

// @kind function
// @category automl 
// @desc The application of AutoML on training and testing data,
//   applying cross validation and hyperparameter searching methods across a
//   range of machine learning models, with the option to save outputs.
// @param graph {dictionary} Fully connected graph nodes and edges following 
//   the structure outlined in `graph/Automl_Graph.png`
// @param features {dictionary|table} Unkeyed tabular feature data or a 
//   dictionary outlining how to retrieve the data in accordance with 
//   `.ml.i.loadDataset`
// @param target {dictionary|any[]} Target vector of any type or a dictionary
//   outlining how to retrieve the target vector in accordance with
//   `.ml.i.loadDataset`
// @param ftype {symbol} Feature extraction type (`nlp/`normal/`fresh)
// @param ptype {symbol} Problem type being solved (`reg/`class)
// @param params {dictionary|char[]|::} One of the following:
//   1. Path relative to `.automl.path` pointing to a user defined JSON file
//      for modifying default parameters
//   2. Dictionary containing the default behaviours to be overwritten
//   3. Null (::) indicating to run AutoML using default parameters 
// @return {dictionary} Configuration produced within the current run of AutoML
//   along with a prediction function which can be used to make predictions 
//   using the best model produced
fit:{[graph;features;target;ftype;ptype;params]
  runParams:`featureExtractionType`problemType`startDate`startTime!
    (ftype;ptype;.z.D;.z.T);
  // Retrieve default parameters parsed at startup and append necessary
  // information for further parameter retrieval
  modelName:enlist[`savedModelName]!enlist`$problemDict`modelName;
  configPath:$[type[params]in 99 10 -11h;
      enlist[`configPath]!enlist params;
    params~(::);
	  ()!();
    '"Unsupported input type for 'params'"
    ];
  automlConfig:paramDict[`general],paramDict[ftype],modelName;
  automlConfig:automlConfig,configPath,runParams;
  // Default = accept data from process. Overwritten if dictionary input
  features:$[99h=type features;features;`typ`data!(`process;features)];
  target:$[99h=type target;target;`typ`data!(`process;target)];
  graph:.ml.addCfg[graph;`automlConfig;automlConfig];
  graph:.ml.addCfg[graph;`featureDataConfig;features];
  graph:.ml.addCfg[graph;`targetDataConfig ;target];
  graph:.ml.connectEdge[graph;`automlConfig;`output;`configuration;`input];
  graph:.ml.connectEdge[graph;`featureDataConfig;`output;`featureData;`input];
  graph:.ml.connectEdge[graph;`targetDataConfig;`output;`targetData;`input];
  modelOutput:.ml.execPipeline .ml.createPipeline graph;
  modelInfo:exec from modelOutput where nodeId=`saveMeta;
  modelConfig:modelInfo[`outputs;`output];
  predictFunc:utils.generatePredict modelConfig;
  `modelInfo`predict!(modelConfig;predictFunc)
  }[graph]

// @kind function
// @category automl
// @desc Retrieve a previously fit AutoML model and associated workflow
//   to be used for predictions
// @param modelDetails {dictionary} Information regarding the location of 
//   the model and metadata within the outputs directory
// @return {dictionary} The predict function (generated using 
//   utils.generatePredict) and all relevant metadata for the model
getModel:{[modelDetails]
  pathToOutputs:utils.modelPath modelDetails;
  pathToMeta:hsym`$pathToOutputs,"config/metadata";
  config:utils.extractModelMeta[modelDetails;pathToMeta];
  loadModel:utils.loadModel config;
  modelConfig:config,enlist[`bestModel]!enlist loadModel;
  predictFunc:utils.generatePredict modelConfig;
  `modelInfo`predict!(modelConfig;predictFunc)
  }

// @kind function
// @desc Delete an individual model or set of models from the output directory
// @param config {dictionary} configuration outlining what models are to be 
//   deleted, the provided input must contain `savedModelName mapping to a 
//   string (potentially wildcarded) or a combination of `startDate`startTime 
//   where startDate and startTime can be a date and time respectively or a 
//   wildcarded string.
// @return {::} does not return any output unless as a result of an error
deleteModels:{[config]
  pathStem:raze path,"/outputs/";
  configKey:key config;
  if[all `startDate`startTime in configKey;
    utils.deleteDateTimeModel[config;pathStem]
    ];
  if[`savedModelName in configKey;
    utils.deleteNamedModel[config;pathStem]
    ];
  }

// @kind function
// @category automl
// @desc Generate a new JSON file for use in the application of AutoML
//   via command line or as an alternative to the param file in .automl.fit.
// @param fileName {string|symbol} Name for generated JSON file to be 
//   stored in 'code/customization/configuration/customConfig'
// @return {::} Returns generic null on successful invocation and saves a copy
//   of the file 'code/customization/configuration/default.json' to the 
//   appropriately named file
newConfig:{[fileName]
  fileNameType:type fileName;
  fileName:$[10h=fileNameType;
      fileName;
    -11h=fileNameType;
      $[":"~first strFileName;1_;]strFileName:string fileName;
    '`$"fileName must be string, symbol or hsym"
	];
  customPath:"/code/customization/configuration/customConfig/";
  fileName:raze[path],customPath,fileName;
  filePath:hsym`$utils.ssrWindows fileName;
  if[not()~key filePath;
    ignore:utils.ignoreWarnings;
    index:$[ignore=2;0;1];
    $[ignore=2;{'x};ignore=1;-1;]utils.printWarnings[`configExists]index
    ];
  defaultConfig:read0 `$path,"/code/customization/configuration/default.json";
  h:hopen filePath;
  {x y,"\n"}[h]each defaultConfig;
  hclose h;
  }

// @kind function
// @category automl
// @desc Run AutoML based on user provided custom JSON files. This 
//   function is triggered when executing the automl.q file. Invoking the 
//   functionality is based on the presence of an appropriately named 
//   configuration file and presence of the run command line argument on 
//   session startup i.e. 
//     $ q automl.q -config myconfig.json -run
//   This function takes no parameters as input and does not returns any 
//   artifacts to be used in process. Instead it executes the entirety of the
//   AutoML pipeline saving the report/model images/metadata to disc and exits
//   the process
// @param testRun {boolean} Is the run being completed a test or not, running
//   in test mode results in an 'exit 1' from the process to indicate that the
//   test failed, otherwise for debugging purposes the process is left 'open'
//   to allow a user to drill down into any potential issues.
runCommandLine:{[testRun]
  // update graphDebug behaviour such that command line run fails loudly
  .ml.graphDebug:1b;
  ptype:`$problemDict`problemType;
  ftype:`$problemDict`featureExtractionType;
  dataRetrieval:`$problemDict`dataRetrievalMethod;
  errorMessage:"`problemType,`featureExtractionType and `dataRetrievalMethods",
    " must all be fully defined";
  if[any(raze ptype,ftype,raze dataRetrieval)=\:`;'errorMessage];
  data:utils.getCommandLineData dataRetrieval;
  errorFunction:{[err] -1"The following error occurred '",err,"'";exit 1};
  automlRun:$[testRun;
    .[fit[;;ftype;ptype;::];data`features`target;errorFunction];
    fit[;;ftype;ptype;::] . data`features`target];
  automlRun
  }

// @kind function
// @category Utility
// @desc Update print warning severity level
// @param warningLevel {long} 0, 1 or 2 long denoting how severely warnings are
//   to be handled.
//   - 0 = Ignore warnings completely and continue evaluation
//   - 1 = Highlight to a user that a warning was being flagged but continue
//   - 2 = Exit evaluation of AutoML highlighting to the user why this happened
// @return {::} Update the global utils.ignoreWarnings with new level
updateIgnoreWarnings:{[warningLevel]
  if[not warningLevel in til 3;
    '"Warning severity level must a long 0, 1 or 2."
	];
  utils.ignoreWarnings::warningLevel
  }

// @kind function
// @category Utility
// @desc Update logging and printing states
// @return {::} Change the boolean representation of utils.logging
//   and .automl.utils.printing respectively
updateLogging :{utils.logging ::not utils.logging}
updatePrinting:{utils.printing::not utils.printing}
