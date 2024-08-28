\l automl/automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Load Python version of .ml.trainTestSplit
\l code/nodes/dataCheck/tests/pythonTTS.p

\S 10

// Features and targets
featData:([]100?1f;100?1f;asc 100?1f);
targData:100?0b;
sigFeats:`x`x2

// Utilities
matrixTTS:{[x;y;sz]
  value .ml.trainTestSplit[x;y;sz]
  }
wrongKeyTTS:{[x;y;sz]
  `a`b`c`d!til 4
  }

// Config
cfg13      :`trainTestSplit`testingSize!(`.ml.trainTestSplit;.13)
cfg20      :`trainTestSplit`testingSize!(`.ml.trainTestSplit;.2)
cfg40      :`trainTestSplit`testingSize!(`.ml.trainTestSplit;.4)
cfgNeg1    :`trainTestSplit`testingSize!(`.ml.trainTestSplit;-1)
cfgMatrix  :`trainTestSplit`testingSize!(`matrixTTS  ;.2)
cfgWrongKey:`trainTestSplit`testingSize!(`wrongKeyTTS;.2)
cfgPy      :`trainTestSplit`testingSize!(`python_train_test_split;.2)

// Expected output
keyTTSOut:`xtest`xtrain`ytest`ytrain
ttsOut13 :`xtrain`ytrain`xtest`ytest!87 87 13 13 
ttsOut20 :`xtrain`ytrain`xtest`ytest!80 80 20 20 
ttsOut40 :`xtrain`ytrain`xtest`ytest!60 60 40 40 

// Generate testing functions
getKey:{[cfg;featData;targData;sigFeats]
  asc key .automl.trainTestSplit.node.function[cfg;featData;targData;sigFeats]
  }

countFeat:{[cfg;featData;targData;sigFeats]
  count each .automl.trainTestSplit.node.function[cfg;featData;targData;sigFeats]
  }

-1"\nTesting appropriate input data for TrainTestSplit";

// Testing appropriate return for TrainTestSplit
passingTest[getKey   ;(cfg13;featData;targData;sigFeats);0b;keyTTSOut]
passingTest[countFeat;(cfg13;featData;targData;sigFeats);0b;ttsOut13 ]
passingTest[countFeat;(cfg20;featData;targData;sigFeats);0b;ttsOut20 ]
passingTest[countFeat;(cfg40;featData;targData;sigFeats);0b;ttsOut40 ]

// Python tests
passingTest[getKey   ;(cfgPy;featData;targData;sigFeats);0b;keyTTSOut]
passingTest[countFeat;(cfg20;featData;targData;sigFeats);0b;ttsOut20 ]

-1"\nTesting inappropriate input data for TrainTestSplit";

// Failing tests for TrainTestSplit
failingTest[.automl.trainTestSplit.node.function;(cfgMatrix;featData;targData;sigFeats);0b;"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest"]
failingTest[.automl.trainTestSplit.node.function;(cfgWrongKey;featData;targData;sigFeats);0b;"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest"]
