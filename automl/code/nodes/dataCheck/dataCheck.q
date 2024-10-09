// code/nodes/dataCheck/dataCheck.q - The dataCheck node
// Copyright (c) 2021 Kx Systems Inc
//
// Update configuration to include default parameters. Check that various 
// aspects of the dataset and configuration are suitable for running with
// AutoML.

\d .automl

// @kind function
// @category node
// @desc Ensure that the data and configuration provided are suitable 
//   for the application of AutoML. In the case that there are issues, error as
//   appropriate or augment the data to be suitable for the use case in 
//   question.
// @param config {dictionary} Configuration information assigned by the user 
//   and related to the current run
// @param features {table} Feature data as a table 
// @param target {number[]|symbol[]} Numerical or symbol vector containing 
//   the target dataset
// @return {dictionary} Modified configuration, feature and target datasets. 
//   Error on issues with configuration, setup, target or feature dataset.
dataCheck.node.function:{[config;features;target]
  config:dataCheck.updateConfig[features;config];
  dataCheck.functions config;
  dataCheck.length[features;target;config];
  dataCheck.target target;
  dataCheck.ttsSize config;
  dataCheck.NLPLoad config;
  dataCheck.NLPSchema[config;features];
  features:dataCheck.featureTypes[features;config];
  `config`features`target!(config;features;target)
  }

// Input information
dataCheck.node.inputs:`config`features`target!"!+F"

// Output information
dataCheck.node.outputs:`config`features`target!"!+F"

