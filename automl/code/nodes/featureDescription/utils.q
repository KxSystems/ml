// code/nodes/featureDescription/utils.q - Utilities featureDescription node
// Copyright (c) 2021 Kx Systems Inc
//
// Utility functions specific the the featureDescription node implementation

\d .automl

// @private
// @kind function
// @category featureDescriptionUtility
// @desc Apply data from a table relating to a subset of columns to a
//   list of aggregating functions in order to retrieve relevant statistics to
//   describe the dataset
// @param feature {table} Feature data as a table
// @param colList {symbol[]} Column list on which the functions are to be 
//   applied
// @param  funcList {fn[]} List of functions to apply to relevant data
// @return {number[][]} Descriptive statistics and information
featureDescription.i.metaData:{[feature;colList;funcList]
  $[0<count colList;funcList@\:/:flip colList#feature;()]
  }

// @private
// @kind function
// @category featureDescriptionUtility
// @desc Generate a list of functions to be applied to the dataset for 
//   non-numeric data
// @param typ {fn} A function returning as its argument the name to be 
//   associated with the rows being described
// @return {fn[]} List of functions to be applied to relevant data
featureDescription.i.nonNumeric:{[typ]
  (count;{count distinct x};{};{};{};{};typ)
  }
