// update.q - Functionality for updating information related to the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for updating registry information
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Update the configuration supplied by a user such to include
// all relevant information for the saving of a model and its
// associated configuration
//
// @param modelName {string} The name to be associated with the model
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"
// @param config {dict} Configuration information provided by the user
//
// @return {dict} Default configuration defined by
//   '.ml.registry.config.model' updated with user supplied information
registry.util.update.config:{[modelName;modelType;config]
  config:registry.config.model,config;
  config[`experimentName]:registry.util.check.experiment config`experimentName;
  config,:`modelName`modelType!(modelName;modelType);
  registry.util.check.modelType config;
  config,:`registrationTime`uniqueID!(enlist .z.p;-1?0Ng);
  registry.util.search.version config
  }

// @private
//
// @overview
// Check folder paths, storage type and configuration and prepare the
//   ML Registry for publishing to the appropriate vendor
//
// @param folderPath {string|null} A folder path indicating the location
//   of the registry or generic null if in the current directory
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
// @param config {dict|null} Configuration information provided by the user
//
// @return {dict} Updated configuration information
registry.util.update.checkPrep:{[folderPath;experimentName;modelName;version;config]
  config,:registry.util.check.config[folderPath;config];
  if[`local<>storage:config`storage;storage:`cloud];
  prepParams:(folderPath;experimentName;modelName;version;config);
  registry[storage;`update;`prep]. prepParams
  }
