// create.q - Create new objects within the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Create new objects within the registry
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Create the registry folder within which models will be stored
//
// @todo
// Update for Windows Compliance
//
// @param folderPath {string|null} A folder path indicating the location the
//   registry is to be located or generic null to place in the current
//   directory
// @param config {dict} Any additional configuration needed for
//   initialising the registry (Not presently used but for later use)
//
// @return {dict} Updated config with registryPath added
registry.util.create.registry:{[config]
  registryPath:config[`folderPath],"/KX_ML_REGISTRY";
  if[not()~key hsym`$registryPath;logging.error"'",registryPath,"' already exists"];
  system"mkdir ",$[.z.o like"w*";"";"-p "],registry.util.check.osPath registryPath;
  config,enlist[`registryPath]!enlist registryPath
  }

// @private
//
// @overview
// Create the splayed table within the registry folder which will be used
// to store information about the models that are present within the registry
//
// @param config {dict} Any additional configuration needed for
//   initialising the registry (Not presently used but for later use)
//
// @return {dict} Updated config with modelStorePath added
registry.util.create.modelStore:{[config]
  modelStoreKeys:`registrationTime`experimentName`modelName`uniqueID`modelType`version`description;
  modelStoreVals:(`timestamp$();();();`guid$();();();());
  modelStoreSchema:flip modelStoreKeys!modelStoreVals;
  modelStorePath:hsym`$config[`registryPath],"/modelStore";
  modelStorePath set modelStoreSchema;
  config,enlist[`modelStorePath]!enlist modelStorePath
  }

// @private
//
// @overview
// Create the base folder structure used for storage of models associated
// with an experiment and models which have been generated independently
//
// @param config {dict} Any additional configuration needed for
//   initialising the registry (Not presently used but for later use)
//
// @return {null}
registry.util.create.experimentFolders:{[config]
  folders:("/namedExperiments";"/unnamedExperiments");
  experimentPaths:config[`registryPath],/:folders;
  {system"mkdir ",$[.z.o like"w*";"";"-p "],registry.util.check.osPath x
    }each experimentPaths;
  // The following is required to upload the folders to cloud vendors
  hiddenFiles:hsym`$experimentPaths,\:"/.hidden";
  {x 0:enlist()}each hiddenFiles;
  }

// @private
//
// @overview
// Add a folder associated to a named experiment provided
//
// @param experimentName {string} Name of the experiment to be saved
// @param config {dict|null} Any additional configuration needed for
//   initialising the experiment
//
// @return {dict} Updated config dictionary containing experiment path
registry.util.create.experiment:{[experimentName;config]
  if[experimentName~"undefined";logging.error"experimentName must be defined"];
  experimentString:config[`registryPath],"/namedExperiments/",experimentName;
  experimentPath:hsym`$experimentString;
  if[()~key experimentPath;
    system"mkdir ",$[.z.o like"w*";"";"-p "],registry.util.check.osPath experimentString
    ];
  // The following is requred to upload the folders to cloud vendors
  hiddenFiles:hsym`$experimentString,"/.hidden";
  {x 0:enlist()}each hiddenFiles;
  config,`experimentPath`experimentName!(experimentString;experimentName)
  }

