// set.q - Callable functions for the publishing of items to local file system
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Publish items to local file system
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category local
// @subcategory set
//
// @overview
// Set a model within local file-system storage
//
// @param experimentName {string} The name of the experiment to which a model
//   being added to the registry is associated
// @param model {any} `(<|dict|fn|proj)` The model to be saved to the registry.
// @param modelName {string} The name to be associated with the model
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"|"python"
// @param config {dict} Any additional configuration needed for
//   setting the model
//
// @return {null}
registry.local.set.model:{[experimentName;model;modelName;modelType;config]
  config:registry.util.check.registry config;
  $[experimentName in ("undefined";"");
    config[`experimentPath]:config[`registryPath],"/unnamedExperiments";
    config:registry.new.experiment[config`folderPath;experimentName;config]
    ];
  config:(enlist[`major]!enlist 0b),config;
  config:registry.util.update.config[modelName;modelType;config];
  function:registry.util.set.model;
  arguments:(model;modelType;config);
  registry.util.protect[function;arguments;config]
  }

// @kind function
// @category local
// @subcategory set
//
// @overview
// Set parameter information associated with a model locally
//
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
// @param paramName {string} The name of the parameter to be saved
// @param params {dict|table|string} The parameters to save to file
//
// @return {null}
registry.local.set.parameters:{[experimentName;modelName;version;paramName;params;config]
  config:registry.util.check.registry config;
  // Retrieve the model from the store meeting the user specified conditions
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to model folder containing the model to be retrieved
  config,:flip modelDetails;
  paramPath:registry.util.path.modelFolder[config`registryPath;config;`params];
  paramPath:paramPath,paramName,".json";
  registry.util.set.params[paramPath;params]
  }
