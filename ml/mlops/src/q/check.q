\d .ml

// Check that the q model being set/retrieved from the model registry
// is of an appropriate type
//
// @param model {fn|proj|dictionary} The model to be saved to the registry.
//   In the case this is a dictionary it is assumed that a 'predict' key
//   exists such that the model can be used on retrieval
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.q:{[model;getOrSet]
  if[not type[model]in 99 100 104h;
    printString:$[getOrSet;"retrieved is not";"must be"];
    '"model ",printString," a q function/projection/dictionary"
    ];
  if[99h=type model;
    if[not `predict in key model;
      printString:$[getOrSet;"retrieved";"saved"];
      '"q dictionaries being ",printString," must contain a 'predict' key"
      ];
    ];
  }

// Check that the Python object model being set/retrieved from the model
// registry is of an appropriate type
//
// @param model {<} The model to be saved to the registry. This must be
//   an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.python:{[model;getOrSet]
  if[not type[model]in 105 112h;
    printString:$[getOrSet;"retrieved is not";"must be"];
    '"model ",printString," an embedPy object"
    ];
  }

// Check that a model that is being added to the or retrieved from the
// registry is an sklearn model with a predict method
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.sklearn:{[model;getOrSet]
  mlops.check.python[model;getOrSet];
  mlops.check.pythonlib[model;"sklearn"];
  @[{x[`:predict]};model;{[x]'"model must contain a predict method"}]
  }

// Check that a model that is being added to the or retrieved from the
// registry is an xgboost model with a predict method
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.xgboost:{[model;getOrSet]
  mlops.check.python[model;getOrSet];
  mlops.check.pythonlib[model;"xgboost"];
  @[{x[`:predict]};model;{[x]'"model must contain a predict method"}]
  }

// Check that a model that is being added to the or retrieved from the
// registry is a Keras model with a predict method
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.keras:{[model;getOrSet]
  mlops.check.python[model;getOrSet];
  mlops.check.pythonlib[model;"keras"];
  @[{x[`:predict]};model;{[x]'"model must contain a predict method"}]
  }

// Check that a model that is being added to the or retrieved from the
// registry is a Theano model with a predict method
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.theano:{[model;getOrSet]
  mlops.check.python[model;getOrSet];
  mlops.check.pythonlib[model;"theano"]
  }

// Check that a model that is being added to or retrieved from the
// registry is a PyTorch model 
//
// TO-DO
//   - Increase type checking on torch objects
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.torch:{[model;getOrSet]
  mlops.check.python[model;getOrSet];
  }

// Check that a DAG being saved/retrieved is appropriately formatted
//
// @param model {dictionary} The DAG to be saved/retrieved
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.graph:{[model;getOrSet]
  if[not 99h=type model;
    printString:$[getOrSet;"retrieved is not";"must be"];
    '"graph ",printString," a q dictionary"
    ];
  if[not `vertices`edges~key model;
    '"graph does not contain 'vertices' and 'edges' keys expected"
    ];
  }

// Check that a model that is being added to or retrieved from the
// registry is a pyspark pipeline with a transform method
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param getOrSet {boolean} Is the model being retrieved or persisted, this
//   modifies the error statement on issue with invocation
// @return {::} Function will error on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.pyspark:{[model;getOrSet]
  .ml.mlops.check.python[model;getOrSet];
  @[{x[`:transform]};model;{[x]'"model/pipeline must contain a transform method"}]
  }

// Check that the python object that is retrieved contains an appropriate
// indication that it comes from the library that it is expected to come
// from.
//
// @param model {<} The model to be saved to or retrieved from the registry.
//   This must be an embedPy or foreign object
// @param library {string} The name of the library that is being checked
//   against, this is sufficient in the case of fit sklearn/xgboost/keras models
//   but may not be generally applicable
// @return {::} Function willerror on unsuccessful invocation otherwise
//   generic null is returned
mlops.check.pythonlib:{[model;library]
  builtins:.p.import[`builtins];
  stringRepr:builtins[`:str;<][builtins[`:type]model];
  if[not stringRepr like "*",library,"*";
    '"Model retrieved not a python object derived from the library '",
    library,"'."
    ];
  }
