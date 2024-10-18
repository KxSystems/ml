// get.q - Main callable functions for retrieving information from the
// model registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Retrieve items from the registry including
// 1. Models:
//    - q (functions/projections/appropriate dictionaries)
//    - Python (python functions + sklearn/keras specific functionality)
// 2. Configuration
// 3. Model registry
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory get
//
// @overview
// Retrieve a q/python/sklearn/keras model from the registry
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
//
// @return {dict} The model and information related to the
//   generation of the model
registry.get.model:registry.util.get.object[`model;;;;;::]

// @kind function
// @category main
// @subcategory get
//
// @overview
// Retrieve a keyed q/python/sklearn/keras model from the registry
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
// @param key {symbol} key from the model to retrieve
//
// @return {dict} The model and information related to the
//   generation of the model
registry.get.keyedmodel:registry.util.get.object[`model]

// @kind function
// @category main
// @subcategory get
//
// @overview
// Retrieve language/library version information associated with a model stored in the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string|null} The name of an experiment from which
//   to retrieve model information, if no modelName is provided the newest model
//   within this experiment will be used. If neither modelName or
//   experimentName are defined the newest model within the
//   "unnamedExperiments" section is chosen
// @param modelName {string|null} The name of the model from which to retrieve
//   version information in the case this is null, the newest model associated
//   with the experiment is retrieved
// @param version {long[]|null} The specific version of a named model to retrieve
//   in the case that this is null the newest model is retrieved (major;minor)
//
// @return {dict} Information about the model stored in the registry including 
//   q version/date and if applicable Python version and Python library versions
registry.get.version:registry.util.get.object[`version;;;;;::]

// @kind function
// @category main
// @subcategory get
//
// @overview
// Load the metric table for a specific model
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
// @param param {null|dict|symbol|string} Search parameters for the retrieval
//   of metrics
//   in the case when this is a string, it is converted to a symbol
//
// @return {table} The metric table for a specific model, which may
//   potentially be filtered
registry.get.metric:registry.util.get.object[`metric]

// @kind function
// @category main
// @subcategory get
//
// @overview
// Load the parameter information for a specific model
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
// @param param {symbol|string} The name of the parameter to retrieve
//
// @return {string|dict|table|float} The value of the parameter associated
//   with a named parameter saved for the model.
registry.get.parameters:registry.util.get.object[`params]

// @kind function
// @category main
// @subcategory get
//
// @overview
// Retrieve a q/python/sklearn/keras model from the registry for prediction
//
// @todo
// Add type checking for modelName/experimentName/version
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
//
// @return {any} `(<|dict|fn|proj)` Model retrieved from the registry.
registry.get.predict:{[folderPath;experimentName;modelName;version]
  getModel:registry.get.model[folderPath;experimentName;modelName;version];
  if[registry.config.commandLine[`deployType];:getModel`model];
  modelType:`$getModel[`modelInfo;`model;`type];
  if[`graph~modelType;
    logging.error"Retrieval of prediction function not supported for 'graph'"
    ];
  axis:getModel[`modelInfo;`model;`axis];
  if[""~axis;axis:0b];
  model:getModel`model;
  mlops.wrap[modelType;model;axis]
  }

// @kind function
// @category main
// @subcategory get
//
// @overview
// Retrieve a q/python/sklearn/keras model from the registry for update
//
// @todo
// Add type checking for modelName/experimentName/version
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
// @param supervised {boolean} Decide is model update supervised
//
// @return {any} `(<|dict|fn|proj)` Model retrieved from the registry.
registry.get.update:{[folderPath;experimentName;modelName;version;supervised]
  getModel:registry.get.model[folderPath;experimentName;modelName;version];
  if[registry.config.commandLine[`deployType];:getModel`model];
  modelType:`$getModel[`modelInfo;`model;`type];
  if[`graph~modelType;
    logging.error"Retrieval of prediction function not supported for 'graph'"
    ];
  axis:getModel[`modelInfo;`model;`axis];
  model:getModel`model;
  mlops.wrapUpdate[modelType;model;axis;supervised]
  }

// @kind function
// @category main
// @subcategory get
//
// @overview
// Wrap models such that they all have a predict key regardless of where
// they originate
//
// @param mdlType {symbol} Form of model being used ```(`q/`sklearn/`keras)```, this
//   defines how the model gets interpreted in the case it is Python code
//   in particular.
// @param model {any} `(<|dict|fn|proj|foreign)` Model retrieved from registry.
//
// @return {any} `(<|fn|proj|foreign)` Predict function.
mlops.formatUpdate:{[mdlType;model]
  $[99h=type model;
    $[`update in key model;
      model[`update];
      logging.error"model does not come with update function"];
    mdlType~`sklearn;
    $[`partial_fit in .ml.csym model[`:__dir__][]`;
      model[`:partial_fit];
      logging.error"No update function available for sklearn model"];
    logging.error"Update functionality not available for requested model"
    ]
  }

// @kind function
// @category main
// @subcategory get
//
// @overview
// Wrap models retrieved such that they all have the same format regardless of
// from where they originate, the data passed to the model will also be transformed
// to the appropriate format
//
// @param mdlType {symbol} Form of model being used ```(`q/`sklearn/`keras)```. This
//   defines how the model gets interpreted in the case it is Python code
//   in particular.
// @param model {any} `(<|dict|fn|proj|foreign)` Model retrieved from the registry.
// @param axis {boolean} Data in a 'long' or 'wide' format (`0b/1b`)
//
// @return {any} `(<|fn|proj|foreign)` The update function wrapped with a transformation
//   function.
mlops.wrapUpdate:{[mdlType;model;axis;supervised]
  model:mlops.formatUpdate[mdlType;model];
  transform:mlops.transform[;axis;mdlType];
  $[supervised;
  model . {(x y;z)}[transform]::;
  model transform::]
  }

// @kind function
// @category main
// @subcategory get
//
// @overview
// Load the model registry at the user specified location into process.
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param config {dict} Any additional configuration needed for
//   retrieving the modelStore
//
// @return {table} Most recent version of the modelStore
registry.get.modelStore:{[folderPath;config]
  config:registry.util.check.config[folderPath;config];
  if[not`local~storage:config`storage;storage:`cloud];
  $[storage~`local;
    [modelStorePath:registry.util.check.registry[config]`modelStorePath;
     load modelStorePath;
     ?[modelStorePath;();0b;()]
     ];
    [modelStore:get hsym`$config[`folderPath],"/KX_ML_REGISTRY/modelStore";
     key hsym` sv `$#[3;("/") vs ":",config`folderPath],"_";
     modelStore
     ]
    ]
  }
