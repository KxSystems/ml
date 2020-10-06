// The functionality below pertains to the application of NLP methods to kdb+

\d .automl

// Utility function used both in the application of NLP on the initial run and on new data
// It covers sentiment analysis, named entity recognition, word2vec and stop word analysis
/* t    = input table
/* p    = parameter dictionary passed as default or modified by user
/* smdl = use a saved model or not (required to differentiate new/run logic)
/* fp   = file path to the location where the word2vec model is saved for a specified run
prep.i.nlp_proc:{[t;p;smdl;fp]
  args:(.p.import[`spacy;`:load]"en_core_web_sm";t strcol:.ml.i.fndcols[t;"C"]);
  sents:$[1<count strcol;{x@''flip y};{x each y 0}]. args;
  regex_tab:prep.i.regex_tab[t;strcol;prep.i.regexlst];
  ner_tab:prep.i.ner_tab[sents;strcol];
  sent_tab:prep.i.sent_tab[t;strcol;`compound`pos`neg`neu];
  chk:prep.i.col_check cols corpus:prep.i.corpus[t;strcol;`isStop`tokens`uniPOS`likeNumber];
  uni_tab:prep.i.unipos_tagging[corpus;strcol]chk"uniPOS*";
  stop_tab:prep.i.bool_tab[corpus]chk"isStop*";
  num_tab:prep.i.bool_tab[corpus]chk"likeNumber*";
  cnt_tks:flip enlist[`cnt_tks]!enlist count each corpus`tokens;
  tokens:string(,'/)corpus chk"tokens*";
  w2v_tab:prep.i.word2vec[tokens;p;fp;smdl];
  nlp_tab:(,'/)(uni_tab;sent_tab;w2v_tab 0;ner_tab;regex_tab;stop_tab;num_tab;cnt_tks);
  `tb`strcol`mdl!(nlp_tab;strcol;w2v_tab 1)
  }

/* t   = input table
/* col = column containing list of booleans
/. r > table indicating percentage of true values within a column 
prep.i.bool_tab:{[t;col]flip col!{sum[x]%count x}@''t col}

/* fields = list of items to retrieve from newParser - also used in the naming of columns
/. r > table of parsed character data in appropriate corpus for word2vec/stop word/unipos analysis
prep.i.corpus:{[t;col;fields]
  parse_cols:prep.i.col_naming[fields;col];
  new_parser:.nlp.newParser[`en;fields];
  // apply new parser to table data
  $[1<count col;prep.i.nm_raze[parse_cols]new_parser@'t[col];new_parser@t[col]0]
  }

/. r > table containing part of speech components as a percentage of the total parts of speech
prep.i.unipos_tagging:{[t;col;fields]
  // retrieve all relevant part of speech types
  pos_types:.p.import[`builtins;`:dir][.p.import[`spacy]`:parts_of_speech]`;
  unipos_types:`$pos_types where not 0 in/:pos_types ss\:"__";
  tab:t fields;
  // encode the percentage of each sentance which is of a specific part of speech
  perc_fn:prep.i.percdict[;unipos_types];
  $[1<count col;
    prep.i.nm_raze[prep.i.col_naming[unipos_types;fields]]perc_fn@''group@''tab;
    perc_fn each group each tab 0]
  }

// Apply named entity recognition to retrieve information about the content of
// a sentence/paragraph, allowing for context to be provided for a sentence.
/* sents = sentences on which named entity recognition is to be applied
/. r > table containing the percentage of each sentence belonging to particular named entities
prep.i.ner_tab:{[sents;col]
  // Named entities being searched over
  named_ents:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW,
             `LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  perc_fn:prep.i.percdict[;named_ents];
  data:$[num_cols:1<count col;flip;::]sents;
  ner_data:$[num_cols;
    {x@''count@'''group@''{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@''y};
    {x@'count@''group@'{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@'y}].(perc_fn;data);
  $[num_cols;prep.i.nm_raze[prep.i.col_naming[named_ents;col]];]ner_data
  }

// Apply sentiment analysis to an input table
/. r > table containing information about the pos/neg/compound sentiment of each column
prep.i.sent_tab:{[t;col;fields]
  sent_cols:prep.i.col_naming[fields;col];
  // get sentiment values
  $[1<count col;prep.i.nm_raze[sent_cols].nlp.sentiment@''t[col];.nlp.sentiment each t[col][0]]
  }

// Find Regualar expressions within the text
/. r > returns a table with the count of each expression found
prep.i.regex_tab:{[t;col;fields]
  regex_cols:prep.i.col_naming[fields;col];
  // get regex values
  $[1<count col;prep.i.nm_raze[regex_cols]prep.i.regexchk@''t[col];prep.i.regexchk each t[col] 0]}

// Function to count each expression within a single text
/. r > dictionary with count of each expression found
prep.i.regexchk:{[txt]
   count each .nlp.findRegex[txt;prep.i.regexlst]}

// Create/load a word2vec model for the corpus and apply this analysis to the sentences
// to encode the sentence information into a numerical representation which can
// provide context to the meaning of a sentence.
/* tokens = all the corpus tokens retrieved from the application of .nlp.newParser
/* p      = parameter dictionary which may be modified by the user
/* fp     = file path pointing to the location of a saved word2vec model
/* smdl   = Is a saved model being used or is a word2vec model required
prep.i.word2vec:{[tokens;p;fp;smdl]
  size:300&count raze distinct tokens;
  tkpl:avg count each tokens;
  window:$[30<tkpl;10;10<tkpl;5;2];
  gen_mdl:.p.import`gensim.models;
  args:`size`window`sg`seed`workers!(size;window;p`w2v;p`seed;1);
  model:$[smdl;
          gen_mdl[`:load]i.ssrwin fp,"/w2v.model";
          gen_mdl[`:Word2Vec][tokens;pykwargs args]];
  w2vind:where each tokens in model[`:wv.index2word]`;
  sentvec:{x[y;z]}[tokens]'[til count w2vind;w2vind];
  avg_vec:avg each prep.i.getw2vitem[model]each sentvec;
  (flip(`$"col",/:string til size)!flip avg_vec;model)
  }

/* mdl  = model to be applied
/* sent = sentiment values
/. r    > retrieves the word2vec items for sentences based on the model  
prep.i.getw2vitem:{[mdl;sent]$[()~sent;0;mdl[`:wv.__getitem__][sent]`]}

/* attr_check = list of attributes to check
/* attr_all   = list of all possible attributes
/. r   > returns percentage of each attribute present in NLP
prep.i.percdict:{[attr_check;attr_all]
  (attr_all!count[attr_all]#0f),`float$(count each attr_check)%sum count each attr_check}

/* attr1 = list of fixed types
/* attr2 = list of column names to append to attr1
/. r     > generates column names based on a fixed list and multiple options
prep.i.col_naming:{[attr1;attr2]`${string[x],\:"_",string y}[attr1]each attr2}

/. r > returns renamed columns, with individual columns razed together
prep.i.nm_raze:{[col;t](,'/){xcol[x;y]}'[col;t]}

/. r > finds all names according to a regex search
prep.i.col_check:{[col;attr_check]col where col like attr_check}

// List of expressions to search for within text
prep.i.regexlst:`specialChars`money`phoneNumber`emailAddress`url`zipCode`postalCode`day`month`year`time
