\d .automl

// Preprocess the dataset prior to application of ML algorithms. This includes
//   the application of symbol encoding, handling of null data/infinities and 
//   removal of constant columns

// @kind function
// @category node
// @fileoverview Preprocess input data based on the type of problem being 
//   solved and the parameters supplied by the user
// @param config {dict} Information related to the current run of AutoML
// @param features {tab}  Feature data as a table 
// @param symEncode {dict} Columns to symbol encode and their required encoding
// @return {tab} Feature table with the data preprocessed appropriately
dataPreprocessing.node.function:{[config;features;symEncode]
  symTable:dataPreprocessing.symEncoding[features;config;symEncode];
  dataPreprocessing.featPreprocess[symTable;config]
  }

// Input information
dataPreprocessing.node.inputs  :`config`features`symEncode!"!+S"

// Output information
dataPreprocessing.node.outputs :"+"
