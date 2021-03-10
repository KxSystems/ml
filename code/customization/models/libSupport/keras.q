// code/customization/models/libSupport/keras.q - Customized keras models
// Copyright (c) 2021 Kx Systems Inc
//
// The purpose of this file is to include all the necessary utilities to 
// create a minimal interface for the support of keras models. It also 
// acts as a location to which users defined keras models are added

\d .automl

// @kind function
// @category models
// @desc Fit model on training data and score using test data
// @param data {dictionary} Containing training and testing data according to
//   keys `xtrn`ytrn`xtst`ytst
// @param seed {int} Seed used for initialising the same model
// @param mname {symbol} Name of the model being applied
// @return {int|float|boolean} The predicted values for a given model as 
//   applied to input data
models.keras.fitScore:{[data;seed;mname]
  if[mname~`multi;
    data[;1]:models.i.npArray@'flip@'value@'.ml.i.oneHot each data[;1]
    ];
  dataDict:`xtrain`ytrain`xtest`ytest!raze data;
  mdl:get[".automl.models.keras.",string[mname],".model"][dataDict;seed];
  mdl:get[".automl.models.keras.",string[mname],".fit"][dataDict;mdl];
  get[".automl.models.keras.",string[mname],".predict"][dataDict;mdl]
  }

// @kind function
// @category models
// @desc Fit a vanilla keras model to data
// @param data {dictionary} Containing training and testing data according to
//   keys `xtrn`ytrn`xtst`ytst
// @param model {<} Model object being passed through the system 
//   (compiled/fitted)
// @return {<} A vanilla fitted keras model
models.keras.binary.fit:models.keras.reg.fit:models.keras.multi.fit:{[data;model]
  model[`:fit][models.i.npArray data`xtrain;data`ytrain;`batch_size pykw 32;
    `verbose pykw 0];
  model
  }

// @kind function
// @category models
// @desc Compile a keras model for binary problems
// @param data {dictionary} Containing training and testing data according to 
//   keys `xtrn`ytrn`xtst`ytst
// @param seed {int} Seed used for initialising the same model
// @return {<} The compiled keras models
models.keras.binary.model:{[data;seed]
  models.i.numpySeed[seed];
  if[models.i.tensorflowBackend;models.i.tensorflowSeed[seed]];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw"relu";
    `input_dim pykw count first data`xtrain];
  mdl[`:add]models.i.kerasDense[1;`activation pykw "sigmoid"];
  mdl[`:compile][`loss pykw "binary_crossentropy";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @desc Predict test data values using a compiled model
//  for binary problem types
// @param data {dictionary} Containing training and testing data according to 
//   keys `xtrn`ytrn`xtst`ytst
// @param model {<} Model object being passed through the system (
//   compiled/fitted)
// @return {boolean} The predicted values for a given model
models.keras.binary.predict:{[data;model]
  .5<raze model[`:predict][models.i.npArray data`xtest]`
  }

// @kind function
// @category models
// @desc Compile a keras model for regression problems
// @param data {dictionary} Containing training and testing data according to
//   keys `xtrn`ytrn`xtst`ytst
// @param seed {int} Seed used for initialising the same model
// @return {<} The compiled keras models
models.keras.reg.model:{[data;seed]
  models.i.numpySeed[seed];
  if[models.i.tensorflowBackend;models.i.tensorflowSeed[seed]];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw "relu";
    `input_dim pykw count first data`xtrain];
  mdl[`:add]models.i.kerasDense[1 ;`activation pykw "relu"];
  mdl[`:compile][`loss pykw "mse";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @desc Predict test data values using a compiled model
//  for regression problem types
// @param data {dictionary} Containing training and testing data according to 
//   keys `xtrn`ytrn`xtst`ytst
// @param model {<} Model object being passed through the system 
//   (compiled/fitted)
// @return {int|float} The predicted values for a given model
models.keras.reg.predict:{[data;model]
  raze model[`:predict][models.i.npArray data`xtest]`
  }

// @kind function
// @category models
// @desc Compile a keras model for multiclass problems
// @param data {dictionary} Containing training and testing data according to 
//   keys `xtrn`ytrn`xtst`ytst
// @param seed {int} Seed used for initialising the same model
// @return {<} The compiled keras models
models.keras.multi.model:{[data;seed]
  models.i.numpySeed[seed];
  if[models.i.tensorflowBackend;models.i.tensorflowSeed[seed]];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw "relu";
    `input_dim pykw count first data`xtrain];
  mdl[`:add]models.i.kerasDense[count distinct data[`ytrain]`;
    `activation pykw "softmax"];
  mdl[`:compile][`loss pykw "categorical_crossentropy";
    `optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @desc Predict test data values using a compiled model
//   for multiclass problem types
// @param data {dictionary} Containing training and testing data according to
//   keys `xtrn`ytrn`xtst`ytst
// @param model {<} Model object being passed through the system (
//   compiled/fitted)
// @return {int|float|boolean} The predicted values for a given model
models.keras.multi.predict:{[data;model]
  model[`:predict_classes][models.i.npArray data`xtest]`
  }

// load required python modules
models.i.npArray:.p.import[`numpy        ]`:array;
models.i.kerasSeq:.p.import[`keras.models ]`:Sequential;
models.i.kerasDense:.p.import[`keras.layers ]`:Dense;
models.i.numpySeed:.p.import[`numpy.random ]`:seed;
models.i.backend:.p.import[`keras.backend]`:backend;

// Check if tensorflow is being used as the backend for keras
models.i.tensorflowBackend:"tensorflow"~models.i.backend[]`

// import appropriate random seed depending on tensorflow version
if[models.i.tensorflowBackend;
  models.i.tf:.p.import[`tensorflow];
  models.i.tfType:$[2>"I"$first models.i.tf[`:__version__]`;
    `:set_random_seed;
    `:random.set_seed
    ];
  models.i.tensorflowSeed:models.i.tf models.i.tfType
  ];

p)def tfWarnings(warn):
  import os
  os.environ['TF_CPP_MIN_LOG_LEVEL'] = warn

// allow multiprocess
.ml.loadfile`:util/mproc.q
if[0>system"s";
  .ml.mproc.init[abs system"s"]("system[\"l automl/automl.q\"]";
  ".automl.loadfile`:init.q")
  ];
