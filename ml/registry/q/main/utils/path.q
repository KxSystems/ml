// path.q - Utilities for generation of registry paths
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for generation of registry paths
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Generate the path to the model/parameter/metric/version folder based
// on provided registry path and model information
//
// @param registryPath {string} Full/relative path to the model registry
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
// @param folderType {symbol|null} Which folder is to be accessed? 'model'/
//   'params'/'metrics', if '::' then the path to the versioned model is
//   returned
//
// @return {string} The full path to the requested folder within a versioned
//   model
registry.util.path.modelFolder:{[registryPath;config;folderType]
  folder:$[folderType~`model;
      "/model/";
    folderType~`params;
      "/params/";
    folderType~`metrics;
      "/metrics/";
    folderType~`code;
      "/code/";
    folderType~(::);
      "";
    logging.error"Unsupported folder type"
    ];
  experiment:config`experimentName;
  expBool:any experiment like "undefined";
  experimentType:$[expBool;"un",;]"namedExperiments/";
  if[not expBool;
    experimentType:experimentType,/experiment,"/"
    ];
  modelName:raze config`modelName;
  modelVersion:"/",/registry.util.strVersion config`version;
  registryPath,"/",experimentType,modelName,modelVersion,folder
  }