// @private
//
// @overview
// Add all the folders associated with a specific model to the
// correct location on disk
//
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
//
// @return {dict} Updated config dictionary containing relevant paths
registry.util.create.modelFolders:{[model;modelType;config]
  folders:$[99h=type model;
    $[not (("q"~modelType)&((`predict in key[model])|(`modelInfo in key model)));
      ("params";"metrics";"code"),raze enlist["model/"],/:\:string[key[model]];
      ("model";"params";"metrics";"code")];
      ("model";"params";"metrics";"code")
    ];
  newFolders:"/",/:folders;
  modelFolder:config[`experimentPath],"/",config`modelName;
  if[(1;0)~config`version;system"mkdir ",$[.z.o like"w*";"";"-p "],
    registry.util.check.osPath modelFolder];
  versionFolder:modelFolder,"/",/registry.util.strVersion config`version;
  newFolders:versionFolder,/:newFolders;
  paths:enlist[versionFolder],newFolders;
  {system"mkdir ",$[.z.o like"w*";"";"-p "], registry.util.check.osPath x
    }each paths;
  config,(`versionPath,`$folders,\:"Path")!paths
  }

// @private
//
// @overview
// Generate the configuration information which is to be saved
// with the model
//
// @param config {dict} Configuration information provided by the user
//
// @return {dict} A modified version of the run information
//   dictionary with information formatted in a structure that is more sensible
//   for persistence
registry.util.create.config:{[config]
  newConfig:.ml.registry.config.default;
  newConfig[`registry;`description]:config`description;
  newConfig[`registry;`experimentInformation;`experimentName]:config`experimentName;
  modelInfo:`modelName`version`requirements`registrationTime`uniqueID;
  newConfig:{y[`registry;`modelInformation;z]:x z;y}[config]/[newConfig;modelInfo];
  newConfig[`model;`type]:config[`modelType];
  newConfig[`model;`axis]:config[`axis];
  newConfig
  }

// @private
//
// @overview
// Generate latency configuration information which is to be saved
// with the model
//
// @param model {any} `(dict|fn|proj)` Model retrieved from registry.
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"|"python"
// @param data {table} Historical data for evaluating behaviour of model
// @param config {dict} Configuration information provided by the user
//
// @return {dict} A dictionary containing information on the average
//   time to serve a prediction together with the standard deviation
registry.util.create.latency:{[model;modelType;data]
  function:{[model;modelType;data]
  // get predict function
  predictor:.ml.mlops.wrap[`$modelType;model;1b];
  // Latency information
  L:{system"sleep 0.0005";zz:enlist value x;a:.z.p;y zz;(1e-9)*.z.p-a}[;predictor] each 30#data;
  `avg`std!(avg L;dev L)}[model;modelType];
  @[function;data;{show "unable to generate latency config due to error: ",x,
   " latency monitoring cannot be supported"}]
  }

// @private
//
// @overview
// Generate schema configuration information which is to be saved
// with the model
//
// @param data {table} Historical data for evaluating behaviour of model
// @param config {dict} Configuration information provided by the user
//
// @return {dict} A dictionary containing information on the schema
//   of the data provided to the prediction service
registry.util.create.schema:{[data]
  // Schema information
  (!). (select c,t from (meta data))`c`t
  }

// @private
//
// @overview
// Generate nulls configuration information which is to be saved
// with the model
//
// @param data {table} Historical data for evaluating behaviour of model
// @param config {dict} Configuration information provided by the user
//
// @return {dict} A dictionary contianing the values for repalcement of
//   null values.
registry.util.create.null:{[data]
  // Null information
  function:{med each flip mlops.infReplace x};
  @[function;data;{show "unable to generate null config due to error: ",x,
   " null replacement cannot be supported"}]
  }

// @private
//
// @overview
// Generate infs configuration information which is to be saved
// with the model
//
// @param data {table} Historical data for evaluating behaviour of model
// @param config {dict} Configuration information provided by the user
//
// @return {dict} A dictionary contianing the values for replacement of
//   infinite values
registry.util.create.inf:{[data]
  // Inf information
  function:{(`negInfReplace`posInfReplace)!(min;max)@\:mlops.infReplace x};
  @[function;data;{show "unable to generate inf config due to error: ",x,
   " inf replacement cannot be supported"}]
  }

// @private
//
// @overview
// Generate csi configuration information which is to be saved
// with the model
//
// @param data {table} Historical data for evaluating behaviour of model
//
// @return {dict} A dictionary contianing the values for replacement of
//   infinite values
registry.util.create.csi:{[data]
  bins:@["j"$;(count data)&registry.config.commandLine`bins;
    {logging.error"Cannot convert 'bins' to an integer"}];
  @[{mlops.create.binExpected[;y] each flip x}[;bins];data;{show "unable ",
    "to generate csi config due to error: ",x," csi monitoring cannot be ",
    "supported"}]
  }

// @private
//
// @overview
// Generate psi configuration information which is to be saved
// with the model
//
// @param model {any} `(dict|fn|proj)` Model retrieved from registry.
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"|"python"
// @param data {table} Historical data for evaluating behaviour of model
//
// @return {dict} A dictionary containing information on the average
//   time to serve a prediction together with the standard deviation
registry.util.create.psi:{[model;modelType;data]
  bins:@["j"$;(count data)&registry.config.commandLine`bins;
    {logging.error"Cannot convert 'bins' to an integer"}];
  function:{[bins;model;modelType;data]
    // get predict function
    predictor:.ml.mlops.wrap[`$modelType;model;0b];
    preds:predictor data;
    mlops.create.binExpected[raze preds;bins]
    }[bins;model;modelType];
  @[function;data;{show "unable to generate psi config due to error: ",x,
   " psi monitoring cannot be supported"}]
  }

// @private
//
// @overview
// Create a table within the registry folder which will be used
// to store information about the metrics of the model
//
// @param metricPath {string} The path to the metrics file
//
// @return {null}
registry.util.create.modelMetric:{[metricPath]
  modelMetricKeys:`timestamp`metricName`metricValue;
  modelMetricVals:(enlist 0Np;`; ::);
  modelMetricSchema:flip modelMetricKeys!modelMetricVals;
  modelMetricPath:hsym`$metricPath,"metric";
  modelMetricPath set modelMetricSchema;
  }
