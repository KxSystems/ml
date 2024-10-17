// new.q - Functionality for generation of new elements of the ML registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// This functionality is intended to provide the ability to generate new
// registries and experiments within these registries.
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory new
//
// @overview
// Generates a new model registry at a user specified location on-prem
// or within a supported cloud providers storage solution
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param config {dict|null} Any additional configuration needed for
//   initialising the registry
//
// @return {dict} Updated config dictionary containing relevant
//   registry paths
registry.new.registry:{[folderPath;config]
  config:registry.util.check.config[folderPath;config];
  if[not`local~storage:config`storage;storage:`cloud];
  registry[storage;`new;`registry]config
  }

// @kind function
// @category main
// @subcategory new
//
// @overview
// Generates a new named experiment within the specified registry without
// adding a model on-prem or within a supported cloud providers storage solution
//
// @todo
// It should be possible via configuration to add descriptive information
//   about an experiment.
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} The name of the experiment to be located
//   under the namedExperiments folder which can be populated by new models
//   associated with the experiment
// @param config {dict|null} Any additional configuration needed for
//   initialising the experiment
//
// @return {dict} Updated config dictionary containing relevant
//   registry paths
registry.new.experiment:{[folderPath;experimentName;config]
  config:registry.util.check.config[folderPath;config];
  if[not`local~storage:config`storage;storage:`cloud];
  experimentName:registry.util.check.experiment experimentName;
  registry[storage;`new;`experiment][experimentName;config]
  }
