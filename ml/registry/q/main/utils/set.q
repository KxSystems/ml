// set.q - Utilties relating to setting objects in the registry
// Copyright (c) 2021 Kx Systems Inc
//
// @overview
// Registry object setting utilities
//
// @category    Model-Registry
// @subcategory Utilities
//
// @end

\d .ml

// @private
//
// @overview
// Add a q/Python objects to the registry so that they can be retrieved and
// applied to new data. In the current iteration there is an assumption of
// complete independence for the q functions/files i.e. q function/workflows
// explicitly don't use Python to make it easier to store and generate
// reintroduce models
//
// @param model {any} `(<|dict|fn|proj)` The model to be saved to the registry.
// @param modelType {string} The type of model that is being saved, namely
//   "q"|"sklearn"|"keras"
// @param config {dict} Any additional configuration needed for
//   initialising the experiment
//
// @return {dict} Updated config dictionary containing relevant
//   registry paths
registry.util.set.model:{[model;modelType;config]
  load config`modelStorePath;
  config:registry.util.create.modelFolders[model;modelType] config;
  registry.set.object[modelType;config`registryPath;model;config];
  if[not count key hsym `$config`codePath;
     registry.util.set.code[config`code;config`registryPath;config]
    ];
  registry.util.set.version[modelType;config];
  registry.util.set.requirements config;
  registry.set.modelConfig[model;modelType] config;
  registry.set.modelStore config;
  if[`data in key config;
    registry.set.monitorConfig[model;modelType;config`data;config]
    ];
  if[`supervise in key config;
    registry.set.superviseConfig[model;config]
    ];
  load config`modelStorePath;
  whereClause: enlist (&;(&;(~\:;`version;config[`version]);(~\:;`modelName;config[`modelName]));
                        (~\:;`experimentName;config[`experimentName]));
  columns:enlist `uniqueID;
  config[`uniqueID]:first ?[config`modelStorePath;whereClause;0b;columns!columns]`uniqueID;
  config
  }

// @private
//
// @overview
// General function for setting a file within the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.file:{[extension;registryPath;model;modelInfo]
  model:hsym $[10h=type model;`$;]model;
  modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
  registry.util.copy.file[model;hsym`$modelPath,extension]
  }

// @private
//
// @overview
// General function for setting a directory within the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @param extension {string} The name to be associated with the new copied dir
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.dir:{[extension;registryPath;model;modelInfo]
  model:hsym $[10h=type model;`$;]model;
  modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
  registry.util.copy.dir[model;hsym`$modelPath,extension]
  }

