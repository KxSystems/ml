// new.q - Generation of new elements of the ML registry locally
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
// @category local
// @subcategory new
//
// @overview
// Generates a new model registry at a user specified location on-prem.
//
// @param config {dict|null} Any additional configuration needed for
//   initialising the registry
//
// @return {dict} Updated config dictionary containing relevant
//   registry paths
registry.local.new.registry:{[config]
  config:registry.util.create.registry config;
  config:registry.util.create.modelStore config;
  registry.util.create.experimentFolders config;
  config
  }

// @kind function
// @category local
// @subcategory new
//
// @overview
// Generates a new named experiment within the specified registry
// locally without adding a model
//
// @todo
// It should be possible via configuration to add descriptive information
// about an experiment.
//
// @param experimentName {string} The name of the experiment to be located
//   under the namedExperiments folder which can be populated by new models
//   associated with the experiment
// @param config {dict|null} Any additional configuration needed for
//   initialising the experiment
//
// @return {dict} Updated config dictionary containing relevant
//   registry paths
registry.local.new.experiment:{[experimentName;config]
  config:registry.local.util.check.registry config;
  registry.util.create.experiment[experimentName;config]
  }
