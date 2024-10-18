// log.q - Main callable functions for logging information to the
// model registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Log information to the registry
//
// @category    Model-Registry
// @subcategory Functionality
//
// @end

\d .ml

// @kind function
// @category main
// @subcategory log
//
// @overview
// Log metric values for a model
//
// @todo
// Add type checking for modelName/experimentName/version
// Improve function efficiency when dealing with cloud vendors presently this is limited
//   by retrieval of registry and republish.
//
// @param folderPath {dict|string|null} Registry location, can be:
//   1. A dictionary containing the vendor and location as a string, e.g.
//      ```enlist[`local]!enlist"myReg"``` or
//      ```enlist[`aws]!enlist"s3://ml-reg-test"``` etc;
//   2. A string indicating the local path;
//   3. A generic null to use the current .ml.registry.location pulled from CLI/JSON.
// @param experimentName {string|null} The name of an experiment from which
//   to retrieve a model, if no modelName is provided the newest model
//   within this experiment will be used. If neither modelName or
//   experimentName are defined the newest model within the
//   "unnamedExperiments" section is chosen
// @param modelName {string|null} The name of the model to be retrieved
//   in the case this is null, the newest model associated with the
//   experiment is retrieved
// @param version {long[]|null} The specific version of a named model to retrieve
//   in the case that this is null the newest model is retrieved (major;minor)
// @param metricName {symbol|string} The name of the metric to be persisted
//   in the case when this is a string, it is converted to a symbol
// @param metricValue {float} The value of the metric to be persisted
//
// @return {null}
registry.log.metric:{[folderPath;experimentName;modelName;version;metricName;metricValue]
  metricName: $[10h=abs[type metricName]; `$; ]metricName;
  config:registry.util.check.config[folderPath;()!()];
  if[not`local~storage:config`storage;storage:`cloud];
  config:$[storage~`local;
    registry.local.util.check.registry config;
    [checkFunction:registry.cloud.util.check.model;
     checkFunction[experimentName;modelName;version;config`folderPath;config]
     ]
    ];
  logParams:(storage;experimentName;modelName;version;config;metricName;metricValue);
  .[registry.util.set.metric;
    logParams;
    {[x;y;z]
      $[`local~x;;registry.util.delete.folder]y;
      logging.error z
      }[storage;config`folderPath]
    ]
  }
