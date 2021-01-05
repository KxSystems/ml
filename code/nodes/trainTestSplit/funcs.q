\d .automl

// Definitions of the main callable functions used in the application of
//   .automl.trainTestSplit

// Configuration update

// @kind function
// @category trainTestSplit
// @fileoverview Apply TTS function
// @param config {dict} Location and method by which to retrieve the data
// @param features {tab} The feature data as a table 
// @param target {num[]} Numerical vector containing target data
// @param sigFeats {sym[]} Significant features
// @return  {dict} Data separated into training and testing sets
trainTestSplit.applyTTS:{[config;features;target;sigFeats]
  data:flip features sigFeats;
  ttsFunc:utils.qpyFuncSearch config`trainTestSplit;
  ttsFunc[data;target;config`testingSize]
  }

// @kind function
// @category trainTestSplit
// @fileoverview Check type of TTS object
// @param tts {dict} Feature and target data split into training/testing sets
// @return {(Null;err)} Null on success, error on unsuitable TTS output type
trainTestSplit.ttsReturnType:{[tts]
  err:"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest";
  $[99h<>type tts;'err;not`xtest`xtrain`ytest`ytrain~asc key tts;'err;]
  }
