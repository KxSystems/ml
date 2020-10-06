\d .automl

// Apply word2vec on string data for nlp problems
/* t = table from which NLP features are to be extracted
/* p = parameter dictionary containing information used in the extraction of features
/* mpath = save path for model, if saveopt = 0 then this will be (::) otherwise string filepath
/. r > table with features created in accordance with the nlp feature creation procedure
prep.nlpcreate:{[t;p;mpath]
  fe_start:.z.T;
  // Preprocess the character data
  prep:prep.i.nlp_proc[t;p;0b;(::)];
  // Table returned with NLP feature creation, any constant columns are dropped
  tb:.ml.dropconstant prep`tb;
  // run normal feature creation on numeric datasets and add to nlp features if relevant
  if[0<count cols[t]except prep`strcol;tb:tb,'first prep.normalcreate[(prep`strcol)_t;p]];
  // save the word2vec model down if applicable for use on new data
  if[p[`saveopt]in 1 2;prep[`mdl][`:save][i.ssrwin[mpath,"w2v.model"]]];
  fe_end:.z.T-fe_start;
  `preptab`preptime!(.ml.dropconstant prep.i.nullencode[.ml.infreplace tb;med];fe_end)}
