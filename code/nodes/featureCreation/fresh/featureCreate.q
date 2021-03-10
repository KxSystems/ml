// code/nodes/featureCreation/fresh/featureCreation.q - FRESH feature creation
// Copyright (c) 2021 Kx Systems Inc
//
// Create features using the fresh algorithm

\d .automl

// @kind function
// @category featureCreate 
// @desc Create features using the FRESH algorithm
// @param features {table} Feature data as a table 
// @param config  {dictionary} Information related to the current run of AutoML
// @return {table} Features created in accordance with the FRESH feature 
//   creation procedure
featureCreation.fresh.create:{[features;config]
  aggCols:config`aggregationColumns;
  problemFunctions:config`functions;
  params:$[type[problemFunctions]in -11 11h;
    get;
    99h=type problemFunctions;
    ;
    '"Inappropriate type for FRESH parameter data"
    ]problemFunctions;
  // Feature extraction should be performed on all columns that are 
  // non-aggregate columns
  cols2use:cols[features]except aggCols;
  featExtractStart:.z.T;
  // Apply feature creation and encode nulls with the median value of column
  features:value .ml.fresh.createFeatures[features;aggCols;cols2use;params];
  features:dataPreprocessing.nullEncode[features;med];
  features:.ml.infReplace features;
  features:0^.ml.dropConstant features;
  featExtractEnd:.z.T-featExtractStart;
  `creationTime`features`featModel!(featExtractEnd;features;())
  }
