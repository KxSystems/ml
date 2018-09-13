\d .nlp

.p.import[`sys;:;`:argv;()]; / spacy expects python be the main process

// Python functions for running spacy
p)def get_doc_info(parser,tokenAttrs,opts,text):
  doc=parser(text)
  res=[[getattr(w,a)for w in doc]for a in tokenAttrs]
  if('sentChars' in opts): # indices of first+last char per sentence
    res.append([(s.start_char,s.end_char)for s in doc.sents])
  if('sentIndices' in opts): # index of first token per sentence
    res.append([s.start for s in doc.sents])
  res.append([w.is_punct or w.is_bracket or w.is_space for w in doc])
  return res
parser.i.parseText:.p.get[`get_doc_info;<];
parser.i.cleanUTF8:.p.import[`builtins;`:bytes.decode;<][;`errors pykw`ignore]$["x"]@;

// Dependent options
parser.i.depOpts:(!). flip(
  (`keywords;   `tokens`isStop);
  (`sentChars;  `sbd`sentIndices);
  (`sentIndices;`sbd);
  (`uniPOS;     `tagger);
  (`pennPOS;    `tagger))

// Map from q-style attribute names to spacy
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

// Create new parser
// Valid opts : text keywords likeEmail likeNumber likeURL isStop tokens lemmas uniPOS pennPOS starts sentChars sentIndices
parser.i.newParser:{[lang;opts]
  opts:distinct opts,raze parser.i.depOpts colnames:opts;
  disabled:`ner`tagger`parser except opts;
  model:.p.import[`spacy;`:load][lang;`disable pykw disabled];
  if[(`sbd in opts)&`parser in disabled;model[`:add_pipe]model[`:create_pipe;`sbd]];
  tokenAttrs:parser.i.q2spacy key[parser.i.q2spacy]inter opts;
  pyParser:parser.i.parseText[model;tokenAttrs;opts;];
  parser.i.runParser[pyParser;colnames;opts]}

// Operations that must be done in q, or give better performance in q
parser.i.runParser:{[pyParser;colnames;opts;docs]
  t:parser.i.cleanUTF8 each docs;
  parsed:parser.i.unpack[pyParser;opts]each t;
  if[`keywords in opts;parsed[`keywords]:TFIDF parsed];
  colnames#@[parsed;`text;:;t]}

// Operations that must be done in q, or give better performance in q
parser.i.unpack:{[pyParser;opts;text]
  names:inter[key[parser.i.q2spacy],`sentChars`sentIndices;opts],`isPunct;
  doc:names!pyParser text;
  doc:@[doc;names inter`tokens`lemmas`uniPOS`pennPOS;`$];
  if[`entities in names;doc:.[doc;(`entities;::;0 1);`$]]
  if[`isStop in names;
    if[`tokens  in names;doc[`isStop]|:doc[`tokens ]in i.stopwords  ];
    if[`uniPOS  in names;doc[`isStop]|:doc[`uniPOS ]in i.stopUniPOS ];
    if[`pennPOS in names;doc[`isStop]|:doc[`pennPOS]in i.stopPennPOS];
  ];
  doc:parser.i.removePunct parser.i.adjustIndices[text]doc;
  if[`sentIndices in opts;
    doc[`sentIndices]@:unique:value last each group doc`sentIndices;
    if[`sentChars in opts;doc[`sentChars]@:unique]
  ];
  @[doc;`;:;::]}

// Python indexes into strings by char instead of byte, so must be modified to index a q string
parser.i.adjustIndices:{[text;doc]
  adj:cont-til count cont:where text within"\200\277";
  if[`starts    in cols doc;doc[`starts   ]+:adj binr 1+doc`starts   ];
  if[`sentChars in cols doc;doc[`sentChars]+:adj binr 1+doc`sentChars];
  doc}

// Removes punctuation and space tokens and updates indices
parser.i.removePunct:{[doc]
  doc:@[doc;key[parser.i.q2spacy]inter k:cols doc;@[;where not doc`isPunct]];
  idx:sums 0,not doc`isPunct;
  if[`sentIndices in k;doc:@[doc;`sentIndices;idx]];
  doc _`isPunct}
