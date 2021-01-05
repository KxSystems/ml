\d .automl

// The functionality below pertains to the application of NLP methods to
//    kdb+ data

// @kind function
// @category featureCreation
// @fileoverview Utility function used both in the application of NLP on the
//   initial run and on new data. It covers sentiment analysis, named entity 
//   recognition, word2vec and stop word analysis.
// @param features {tab} Feature data as a table 
// @param config {dict} Information related to the current run of AutoML
// @return {dict} Updated table with NLP created features included, along with
//   the string columns and word2vec model
featureCreation.nlp.proc:{[features;config]
  stringCols:.ml.i.fndcols[features;"C"];
  spacyLoad:.p.import[`spacy;`:load]"en_core_web_sm";
  args:(spacyLoad;features stringCols);
  sentences:$[1<count stringCols;
    {x@''flip y};
    {x each y 0}
    ]. args;
  regexTab      :featureCreation.nlp.regexTab[features;stringCols;featureCreation.nlp.i.regexList];
  namedEntityTab:featureCreation.nlp.getNamedEntity[sentences;stringCols];
  sentimentTab  :featureCreation.nlp.sentimentCreate[features;stringCols;`compound`pos`neg`neu];
  corpus        :featureCreation.nlp.corpus[features;stringCols;`isStop`tokens`uniPOS`likeNumber];
  colsCheck     :featureCreation.nlp.i.colCheck[cols corpus;];
  uniposTab     :featureCreation.nlp.uniposTagging[corpus;stringCols]colsCheck"uniPOS*";
  stopTab       :featureCreation.nlp.boolTab[corpus]colsCheck"isStop*";
  numTab        :featureCreation.nlp.boolTab[corpus]colsCheck"likeNumber*";
  countTokens   :flip enlist[`countTokens]!enlist count each corpus`tokens;
  tokens        :string(,'/)corpus colsCheck"tokens*";
  w2vTab        :featureCreation.nlp.word2vec[tokens;config];
  nlpTabList    :(uniposTab;sentimentTab;w2vTab 0;namedEntityTab;regexTab;stopTab;numTab;countTokens);
  nlpTab        :(,'/)nlpTabList;
  nlpKeys       :`features`stringCols`model;
  nlpValues     :(nlpTab;stringCols;w2vTab 1);
  nlpKeys!nlpValues
  }

// @kind function
// @category featureCreation
// @fileoverview Calculate percentage of positive booleans in a column
// @param features {tab} Feature data as a table 
// @param col {str} Column containing list of booleans 
// @return {tab} Updated features indicating percentage of true values
//   within a column
featureCreation.nlp.boolTab:{[features;col]
  flip col!{sum[x]%count x}@''features col
  }

// @kind function
// @category featureCreation
// @fileoverview Utility function used both in the application of NLP on the
//   initial run and on new data
// @param features {tab} Feature data as a table 
// @param stringCols {str} String columns within the table
// @param fields {str[]} Items to retrieve from newParser - also used in the 
//   naming of columns 
// @return {tab} Parsed character data in appropriate corpus for word2vec/stop
//    word/unipos analysis
featureCreation.nlp.corpus:{[features;stringCols;fields]
  parseCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  newParser:.nlp.newParser[`en;fields];
  // apply new parser to table data
  $[1<count stringCols;
    featureCreation.nlp.i.nameRaze[parseCols]newParser@'features stringCols;
    newParser@features[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Calculate percentage of each uniPOS tagging element present
// @param features {tab} Feature data as a table 
// @param stringCols {str} String columns within the table
// @param fields {str[]} uniPOS elements created from parser 
// @return {tab} Part of speech components as a percentage of the total parts
//   of speech 
featureCreation.nlp.uniposTagging:{[features;stringCols;fields]
  // retrieve all relevant part of speech types
  pyDir:.p.import[`builtins;`:dir];
  uniposTypes:pyDir[.p.import[`spacy]`:parts_of_speech]`;
  uniposTypes:`$uniposTypes where not 0 in/:uniposTypes ss\:"__";
  table:features fields;
  // Encode the percentage of each sentence which is of a specific POS
  percentageFunc:featureCreation.nlp.i.percentDict[;uniposTypes];
  $[1<count stringCols;
    [colNames:featureCreation.nlp.i.colNaming[uniposTypes;fields];
     percentageTable:percentageFunc@''group@''table;
     featureCreation.nlp.i.nameRaze[colNames;percentageTable]
     ];
    percentageFunc each group each table 0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Apply named entity recognition to retrieve information about
//   the content of a sentence/paragraph, allowing for context to be provided
//   for a sentence
// @param sentences {str} Sentences on which named entity recognition is to be
//   applied
// @param stringCols {str} String columns within the table 
// @return {tab} Percentage of each sentence belonging to particular named 
//  entity
featureCreation.nlp.getNamedEntity:{[sentences;stringCols]
  // Named entities being searched over
  namedEntity:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW,
    `LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  percentageFunc:featureCreation.nlp.i.percentDict[;namedEntity];
  data:$[countCols:1<count stringCols;flip;::]sentences;
  labelFunc:{`${(.p.wrap x)[`:label_]`}each x[`:ents]`};
  nerData:$[countCols;
    {x@''count@'''group@''z@''y}[;;labelFunc];
    {x@'count@''group@'z@'y}[;;labelFunc]
    ].(percentageFunc;data);
  $[countCols;
    [colNames:featureCreation.nlp.i.colNaming[namedEntity;stringCols];
     featureCreation.nlp.i.nameRaze colNames
     ];
    ]nerData
  }

// @kind function
// @category featureCreation
// @fileoverview Apply sentiment analysis to an input table
// @param features {tab} Feature data as a table 
// @param stringCols {str} String columns within the table
// @param fields {str[]} Sentiments to extract 
// @return {tab} Information about the pos/neg/compound sentiment of columns
featureCreation.nlp.sentimentCreate:{[features;stringCols;fields]
  sentimentCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  $[1<count stringCols;
    featureCreation.nlp.i.nameRaze[sentimentCols].nlp.sentiment@''features stringCols;
    .nlp.sentiment each features[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Find Regualar expressions within the text
// @param features {tab} Feature data as a table 
// @param stringCols {str} String columns within the table
// @param fields {str[]} Expressions to search for within the text
// @return {tab} Count of each expression found 
featureCreation.nlp.regexTab:{[features;stringCols;fields]
  regexCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  // get regex values
  $[1<count stringCols;
    [regexCount:featureCreation.nlp.i.regexCheck@''features stringCols;
     featureCreation.nlp.i.nameRaze[regexCols;regexCount]
     ];
    featureCreation.nlp.i.regexCheck each features[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Create/load a word2vec model for the corpus and apply this
//   analysis to the sentences to encode the sentence information into a 
//   numerical representation which can provide context to the meaning of a
//   sentence.
// @param tokens {tab} Feature data as a table 
// @param config {dict} Information related to the current run of AutoML
// @return {tab} word2vec applied to the string column
featureCreation.nlp.word2vec:{[tokens;config]
  size:300&count raze distinct tokens;
  tokenCount:avg count each tokens;
  window:$[30<tokenCount;10;10<tokenCount;5;2];
  gensimWord2Vec:.p.import[`gensim.models][`:Word2Vec];
  args:`size`window`sg`seed`workers!(size;window;config`w2v;config`seed;1);
  model:$[config`savedWord2Vec;
    gensimWord2Vec[`:load]utils.ssrWindows config[`modelsSavePath],"/w2v.model";
    @[gensimWord2Vec .;(tokens;pykwargs args);{'"\nGensim returned the following error\n",x,
      "\nPlease review your input NLP data\n"}]
    ];
  if[config`savedWord2Vec;size:model[`:vector_size]`];
  w2vIndex:where each tokens in model[`:wv.index2word]`;
  sentenceVector:featureCreation.nlp.i.w2vTokens[tokens]'[til count w2vIndex;w2vIndex]; 
  avgVector:avg each featureCreation.nlp.i.w2vItem[model]each sentenceVector;
  w2vTable:flip(`$"col",/:string til size)!flip avgVector;
  (w2vTable;model)
  }
