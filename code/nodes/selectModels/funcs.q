\d .automl

// Definitions of the main callable functions used in the application of 
//   .automl.selectModels

// @kind function
// @category selectModels
// @fileoverview Remove Keras models if criteria met
// @param modelTab {tab} Models which are to be applied to the dataset
// @param tts {dict} Feature and target data split into train and testing sets
// @param target {(num[];sym[])} Numerical or symbol target vector
// @param config {dict} Information related to the current run of AutoML
// @return {tab} Keras model removed if needed and removal highlighted
selectModels.targetKeras:{[modelTab;tts;target;config]
  if[not check.keras[];:?[modelTab;enlist(<>;`lib;enlist`keras);0b;()]];
  multiCheck:`multi in modelTab`typ;
  tgtCount:min count@'distinct each tts`ytrain`ytest;
  tgtCheck:tgtCount<count distinct target;
  if[multiCheck&tgtCheck;
    config[`logFunc]utils.printDict`kerasClass;
    :delete from modelTab where lib=`keras,typ=`multi
    ];
  modelTab
  }

// @kind function
// @category selectModels
// @fileoverview Update models available for use based on the number of data
//   points in the target vector
// @param modelTab {tab} Models which are to be applied to the dataset
// @param target {(num[];sym[])} Numerical or symbol target vector
// @param config {dict} Information related to the current run of AutoML
// @return {tab} Appropriate models removed and highlighted to the user
selectModels.targetLimit:{[modelTab;target;config]
  if[config[`targetLimit]<count target;
    if[utils.ignoreWarnings=2;
      tlim:string config`targetLimit;
      config[`logFunc](utils.printWarnings[`neuralNetWarning]0),tlim;
      :select from modelTab where lib<>`keras,not fnc in`neural_network`svm
      ];
    if[utils.ignoreWarnings=1;
      tlim:string config`targetLimit;
      config[`logFunc](utils.printWarnings[`neuralNetWarning]1),tlim
      ]
    ];
   modelTab
   }

// @kind function
// @category selectModels
// @fileoverview Remove theano/torch models if these are unavailable
// @param config {dict} Information related to the current run of AutoML
// @param modelTab {tab} Models which are to be applied to the dataset
// @param lib {sym} Which library you are checking for e.g.`theano`torch
// @return {tab} Model removed if needed and removal highlighted
selectModels.removeUnavailable:{[config;modelTab;lib]
  if[0<>checkimport$[lib~`torch;1;5];
    config[`logFunc]utils.printDict`$string[lib],"Models";
    :?[modelTab;enlist(<>;`lib;enlist lib);0b;()]
    ];
  modelTab
  }
