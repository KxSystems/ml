// delete.q - Delete items from the model registry and folder structure
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Delete items from the registry
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Delete all files contained within a specified directory recursively
//
// @param folderPath {symbol} Folder to be deleted
//
// @return {null}
registry.util.delete.folder:{[folderPath]
  ty:type folderPath;
  folderPath:hsym$[10h=ty;`$;-11h=ty;;logging.error"type"]folderPath;
  orderedPaths:(),{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]}folderPath;
  hdel each desc orderedPaths;
  }

// @private
//
// @overview
// Delete all folders relating to an experiment or to 1/all versions of a model
//
// @param config {dict} Configuration information provided by the user
// @param objectType {symbol} ``` `experiment `allModels or `modelVersion```
//
// @return {null}
registry.util.delete.object:{[config;objectType]
  // Required variables
  folderPath:config`folderPath;
  experimentName:config`experimentName;
  modelName:config`modelName;
  version:config`version;
  // Generate modelStore and object paths based on objectType
  paths:registry.util.getObjectPaths
    [folderPath;objectType;experimentName;modelName;version;config];
  modelStorePath:paths`modelStorePath;
  checkPath:objectPath:paths`objectPath;
  objectString:1_string objectPath;
  // Check if object exists before attempting to delete
  if["*"~last objectString;checkPath:hsym`$-1_objectString];
  if[emptyPath:()~key checkPath;
    logging.info"No artifacts created for ",objectString,". Unable to delete."
    ];
  // Where clause relative to each object type
  objectCondition:registry.util.delete.where
    [experimentName;modelName;version;objectType];
  whereClause:enlist(not;objectCondition);
  // Update the modelStore with remaining models
  newModels:?[modelStorePath;whereClause;0b;()];
  modelStorePath set newModels;
  // Delete relevant folders
  if[not emptyPath;
    logging.info"Removing all contents of ",objectString;
    registry.util.delete.folder objectPath
    ];
  // Load new modelStore
  load modelStorePath;
  }

// @private
//
// @overview
// Functional where clause required to delete objects from the modelStore
//
// @param experimentName {string} Name of experiment
// @param modelName {string} Name of model
// @param version {long[]} Model version number (major;minor)
// @param objectType {symbol} ``` `experiment `allModels or `modelVersion```
//
// @return {(fn;symbol;symbol)} Where clause in functional form
registry.util.delete.where:{[experimentName;modelName;version;objectType]
  $[objectType~`allModels;
      (like;`modelName;modelName);
    objectType~`modelVersion;
      (&;(like;`modelName;modelName);({{x~y}[y]'[x]};`version;version));
    (like;`experimentName;experimentName)
    ]
  }
