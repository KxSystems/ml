// requirements.q - Utilities for the addition of requirements with a model
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for the addition of requirements with a model
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Generate a requirements file using pip freeze and save to the
// model folder, this requires the user to be using a virtual environment
// as allowing ad-hoc pip freeze results in incompatible requirements due
// to on prem files generated over time
//
// @param config {dict} Configuration provided by the user to
//   customize the experiment
//
// @return {::}
registry.util.requirements.pipfreeze:{[config]
  sys:.p.import`sys;
  if[(sys[`:prefix]`)~sys[`:base_prefix]`;
    logging.error"Cannot execute a pip freeze when not in a virtualenv"
    ];
  destPath:config[`versionPath],"/requirements.txt";
  requirements:system"pip freeze";
  hsym[`$destPath]0:requirements
  }

// @private
//
// @overview
// Generate a copy of a requirements file that a user has pointed to
// to the model folder. There are no checks made on the validity of these
// files other than that they exist, as such it is on the user to point
// to the appropriate file
//
// @param srcPath {string} Full/relative path to the requirements
//   file to be copied
// @param config {dict} Configuration provided by the user to
//   customize the experiment
//
// @return {null}
registry.util.requirements.copyfile:{[config]
  srcPath:hsym config`requirements;
  if[not srcPath~key srcPath;
    logging.error"Requirements file you are attempting to copy does not exist"
    ];
  srcPath:registry.util.check.osPath 1_string srcPath;
  destPath:registry.util.check.osPath config[`versionPath],"/requirements.txt";
  copyCommand:$[.z.o like"w*";"copy /b/y";"cp"];
  system sv[" ";(copyCommand;srcPath;destPath)]
  }

// @private
//
// @overview
// Add a user defined list of lists as a requirements file, this includes
// checking that the requirements provided are all strings but does not
// validate that they are valid pip requirements, it is assumed that the
// user will supply compliant values for this
//
// @param config {dict} Configuration provided by the user to
//   customize the experiment
//
// @return {null}
registry.util.requirements.list:{[config]
  requirements:config`requirements;
  if[not all 10h=type each requirements;
    logging.error"User provided list of arguments must be a list of strings"
    ];
  destPath:config[`versionPath],"/requirements.txt";
  hsym[`$destPath]0:requirements
  }
