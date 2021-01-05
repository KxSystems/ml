\d .automl

// Update configuration to include default parameters. Check that various
//   aspects of the dataset and configuration are suitable for running with
//   AutoML

// @kind function
// @category node
// @fileoverview Retrieve any initial information that is needed for the 
//   generation of reports or running on new data
// @param config {dict} Information related to the current run of AutoML
// @param features {tab}  Feature data as a table 
// @return {dict} Symbol encoding, feature data and description
featureDescription.node.function:{[config;features]
  symEncode:featureDescription.symEncodeSchema[features;10;config];
  dataSummary:featureDescription.dataDescription features;
  config[`logFunc]each(utils.printDict`describe;dataSummary);
  `symEncode`dataDescription`features!(symEncode;dataSummary;features)
  }

// Input information
featureDescription.node.inputs  :`config`features!"!+"

// Output information
featureDescription.node.outputs :`symEncode`dataDescription`features!"S++"
