\d .automl

// @kind function
// @category node
// @fileoverview Collect all the parameters relevant for the generation of 
//   reports/graphs etc in the preprocessing phase such they can be 
//   consolidated into a single node later in the workflow
// @param config {dict} Location and method by which to retrieve the data
// @param descrip {table} Symbol encoding, feature data and description
// @param cTime {time} Time taken for feature creation
// @param sigFeats {sym[]} Significant features
// @param symEncode {dict} Columns to symbol encode and their required encoding
// @param symMap {dict} Mapping of symbol encoded target data
// @param featModel {embedPy} NLP feature creation model used (if required)
// @param tts {dict} Feature and target data split into training/testing sets
// @return {dict} Consolidated parameters to be used to generate reports/graphs
preprocParams.node.function:{[config;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts]
  params:`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject;
  params!(config;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts)
  }

// Input information
inputKeys :`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject
inputTypes:"!+tSS!<!"
preprocParams.node.inputs  :inputKeys!inputTypes

// Output information
preprocParams.node.outputs :"!"