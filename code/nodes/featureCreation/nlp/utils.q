\d .automl

// The functionality below pertains to the utility functions used within the NLP implementation

// @kind function
// @category featureCreationUtility
// @fileoverview Retrieves the word2vec items for sentences based on the model
// @param model    {<} model to be applied
// @param sentence {sym} sentence to retrieve information from 
// @return {float[]} word2vec transformation for sentence
featureCreation.nlp.i.w2vItem:{[model;sentence]
  $[()~sentence;0;model[`:wv.__getitem__][sentence]`]
   }

// @kind function
// @category featureCreationUtility
// @fileoverview Transform tokens into correct word2vec format
// @param tokens {sym[]} tokens within input text
// @param index1 {int} 1st index of tokens
// @param index2 {int} 2nd index of tokens
// @return {str[]} tokens present in w2v 
featureCreation.nlp.i.w2vTokens:{[tokens;index1;index2]
  tokens[index1;index2]
  }

// @kind function
// @category featureCreationUtility
// @fileoverview Count each expression within a single text
// @param text {str} textual data
// @return {dict} count of each expression found
featureCreation.nlp.i.regexCheck:{[text]
  count each .nlp.findRegex[text;featureCreation.nlp.i.regexList]
  }

// @kind function
// @category featureCreationUtility
// @fileoverview Retrieves the word2vec items for sentences based on the model
// @param  attrCheck {sym[]} attributes to check 
// @param  attrAll   {sym[]} all possible attributes 
// @return {dict} percentage of each attribute present in NLP
featureCreation.nlp.i.percentDict:{[attrCheck;attrAll]
  countAttr:count each attrCheck;
  attrDictAll:attrAll!count[attrAll]#0f;
  percentValue:`float$(countAttr)%sum countAttr;
  attrDictAll,percentValue
  }

// @kind function
// @category featureCreationUtility
// @fileoverview Generates column names based on a fixed list and multiple options
// @param  attr1 {sym[]} 1st attribute of new column name
// @param  attr2 {sym[]} 2nd attribute of new column name
// @return {sym[]} new column names
featureCreation.nlp.i.colNaming:{[attr1;attr2]
  `${string[x],\:"_",string y}[attr1]each attr2
  }

// @kind function
// @category featureCreationUtility
// @fileoverview Rename columns with individual columns razed together
// @param  colNames {sym[]} column name
// @param  feat     {tab[]} nlp features as a table 
// @return {sym[]} renamed columns, with individual columns razed together
featureCreation.nlp.i.nameRaze:{[colNames;feat]
  (,'/){xcol[x;y]}'[colNames;feat]
  }

// @kind function
// @category featureCreationUtility
// @fileoverview Finds all names according to a regex search
// @param  col       {sym[]} column names
// @param  attrCheck {sym[]} attributes to check 
// @return {sym[]} all names according to a regex search
featureCreation.nlp.i.colCheck:{[col;attrCheck]
  col where col like attrCheck
  }

// @kind list
// @category featureCreationUtility
// @fileoverview Expressions to search for within text
featureCreation.nlp.i.regexList:`specialChars`money`phoneNumber`emailAddress`url`zipCode`postalCode`day`month`year`time
