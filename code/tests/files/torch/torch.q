\d .automl

// @kind function
// @category models
// @fileoverview Fit model on training data and score using test data
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @param mname {sym} name of the model being applied
// @return {int;float;bool} the predicted values for a given model as applied to input data
models.torch.fitScore:{[data;seed;mname]
  dataDict:`xtrain`ytrain`xtest`ytest!raze data;
  mdl:get[".automl.models.torch.",string[mname],".model"][dataDict;seed];
  mdl:get[".automl.models.torch.",string[mname],".fit"][dataDict;mdl];
  get[".automl.models.torch.",string[mname],".predict"][dataDict;mdl]
  }


// @kind function
// @category models
// @fileoverview Fit a vanilla torch model to data
// @param data {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param model {<} model object being passed through the system (compiled)
// @return {<} a vanilla fitted torch model
models.torch.NN.fit:{[data;model]
  optimArg:enlist[`lr]!enlist 0.9;
  optimizer:models.i.Adam[model[`:parameters][];pykwargs optimArg];
  criterion:models.i.neuralNet[`:BCEWithLogitsLoss][];
  dataX:models.i.numpy[models.i.npArray[data`xtrain]][`:float][];
  dataY:models.i.numpy[models.i.npArray[data`ytrain]][`:float][];
  tensorXY:models.i.tensorData[dataX;dataY];
  modelArgs:`batch_size`shuffle`num_workers!(count first data`xtrain;1b;0);
  dataLoader:models.i.dataLoader[tensorXY;pykwargs modelArgs];
  nEpochs:10|`int$(count[data`xtrain]%1000);
  models.torch.torchFit[model;optimizer;criterion;dataLoader;nEpochs]
  }


// @kind function
// @category models
// @fileoverview Compile a keras model for binary problems
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @return {<} the compiled torch models
models.torch.NN.model:{[data;seed]
  models.torch.torchModel[count first data`xtrain;200]
  }


// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for binary problem types
// @param data {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param model {<} model object being passed through the system (fitted)
// @return {bool} the predicted values for a given model
models.torch.NN.predict:{[data;model] 
  dataX:models.i.numpy[models.i.npArray[data`xtest]][`:float][];
  torchMax:last models.i.torch[`:max][model[dataX];1]`;
  (.p.wrap torchMax)[`:detach][][`:numpy][][`:squeeze][]`
  }


// load required python modules
models.i.torch      :.p.import[`torch           ]
models.i.npArray    :.p.import[`numpy           ]`:array;
models.i.Adam       :.p.import[`torch.optim     ]`:Adam
models.i.numpy      :.p.import[`torch           ]`:from_numpy
models.i.tensorData :.p.import[`torch.utils.data]`:TensorDataset
models.i.dataLoader :.p.import[`torch.utils.data]`:DataLoader
models.i.neuralNet  :.p.import[`torch.nn]

models.torch.torchFit:.p.get[`runmodel];
models.torch.torchModel:.p.get[`classifier];
