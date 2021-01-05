\d .automl

// Apply the user defined train test split functionality onto the users feature
//   and target datasets returning the train-test split data as a list of 
//   (xtrain;ytrain;xtest;ytest)

// @kind function
// @category node
// @fileoverview Split data into training and testing sets
// @param config {dict} Location and method by which to retrieve the data
// @param features {tab} The feature data as a table 
// @param target {num[]} Numerical vector containing target data
// @param sigFeats {sym[]} Significant features
// @return {dict} Data separated into training and testing sets
trainTestSplit.node.function:{[config;features;target;sigFeats]
  tts:trainTestSplit.applyTTS[config;features;target;sigFeats];
  trainTestSplit.ttsReturnType tts;
  tts
  }

// Input information
trainTestSplit.node.inputs  :`config`features`target`sigFeats!"!+FS"

// Output information
trainTestSplit.node.outputs :"!"
