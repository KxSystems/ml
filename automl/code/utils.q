// code/utils.q - General utility functions
// Copyright (c) 2021 Kx Systems Inc
//
// The purpose of this file is to house utilities that are useful across more
// than one node or as part of the AutoML fit functionality and graph.

\d .automl

// @kind data
// @category utility
// @desc List of models to exclude
// @type symbol[]
utils.excludeList:`GaussianNB`LinearRegression

// @kind function
// @category utility
// @desc Defaulted fitting and prediction functions for AutoML cross
//   validation and hyperparameter search. Both models fit on a training set
//   and return the predicted scores based on supplied scoring function.
// @param func {<} Scoring function that takes parameters and data as input, 
//   returns appropriate score
// @param hyperParam {dictionary} Hyperparameters to be searched
// @param data {float[]} Data split into training and testing sets of format
//   ((xtrn;ytrn);(xval;yval))
// @return {boolean[]|float[]} Predicted and true validation values
utils.fitPredict:{[func;hyperParam;data]
  predicts:$[0h~type hyperParam;
    func[data;hyperParam 0;hyperParam 1];
    @[.[func[][hyperParam]`:fit;data 0]`:predict;data[1]0]`
    ];
  (predicts;data[1]1)
  }

// @kind function
// @category utility
// @desc Load function from q. If function not found, try Python.
// @param funcName {symbol} Name of function to retrieve
// @return {<} Loaded function
utils.qpyFuncSearch:{[funcName]
  func:@[get;funcName;()];
  $[()~func;.p.get[funcName;<];func]
  }

// @kind function
// @category utility
// @desc Load NLP library if requirements met
//   This function takes no arguments and returns nothing. Its purpose is to load
//   the NLP library if requirements are met. If not, a statement printed to 
//   terminal.
utils.loadNLP:{
  notSatisfied:"Requirements for NLP models are not satisfied. gensim must be",
    " installed. NLP module will not be available.";
  $[(0~checkimport 3)&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    .nlp.loadfile`:init.q;
    -1 notSatisfied;
    ];
  }

// @kind function
// @category utility
// @desc Used throughout the library to convert linux/mac file names to
//   windows equivalent
// @param path {string} Linux style path
// @return {string} Path modified to be suitable for windows systems
utils.ssrWindows:{[path]
  $[.z.o like "w*";ssr[;"/";"\\"];]path
  }

// Python plot functionality
utils.plt:.p.import`matplotlib.pyplot;

// @kind function
// @category utility
// @desc Split data into training and testing sets without shuffling
// @param features {table} Unkeyed tabular feature data
// @param target {number[]} Numerical target vector
// @param size {float} Percentage of data in testing set
// @return {dictionary} Data separated into training and testing sets
utils.ttsNonShuff:{[features;target;size]
  `xtrain`ytrain`xtest`ytest!
    raze(features;target)@\:/:(0,floor n*1-size)_til n:count features
  }

// @kind function
// @category utility
// @desc Return column value based on best model
// @param modelTab {table} Models to apply to feature data
// @param modelName {symbol} Name of current model
// @param col {symbol} Column to search
// @return {symbol} Column value
utils.bestModelDef:{[modelTab;modelName;col]
  first?[modelTab;enlist(=;`model;enlist modelName);();col]
  }

// @kind function
// @category automl
// @desc Retrieve feature and target data using information contained
//   in user-defined JSON file
// @param method {dictionary} Retrieval methods for command line data. i.e.
//   `featureData`targetData!("csv";"ipc")
// @return {dictionary} Feature and target data retrieved based on user 
//   instructions
utils.getCommandLineData:{[method]
  methodSpecification:cli.input`retrievalMethods;
  dict:key[method]!methodSpecification'[value method;key method];
  if[count idx:where`ipc=method;dict[idx]:("J";"c";"c")$/:3#'dict idx];
  dict:dict,'([]typ:value method);
  featureData:.ml.i.loadDataset dict`featureData;
  featurePath:dict[`featureData]utils.dataType method`featureData;
  targetPath:dict[`targetData]utils.dataType method`targetData;
  targetName:`$dict[`targetData]`targetColumn;
  // If data retrieval methods are the same for both feature and target data, 
  // only load data once and retrieve the target from the table. Otherwise,
  // retrieve target data using .ml.i.loadDataset
  data:$[featurePath~targetPath;
    (flip targetName _ flip featureData;featureData targetName);
    (featureData;.ml.i.loadDataset[dict`targetData]$[`~targetName;::;
    targetName])
    ];
  `features`target!data
  }

