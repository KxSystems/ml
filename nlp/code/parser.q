// code/parser.q - Nlp parser utilities
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities for parsing 

\d .nlp

// @private
// @kind function
// @category nlpParserUtility
// @desc Retrieve python function for running spacy
parser.i.parseText:.p.get[`get_doc_info;<];

// @private
// @kind function
// @category nlpParserUtility
// @desc Convert string input to an appropriate
//   byte representation suitable for application in Python
//   functions, this is particularly useful when dealing with
//   languages other than English
// @param data {string} Any input string containing any character
//   arrays
// @returns {string} The data parsed such that UTF-8 compliant
//   characters can be appropriately managed by the NLP models
parser.i.cleanUTF8:{[data]
  byteDecode:.p.import[`builtins;`:bytes.decode;<];
  // Convert data to bytes and decode to appropriate string
  byteDecode["x"$data;`errors pykw`ignore]
  }

// @private
// @kind dictionary
// @category nlpParserUtility
// @desc Dependent options for input to spacy module
// @type dictionary
parser.i.depOpts:(!). flip(
  (`keywords;   `tokens`isStop);
  (`sentChars;  `sentIndices);
  (`sentIndices;`sbd);
  (`uniPOS;     `tagger);
  (`pennPOS;    `tagger);
  (`lemmas;     `tagger);
  (`isStop;     `lemmas))

// @private
// @kind dictionary
// @category nlpParserUtility
// @desc Map from q-style attribute names to spacy
// @type dictionary
parser.i.q2spacy:(!). flip(
  (`likeEmail;  `like_email);
  (`likeNumber; `like_num);
  (`likeURL;    `like_url);
  (`isStop;     `is_stop);
  (`tokens;     `lower_);
  (`lemmas;     `lemma_);
  (`uniPOS;     `pos_);
  (`pennPOS;    `tag_);
  (`starts;     `idx))

// @private
// @kind dictionary
// @category nlpParserUtility
// @desc Model inputs for spacy 'alpha' models
// @type dictionary
parser.i.alphaLang:(!). flip(
  (`ja;`Japanese);
  (`zh;`Chinese))

// @private
// @kind function
// @category nlpParser
// @desc Create a new parser
// @param modelName {symbol} The spaCy model/language to use. 
//   This must already be installed.
// @param options {symbol[]} The fields the parser should return
// @param disabled {symbol[]} The modules to be disabled
// @returns {fn} a parser for the given language
parser.i.newSubParser:{[modelName;options;disabled] 
  checkLang:parser.i.alphaLang modelName;
  lang:$[`~checkLang;`spacy;sv[`]`spacy.lang,modelName];
  model:.p.import[lang][hsym$[`~checkLang;`load;checkLang]];
  model:model . raze[$[`~checkLang;modelName;()];`disable pykw disabled];
  if[`sbd in options;
    pipe:$[`~checkLang;model[`:create_pipe;`sentencizer];.p.pyget`x_sbd];
    model[`:add_pipe]pipe;
    ];
  if[`spell in options;
    spacyTokens:.p.import[`spacy.tokens][`:Token];
    if[not spacyTokens[`:has_extension]["hunspell_spell"]`;
      spHun:.p.import[`spacy_hunspell]`:spaCyHunSpell;
      platform:`$.p.import[`platform][`:system][]`;
      osSys:$[`Darwin~platform;`mac;lower platform];
      hunspell:spHun[model;osSys];
      model[`:add_pipe]hunspell
      ]
    ];
  model
  }

// @private
// @kind function
// @category nlpParserUtility
// @desc Parser operations that must be done in q, or give better 
//   performance in q
// @param pyParser {fn} A projection to call the spacy parser
// @param fieldNames {symbol[]} The field names the parser should return
// @param options {symbol[]} The fields to compute
// @param stopWords {symbol[]} The stopWords in the text
// @param docs {string|string[]} The text being parsed
// @returns {dictionary|table} The parsed document(s)
parser.i.runParser:{[pyParser;fieldNames;options;stopWords;docs]
  tab:parser.i.cleanUTF8 each docs;
  parsed:parser.i.unpack[pyParser;options;stopWords]each tab;
  if[`keywords in options;parsed[`keywords]:TFIDF parsed];
  fieldNames:($[1=count fieldNames;enlist;]fieldNames) except `spell;
  fieldNames#@[parsed;`text;:;tab]
  }

