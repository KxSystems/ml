// code/nodes/dataPreprocessing/dataPreprocessing.q - Data preprocessing node
// Copyright (c) 2021 Kx Systems Inc
//
// Preprocess the dataset prior to application of ML algorithms. This includes
// the application of symbol encoding, handling of null data/infinities and 
// removal of constant columns

\d .automl

// @kind function
// @category node
// @desc Preprocess input data based on the type of problem being  solved and 
//   the parameters supplied by the user
// @param config {dictionary} Information related to the current run of AutoML
// @param features {table}  Feature data as a table 
// @param symEncode {dictionary} Columns to symbol encode and their required
//   encoding
// @return {table} Feature table with the data preprocessed appropriately
dataPreprocessing.node.function:{[config;features;symEncode]
  symTable:dataPreprocessing.symEncoding[features;config;symEncode];
  dataPreprocessing.featPreprocess[symTable;config]
  }

// Input information
dataPreprocessing.node.inputs:`config`features`symEncode!"!+S"

// Output information
dataPreprocessing.node.outputs:"+"
