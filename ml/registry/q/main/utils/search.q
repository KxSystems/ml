// search.q - Search the model store for specific information
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Utilities for searching the modelStore
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Select the model most closely matching the users request for a model based
// on associated experiment, name of the mode and version of the model.
//
// - If no experiment, model name or version are provided, retrieve the most
//   recently added model.
// - If no experiment or version are provided but a model name is, retrieve the
//   highest versioned experiment associated with that name
// - If no experiment is provided by a model name and version are, retrieve the
//   version of the model requested
// - If no model name or version are provided but an experiment name is,
//   retrieve the most recent model added to that experiment
//
// @param experimentName {string|null} The name of the experiment to retrieve
//   from
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]|null} The version of the model to retrieve
//   initialising the experiment
//
// @return {table} A table containing the entry matching the user provided
//   information
registry.util.search.model:{[experimentName;modelName;version;config]
  infoKeys:`experimentName`modelName`modelType`version;
  fmax:{xx:x where x[;0]=max x[;0];first xx where xx[;1]=max xx[;1]};
  modelNoVersion:(
    (like;`modelName;modelName);
    ({{x~y}[x y]'[y]};fmax;`version)
    );
  modelVersion:(
    (like;`modelName;modelName);
    ({y~/:x};`version;version)
    );
  whereCond:$[modelName~(::);
    enlist(=;`registrationTime;(max;`registrationTime));
    $[version~(::);modelNoVersion;modelVersion]
    ];
  whereCond,:$[any experimentName ~/: (::;"");();(like;`experimentName;experimentName)];
  ?[config`modelStorePath;whereCond;0b;infoKeys!infoKeys]
  }

// @private
//
// @overview
// Retrieve and increment the version of the model being saved within the
// registry based on previous versions
//
// @param config {dict} Configuration provided by the user to customize
//   the experiment
//
// @return {dict} The updated version number to be used when persisting
//   the model
registry.util.search.version:{[config]
  if[`version in key config;:config];
  whereClause:(
    (like;`experimentName;config`experimentName);
    (like;`modelName;config`modelName)
    );
  if[(`majorVersion in key config)&config[`major];
    logging.error"cant select majorVersion while incrementing version"
    ];
  if[`majorVersion in key config;
    mV:floor config`majorVersion;
    whereClause,:(=;(`version;::;0);mV)
    ];
  fmax:{xx:x where x[;0]=max x[;0];first xx where xx[;1]=max xx[;1]};
  selectClause:(fmax;`version);
  currentVersion:?[config`modelStorePath;whereClause;();selectClause];
  if[(not count currentVersion)&`majorVersion in key config;
    logging.error"cant select majorVersion if no models present"
    ];
  if[not count currentVersion;:config,enlist[`version]!enlist (1;0)];
  if[bool:config[`major];
    :config,enlist[`version]!enlist(currentVersion[0]+1;0)
    ];
  config,enlist[`version]!enlist currentVersion+(0;1)
  }

// @private
//
// @overview
// Search for a particular parameter in the metrics table
//
// @todo
// Add additional search parameters other than just metric name?
//
// @param metricTab {table} The table of metric information
// @param param {dict} Search parameters for config table
//
// @return {table} Metric table
registry.util.search.metric:{[metricTab;param]
  if[not 99=type param;:metricTab];
  if[`metricName in key param;
    metricName:enlist param`metricName;
    metricTab:{[tab;metricName]?[tab;enlist(in;`metricName;metricName);0b;()]
      }[metricTab;metricName]
    ];
  metricTab
  }

// @private
//
// @overview
// Search for the parameter json fil
//
// @param paramPath {string} The path to the param JSON file
//
// @return {table|dict|string} The information within the parameter JSON file
registry.util.search.params:{[paramPath]
  .j.k raze read0 hsym`$paramPath
  }