// @private
//
// @overview
// Set a file associated with a model to the ML Registry such that it
// can be deployed in the same way as the functions added to the registry
// from within process
//
// @param typ {symbol} Type of model being saved
// @param func {fn} Function used to load model
// @param mdl {symbol} Model name
// @param args {any} Arguments required for `registry.util.set.file`.
//
// @return {null}
registry.util.set.modelFile:{[typ;func;mdl;args]
  err:"Could not retrieve ",string[typ]," model";
  mdl:@[func;mdl;{[x;y]'x," with error: ",y}err];
  mlops.check[typ][mdl;1b];
  registry.util.set.file . args
  }

// @private
//
// @overview
// Set a dir associated with a model to the ML Registry such that it
// can be deployed in the same way as the functions added to the registry
// from within process
//
// @param typ {symbol} Type of model being saved
// @param func {fn} Function used to load model
// @param mdl {symbol} Model name
// @param args {any} Arguments required for `registry.util.set.dir`.
//
// @return {null}
registry.util.set.modelDir:{[typ;func;mdl;args]
  err:"Could not retrieve ",string[typ]," model";
  mdl:@[func;mdl;{[x;y]'x," with error: ",y}err];
  registry.util.set.dir . args
  }

// @private
//
// @overview
// Set a file associated with a q binary file to the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @todo
// Check that the file can be retrieved and is a suitable q object to be
//   introduced to the system
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.qFile:{[extension;registryPath;model;modelInfo]
  func:get;
  mdl:hsym$[10h=type model;`$;]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelFile[`q;func;mdl;args]
  }["/mdl"]

// @private
//
// @overview
// Set a file associated with an Python object model to the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @todo
// Check that the file can be unpickled using joblib such that it can be
//   introduced to the system appropriately
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.pythonFile:{[extension;registryPath;model;modelInfo]
  func:.p.import[`joblib]`:load;
  mdl:$[10h=type model;;1 _ string hsym@]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelFile[`python;func;pydstr mdl;args]
  }["/mdl.pkl"]

// @private
//
// @overview
// Set a file associated with an Sklearn pickled fit model to the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @todo
// Check that the file being added to the registry complies with
//   being an fit sklearn model
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.sklearnFile:{[extension;registryPath;model;modelInfo]
  func:.p.import[`joblib]`:load;
  mdl:$[10h=type model;;1_string hsym@]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelFile[`sklearn;func;pydstr mdl;args]
  }["/mdl.pkl"]

// @private
//
// @overview
// Set a file associated with an XGBoost pickled fit model to the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @todo
// Check that the file being added to the registry complies with
//   being an fit xgboost model
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.xgboostFile:{[extension;registryPath;model;modelInfo]
  func:.p.import[`joblib]`:load;
  mdl:$[10h=type model;;1_string hsym@]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelFile[`xgboost;func;pydstr mdl;args]
  }["/mdl.pkl"]

// @private
//
// @overview
// Set a file associated with a Keras model (.h5) to the
// ML Registry such that it can be deployed in the same way as the
// functions added to the registry from within process
//
// @todo
// Check that the file being added to the registry complies with
//   being an fit keras model
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.kerasFile:{[extension;registryPath;model;modelInfo]
  func:.p.import[`keras.models]`:load_model;
  mdl:$[10h=type model;;1_string hsym@]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelFile[`keras;func;pydstr mdl;args]
  }["/mdl.h5"]

// @private
//
// @overview
// Set a file associated with a Pytorch jit saved model to the
// ML Registry such that it can be deployed
//
// @todo
// Check that the file can be retrieved and is a suitable torch object to be
//   introduced to the system
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.torchFile:{[extension;registryPath;model;modelInfo]
  torch:@[.p.import;
    `torch;
    {[x]logging.error"PyTorch not installed, cannot add PyTorch models to registry"}
    ];
  modelPath:$[10h=type model;;1_string hsym@]model;
  mdl:@[torch[`:jit.load];
    modelPath;
    {[torch;modelPath;err]
      @[torch[`:load];
       pydstr modelPath;
      {[x]
       logging.error"Torch models saved must be loadable using 'torch.load'|'torch.jit.load'"
       }]
      }[torch;modelPath]
    ];
  mlops.check.torch[mdl;1b];
  registry.util.set.file[extension;registryPath;model;modelInfo]
  }["/mdl.pt"]


// @private
//
// @overview
// Set a file associated with a PySpark pipeline saved model to the
// ML Registry such that it can be deployed
//
// @todo
// NOTE CAN ONLY LOAD FIT PIPELINES NOT MODELS
//
// @param extension {string} The name to be associated with the new copied file
// @param registryPath {string} Full/relative path to the model registry
// @param model {string|#hsym|symbol} Full/relative path to the model being copied
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.pysparkFile:{[extension;registryPath;model;modelInfo]
  pipe:.p.import[`pyspark.ml]`:PipelineModel;
  func:pipe`:load;
  mdl:$[10h=type model;;1_string hsym@]model;
  args:(extension;registryPath;model;modelInfo);
  registry.util.set.modelDir[`pyspark;func;mdl;args]
  }["/mdl.model"]

// @private
//
// @overview
// Protected writing of a model
//
// @param writer {fn} Function to write model to disk
// @param path {string} Path to write model to
//
// @return {null}
registry.util.set.write:{[writer;path] if[not count key hsym `$path;writer path]}

// @private
//
// @overview
// Set an underlying Sklearn embedPy object within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The sklearn model to be saved as a pickle file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.sklearnModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [
    {[registryPath;modelInfo;sym;model]
    mlops.check.sklearn[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;y]}[model];modelPath,string[sym],"/mdl.pkl"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.sklearn[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;pydstr y]}[model];modelPath,"/mdl.pkl"];
    ]
  ]
  }

// @private
//
// @overview
// Set an underlying XGBoost embedPy object within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The xgboost model to be saved as a pickle file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.xgboostModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [
    {[registryPath;modelInfo;sym;model]
    mlops.check.xgboost[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;y]}[model];modelPath,"/",string[sym],"/mdl.pkl"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.xgboost[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;pydstr y]}[model];modelPath,"/mdl.pkl"];
    ]
    ]
  }


