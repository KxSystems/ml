\d .automl

// Loading of the target dataset, data can be loaded from in process or 
//   alternative data sources

// @kind function
// @category node
// @fileoverview Load target dataset from a location defined by a user 
//   provided dictionary and in accordance with the function .ml.i.loaddset
// @param config {dict} Location and method by which to retrieve the data
// @return {(num[];sym[])} Numerical or symbol target vector
targetData.node.function:{[config]
  dset:.ml.i.loaddset config;
  $[.Q.ty[dset]in"befhijs";
    dset;
    '`$"Dataset not of a suitable type only 'befhijs' currently supported"
    ]
  }

// Input information
targetData.node.inputs:"!"

// Output information
targetData.node.outputs:"F"
