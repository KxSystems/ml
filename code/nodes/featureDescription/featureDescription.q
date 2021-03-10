// code/nodes/featureDescription/featureDescription.q - Feature description
// Copyright (c) 2021 Kx Systems Inc
//
// Update configuration to include default parameters. Check that various
// aspects of the dataset and configuration are suitable for running with
// AutoML

\d .automl

// @kind function
// @category node
// @desc Retrieve any initial information that is needed for the 
//   generation of reports or running on new data
// @param config {dictionary} Information related to the current run of AutoML
// @param features {table}  Feature data as a table 
// @return {dictionary} Symbol encoding, feature data and description
featureDescription.node.function:{[config;features]
  symEncode:featureDescription.symEncodeSchema[features;10;config];
  dataSummary:featureDescription.dataDescription features;
  config[`logFunc]each(utils.printDict`describe;dataSummary);
  `symEncode`dataDescription`features!(symEncode;dataSummary;features)
  }

// Input information
featureDescription.node.inputs:`config`features!"!+"

// Output information
featureDescription.node.outputs:`symEncode`dataDescription`features!"S++"