// @private
//
// @overview
// Set an underlying PySpark embedPy object within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The xgboost model to be saved as a pickle file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.pysparkModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [{[registryPath;modelInfo;sym;model]
    mlops.check.pyspark[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    if[not (model[`:__class__][`:__name__]`) like "*Pipeline*";
      pipe:.p.import[`pyspark.ml]`:Pipeline;
      model:pipe[`stages pykw enlist model`][`:fit][()];
      ];
    registry.util.set.write[model[`:save];modelPath,"/",string[sym],"/mdl.model"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.pyspark[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    if[not (model[`:__class__][`:__name__]`) like "*Pipeline*";
      pipe:.p.import[`pyspark.ml]`:Pipeline;
      model:pipe[`stages pykw enlist model`][`:fit][()];
      ];
    registry.util.set.write[{x[pydstr y]}[model[`:save]];modelPath,"/mdl.model"];
    ]
  ]
  }


// @private
//
// @overview
// Set an q function object within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(dict|fn|proj)` The model to be saved
// @param modelInfo {dict} Information relating to the model that is
//   to be saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.qModel:{[registryPath;model;modelInfo]
  func1:{[registryPath;modelInfo;model]
    mlops.check.q[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{hsym[`$y]set x}[model];modelPath,"mdl"];
    }[registryPath;modelInfo];

  func2:{[registryPath;modelInfo;sym;model]
    mlops.check.q[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{hsym[`$y]set x}[model];modelPath,string[sym],"/mdl"];
    }[registryPath;modelInfo];

  $[(99h=type[model]);
    $[not(`predict in key model)|(`modelInfo in key model);func2'[key model;value model];func1[model]];
    func1[model]
   ];
  }

// @private
//
// @overview
// Set an python embedPy object within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The Python object to be saved as a pickle file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.pythonModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [
    {[registryPath;modelInfo;sym;model]
    mlops.check.python[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;y]}[model];modelPath,"/",string[sym],"/mdl.pkl"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.python[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`joblib][`:dump][x;y]}[model];modelPath,"/mdl.pkl"];
    ]
  ]
  }

// @private
//
// @overview
// Set a Keras model within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The Keras object to be saved as a h5 file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.kerasModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [{[registryPath;modelInfo;sym;model]
    mlops.check.keras[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[model[`:save];modelPath,"/",string[sym],"/mdl.h5"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.keras[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[model[`:save];modelPath,"/mdl.h5"];
    ]
  ]
  }

