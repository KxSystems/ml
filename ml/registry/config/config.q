// config.q - Configuration used by the default usage of the registry functions
// Copyright (c) 2021 Kx Systems Inc
//
// @category    Model-Registry
// @subcategory Configuration

\d .ml

// @kind function
// @category config
//
// @overview
// Retreive default dictionary values from JSON file
//
// @param file {string} File to retrieve
//
// @return {dict} Default JSON values
getJSON:{[file]
  registry.config.util.getJSON"registry/config/",file,".json"
  }

// @private
registry.config.default:getJSON"model"

// @private
registry.config.model:getJSON"default"

// @private
/registry.config.cloudDefault:getJSON"cloud"

// @private
registry.config.cliDefault:getJSON"command-line"

// @private
symConvert:`modelName`version`vendor`code

// @private
registry.config.cliDefault[symConvert]:`$registry.config.cliDefault symConvert


// @kind function
// @category config
//
// @overview
// Convert CLI version to correct format
//
// @param cfg {dict} CLI config dictionary
//
// @return {string|null} Updated version
convertVersion:{[cfg]
  $[`inf~cfg`version;(::);raze"J"$"."vs string cfg`version]
  }

// @private
registry.config.commandLine:.Q.def[registry.config.cliDefault].Q.opt .z.x

// @private
registry.config.commandLine[`version]:convertVersion registry.config.commandLine

// Ensure only one cloud vendor is to be used
// @private
cloudVendors:`aws`azure`gcp
if[1<sum cv:cloudVendors in key registry.config.commandLine;
  .ml.log.fatal "Only one of `aws`azure`gcp should be defined as command line inputs"
  ]

// @kind function
// @category config
//
// @overview
// Update configuration appropriately based on cloud vendor
// input to ensure that command line arguments are picked appropriately
// and inputs are appropriately formatted for each vendor. Then updated the
// registry location based on cloud vs local and vendor.
//
// @param storage {symbol} Type registry storage, e.g. gcp, aws, azure
//
// @return {dict} Cloud storage location
cloudLocation:{[storage]
  func:`$"update",$[storage in`gcp`aws;upper;@[;0;upper]]string storage;
  registry.config.util[func][];
  enlist[storage]!enlist registry.config.commandLine storage
  }

// @kind function
// @category config
//
// @overview
// Update registry location to local storage location from CLI
//
// @return {dict} Local storage location
onpremLocation:{
  l:registry.config.commandLine`local;
  enlist[`local]!enlist$[l~`;".";l]
  }

// @private
registry.location:$[any cv;
  string cloudLocation first cloudVendors where cv;
  onpremLocation[]
  ]
