\d .automl

// @kind function
// @category featureCreate 
// @fileoverview Create features using the FRESH algorithm
// @param features {tab} Feature data as a table 
// @param config  {dict} Information related to the current run of AutoML
// @return {tab} Features created in accordance with the FRESH feature 
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
  //   non-aggregate columns
  cols2use:cols[features]except aggCols;
  featExtractStart:.z.T;
  // Apply feature creation and encode nulls with the median value of column
  features:value .ml.fresh.createfeatures[features;aggCols;cols2use;params];
  features:dataPreprocessing.nullEncode[features;med];
  features:dataPreprocessing.infreplace features;
  features:0^.ml.dropconstant features;
  featExtractEnd:.z.T-featExtractStart;
  `creationTime`features`featModel!(featExtractEnd;features;())
  }
