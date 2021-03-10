// code/nodes/trainTestSplit/trainTestSplit.q - Train test split node
// Copyright (c) 2021 Kx Systems Inc
//
// Apply the user defined train test split functionality onto the users feature
// and target datasets returning the train-test split data as a list of 
// (xtrain;ytrain;xtest;ytest)

\d .automl

// @kind function
// @category node
// @desc Split data into training and testing sets
// @param config {dictionary} Location and method by which to retrieve the data
// @param features {table} The feature data as a table 
// @param target {number[]} Numerical vector containing target data
// @param sigFeats {symbol[]} Significant features
// @return {dictionary} Data separated into training and testing sets
trainTestSplit.node.function:{[config;features;target;sigFeats]
  tts:trainTestSplit.applyTTS[config;features;target;sigFeats];
  trainTestSplit.ttsReturnType tts;
  tts
  }

// Input information
trainTestSplit.node.inputs:`config`features`target`sigFeats!"!+FS"

// Output information
trainTestSplit.node.outputs:"!"
