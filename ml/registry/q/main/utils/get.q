// get.q - Utilties relating to retrieval of objects from the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for object retrieval within the registry
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Retrieve a model from the registry, this is a wrapped version of
// this functionality to facilitate protected execution in the case
// that issues arise with retrieval and loading of a model from
// cloud providers or an on-prem location
//
// @param storage {symbol} The form of storage from which the model is
//   being retrieved
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
// @param config {dict} Configuration containing information surrounding
//   the location of the registry and associated files
// @param optionalKey {sym} Optional symbol for loading model
//
// @return {dict} The model and information related to the
//   generation of the model
registry.util.get.model:{[storage;experimentName;modelName;version;config;optionalKey]
  // Retrieve the model from the store meeting the user specified conditions
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to model folder containing the model to be retrieved
  config,:flip modelDetails;
  configPath:registry.util.path.modelFolder[config`registryPath;config;::];
  modelPath:registry.util.path.modelFolder[config`registryPath;config;`model];
  codePath:registry.util.path.modelFolder[config`registryPath;config;`code];
  registry.util.load.code codePath;
  func:{[k;configPath;modelDetails;modelPath;config;storage]
    $[k~(::);
    modelConfig:configPath,"/config/modelInfo.json";
    modelConfig:configPath,"/config/",string[k],"/modelInfo.json"
    ];
    modelInfo:.j.k raze read0 hsym`$modelConfig;
    // Retrieve the model based on the form of saved model
    modelType:first`$modelDetails`modelType;
    modelPath,:$[k~(::);"";string[k],"/"],$[modelType~`q;
       "mdl";
    modelType~`keras;
       "mdl.h5";
    modelType~`torch;
      "mdl.pt";
    modelType~`pyspark;
      "mdl.model";
    "mdl.pkl"
    ];
    model:mlops.get[modelType] $[modelType in `q;modelPath;pydstr modelPath];
    if[registry.config.commandLine`deployType;
      axis:modelInfo[`modelInformation;`axis];
      model:mlops.wrap[`python;model;axis];
      ];
    returnInfo:`modelInfo`model!(modelInfo;model);
    returnInfo
    }[;configPath;modelDetails;modelPath;config;storage];
  if[b:()~key hsym `$configPath,"/config/modelInfo.json";
     k:key hsym `$configPath,"/config"];
  r:$[b;$[optionalKey~(::);k!func'[k];func optionalKey];func[::]];
  if[`local<>storage;registry.util.delete.folder config`folderPath];
  r
  }

// @private
//
// @overview
// Retrieve metrics from the registry, this is a wrapped version of this
// functionality to facilitate protected execution in the case that issues
// arise with retrieval or loading of metrics from cloud providers or
// an on-prem location
//
// @param storage {symbol} The form of storage from which the model is
//   being retrieved
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
// @param config {dictionary} Configuration containing information surrounding
//   the location of the registry and associated files
// @param param {null|dict|symbol} Search parameters for the retrieval
//   of metrics
//
// @return {table} The metric table for a specific model, which may
//   potentially be filtered
registry.util.get.metric:{[storage;experimentName;modelName;version;config;param]
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to model folder containing the model to be retrieved
  config,:flip modelDetails;
  metricPath:registry.util.path.modelFolder[config`registryPath;config;`metrics];
  metricPath:metricPath,"metric";
  metric:1_get hsym`$metricPath;
  returnInfo:registry.util.search.metric[metric;param];
  if[`local<>storage;registry.util.delete.folder config`folderPath];
  returnInfo
  }

// @private
//
// @overview
// Retrieve parameters from the registry, this is a wrapped version of this
// functionality to facilitate protected execution in the case that issues
// arise with retrieval or loading of metrics from cloud providers or
// an on-prem location
//
// @param storage {symbol} The form of storage from which the model is
//   being retrieved
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
// @param config {dictionary} Configuration containing information surrounding
//   the location of the registry and associated files
// @param paramName {symbol|string} The name of the parameter to retrieve
//
// @return {string|dict|table|float} The value of the parameter associated
//   with a named parameter saved for the model.
registry.util.get.params:{[storage;experimentName;modelName;version;config;paramName]
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to model folder containing the model to be retrieved
  config,:flip modelDetails;
  paramPath:registry.util.path.modelFolder[config`registryPath;config;`params];
  paramName:$[-11h=type paramName;
    string paramName;
    10h=type paramName;
    paramName;
    logging.error"ParamName must be of type string or symbol"
    ];
  paramPath,:paramName,".json";
  returnInfo:registry.util.search.params[paramPath];
  if[`local<>storage;registry.util.delete.folder config`folderPath];
  returnInfo
  }

registry.util.get.version:{[storage;experimentName;modelName;version;config;param]
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  config,:flip modelDetails;
  rootPath:registry.util.path.modelFolder[config`registryPath;config;::];
  versionInfo:@[read0;hsym `$rootPath,"/.version.info";{'"Version information not found for model"}];
  .j.k raze versionInfo
  };


// @private
//
// @overview
// Retrieve a q/python/sklearn/keras model or parameters/metrics related to a
// specific model from the registry.
//
// @todo
// Add type checking for modelName/experimentName/version
//
// @param cli {dict} Command line arguments as passed to the system on
//   initialisation, this defines how the fundamental interactions of
//   the interface are expected to operate.
// @param folderPath {dict|string|null} Registry location.
//   1. Can be a dictionary containing the vendor and location as a string, e.g.:
//       - enlist[`local]!enlist"myReg"
//       - enlist[`aws]!enlist"s3://ml-reg-test"
//   2. A string indicating the local path
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON
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
// @param param {null|dict|symbol|string} Parameter required for parameter/
//   metric retrieval
//   in the case when this is a string, it is converted to a symbol
//
// @return {dict} The model and information related to the
//   generation of the model
registry.util.get.object:{[typ;folderPath;experimentName;modelName;version;param]
  if[(typ~`metric)&abs[type param] in 10 11h;
    param:enlist[`metricName]!enlist $[10h=abs[type param];`$;]param
    ];
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]
     ]
    ];
  getParams:$[(typ~`model)&param~(::);
    (storage;experimentName;modelName;version;config;::);
    (storage;experimentName;modelName;version;config;param)
    ];
  .[registry.util.get typ;
    getParams;
    {[x;y;z]
      $[`local~x;;registry.util.delete.folder]y;
      'z
      }[storage;config`folderPath]
    ]
  }
