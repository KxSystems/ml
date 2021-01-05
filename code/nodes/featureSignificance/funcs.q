\d .automl

// Definitions of the main callable functions used in the application of 
//   .automl.featureSignificance

// @kind function
// @category featureSignificance
// @fileoverview Extract feature significant tests and apply to feature data
// @param config {dict} Information related to the current run of AutoML
// @param features {tab} Feature data as a table 
// @param target {num[]} Numerical vector containing target data
// @return {sym[]} Significant features or error if function does not exist
featureSignificance.applySigFunc:{[config;features;target]
  sigFunc:utils.qpyFuncSearch config`significantFeatures;
  sigFunc[features;target]
  }

// @kind function
// @category featureSignificance
// @fileoverview Apply feature significance function to data post feature
//   extraction
// @param config {dict} Information related to the current run of AutoML
// @param features {tab} Feature data as a table 
// @param target {num[]} Numerical vector containing target data
// @return {sym[]} Significant features
featureSignificance.significance:{[features;target]
  BHTest:.ml.fresh.benjhoch .05;
  percentile:.ml.fresh.percentile .25;
  sigFeats:.ml.fresh.significantfeatures[features;target;BHTest];
  if[0=count sigFeats;
    sigFeats:.ml.fresh.significantfeatures[features;target;percentile]
	];
  sigFeats
  }

// @kind function
// @category featureSignificance
// @fileoverview Find any correlated columns and remove them
// @param sigFeats {tab} Significant data features
// @return {sym[]} Significant columns
featureSignificance.correlationCols:{[sigFeats]
  thres:.95;
  sigCols:cols sigFeats;
  corrMat:abs .ml.corrmat sigFeats;
  boolMat:t>\:t:til count first sigFeats;
  sigCols:featureSignificance.threshVal[thres;sigCols]'[corrMat;boolMat];
  raze distinct 1#'asc each key[sigCols],'value sigCols
  }

// @kind function
// @category featureSignificance
// @fileoverview Find any correlated columns within threshold
// @param thres {float} Threshold value to search within
// @param sigCols {sym[]} Significant columns
// @param corr {float[]} Correlation values
// @param bool {float[]} Lower triangle booleans
// @return {sym[]} Columns within threshold
featureSignificance.threshVal:{[thres;sigCols;corr;bool]
  $[any thres<value[corr]idx:where bool;sigCols idx;()]
  }
