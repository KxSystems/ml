// code/nodes/targetData/targetData.q - Target data node
// Copyright (c) 2021 Kx Systems Inc
//
// Loading of the target dataset, data can be loaded from in process or 
// alternative data sources

\d .automl

// @kind function
// @category node
// @desc Load target dataset from a location defined by a user 
//   provided dictionary and in accordance with the function .ml.i.loaddset
// @param config {dictionary} Location and method by which to retrieve the data
// @return {number[]|symbol[]} Numerical or symbol target vector
targetData.node.function:{[config]
  dset:.ml.i.loadDataset config;
  $[.Q.ty[dset]in"befhijs";
    dset;
    '`$"Dataset not of a suitable type only 'befhijs' currently supported"
    ]
  }

// Input information
targetData.node.inputs:"!"

// Output information
targetData.node.outputs:"F"
