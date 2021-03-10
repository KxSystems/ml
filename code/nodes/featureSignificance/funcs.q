// code/nodes/featureSignificance/funcs.q - Feature significance functions 
// Copyright (c) 2021 Kx Systems Inc
//
// Definitions of the main callable functions used in the application of 
// .automl.featureSignificance

\d .automl

// @kind function
// @category featureSignificance
// @desc Extract feature significance tests and apply to feature data
// @param config {dictionary} Information related to the current run of AutoML
// @param features {table} Feature data as a table 
// @param target {number[]} Numerical vector containing target data
// @return {symbol[]} Significant features or error if function does not exist
featureSignificance.applySigFunc:{[config;features;target]
  sigFunc:utils.qpyFuncSearch config`significantFeatures;
  sigFunc[features;target]
  }

// @kind function
// @category featureSignificance
// @desc Apply feature significance function to data post feature
//   extraction
// @param config {dictionary} Information related to the current run of AutoML
// @param features {table} Feature data as a table 
// @param target {number[]} Numerical vector containing target data
// @return {symbol[]} Significant features
featureSignificance.significance:{[features;target]
  BHTest:.ml.fresh.benjhoch .05;
  percentile:.ml.fresh.percentile .25;
  sigFeats:.ml.fresh.significantFeatures[features;target;BHTest];
  if[0=count sigFeats;
    sigFeats:.ml.fresh.significantFeatures[features;target;percentile]
    ];
  sigFeats
  }

// @kind function
// @category featureSignificance
// @desc Find any correlated columns and remove them
// @param sigFeats {table} Significant data features
// @return {symbol[]} Significant columns
featureSignificance.correlationCols:{[sigFeats]
  thres:.95;
  sigCols:cols sigFeats;
  corrMat:abs .ml.corrMatrix sigFeats;
  boolMat:t>\:t:til count first sigFeats;
  sigCols:featureSignificance.threshVal[thres;sigCols]'[corrMat;boolMat];
  raze distinct 1#'asc each key[sigCols],'value sigCols
  }

// @kind function
// @category featureSignificance
// @desc Find any correlated columns within threshold
// @param thres {float} Threshold value to search within
// @param sigCols {symbol[]} Significant columns
// @param corr {float[]} Correlation values
// @param bool {float[]} Lower triangle booleans
// @return {symbol[]} Columns within threshold
featureSignificance.threshVal:{[thres;sigCols;corr;bool]
  $[any thres<value[corr]idx:where bool;sigCols idx;()]
  }
