// fresh/select.q - Feature selection
// Copyright (c) 2021 Kx Systems Inc
//
// Selection of statistically significant features

\d .ml

// @kind function
// @category fresh
// @fileoverview Statistically significant features based on defined selection
//   procedure
// @param tab {table} Value side of a table of created features
// @param target {int[]|float[]} Targets corresponding to the rows the table
// @param func {fn} Projection of significant feature function to apply e.g. 
//   .ml.fresh.kSigFeat[10]
// @returns {symbol[]} Features deemed statistically significant according to 
//   user-defined func
fresh.significantFeatures:{[tab;target;func]
  func fresh.sigFeat[tab;target]
  }

  // @kind function
// @category fresh
// @fileoverview Return p-values for each feature
// @param tab {table} Value side of a table of created features
// @param target {int[]|float[]} Targets corresponding to the rows the table
// @return {dictionary} P-value for each feature to be passed to user-defined 
//   significance function
fresh.sigFeat:{[tab;target]
  func:fresh.i$[2<count distinct target;`kTau`ksYX;`ks`fisher];
  sigCols:where each(2<;2=)@\:(count distinct@)each flip tab;
  raze[sigCols]!(func[where count each sigCols]@\:target)@'tab raze sigCols
  }

// @kind function
// @category fresh
// @fileoverview The Benjamini-Hochberg-Yekutieli (BHY) procedure: determines 
//   if the feature meets a defined False Discovery Rate (FDR) level. The 
//   recommended input is 5% (0.05).
// @param rate {float} False Discovery Rate
// @param pValues {dictionary} Output of .ml.fresh.sigFeat
// @return {symbol[]} Significant features
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
// @param pValues {dictionary} Output of .ml.fresh.sigFeat
// @return {symbol[]} Significant features
fresh.kSigFeat:{[k;pValues]
  key k sublist asc pValues
  }

// @kind function
// @category fresh
// @fileoverview Percentile based selection: set a percentile threshold for 
//   p-values below which features are selected.
// @param percentile {float} Percentile threshold
// @param pValues {dictionary} Output of .ml.fresh.sigFeat
// @return {symbol[]} Significant features
fresh.percentile:{[percentile;pValues]
  where pValues<=fresh.feat.quantile[value pValues]percentile
  }
