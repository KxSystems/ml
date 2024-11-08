// check.q - Utilities relating to checking of suitability of registry items
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for checking items locally
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Check if the registry which is being manipulated exists, if it does not
// generate the registry at the sprcified location
//
// @param config {dict|null} Any additional configuration needed for
//   initialising the registry
//
// @return {dict} Updated config dictionary containing registry path
registry.local.util.check.registry:{[config]
  registryPath:config[`folderPath],"/KX_ML_REGISTRY";
  config:$[()~key hsym`$registryPath;
    [logging.info"Registry does not exist at: '",registryPath,
       "'. Creating registry in that location.";
     registry.new.registry[config`folderPath;config]
     ];
    [modelStorePath:hsym`$registryPath,"/modelStore";
     paths:`registryPath`modelStorePath!(registryPath;modelStorePath);
     config,paths
     ]
    ];
  config
  }
