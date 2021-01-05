\d .automl

// Apply feature significance logic to data post feature extraction, returning
//   the original dataset and a list of significant features to be used both 
//   for selection of data from new runs and within the current run.

// @kind function
// @category node
// @fileoverview Apply feature significance logic to data post feature 
//   extraction
// @param config {dict} Information related to the current run of AutoML
// @param features {tab} Feature data as a table 
// @param target {num[]} Numerical vector containing target data
// @return {dict} List of significant features and the feature data post 
//   feature extraction
featureSignificance.node.function:{[config;features;target]
  sigFeats:featureSignificance.applySigFunc[config;features;target];
  config[`logFunc]utils.printDict[`totalFeat],string count sigFeats;
  sigFeats:featureSignificance.correlationCols sigFeats#features;
  `sigFeats`features!(sigFeats;features)
  }

// Input information
featureSignificance.node.inputs  :`config`features`target!"!+F"

// Output information
featureSignificance.node.outputs :`sigFeats`features!"S+"
