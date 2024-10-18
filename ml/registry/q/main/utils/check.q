// check.q - Utilities relating to checking of suitability of registry items
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Check that the information provided for adding items to the registry is
// suitable, this includes but is not limited to checking if the model name
// provided already exists, that the configuration is appropriately typed etc.
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Correct syntax for path dependent on OS
//
// @param path {string} A path name
//
// @return {string} Path suitable for OS
registry.util.check.osPath:{[path]
  $[.z.o like"w*";{@[x;where"/"=x;:;"\\"]};]path
  };

// @private
//
// @overview
// Check to ensure that the folder path for the registry is appropriately
// typed
//
// @param folderPath {string|null} A folder path indicating the location the
//   registry is to be located or generic null to place in the current
//   directory
//
// @return {string} type checked folderPath
registry.util.check.folderPath:{[folderPath]
  if[not((::)~folderPath)|10h=type folderPath;
    logging.error"Folder path must be a string or ::"
    ];
  $[(::)~folderPath;enlist".";folderPath]
  }

// @private
//
// @overview
// Check to ensure that the experiment name provided is suitable and return
// an appropriate surrogate in the case the model name is undefined
//
// @param experimentName {string} Name of the experiment to be saved
//
// @return {string} The name of the experiment
registry.util.check.experiment:{[experimentName]
  $[""~experimentName;
    "undefined";
    $[10h<>type experimentName;
      logging.error"'experimentName' must be a string";
      experimentName
      ]
    ]
  }

// @private
//
// @overview
// Check that the model type that the user is providing to save the model
// against is within the list of approved types
//
// @param config {dict} Configuration provided by the user to
//   customize the experiment
//
// @return {null}
registry.util.check.modelType:{[config]
  modelType:config`modelType;
  approvedTypes:("sklearn";"xgboost";"q";"keras";"python";"torch";"pyspark");
  if[10h<>abs type[modelType];
    logging.error"'modelType' must be a string"
    ];
  if[not any modelType~/:approvedTypes;
    logging.error"'",modelType,"' not in approved types for KX model registry"
    ];
  }

// @private
//
// @overview
// Check if the registry which is being manipulated exists
//
// @param config {dict|null} Any additional configuration needed for
//   initialising the registry
//
// @return {dict} Updated config dictionary containing registry path
registry.util.check.registry:{[config]
  folderPath:config`folderPath;
  registryPath:folderPath,"/KX_ML_REGISTRY";
  config:$[()~key hsym`$registryPath;
    [logging.info"Registry does not exist at: '",registryPath,
       "'. Creating registry in that location.";
     registry.new.registry[folderPath;config]
     ];
    [modelStorePath:hsym`$registryPath,"/modelStore";
     paths:`registryPath`modelStorePath!(registryPath;modelStorePath);
     config,paths
     ]
    ];
  config
  }

// @private
//
// @overview
// Check that a list of files that are attempting to be added to the
// registry exist and that they are either '*.q', '*.p' and '*.py' files
//
// @param files {symbol|symbol[]} The absolute/relative path to a file or
//   list of files that are to be added to the registry associated with a
//   model. These must be '*.p', '*.q' or '*.py'
//
// @return {symbol|symbol[]} All files which could be added to the registry
registry.util.check.code:{[files]
  fileExists:{x where {x~key x}each x}$[-11h=type files;enlist;]hsym files;
  // TO-DO
  //   - Add print to indicate what files couldnt be added
  fileType:fileExists where any fileExists like/:("*.q";"*.p";"*.py");
  // TO-DO
  //   - Add print to indicate what files didn't conform to supported types
  fileType
  }

// @private
//
// @overview
// Check user provided config has correct format
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param config {dict} Configuration provided by the user to
//   customize the pipeline
//
// @returns {dict} Returns config in correct format
registry.util.check.config:{[folderPath;config]
  config:$[any[config~/:(();()!())]|101h=type config;
      ()!();
    type[config]~99h;
      config;
    logging.error"config should be null or prepopulated dictionary"
    ];
  loc:$[10h=abs type folderPath;
    $[like[(),folderPath;"s3://*"];
      enlist[`aws]!;
      like[(),folderPath;"ms://*"];
      enlist[`azure]!;
      like[(),folderPath;"gs://*"];
      enlist[`gcp]!;
      enlist[`local]!
      ]enlist folderPath;
    99h=type folderPath;
    folderPath;
    any folderPath~/:((::);());
    registry.location;
    logging.error"Unsupported folderPath provided"
    ];
  locInfo:`storage`folderPath!first@'(key;value)@\:loc;
  config,locInfo
  }

// @private
//
// @overview
// Define which form of storage is to be used by the interface
//
// @param cli {dict} Command line arguments as passed to the system on
//   initialisation, this defines how the fundamental interactions of
//   the interface are expected to operate.
//
// @returns {symbol} The form of storage to which all functions are expected
//   to interact
registry.util.check.storage:{[cli]
  vendorList:`gcp`aws`azure;
  vendors:vendorList in key cli;
  if[not any vendors;:`local];
  if[1<sum vendors;
    logging.error"Users can only specify one of `gcp`aws`azure via command line"
    ];
  first vendorList where vendors
  }
