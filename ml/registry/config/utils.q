// utils.q - Utilities for the generation and modification of configuration
// Copyright (c) 2021 Kx Systems Inc
//
// @category    Model-Registry
// @subcategory Configuration

\d .ml

// @private
//
// @overview
// Read JSON from file and store as a q object
//
// @param filePath {string} The path to a JSON file to be read
//
// @return {dict} A q representation of the underlying JSON file
registry.config.util.readJSON:{[filePath]
  .j.k raze read0 hsym `$filePath
  }

// @private
//
// @overview
// Retrieve JSON from file and store as a q object at startup
//
// @param filePath {string} The path to a JSON file to be read
//
// @return {dict} A q representation of the underlying JSON file
.ml.registry.config.util.getJSON:{[filePath]
  @[.ml.registry.config.util.readJSON;
    path,"/",filePath;
    {[x;y].ml.registry.config.util.readJSON x}[filePath]
    ]
  }

// @private
//
// @overview
// Update the AWS default configuration if required and validate
// configuration is suitable, error if configuration is not appropriate
// as command line input or within the default configuration.
//
// @return {null}
registry.config.util.updateAWS:{[]
  cli :registry.config.commandLine`aws;
  json:registry.config.cloudDefault[`aws;`bucket];
  bool:`~.ml.registry.config.commandLine`aws;
  aws :$[bool;json;cli];
  if[not aws like "s3://*";
    .ml.log.fatal "AWS bucket must be defined via command line or in JSON config in the form s3://*"
    ];
  .ml.registry.config.commandLine[`aws]:$[-11h<>type aws;`$;]aws;
  }

// @private
//
// @overview
// Update the GCP default configuration if required and validate
// configuration is suitable, error if configuration is not appropriate
// as command line input or within the default configuration.
//
// @return {null}
registry.config.util.updateGCP:{[]
  cli :registry.config.commandLine`gcp;
  json:registry.config.cloudDefault[`gcp;`bucket];
  bool:`~.ml.registry.config.commandLine`gcp;
  gcp :$[bool;json;cli];
  if[not gcp like "gs://*";
    .ml.log.fatal "GCP bucket must be defined via command line or in JSON config in the form gs://*";
    ];
  .ml.registry.config.commandLine[`gcp]:$[-11h<>type gcp;`$;]gcp;
  }

// @private
//
// @overview
// Update the Azure default configuration if required and validate
// configuration is suitable, error if configuration is not appropriate
// as command line input or within the default configuration.
//
// @return {null}
registry.config.util.updateAzure:{[]
  cli  :registry.config.commandLine`azure;
  json :`${x[0],"?",x 1}registry.config.cloudDefault[`azure;`blob`token];
  bool :`~.ml.registry.config.commandLine`azure;
  azure:$[bool;json;cli];
  if[not like[azure;"ms://*"]|all like[azure]each("*?*";"http*");
    .ml.log.fatal "Azure blob definition via command line or in JSON config in the form http*?* | ms://*";
    ];
  .ml.registry.config.commandLine[`azure]:$[-11h<>type azure;`$;]azure;
  }
