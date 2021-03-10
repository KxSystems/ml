// code/nodes/featureData/featureData.q - Feature data node
// Copyright (c) 2021 Kx Systems Inc
//
// Loading of the feature dataset, this can be from in process or several 
// alternative data sources

\d .automl

// @kind function
// @category node
// @desc Load feature dataset from a location defined by a user 
//   provided dictionary and in accordance with the function .ml.i.loaddset
// @param config {dictionary} Location and method by which to retrieve the data
// @return {table} Feature data as a table
featureData.node.function:{[config]
  data:.ml.i.loadDataset config;
  $[98h<>type data;
    '`$"Feature dataset must be a simple table for use with Automl";
    data
    ]
  }

// Input information
featureData.node.inputs:"!"

// Output information
featureData.node.outputs:"+"
