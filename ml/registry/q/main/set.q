// set.q - Main callable functions for adding information to the model registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Setting items within the registry including
// 1. Models:
//    - q (functions/projections/appropriate dictionaries)
//    - Python (python functions + sklearn/keras specific functionality)
// 2. Configuration
// 3. Model information table
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory set
//
// @overview
// Add a q object, Python function, Keras model or sklearn model
// to the registry so that it can be retrieved and applied to new data.
// In the current iteration there is an assumption of complete
// independence for the q functions/files i.e. q function/workflows
// explicitly don't use Python to make it easier to store and generate
// reintroduce models
//
// @todo
// Improve the configuration information that is being persisted
//   presently this contains all information within the config folder
//   however this is not particularly informative and may be confusing
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string|null} Name of experiment model belongs to
// @param model {any} `(<|dict|fn|proj)` Model to be saved to the registry.
// @param modelName {string} The name to be associated with the model
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"|"python"
// @param config {dict} Any additional configuration needed for
//   setting the model
//
// @return {null}
registry.set.model:{[folderPath;experimentName;model;modelName;modelType;config]
  config:registry.util.check.config[folderPath;config];
  if[not`local~storage:config`storage;storage:`cloud];
  experimentName:$[(any experimentName ~/: (::;""))|10h<>abs type experimentName;
    "undefined";
    experimentName
    ];
  c:registry[storage;`set;`model][experimentName;model;modelName;modelType;config];
  first c`uniqueID
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Add a q object to the registry. This should be a q object in the
// current process which is either a function/projection/dictionary
// containing a predict key
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(dict|fn|proj)` Model to be saved to the registry.
// @param config {dict} Information relating to the model that is
//   to be saved, this includes version, experiment and model names
//
// @return {null}
registry.set.object:{[typ;registryPath;model;config]
  toSet:$[type[model]in 10 11 -11h;"File";"Model"];
  registry.util.set[`$typ,toSet][registryPath;model;config]
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Set the configuration associated with a specified model version such
// that all relevant information needed to redeploy the model is present
// with a packaged model
//
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.set.modelConfig:{[model;modelType;config]
  safeWrite:{[config;path]
   if[not count key hsym `$config[`versionPath],"/config/",path,".json";
     registry.util.set.json[config;`config;path;enlist config]
     ]};
  $[99h=type model;
    $[not (("q"~modelType)&((`predict in key model)|(`modelInfo in key model)));
      {[safeWrite;config;sym;model]
        safeWrite[config;string[sym],"/modelInfo"]
        }[safeWrite;config]'[key model;value model];
      safeWrite[config;"modelInfo"]];
      safeWrite[config;"modelInfo"]
    ]
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Set the configuration associated with monitoring a specified model version
// such that all relevant information needed to monitor the model is present
// with a packaged model
//
// @param model {any} `(<|dict|fn|proj)` Model to be monitored.
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"
// @param data {table} Historical data to understand model behaviour
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.set.monitorConfig:{[model;modelType;data;config]
  func : {[sym;model;modelType;data;config]
      if[not 98h~type data;:(::)];
      $[sym~(::);
        newConfig:.j.k raze read0 hsym `$config[`versionPath],"/config/modelInfo.json";
        newConfig:.j.k raze read0 hsym `$config[`versionPath],"/config/",string[sym],"/modelInfo.json"
       ];
      newConfig[`monitoring;`schema;`values]:registry.util.create.schema data;
      newConfig[`monitoring;`schema;`monitor]:1b;
      newConfig[`monitoring;`nulls;`values]:registry.util.create.null data;
      newConfig[`monitoring;`nulls;`monitor]:1b;
      newConfig[`monitoring;`infinity;`values]:registry.util.create.inf data;
      newConfig[`monitoring;`infinity;`monitor]:1b;
      newConfig[`monitoring;`latency;`values]:registry.util.create.latency[model;modelType;data];
      newConfig[`monitoring;`latency;`monitor]:1b;
      newConfig[`monitoring;`csi;`values]:registry.util.create.csi data;
      newConfig[`monitoring;`csi;`monitor]:1b;
      newConfig[`monitoring;`psi;`values]:registry.util.create.psi[model;modelType;data];
      newConfig[`monitoring;`psi;`monitor]:1b;
      params:`maxDepth`indent!(10;"  ");
      $[sym~(::);
      (hsym `$config[`versionPath],"/config/modelInfo.json") 0: enlist .j.j newConfig;
      (hsym `$config[`versionPath],"/config/",string[sym],"/modelInfo.json") 0: enlist .j.j newConfig]
      }[;;modelType;;config];
  $[all 99h=(type[model];type[data]);
    [k:key[model] inter key[data];func'[k;model k;data k]];
    not 99h=type[model];
    func[::;model;data];
    '"data to fit monitoring statistics is not partitioned on model key"
   ]
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Set the configuration associated with supervised monitoring
//
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.set.superviseConfig:{[model;config]
  func:{[sym;model;config]
    $[sym~(::);
        newConfig:.j.k raze read0 hsym `$config[`versionPath],"/config/modelInfo.json";
        newConfig:.j.k raze read0 hsym `$config[`versionPath],"/config/",string[sym],"/modelInfo.json"
       ];
    newConfig[`monitoring;`supervised;`values]:config `supervise;
    newConfig[`monitoring;`supervised;`monitor]:1b;
    params:`maxDepth`indent!(10;"  ");
    $[sym~(::);
        (hsym `$config[`versionPath],"/config/modelInfo.json") 0: enlist .j.j newConfig;
        (hsym `$config[`versionPath],"/config/",string[sym],"/modelInfo.json") 0: enlist .j.j newConfig
       ];
    }[;;config];
  $[99h~type[model];
    func'[key[model];value[model]];
    func[::;model]]
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Upsert relevant data from current run to modelStore
//
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.set.modelStore:{[config]
  enlistCols:`experimentName`modelName`modelType`version`description;
  regularCols:`registrationTime`uniqueID!config`registrationTime`uniqueID;
  experimentName:config`experimentName;
  experimentName:$[0h=type experimentName;;enlist]experimentName;
  modelName:enlist config`modelName;
  modelType:config`modelType;
  modelType:enlist$[-10h=type modelType;enlist;]modelType;
  description:config`description;
  if[0=count description;description:""];
  description:enlist$[-10h=type description;enlist;]description;
  version:enlist config`version;
  info:regularCols,enlistCols!
    (experimentName;modelName;modelType;version;description);
  // check if model already exists
  whereClause:enlist (&;(&;(~\:;`version;config[`version]);(~\:;`modelName;config[`modelName]));
                        (~\:;`experimentName;config[`experimentName]));
  columns:enlist `uniqueID;
  if[not count ?[config[`modelStorePath];whereClause;0b;columns!columns]`uniqueID;
     config[`modelStorePath]upsert flip info
    ];
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Save parameter information for a model
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string|null} The name of an experiment from which
//   to retrieve a model, if no modelName is provided the newest model
//   within this experiment will be used. If neither modelName or
//   experimentName are defined the newest model within the
//   "unnamedExperiments" section is chosen
// @param modelName {string|null} The name of the model to be retrieved
//   in the case this is null, the newest model associated with the
//   experiment is retrieved
// @param version {long[]|null} The specific version of a named model to retrieve
//   in the case that this is null the newest model is retrieved (major;minor)
// @param paramName {string|symbol} The name of the parameter to be saved
// @param params {dict|table|string} The parameters to save to file
//
// @return {null}
registry.set.parameters:{[folderPath;experimentName;modelName;version;paramName;params]
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  paramName:$[-11h=type paramName;
    string paramName;
    10h=type paramName;
    paramName;
    logging.error"ParamName must be of type string or symbol"
    ];
  setParams:(experimentName;modelName;version;paramName;params;config);
  registry[storage;`set;`parameters]. setParams
  }

// @kind function
// @category main
// @subcategory set
//
// @overview
// Upsert relevant data from current run to metric table
//
// @param metricName {string} The name of the metric to be persisted
// @param metricValue {float} The value of the metric to be persistd
// @param metricPath {string} The path to the metric table
//
// @return {null}
registry.set.modelMetric:{[metricName;metricValue;metricPath]
  enlistCols:`timestamp`metricName`metricValue;
  metricDict:enlistCols!(.z.P;metricName;metricValue);
  metricPath:hsym`$metricPath,"metric";
  metricPath upsert metricDict;
  }
