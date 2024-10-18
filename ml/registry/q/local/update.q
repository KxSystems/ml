// update.q - Callable functions for updating information related to a model
//   on local file-sytem
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Update local model information
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category local
// @subcategory update
//
// @overview
// Prepare information for local updates
//
// @param folderPath {string|null} A folder path indicating the location
//   of the registry or generic null if in the current directory
// @param experimentName {string|null} The name of an experiment within which
//   the model having additional information added is located.
// @param modelName {string|null} The name of the model to which additional
//   information is being added. In the case this is null, the newest model
//   associated with the experiment is retrieved
// @param version {long[]|null} The specific version of a named model to add the
//   new parameters to. In the case that this is null the newest model is retrieved
//   generaly expressed as a duple (major;minor)
// @param config {dict} Any additional configuration needed for updating
//   the parameter information associated with a model
//
// @return {dict} All information required for setting new configuration/
//   requirements information associated with a model
registry.local.update.prep:{[folderPath;experimentName;modelName;version;config]
  config:registry.util.check.registry config;
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to model folder containing the model to be retrieved
  config,:flip modelDetails;
  config[`versionPath]:registry.util.path.modelFolder[config`registryPath;config;::];
  config:registry.config.model,config;
  config
  }