// @private
// @kind function
// @category nlpParserUtility
// @desc This handles operations such as casting/removing punctuation
//   that need to be done in q, or for performance reasons are better in q
// @param pyParser {fn} A projection to call the spaCy parser
// @param options {symbol[]} The fields to include in the output
// @param stopWords {symbol[]} The stopWords in the text
// @param text {string} The text being parsed
// @returns {dictionary} The parsed document
parser.i.unpack:{[pyParser;options;stopWords;text]
  names:inter[key[parser.i.q2spacy],`sentChars`sentIndices;options],`isPunct;
  doc:names!pyParser text;
  // Cast any attributes which should be symbols
  doc:@[doc;names inter`tokens`lemmas`uniPOS`pennPOS;`$];
  // If there are entities, cast them to symbols
  if[`entities in names;doc:.[doc;(`entities;::;0 1);`$]]
  if[`isStop in names;
    if[`uniPOS in names;doc[`isStop]|:doc[`uniPOS]in i.stopUniPOS];
    if[`pennPOS in names;doc[`isStop]|:doc[`pennPOS]in i.stopPennPOS];
    if[`lemmas in names;doc[`isStop]|:doc[`lemmas]in stopWords];
    ];
  doc:parser.i.removePunct parser.i.adjustIndices[text]doc;
  if[`sentIndices in options;
    doc[`sentIndices]@:unique:value last each group doc`sentIndices;
    if[`sentChars in options;doc[`sentChars]@:unique]
    ];
  @[doc;`;:;::]
  }

// @private
// @kind function
// @category nlpParserUtility
// @desc This converts python indices to q indices in the text
//   This has to be done because python indexes into strings by char instead
//   of byte, so must be modified to index a q string
// @param text {string} The text being parsed
// @param doc {dictionary} The parsed document
// @returns {dictionary} The document with corrected indices
parser.i.adjustIndices:{[text;doc]
  if[1~count text;text:enlist text];
  // Any bytes following the first byte in UTF-8 multi-byte characters
  // will be in the range 128-191. These are continuation bytes.
  continuations: where text within "\200\277";
  // To find a character's index in python,
  // the number of previous continuation bytes must be subtracted
  adjusted:continuations-til count continuations;
  // Add to each index the number of continuation bytes which came before it
  // This needs to add 1, as the string "“hello”" gives the 
  // adjustedContinuations 1 1 7 7.
  // If the python index is 1, 1 1 7 7 binr 1 gives back 0, so it needs to 
  // check the index after the python index
  if[`starts in cols doc;doc[`starts]+:adjusted binr 1+doc`starts];
  if[`sentChars in cols doc;doc[`sentChars]+:adjusted binr 1+doc`sentChars];
  doc
  }

// @private
// @kind function
// @category nlpParserUtility
// @desc Removes punctuation and space tokens and updates indices
// @param doc {dictionary} The parsed document
// @returns {dictionary} The parsed document with punctuation removed
parser.i.removePunct:{[doc]
  // Extract document attributes
  attrs:cols doc;
  doc:@[doc;key[parser.i.q2spacy]inter attrs;@[;where not doc`isPunct]];
  idx:sums 0,not doc`isPunct;
  if[`sentIndices in attrs;doc:@[doc;`sentIndices;idx]];
  doc _`isPunct
  }

// @private
// @kind function
// @category nlpParserUtility
// @desc Parse a URL into its constituent components
// @param url {string} The URL to be decomposed into its components
// @returns {string[]} The components which make up the 
parser.i.parseURLs:{[url]
  pyLambda:"lambda url: urlparse(url if seReg.match(url) ",
    "else 'http://' + url)";
  .p.eval[pyLambda;<]url
  }