// @private
//
// @overview
// Set a Torch model within the ML Registry
//
// @param registryPath {string} Full/relative path to the model registry
// @param model {any} `(<|foreign)` The Torch object to be saved as a h5 file.
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.torchModel:{[registryPath;model;modelInfo]
  $[99h=type model;
    [{[registryPath;modelInfo;sym;model]
    mlops.check.torch[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`torch][`:save][x;y]}[model];modelPath,"/",string[sym],"/mdl.pt"];
    }[registryPath;modelInfo]'[key model;value model];
    ];
    [
    mlops.check.torch[model;0b];
    modelPath:registry.util.path.modelFolder[registryPath;modelInfo;`model];
    registry.util.set.write[{.p.import[`torch][`:save][x;pydstr y]}[model];modelPath,"/mdl.pt"];
    ]
  ]
  }

// @private
//
// @overview
// Add a code file with extension '*.p','*.py','*.q' to a specific
// model such that the code can be loaded on retrieval of the model.
// This is required to facilitate comprehensive support for PyTorch
// models being persisted and usable.
//
// @param files {symbol|symbol[]} The absolute/relative path to a file or
//   list of files that are to be added to the registry associated with a
//   model. These must be '*.p', '*.q' or '*.py'
// @param registryPath {string} Full/relative path to the model registry
// @param modelInfo {dict} Information relating to the model which is
//   being saved, this includes version, experiment and model names
//
// @return {null}
registry.util.set.code:{[files;registryPath;modelInfo]
  if[(11h<>abs type files)|all null files;:(::)];
  files:registry.util.check.code[files];
  if[0~count files;:(::)];
  codePath:registry.util.path.modelFolder[registryPath;modelInfo;`code];
  registry.util.copy.file[;hsym`$codePath]each files;
  }

// @private
//
// @overview
// Add a requirements file associated with a model to the versioned model
// folder this can be either a 'pip freeze` of the current environment,
// a user supplied list of requirements which can be pip installed or the
// path to an existing requirements.txt file which can be used.
//
// 'pip freeze' is only suitable for users running within venvs and as such
// is not supported within environments which are not inferred to be venvs as
// running within 'well' established environments can cause irreconcilable
// requirements.
//
// @param folderPath {string|null} A folder path indicating the location
//   the registry containing the model which is to be populated with a requirements
//   file
// @param config Configuration provided by the user to
//   customize the experiment
//
// @return {null}
registry.util.set.requirements:{[config]
  requirement:config[`requirements];
  $[0b~requirement;
      :(::);
    1b~requirement;
      registry.util.requirements.pipfreeze config;
    -11h=type requirement;
      registry.util.requirements.copyfile config;
    0h=type requirement;
      registry.util.requirements.list config;
    logging.error"requirements config key must be a boolean, symbol or list of strings"
    ];
  }

// @private
//
// @overview
// Set the parameters to a json file
//
// @param paramPath {string} The path to the parameter file
// @param params {dict|table|string} The parameters to save to file
//
// @return {null}
registry.util.set.params:{[paramPath;params]
   (hsym `$paramPath) 0: enlist .j.j params
  }

// @private
//
// @overview
// Set a metric associated with a model to a supported cloud
// vendor or on-prem. This is a wrapper function used to facilitate
// protected execution.
//
// @param storage {symbol} Type of registry storage - local or cloud
// @param experimentName {string|null} The name of an experiment
// @param modelName {string|null} The name of the model to be retrieved
// @param version {long[]|null} The specific version of a named model
// @param metricName {string} The name of the metric to be persisted
// @param metricValue {float} The value of the metric to be persisted
//
// @return {null}
registry.util.set.metric:{[storage;experimentName;modelName;version;config;metricName;metricValue]
  modelDetails:registry.util.search.model[experimentName;modelName;version;config];
  if[not count modelDetails;
    logging.error"No model meeting your provided conditions was available"
    ];
  // Construct the path to metric folder containing the config to be updated
  config,:flip modelDetails;
  metricPath:registry.util.path.modelFolder[config`registryPath;config;`metrics];
  fileExists:`metric in key hsym`$metricPath;
  if[not fileExists;registry.util.create.modelMetric[metricPath]];
  registry.set.modelMetric[metricName;metricValue;metricPath];
  if[`local<>storage;
    registry.cloud.update.publish config
    ];
  }

// @private
//
// @overview
// Set JSON file for specified object
//
// @param config {dict} Information relating to the model
//   being saved, this includes version, experiment and model names
// @param jsonTyp {symbol} `registry.util.create` function to call
// @param jsonStr {string} Name of JSON file
// @param args {any} Arguments to apply to `registry.util.create` function.
//
// @return {null}
registry.util.set.json:{[config;jsonTyp;jsonStr;args]
  jsonConfig:registry.util.create[jsonTyp]. args;
  if[not(::)~jsonConfig;
    (hsym `$config[`versionPath],"/config/",jsonStr,".json") 0: enlist .j.j jsonConfig
    ];
  }

// @private
//
// @overview
// Set Python library and q/Python language versions with persisted models
//
// @param modelType {string} User provided model type defining is the model was "q"/"sklearn" etc
// @param config Information relating to the model
//   being saved, this includes version, experiment and model names along with
//   path information relating to the saved location of model
//
// @return {null}
registry.util.set.version:{[modelType;config]
  // Information about Python/q version used in model saving
  versionFile:config[`versionPath],"/.version.info";

  // Define q version used when persisting the model
  versionInfo:enlist[`q_version]!enlist "Version: ",string[.z.K]," | Release Date: ",string .z.k;

  // Add model type to version info
  versionInfo,:enlist[`model_type]!enlist modelType;

  // If the model isn't q save version of Python used
  if[`q<>`$modelType;versionInfo,:enlist[`python_version]!enlist .p.import[`sys;`:version]`];
   
  // Information about the Python library version used in the process of generating the model
  if[(`$modelType) in `sklearn`keras`torch`xgboost`pyspark;
    versionInfo,:enlist[`python_library_version]!enlist pygetver modelType;
    ];
  // dont allow same model with different versions of q/python
  $[count key hsym `$versionFile;
    $[(.j.k raze read0 hsym `$versionFile)~.j.k raze .j.j versionInfo;
      (hsym `$versionFile) 0: enlist .j.j versionInfo;
      '"Error writing same model with two environments see .version.info file"
      ];
    (hsym `$versionFile) 0: enlist .j.j versionInfo];
  }
