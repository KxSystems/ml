// code/nodes/preprocParams/preprocParams.q - Preproc params node
// Copyright (c) 2021 Kx Systems Inc
//
// Collect all the parameters relevant for the preprocessing phase
\d .automl

// @kind function
// @category node
// @desc Collect all the parameters relevant for the generation of 
//   reports/graphs etc in the preprocessing phase such they can be 
//   consolidated into a single node later in the workflow
// @param config {dictionary} Location and method by which to retrieve the data
// @param descrip {table} Symbol encoding, feature data and description
// @param cTime {time} Time taken for feature creation
// @param sigFeats {symbol[]} Significant features
// @param symEncode {dictionary} Columns to symbol encode and their required 
//   encoding
// @param symMap {dictionary} Mapping of symbol encoded target data
// @param featModel {<} NLP feature creation model used (if required)
// @param tts {dictionary} Feature and target data split into training/testing 
//   sets
// @return {dictionary} Consolidated parameters to be used to generate
//   reports/graphs
preprocParams.node.function:{[config;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts]
  params:`config`dataDescription`creationTime`sigFeats`symEncode`symMap,
    `featModel`ttsObject;
  params!(config;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts)
  }

// Input information
preprocParams.i.k :`config`dataDescription`creationTime`sigFeats`symEncode,
  `symMap`featModel`ttsObject;
preprocParams.i.t:"!+tSS!<!";
preprocParams.node.inputs:preprocParams.i.k!preprocParams.i.t;

// Output information
preprocParams.node.outputs:"!"
