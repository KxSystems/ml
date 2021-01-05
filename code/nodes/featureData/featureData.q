\d .automl

// Loading of the feature dataset, this can be from in process or several 
//   alternative data sources

// @kind function
// @category node
// @fileoverview Load feature dataset from a location defined by a user 
//   provided dictionary and in accordance with the function .ml.i.loaddset
// @param config {dict} Location and method by which to retrieve the data
// @return {tab} Feature data as a table
featureData.node.function:{[config]
  data:.ml.i.loaddset config;
  $[98h<>type data;
    '`$"Feature dataset must be a simple table for use with Automl";
    data
    ]
  }

// Input information
featureData.node.inputs:"!"

// Output information
featureData.node.outputs:"+"
