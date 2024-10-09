// code/nodes/featureSignificance/featureSignificance.q - Feature Significance
// Copyright (c) 2021 Kx Systems Inc
//
// Apply feature significance logic to data post feature extraction, returning
// the original dataset and a list of significant features to be used both 
// for selection of data from new runs and within the current run.

\d .automl

// @kind function
// @category node
// @desc Apply feature significance logic to data post feature 
//   extraction
// @param config {dictionary} Information related to the current run of AutoML
// @param features {table} Feature data as a table 
// @param target {number[]} Numerical vector containing target data
// @return {dictionary} List of significant features and the feature data post 
//   feature extraction
featureSignificance.node.function:{[config;features;target]
  sigFeats:featureSignificance.applySigFunc[config;features;target];
  config[`logFunc]utils.printDict[`totalFeat],string count sigFeats;
  sigFeats:featureSignificance.correlationCols sigFeats#features;
  `sigFeats`features!(sigFeats;features)
  }

// Input information
featureSignificance.node.inputs:`config`features`target!"!+F"

// Output information
featureSignificance.node.outputs:`sigFeats`features!"S+"
