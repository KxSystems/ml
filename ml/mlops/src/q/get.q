\d .ml

// Retrieve a q model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {dict|fn|proj} The model previously saved to disk
//   registry
mlops.get.q:{[filePath]
  mlops.get.typedModel[`q;filePath;get]
  }

// Retrieve a Python model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.python:{[filePath]
  func:.p.import[`joblib]`:load;
  mlops.get.typedModel[`python;filePath;func]
  }

// Retrieve a sklearn model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.sklearn:{[filePath]
  func:.p.import[`joblib]`:load;
  mlops.get.typedModel[`sklearn;filePath;func]
  }

// Retrieve a xgboost model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.xgboost:{[filePath]
  func:.p.import[`joblib]`:load;
  mlops.get.typedModel[`xgboost;filePath;func]
  }

// Retrieve a Keras model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.keras:{[filePath]
  func:.p.import[`keras.models]`:load_model;
  mlops.get.typedModel[`keras;filePath;func]
  }

// Retrieve a Theano model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.theano:{[filePath]
  func:.p.import[`joblib]`:load;
  mlops.get.typedModel[`theano;filePath;func]
  }

// Retrieve a PyTorch model from disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
mlops.get.torch:{[filePath]
  torch:.p.import`torch;
  model:@[torch`:load;
    filePath;
    {[torch;filePath;err]
      @[torch`:jit.load;
        filePath;
        {[x;y]'"Could not retrieve the requested model at ",x}[filePath]
        ]
        }[torch;filePath]
    ];
  mlops.check.torch[model;1b];
  model
  }

// Retrieve a DAG from a location on disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {dictionary} The dictionary defining a saved workflow
mlops.get.graph:{[filePath]
  func:.dag.loadGraph;
  mlops.get.typedModel[`graph;filePath;func]
  }

// Retrieve a pyspark model from a location on disk
//
// @param filePath {string} The full path the model to be retrieved
// @return {<} The embedPy object associated with the model saved
.ml.mlops.get.pyspark:{[modelPath]
    pipe:.p.import[`pyspark.ml]`:PipelineModel;
    func:pipe`:load;
    @[func;modelPath;{[x;y]'"Could not retrieve the requested model at ",x}[modelPath]]
    };

// Retrieve a model from disk.
//
// @param typ {symbol} Type of model being retrieved
// @param filePath {string} The full path to the desired model
// @param func {function} Function used to retrieve model object
// @return {dict|fn|proj} The model previously saved to disk within the
//   registry
mlops.get.typedModel:{[typ;filePath;func]
  mdl:$[typ~`q;hsym`$filePath;filePath];
  model:@[func;mdl;
    {[x;y]'"Could not retrieve the requested model at ",x}[filePath]
    ];
  mlops.check[typ][model;1b];
  model
  }
