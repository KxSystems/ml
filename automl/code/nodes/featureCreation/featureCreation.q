// code/nodes/featureCreation/featureCreation.q - Feature Creation node
// Copyright (c) 2021 Kx Systems Inc
//
// This function contains the logic required to generate appropriate default
// or custom features for each of the problem types supported by AutoML 

\d .automl

// @kind function
// @category node
// @desc Apply feature creation based on problem type. Individual 
//   functions relating to this functionality are use case dependent and 
//   contained within [fresh/normal/nlp]/featureCreate.q
// @param features {table} Feature data as a table 
// @param config {dictionary} Information related to the current run of AutoML
// @return {dictionary} Features with additional features created along with 
//   time taken and any saved models 
featureCreation.node.function:{[config;features]
  typ:config`featureExtractionType;
  $[typ=`fresh;
      featureCreation.fresh.create[features;config];
    typ=`normal;
      featureCreation.normal.create[features;config];
    typ=`nlp;
      featureCreation.nlp.create[features;config];
    '"Feature extraction type is not currently supported"
    ]
  }

// Input information
featureCreation.node.inputs:`config`features!"!+"

// Output information
featureCreation.node.outputs:`creationTime`features`featModel!"t+<"

