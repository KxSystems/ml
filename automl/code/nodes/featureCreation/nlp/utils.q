// code/nodes/featureCreation/nlp/utils.q - Utilities for nlp feature creation 
// Copyright (c) 2021 Kx Systems Inc
//
// Utility functions specific the the featureCreation node implementation

\d .automl

// @kind function
// @category featureCreationUtility
// @desc Retrieves the word2vec items for sentences based on the model
// @param model {<} Model to be applied
// @param sentence {symbol} Sentence to retrieve information from 
// @return {float[]} word2vec transformation for sentence
featureCreation.nlp.i.w2vItem:{[model;sentence]
  $[()~sentence;0;model[`:wv.__getitem__][sentence]`]
   }

// @kind function
// @category featureCreationUtility
// @desc Transform tokens into correct word2vec format
// @param tokens {symbol[]} Tokens within input text
// @param index1 {int} 1st index of tokens
// @param index2 {int} 2nd index of tokens
// @return {string[]} Tokens present in w2v 
featureCreation.nlp.i.w2vTokens:{[tokens;index1;index2]
  tokens[index1;index2]
  }

// @kind function
// @category featureCreationUtility
// @desc Count each expression within a single text
// @param text {string} Textual data
// @return {dictionary} Count of each expression found
featureCreation.nlp.i.regexCheck:{[text]
  count each .nlp.findRegex[text;featureCreation.nlp.i.regexList]
  }

// @kind function
// @category featureCreationUtility
// @desc Retrieves the word2vec items for sentences based on the model
// @param attrCheck {symbol[]} Attributes to check 
// @param attrAll {symbol[]} All possible attributes 
// @return {dictionary} Percentage of each attribute present in NLP
featureCreation.nlp.i.percentDict:{[attrCheck;attrAll]
  countAttr:count each attrCheck;
  attrDictAll:attrAll!count[attrAll]#0f;
  percentValue:`float$(countAttr)%sum countAttr;
  attrDictAll,percentValue
  }

// @kind function
// @category featureCreationUtility
// @desc Generates column names based on a fixed list and multiple options
// @param attr1 {symbol[]} 1st attribute of new column name
// @param attr2 {symbol[]} 2nd attribute of new column name
// @return {symbol[]} New column names
featureCreation.nlp.i.colNaming:{[attr1;attr2]
  `${string[x],\:"_",string y}[attr1]each attr2
  }

// @kind function
// @category featureCreationUtility
// @desc Rename columns with individual columns razed together
// @param colNames {symbol[]} Column name
// @param feat {table[]} Nlp features as a table 
// @return {symbol[]} Renamed columns, with individual columns razed together
featureCreation.nlp.i.nameRaze:{[colNames;feat]
  (,'/){xcol[x;y]}'[colNames;feat]
  }

// @kind function
// @category featureCreationUtility
// @desc Finds all names according to a regex search
// @param col {symbol[]} Column names
// @param attrCheck {symbol[]} Attributes to check 
// @return {symbol[]} All names according to a regex search
featureCreation.nlp.i.colCheck:{[col;attrCheck]
  col where col like attrCheck
  }

// @kind data
// @category featureCreationUtility
// @desc Expressions to search for within text
// @type list
featureCreation.nlp.i.regexList:`specialChars`money`phoneNumber`emailAddress,
  `url`zipCode`postalCode`day`month`year`time;
