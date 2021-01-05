\d .automl

// @private
// @kind function
// @category featureDescriptionUtility
// @fileoverview Apply data from a table relating to a subset of columns to a
//    list of aggregating functions in order to retrieve relevant statistics to
//    describe the dataset
// @param  feature {tab} Feature data as a table
// @param  colList {sym[]} Column list on which the functions are to be applied
// @param  funcList {lambda[]} List of functions to apply to relevant data
// @return {mat[]} Descriptive statistics and information
featureDescription.i.metaData:{[feature;colList;funcList]
  $[0<count colList;funcList@\:/:flip colList#feature;()]
  }

// @private
// @kind function
// @category featureDescriptionUtility
// @fileoverview Generate a list of functions to be applied to the dataset for 
//   non-numeric data
// @param typ {lambda} A function returning as its argument the name to be 
//   associated with the rows being described
// @return {lambda[]} List of functions to be applied to relevant data
featureDescription.i.nonNumeric:{[typ]
  (count;{count distinct x};{};{};{};{};typ)
  }
