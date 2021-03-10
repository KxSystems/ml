// code/nodes/featureCreation/normal/featureCreation.q - Normal feature create
// Copyright (c) 2021 Kx Systems Inc
//
// Create features for 'normal problems' 

\d .automl

// @kind function
// @category featureCreation
// @desc Create features for 'normal problems' -> one target for each
//   row, with no time dependency or fresh like structure
// @param features {table} Feature data as a table
// @param config {dictionary} Information related to the current run of AutoML
// @return {table} Features created in accordance with the normal feature 
//   creation procedure
featureCreation.normal.create:{[features;config]
  featureExtractStart:.z.T;
  // Time columns are extracted such that constituent parts can be used but are
  // not transformed according to remaining procedures
  timeCols:.ml.i.findCols[features;"dmntvupz"];
  featTable:(cols[features]except timeCols)#features;
  // Apply user defined functions to the table
  featTable:featureCreation.normal.applyFunc/[featTable;config`functions];
  featTable:.ml.infReplace featTable;
  featTable:dataPreprocessing.nullEncode[featTable;med];
  featTable:.ml.dropConstant featTable;
  // Apply the transform of time specific columns as appropriate
  if[0<count timeCols;featTable^:.ml.timeSplit[timeCols#features;::]];
  featureExtractEnd:.z.T-featureExtractStart;
  `creationTime`features`featModel!(featureExtractEnd;featTable;())
  }
