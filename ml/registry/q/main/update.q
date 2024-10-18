// update.q - Main callable functions for retrospectively adding information
// to the model registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Update information within the registry
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the config of a model that's already saved
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param model {any} `(<|dict|fn|proj)` The model to be saved to the registry.
// @param modelName {string} The name to be associated with the model
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"|"python"
// @param config {dict} Any additional configuration needed for
//   setting the model
//
// @return {null}
registry.update.config:{[folderPath;experimentName;modelName;version;config]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;config];
  modelType:first config`modelType;
  config:registry.config.model,config;
  modelPath:registry.util.path.modelFolder[config`registryPath;config;`model];
  model:registry.get[`$modelType]modelPath;
  registry.util.set.requirements config;
  if[`data in key config;
    registry.set.monitorConfig[model;modelType;config`data;config]
    ];
  if[`supervise in key config;
    registry.set.superviseConfig[config]
    ];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the requirement details of a saved model
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
// @param requirements {string[][];hsym;boolean} The location of a saved
//   requirements file, list of user specified requirements or a boolean
//   indicating if the virtual environment of a user is to be 'frozen'
//
// @return {null}
registry.update.requirements:{[folderPath;experimentName;modelName;version;requirements]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  config[`requirements]:requirements;
  registry.util.set.requirements config;
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the latency details of a saved model
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
// @param model {fn} The model on which the latency is to be evaluated
// @param data {table} Data on which to evaluate the model
//
// @return {null}
registry.update.latency:{[folderPath;experimentName;modelName;version;model;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.latency[fpath;model;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the null replacement details of a saved model
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
// @param data {table} Data on which to determine the null replacement
//
// @return {null}
registry.update.nulls:{[folderPath;experimentName;modelName;version;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.nulls[fpath;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the infinity replacement details of a saved model
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
// @param data {table} Data on which to determine the infinity replacement
//
// @return {null}
registry.update.infinity:{[folderPath;experimentName;modelName;version;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.infinity[fpath;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the csi details of a saved model
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
// @param data {table} Data on which to determine historical distribution of the
//   features
//
// @return {null}
registry.update.csi:{[folderPath;experimentName;modelName;version;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  .ml.mlops.update.csi[fpath;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the psi details of a saved model
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
// @param model {fn} The model serving the predictions
// @param data {table} Data on which to determine historical distribution of the
//   predictions
//
// @return {null}
registry.update.psi:{[folderPath;experimentName;modelName;version;model;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.psi[fpath;model;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the type details of a saved model
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
// @param format {string} Type of the given model
//
// @return {null}
registry.update.type:{[folderPath;experimentName;modelName;version;format]
  config:registry.util.update.checkPrep
    [folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.type[fpath;format];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the supervised metrics of a saved model
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
// @param metrics {string[]} Supervised metrics to monitor
//
// @return {null}
registry.update.supervise:{[folderPath;experimentName;modelName;version;metrics]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  .ml.mlops.update.supervise[fpath;metrics];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }

// @kind function
// @category main
// @subcategory update
//
// @overview
// Update the schema details of a saved model
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
// @param data {table} The data which provides the new schema
//
// @return {null}
registry.update.schema:{[folderPath;experimentName;modelName;version;data]
  config:registry.util.update.checkPrep[folderPath;experimentName;modelName;version;()!()];
  fpath:hsym `$config[`versionPath],"/config/modelInfo.json";
  mlops.update.schema[fpath;data];
  if[`local<>config`storage;registry.cloud.update.publish config];
  }
