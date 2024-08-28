// code/nodes/trainTestSplit/funcs.q - Functions called in trainTestSplit node
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of
// .automl.trainTestSplit

\d .automl

// Configuration update

// @kind function
// @category trainTestSplit
// @desc Apply TTS function
// @param config {dictionary} Location and method by which to retrieve the data
// @param features {table} The feature data as a table 
// @param target {number[]} Numerical vector containing target data
// @param sigFeats {symbol[]} Significant features
// @return  {dictionary} Data separated into training and testing sets
trainTestSplit.applyTTS:{[config;features;target;sigFeats]
  data:flip features sigFeats;
  ttsFunc:utils.qpyFuncSearch config`trainTestSplit;
  ttsFunc[data;target;config`testingSize]
  }

// @kind function
// @category trainTestSplit
// @desc Check type of TTS object
// @param tts {dictionary} Feature and target data split into training/testing
//   sets
// @return {::|err} Null on success, error on unsuitable TTS output type
trainTestSplit.ttsReturnType:{[tts]
  err:"Train test split function must return a dictionary with", 
  " `xtrain`xtest`ytrain`ytest";
  $[99h<>type tts;'err;not`xtest`xtrain`ytest`ytrain~asc key tts;'err;]
  }
