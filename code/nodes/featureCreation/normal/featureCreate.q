\d .automl

// Create features for 'normal problems' 

// @kind function
// @category featureCreation
// @fileoverview Create features for 'normal problems' -> one target for each
//   row, with no time dependency or fresh like structure
// @param features {tab} Feature data as a table
// @param config {dict} Information related to the current run of AutoML
// @return {tab} Features created in accordance with the normal feature 
//   creation procedure
featureCreation.normal.create:{[features;config]
  featureExtractStart:.z.T;
  // Time columns are extracted such that constituent parts can be used but are
  //   not transformed according to remaining procedures
  timeCols:.ml.i.fndcols[features;"dmntvupz"];
  featTable:(cols[features]except timeCols)#features;
  // Apply user defined functions to the table
  featTable:featureCreation.normal.applyFunc/[featTable;config`functions];
  featTable:dataPreprocessing.infreplace featTable;
  featTable:dataPreprocessing.nullEncode[featTable;med];
  featTable:.ml.dropconstant featTable;
  // Apply the transform of time specific columns as appropriate
  if[0<count timeCols;featTable^:.ml.timesplit[timeCols#features;::]];
  featureExtractEnd:.z.T-featureExtractStart;
  `creationTime`features`featModel!(featureExtractEnd;featTable;())
  }
