// code/nodes/featureCreation/nlp/featureCreation.q - Feature creation
// Copyright (c) 2021 Kx Systems Inc
//
// Apply NLP specific feature extraction on string characters and normal
// preprocessing methods to remaining data

\d .automl

// @kind function
// @category featureCreate
// @desc Apply word2vec on string data for NLP problems
// @param features {table} Feature data as a table 
// @param config {dictionary} Information related to the current run of AutoML
// @return {table} Features created in accordance with the NLP feature creation 
//   procedure
featureCreation.nlp.create:{[features;config]
  featExtractStart:.z.T;
  // Preprocess the character data
  charPrep:featureCreation.nlp.proc[features;config];
  // Table returned with NLP feature creation, any constant columns are dropped
  featNLP:charPrep`features;
  featNLP:.ml.dropConstant featNLP;
  // Run normal feature creation on numeric datasets and add to NLP features 
  // if relevant
  cols2use:cols[features]except charPrep`stringCols;
  if[0<count cols2use;
    nonTextFeat:charPrep[`stringCols]_features;
    featNLP:featNLP,'featureCreation.normal.create[nonTextFeat;config]`features
    ];
  featureExtractEnd:.z.T-featExtractStart;
  `creationTime`features`featModel!(featureExtractEnd;featNLP;charPrep`model)
  }