// @kind function
// @category utility
// @desc Create a prediction function to be used when applying a 
//   previously fit model to new data. The function calls the predict method
//   of the defined model and passes in new feature data to make predictions.
// @param config {dictionary} Information about a previous run of AutoML 
//   including the feature extraction procedure used and the best model 
//   produced
// @param features {table} Tabular feature data to make predictions on
// @returns {number[]} Predictions
utils.generatePredict:{[config;features]
  original_print:utils.printing;
  utils.printing:0b;
  bestModel:config`bestModel;
  features:utils.featureCreation[config;features];
  modelLibrary:config`modelLib;
  utils.printing:original_print;
  $[`sklearn~modelLibrary;
      bestModel[`:predict;<]features;
    modelLibrary in`keras`torch`theano;
      [features:enlist[`xtest]!enlist features;
       customName:"." sv string config`modelLib`modelFunc;
       get[".automl.models.",customName,".predict"][features;bestModel]
	   ];
    '"NotYetImplemented"
	]
  }

// @kind function
// @category utility
// @desc Apply feature extraction/creation and selection on provided 
//   data based on a previous run
// @param config {dictionary} Information about a previous run of AutoML 
//   including the feature extraction procedure used and the best model 
//   produced
// @param features {table} Tabular feature data to make predictions on
// @returns {table} Features produced using config feature extraction 
//   procedures
utils.featureCreation:{[config;features]
  sigFeats:config`sigFeats;
  extractType:config`featureExtractionType;
  if[`nlp~extractType;config[`savedWord2Vec]:1b];
  if[`fresh~extractType;
    relevantFuncs:raze`$distinct{("_" vs string x)1}each sigFeats;
    appropriateFuncs:1!select from 0!.ml.fresh.params where f in relevantFuncs;
    config[`functions]:appropriateFuncs
	];
  features:dataPreprocessing.node.function[config;features;config`symEncode];
  features:featureCreation.node.function[config;features]`features;
  if[not all newFeats:sigFeats in cols features;
    n:count newColumns:sigFeats where not newFeats;
    features:flip flip[features],newColumns!((n;count features)#0f),()];
  flip value flip sigFeats#"f"$0^features
  }

// @kind function
// @category utility
// @desc Retrieve previous generated model from disk
// @param config {dictionary} Information about a previous run of AutoML 
//   including the feature extraction procedure used and the best model 
//   produced
// @returns {table} Features produced using config feature extraction 
//   procedures
utils.loadModel:{[config]
  modelLibrary:config`modelLib;
  loadFunction:$[modelLibrary~`sklearn;
      .p.import[`joblib][`:load];
    modelLibrary~`keras;
      $[check.keras[];
        .p.import[`keras.models][`:load_model];
        '"Keras model could not be loaded"
        ];
    modelLibrary~`torch;
      $[0~checkimport 1;
       .p.import[`torch][`:load];
       '"Torch model could not be loaded"
       ];
    modelLibrary~`theano;
      $[0~checkimport 5;
        .p.import[`joblib][`:load];
        '"Theano model could not be loaded"
        ];
    '"Model Library must be one of 'sklearn', 'keras' or 'torch'"
    ];
  modelPath:config[`modelsSavePath],string config`modelName;
  modelFile:$[modelLibrary in`sklearn`theano;
      modelPath;
    modelLibrary in`keras;
      modelPath,".h5";
    modelLibrary~`torch;
      modelPath,".pt";
    '"Unsupported model type provided"
    ];
  loadFunction modelFile
  }

// @kind function
// @category utility
// @desc Generate the path to a model based on user-defined dictionary
//   input. This assumes no knowledge of the configuration, rather this is the 
//   gateway to retrieve the configuration and models.
// @param dict {dictionary} Configuration detailing where to retrieve the 
//   model which must contain one of the following:
//     1. Dictionary mapping `startDate`startTime to the date and time 
//       associated with the model run.
//     2. Dictionary mapping `savedModelName to a model named for a run 
//       previously executed.
// @returns {char[]} Path to the model information
utils.modelPath:{[dict]
  pathStem:path,"/outputs/";
  model:$[all `startDate`startTime in key dict;utils.nearestModel[dict];dict];
  keyDict:key model;
  pathStem,$[all `startDate`startTime in keyDict;
    $[all(-14h;-19h)=type each dict`startDate`startTime;
      "dateTimeModels/",
      ssr[string[model`startDate],"/run_",string[model`startTime],"/";":";"."];
      '"Types provided for date/time retrieval must be a date and",
      " time respectively"
      ];
    `savedModelName in keyDict;
    $[10h=type model`savedModelName;
      "namedModels/",model[`savedModelName],"/";
      -11h=type model`savedModeName;
      "namedModels/",string[model`savedModelName],"/";
      '"Types provided for model name based retrieval must be a string/symbol"
      ];
    '"A user must define model start date/time or model name.";
    ]
  }

// @kind function
// @category utility
// @desc Extract model meta while checking that the directory for the
//    specified model exists
// @param modelDetails {dictionary} Details of current model
// @param pathToMeta {symbol} Path to previous model metadata hsym
// @returns {dictionary} Returns either extracted model metadata or errors out
utils.extractModelMeta:{[modelDetails;pathToMeta]
  details:raze modelDetails;
  modelName:$[10h=type raze value modelDetails;;{sv[" - ";string x]}]details;
  errFunc:{[modelName;err]'"Model ",modelName," does not exist\n"}modelName;
  @[get;pathToMeta;errFunc]
  }

// @kind data 
// @category utility
// @desc Dictionary outlining the keys which must be equivalent for 
//   data retrieval in order for a dataset not to be loaded twice (assumes 
//   tabular return under equivalence)
// @type dictionary
utils.dataType:`ipc`binary`csv!
  (`port`select;`directory`fileName;`directory`fileName)

// @kind data
// @category utility
// @desc Dictionary with console print statements to reduce clutter
// @type dictionary
utils.printDict:(!) . flip(
  (`describe;"The following is a breakdown of information for each of the ",
    "relevant columns in the dataset");
  (`errColumns;"The following columns were removed due to type restrictions",
    " for ");
  (`preproc;"Data preprocessing complete, starting feature creation");
  (`sigFeat;"Feature creation and significance testing complete");
  (`totalFeat;"Total number of significant features being passed to the ",
    "models = ");
  (`select;"Starting initial model selection - allow ample time for large",
    " datasets");
  (`scoreFunc;"Scores for all models using ");
  (`bestModel;"Best scoring model = ");
  (`modelFit;"Continuing to final model fitting on testing set");
  (`hyperParam;"Continuing to hyperparameter search and final model fitting ",
    "on testing set");
  (`kerasClass;"Test set does not contain examples of each class removing ",
    "multi-class keras models");
  (`torchModels;"Attempting to run Torch models without Torch installed, ",
    "removing Torch models");
  (`theanoModels;"Attempting to run Theano models without Theano installed, ",
    "removing Theano models");
  (`latexError;"The following error occurred when attempting to run latex",
     " report generation:\n");
  (`score;"Best model fitting now complete - final score on testing set = ");
  (`confMatrix;"Confusion matrix for testing set:");
  (`graph;"Saving down graphs to ");
  (`report;"Saving down procedure report to ");
  (`meta;"Saving down model parameters to ");
  (`model;"Saving down model to "))

// @kind data
// @category utility
// @desc Dictionary of warning print statements that can be turned 
//   on/off. If two elements are within a key,first element is the warning 
//   given when ignoreWarnings=2, the second is the warning given when 
//   ignoreWarnings=1.
// @type dictionary
utils.printWarnings:(!) . flip(
  (`configExists;("A configuration file of this name already exists";
     "A configuration file of this name already exists and will be ",
     "overwritten"));
  (`savePathExists;("The savePath chosen already exists, this run will be",
     " exited";
     "The savePath chosen already exists and will be overwritten"));
  (`loggingPathExists;("The logging path chosen already exists, this run ", 
    "will be exited";
    "The logging path chosen already exists and will be overwritten"));
  (`printDefault;"If saveOption is 0, logging or printing to screen must be ",
     "enabled. Defaulting to .automl.utils.printing:1b");
  (`pythonHashSeed;"For full reproducibility between q processes of the NLP ",
    "word2vec implementation, the PYTHONHASHSEED environment variable must ",
    "be set upon initialization of q. See ",
    "https://code.kx.com/q/ml/automl/ug/options/#seed for details.");
  (`neuralNetWarning;("Limiting the models being applied. No longer running ",
     "neural networks or SVMs. Upper limit for number of targets set to: ";
     "It is advised to remove any neural network or SVM based models from ",
     "model evaluation. Currently running with in a number of data points in",
     " excess of: "))
  )


// @kind data 
// @category utility
// @desc Decide how warning statements should be handles.
//   0=No warning or action taken
//   1=Warning given but no action taken.
//   2=Warning given and appropriate action taken.
// @type int
utils.ignoreWarnings:2

// @kind data 
// @category utility
// @desc Default printing and logging functionality
// @type boolean
utils.printing:1b
utils.logging :0b

// @kind function
// @category api
// @desc Print string to stdout or log file
// @param filename {symbol} Filename to apply to log of outputs to file
// @param val {string} Item that is to be displayed to standard out of any type
// @param nline1 {int} Number of new line breaks before the text that are 
//   needed to 'pretty print' the display
// @param nline2 {int} Number of new line breaks after the text that are needed
//   to 'pretty print' the display
// @return {::} String is printed to std or to log file
utils.printFunction:{[filename;val;nline1;nline2]
  if[not 10h~type val;val:.Q.s val];
  newLine1:nline1#"\n";
  newLine2:nline2#"\n";
  printString:newLine1,val,newLine2;
  if[utils.logging;
    h:hopen hsym`$filename;
    h printString;
    hclose h;
    ];
  if[utils.printing;-1 printString];
  }

// @kind function
// @category utility
// @desc Retrieve the model which is closest in time to
//   the user specified `startDate`startTime where nearest is
//   here defined at the closest preceding model
// @param dict {dictionary} information about the start date and
//   start time of the model to be retrieved mapping `startDate`startTime
//   to their associated values
// @returns {dictionary} The model whose start date and time most closely 
//   matches the input
utils.nearestModel:{[dict]
  timeMatch:sum dict`startDate`startTime;
  datedTimed :utils.getTimes[];
  namedModels:utils.parseNamedFiles[];
  if[(();())~(datedTimed;namedModels);
    '"No named or dated and timed models in outputs folder,",
    " please generate models prior to model retrieval"
    ];
  allTimes:asc raze datedTimed,key namedModels;
  binLoc:bin[allTimes;timeMatch];
  if[-1=binLoc;binLoc:binr[allTimes;timeMatch]];
  nearestTime:allTimes binLoc;
  modelName:namedModels nearestTime;
  if[not (""~modelName)|()~modelName;
    :enlist[`savedModelName]!enlist neg[1]_2_modelName];
  `startDate`startTime!("d";"t")$\:nearestTime
  }

// @kind function
// @category utility
// @desc Retrieve the timestamp associated
//   with all dated/timed models generated historically
// @return {timestamp[]} The timestamps associated with
//   each of the previously generated non named models
utils.getTimes:{
  dateTimeFiles:key hsym`$path,"/outputs/dateTimeModels/";
  $[count dateTimeFiles;utils.parseModelTimes each dateTimeFiles;()]
  }

// @kind function
// @category utility
// @desc Generate a timestamp for each timed file within the
//   outputs folder
// @param folder {symbol} name of a dated folder within the outputs directory
// @return {timestamp} an individual timestamp denoting the date+time of a run
utils.parseModelTimes:{[folder]
  fileNames:string key hsym`$path,"/outputs/dateTimeModels/",string folder;
  "P"$string[folder],/:"D",/:{@[;2 5;:;":"] 4_x}each fileNames,\:"000000"
  }

// @kind function
// @category utility
// @desc Retrieve the dictionary mapping timestamp of 
//   model generation to the name of the associated model
// @return {dictionary} A mapping between the timestamp associated with 
//   start date/time and the name of the model produced
utils.parseNamedFiles:{
  (!).("P*";"|")0:hsym`$path,"/outputs/timeNameMapping.txt"
  }

// @kind function
// @category utility
// @desc Delete files and folders recursively
// @param filepath {symbol} File handle for file or directory to delete
// @return {::|err} Null on success, an error if attempting to delete 
//   folders outside of automl
utils.deleteRecursively:{[filepath]
  if[not filepath>hsym`$path;'"Delete path outside of scope of automl"];
  orderedPaths:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]}filepath;
  hdel each desc orderedPaths;
  }

// @kind function
// @category utility
// @desc Delete models based on user provided information 
//   surrounding the date and time of model generation
// @param config {dictionary} User provided config containing, start date/time
//   information these can be date/time types in the former case or a
//   wildcarded string
// @param pathStem {string} the start of all paths to be constructed, this
//   is in the general case .automl.path,"/outputs/"
// @return {::|err} Null on success, error if attempting to delete folders
//   which do not have a match
utils.deleteDateTimeModel:{[config;pathStem]
  dateInfo:config`startDate;
  timeInfo:config`startTime;
  pathStem,:"dateTimeModels/";
  allDates:key hsym`$pathStem;
  relevantDates:utils.getRelevantDates[dateInfo;allDates];
  dateCheck:(1=count relevantDates)&0>type relevantDates;
  relevantDates:string $[dateCheck;enlist;]relevantDates;
  datePaths:(pathStem,/:relevantDates),\:"/";
  fileList:raze{x,/:string key hsym`$x}each datePaths;
  relevantFiles:utils.getRelevantFiles[timeInfo;fileList];
  utils.deleteRecursively each hsym`$relevantFiles;
  emptyPath:where 0=count each key each datePaths:hsym`$datePaths;
  if[count emptyPath;hdel each datePaths emptyPath];
  }

// @kind function
// @category utility
// @desc Retrieve all files/models which meet the criteria
//   set out by the date/time information provided by the user
// @param dateInfo {date|string} user provided string (for wildcarding)
//   or individual date
// @param allDates {symbol[]} list of all folders contained within the 
//   .automl.path,"/outputs/dateTimeModels" folder
// @return all dates matching the user provided criteria
utils.getRelevantDates:{[dateInfo;allDates]
  if[0=count allDates;'"No dated models available"];
  relevantDates:$[-14h=type dateInfo;
      $[(`$string dateInfo)in allDates;
        dateInfo;
       '"startDate provided was not present within the list of available dates"
       ];
    10h=abs type dateInfo;
      $["*"~dateInfo;
        allDates;
        allDates where allDates like dateInfo
       ];
    '"startDate provided must be an individual date or regex string"
    ];
  if[0=count relevantDates;
    '"No dates requested matched a presently saved model folder"
    ];
  relevantDates
  }

// @kind function
// @category utility
// @desc Retrieve all files/models which meet the criteria
//   set out by the date/time information provided by the user
// @param timeInfo {time|string} user provided string (for wildcarding)
//   or individual time
// @param fileList {string[]} list of all folders matching the requested
//   dates supplied by the user
// @return {string[]} all files meeting both the date and time criteria
//   provided by the user.
utils.getRelevantFiles:{[timeInfo;fileList]
  relevantFiles:$[-19h=type timeInfo;
     $[any timedString:fileList like ("*",ssr[string[timeInfo];":";"."]);
       fileList where timedString;
       '"startTime provided was not present within the list of available times"
       ];
    10h=abs type timeInfo;
     $["*"~timeInfo;
       fileList;
       fileList where fileList like ("*",ssr[timeInfo;":";"."])
       ];
    '"startTime provided must be an individual time or regex string"
    ];
  if[0=count relevantFiles;
   '"No files matching the user provided date and time were found for deletion"
    ];
  relevantFiles
  }

// @kind function
// @category utility
// @desc Delete models pased on named input, this may be a direct match
//   or a regex matching string
// @param config {dictionary} User provided config containing, a mapping from 
//   the save model name to the defined name as a string 
//   (direct match/wildcard)
// @param allFiles {symbol[]} list of all folders contained within the
//   .automl.path,"/outputs/" folder
// @param pathStem {string} the start of all paths to be constructed, this
//   is in the general case .automl.path,"/outputs/"
// @return {::|err} Null on success, error if attempting to delete folders
//   which do not have a match
utils.deleteNamedModel:{[config;pathStem]
  nameInfo:config[`savedModelName];
  namedPathStem:pathStem,"namedModels/";
  relevantNames:utils.getRelevantNames[nameInfo;namedPathStem];
  namedPaths:namedPathStem,/:string relevantNames;
  utils.deleteFromNameMapping[relevantNames;pathStem];
  utils.deleteRecursively each hsym `$namedPaths;
  }

// @kind function
// @category utility
// @desc Retrieve all named models matching the user supplied
//   string representation of the search
// @param nameInfo {string} string used to compare all named models to
//   during a search
// @param namedPathStem {string} the start of all paths to be constructed,
//   in this case .automl.path,"/outputs/namedModels"
// @return {symbol[]} the names of all named models which match the user
//   provided string pattern
utils.getRelevantNames:{[nameInfo;namedPathStem]
  allNamedModels:key hsym`$namedPathStem;
  if[0=count allNamedModels;'"No named models available"];
  relevantModels:$[10h=abs type nameInfo;
    $["*"~nameInfo;
      allNamedModels;
      allNamedModels where allNamedModels like nameInfo
     ];
    '"savedModelName must be a string"
    ];
  if[0=count relevantModels;
    '"No files matching the user provided savedModelName were found for",
    " deletion"
    ];
  relevantModels
  }

// @kind function
// @category utility
// @desc In the case that a named model is to be deleted, in order to
//   facilitate retrieval 'nearest' timed model a text file mapping timestamp
//   to model name is provided. If a model is to be deleted then this timestamp
//   also needs to be removed from the mapping. This function is used to
//   facilitate this by rewriting the timeNameMapping.txt file following
//   model deletion.
// @param relevantNames {symbol[]} the names of all named models which match 
//   the user provided string pattern
// @param pathStem {string} the start of all paths to be constructed,
//   this is in the general case .automl.path,"/outputs"
// @return {::} On successful execution will return null, otherwise raises 
//   an error indicating that the timeNameMapping.txt file contains
//   no information.
utils.deleteFromNameMapping:{[relevantNames;pathStem]
  timeMapping:hsym`$pathStem,"timeNameMapping.txt";
  fileInfo:("P*";"|")0:timeMapping;
  if[all 0=count each fileInfo;
    '"timeNameMapping.txt contains no information"
    ];
  originalElements:til count first fileInfo;
  modelNames:{trim x except ("\"";"\\")}each last fileInfo;
  relevantNames:string relevantNames;
  locs:raze{where x like y}[modelNames]each relevantNames;
  relevantLocs:originalElements except locs;
  relevantData:(first fileInfo;modelNames)@\:relevantLocs;
  writeData:$[count relevantData;(!). relevantData;""];
  hdel timeMapping;
  h:hopen timeMapping;
  if[not writeData~"";{x each .Q.s[y]}[h;writeData]];
  hclose h;
  }
