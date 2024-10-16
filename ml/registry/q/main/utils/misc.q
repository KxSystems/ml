// misc.q - Miscellaneous utilities for interacting with the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Miscellaneous utilities for interacting with the registry
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
/ Protected execution of set function. If an error occurs, any created
// folders will be deleted.
//
// @param function {fn} Function to be applied
// @param arguments {list} Arguments to be applied
// @param config {dict} Configuration information provided by the user
//
// @return {null}
registry.util.protect:{[function;arguments;config]
  $[`debug in key .Q.opt .z.x;
    function . arguments;
    .[function;arguments;registry.util.checkDepth[config;]]
    ]
  }

// @private
//
// @overview
// Check the depth of the failing model. If first model in experiment, remove
// the entire experiment, otherwise simply remove all folders associated with
// the failing model.
//
// @param config {dict} Configuration information provided by the user
// @param err {string} Error string generated when upserting to table
//
// @return {null}
registry.util.checkDepth:{[config;err]
  logging.warn "'",err,"' flagged when adding new model to modelStore.";
  // Check if experiment is already in modelStore
  modelStoreExperiments:?[config`modelStorePath;();();`experimentName];
  $[any config[`experimentName]in distinct modelStoreExperiments;
    // Yes: delete current model version as other models will be
    // present within the experiment
    registry.delete.model . config`folderPath`experimentName`modelName`version;
    // No: delete the entire experiment
    registry.delete.experiment . config`folderPath`experimentName
    ];
  }

// @private
//
// @overview
// Generate paths to object and modelStore
//
// @param folderPath {string|null} A folder path indicating the location
//   the registry containing the model to be deleted
//   or generic to remove registry in the current directory
// @param objectType {symbol} ````experiment `allModels or `modelVersion```
// @param experimentName {string} Name of experiment
// @param modelName {string} Name of model
// @param modelVersion {long[]} Model version number (major;minor)
// @param config {dict} Configuration information provided by the user
//
// @return {dict} Paths to object and modelStore
registry.util.getObjectPaths:{[folderPath;objectType;experimentName;modelName;modelVersion;config]
  paths:registry.util.getRegistryPath[folderPath;config];
  registryPath:paths`registryPath;
  modelStorePath:paths`modelStorePath;
  if[any experimentName ~/: (::;"");experimentName:"undefined"];
  experimentName:"",experimentName;
  experimentPath:$[unnamed:experimentName in("undefined";"");
    "/unnamedExperiments";
    "/namedExperiments/",experimentName
    ];
  additionalFolders:$[objectType~`allModels;
      modelName;
    objectType~`modelVersion;
      modelName,"/",registry.util.strVersion modelVersion;
    unnamed&modelName~"";
      string first key hsym`$registryPath,experimentPath;
    ""
    ];
  objectPath:hsym`$registryPath,experimentPath,"/",additionalFolders;
  `objectPath`modelStorePath!(objectPath;modelStorePath)
  }

// @private
//
// @overview
// Generate path to file
//
// @param folderPath {string|null} A folder path indicating the location
//   the registry containing the file to be deleted
//   or generic to remove registry in the current directory
// @param experimentName {string} Name of experiment
// @param modelName {string} Name of model
// @param modelVersion {long[]} Model version number (major;minor)
// @param localFolder {symbol} Local folder code/metrics/params/config
// @param config {dict} Extra details on file to be located
//
// @return {#hsym} Path to file.
registry.util.getFilePath:{[folderPath;experimentName;modelName;modelVersion;localFolder;config]
  cfg:registry.util.check.config[folderPath;()!()];
  registryPath:registry.util.getRegistryPath[folderPath;cfg]`registryPath;
  if[any experimentName ~/: (::;"");experimentName:"undefined"];
  experimentName:"",experimentName;
  experimentPath:$[unnamed:experimentName in("undefined";"");
    "/unnamedExperiments";
    "/namedExperiments/",experimentName
    ];
  prefix:registryPath,experimentPath,"/",modelName,"/",registry.util.strVersion[modelVersion];
  $[localFolder~`code;
    hsym `$prefix,"/code/",config`codeFile;
    localFolder~`metrics;
    hsym `$prefix,"/metrics/","metric";
    localFolder~`params;
    hsym `$prefix,"/params/",(config`paramFile),".json";
    localFolder~`config;
    hsym `$prefix,"/config/",string[config`configType],".json";
    logging.error"No such local folder in model registry"]
  }

// @private
//
// @overview
// Check user specified folder path and generate corresponding regisrty path
//
// @param folderPath {string|null} A folder path indicating the location
//   the registry containing the model to be deleted
//   or generic to remove registry in the current directory
// @param config {dict} Configuration information provided by the user
//
// @return {string} Path to registry folder
registry.util.getRegistryPath:{[folderPath;config]
  registry.util.check.registry[config]
  }

// @private
//
// @overview
// Parse version as a string
//
// @param version {long[]} Version number represented as a duple of
// major and minor version
//
// @return {string} Version number provided as a string
registry.util.strVersion:{[version]
  if[0h=type version;version:first version];
  "." sv string each version
  }
