// delete.q - Main callable functions for deleting items from the model registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Delete items from the registry
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete a registry and the entirety of its contents
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param config {dict} Information relating to registry being deleted
//
// @return {null}
registry.delete.registry:{[folderPath;config]
  config:registry.util.check.config[folderPath;config];
  if[`local<>storage:config`storage;storage:`cloud];
  registry[storage;`delete;`registry][folderPath;config]
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete an experiment and its associated models from the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
//
// @return {null}
registry.delete.experiment:{[folderPath;experimentName]
  config:registry.util.check.config[folderPath;()!()];
  $[`local<>config`storage;
    registry.cloud.delete.experiment[config`folderPath;experimentName;config];
    [config:`folderPath`experimentName!(config`folderPath;experimentName);
     registry.util.delete.object[config;`experiment];
     ]
    ];
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete a version of a model/all models associated with a name
// from the registry and modelStore table
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]|null} The version of the model to retrieve (major;minor)
//
// @return {null}
registry.delete.model:{[folderPath;experimentName;modelName;version]
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]
     ]
    ];
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  modelName:first modelDetails `modelName;
  config:registry.util.check.config[folderPath;()!()];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  $[`local<>config`storage;
    registry.cloud.delete.model[config;experimentName;modelName;version];
    [configKeys:`folderPath`experimentName`modelName`version;
     configVals:(config`folderPath;experimentName;modelName;version);
     config:configKeys!configVals;
     objectType:$[(::)~version;`allModels;`modelVersion];
     registry.util.delete.object[config;objectType]
     ]
    ];
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete a parameter file associated with a name
// from the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]} The version of the model to retrieve (major;minor)
// @param paramFile {string} Name of the parameter file to delete
//
// @return {null}
registry.delete.parameters:{[folderPath;experimentName;modelName;version;paramFile]
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]
     ]
    ];
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  modelName:first modelDetails `modelName;
  version:first modelDetails `version;
  config:registry.util.check.config[folderPath;()!()];
  $[`local<>config`storage;
    [function:registry.cloud.delete.parameters;
     params:(config;experimentName;modelName;version;paramFile);
     function . params;
     ];
    [function:registry.util.getFilePath;
     params:(config`folderPath;experimentName;modelName;version;`params;enlist[`paramFile]!enlist paramFile);
     location:function . params;
     if[()~key location;logging.error"No parameter files exists with the given name, unable to delete."];
     hdel location;
     ]
    ];
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete the metric table associated with a name
// from the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]} The version of the model to retrieve (major;minor)
//
// @return {null}
registry.delete.metrics:{[folderPath;experimentName;modelName;version]
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]]
    ];
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  modelName:first modelDetails `modelName;
  version:first modelDetails `version;
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  folderPath:config`folderPath;
  $[`local<>storage;
    registry.cloud.delete.metrics[config;experimentName;modelName;version];
    [function:registry.util.getFilePath;
     params:(folderPath;experimentName;modelName;version;`metrics;()!());
     location:function . params;
     if[()~key location;logging.error"No metric table exists at this location, unable to delete."];
     hdel location;
     ]
    ];
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete the code associated with a name
// from the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]} The version of the model to retrieve (major;minor)
// @param codeFile {string} The type of config
//
// @return {null}
registry.delete.code:{[folderPath;experimentName;modelName;version;codeFile]
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]]
    ];
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  modelName:first modelDetails `modelName;
  version:first modelDetails `version;
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  folderPath:config`folderPath;
  $[`local<>storage;
    [function:registry.cloud.delete.code;
     params:(config;experimentName;modelName;version;codeFile);
     function . params
     ];
    [function:registry.util.getFilePath;
     params:(folderPath;experimentName;modelName;version;`code;enlist[`codeFile]!enlist codeFile);
     location:function . params;
     if[()~key location;logging.error"No such code exists at this location, unable to delete."];
     hdel location
     ]
    ];
  }

// @kind function
// @category main
// @subcategory delete
//
// @overview
// Delete a metric from the metric table associated with a name
// from the registry
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string} Name of the experiment to be deleted
// @param modelName {string|null} The name of the model to retrieve
// @param version {long[]} The version of the model to retrieve (major;minor)
// @param metricName {string} The name of the metric
//
// @return {null}
registry.delete.metric:{[folderPath;experimentName;modelName;version;metricName]
  if[-11h=type metricName;metricName:string metricName];
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  // Locate/retrieve the registry locally or from the cloud
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]]
    ];
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  modelName:first modelDetails `modelName;
  version:first modelDetails `version;
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  folderPath:config`folderPath;
  $[`local<>storage;
    [function:registry.cloud.delete.metric;
     params:(config;experimentName;modelName;version;metricName);
     function . params
     ];
    [function:registry.util.getFilePath;
     params:(folderPath;experimentName;modelName;version;`metrics;()!());
     location:function . params;
     if[()~key location;logging.error"No metric table exists at this location, unable to delete."];
     location set ?[location;enlist (not;(like;`metricName;metricName));0b;`symbol$()];
     ]
    ];
  }
