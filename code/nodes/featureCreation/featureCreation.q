\d .automl

// This function contains the logic required to generate appropriate default
// or custom features for each of the problem types supported by AutoML 

// @kind function
// @category node
// @fileoverview Apply feature creation based on problem type. Individual 
//   functions relating to this functionality are use case dependent and 
//   contained within [fresh/normal/nlp]/featureCreate.q
// @param features {tab} Feature data as a table 
// @param config {dict} Information related to the current run of AutoML
// @return {dict} Features with additional features created along with time
//   taken and any saved models 
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
featureCreation.node.inputs  :`config`features!"!+"

// Output information
featureCreation.node.outputs :`creationTime`features`featModel!"t+<"

