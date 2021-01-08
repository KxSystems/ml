\d .ml

// FRESH feature significance

// @kind function
// @category fresh
// @fileoverview Statistically significant features based on defined selection
//   procedure
// @param table {table} Value side of a table of created features
// @param target {(int;float)[]} Targets corresponding to the rows the table
// @param func {func} Projection of significant feature function to apply e.g. 
//   .ml.fresh.ksigfeat[10]
// @returns {sym[]} Features deemed statistically significant according to 
//   user-defined func
fresh.significantfeatures:{[table;target;func]
  func fresh.sigfeat[table;target]
  }

  // @kind function
// @category fresh
// @fileoverview Return p-values for each feature
// @param table {table} Value side of a table of created features
// @param target {(int;float)[]} Targets corresponding to the rows the table
// @return {dict} P-value for each feature to be passed to user-defined 
//   significance function
fresh.sigfeat:{[table;target]
  func:fresh.i$[2<count distinct target;`ktau`ksyx;`ks`fisher];
  sigCols:where each(2<;2=)@\:(count distinct@)each flip table;
  raze[sigCols]!(f[where count each sigCols]@\:target)@'table raze sigCols
  }

// @kind function
// @category fresh
// @fileoverview The Benjamini-Hochberg-Yekutieli (BHY) procedure: determines 
//   if the feature meets a defined False Discovery Rate (FDR) level. The 
//   recommended input is 5% (0.05).
// @param rate {float} False Discovery Rate
// @param pValues {dict} Output of .ml.fresh.sigfeat
// @return {sym[]} Significant features
fresh.benjhoch:{[rate;pValues]
  idx:1+til n:count pValues:asc pValues;
  where pValues<=rate*idx%n*sums 1%idx
  }

// @kind function
// @category fresh
// @fileoverview K-best features: choose the K features which have the lowest
//   p-values and thus have been determined to be the most important features 
//   to allow us to predict the target vector.
// @param k {long} Number of features to select
// @param pValues {dict} Output of .ml.fresh.sigfeat
// @return {sym[]} Significant features
fresh.ksigfeat:{[k;pValues]
  key k sublist asc pValues
  }

// @kind function
// @category fresh
// @fileoverview Percentile based selection: set a percentile threshold for 
//   p-values below which features are selected.
// @param percentile {float} Percentile threshold
// @param pValues {dict} Output of .ml.fresh.sigfeat
// @return {sym[]} Significant features
fresh.percentile:{[percentile;pValues]
  where pValues<=fresh.feat.quantile[value pValues]percentile
  }
