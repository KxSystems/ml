\d .nlp

//Load in python tensorflow_text
tensorf:.p.import[`tensorflow];
text:.p.import[`tensorflow_text];
tensorf[`:enable_eager_execution][];

tf.i.tokenopt:{text[hsym tf.i.tokenDict[x]][]}

/tokenization options for tensorflow_text
tf.i.tokenDict:(!). flip(
 (`whitespace;`WhitespaceTokenizer);
 (`unicode;`UnicodeScriptTokenizer))

//Tokenize a text
tf.tokenize:{
 if[1=count x;-1"Text must be more than one character long"];
 tokenizer:tf.i.tokenopt[y];
 tokens:tokenizer[`:tokenize][enlist x];
 `$raze{.nlp.parser.i.cleanUTF8 each x}each tokens[`:to_list;<][]}

//Tokenization used for sentiment analysis-doesnt include symbols
tf.i.tokenizeSent:{
 tokenizer:tf.i.tokenopt[y];
 tokens:tokenizer[`:tokenize][enlist x];
 punc:text[`:wordshape][tokens;text[`:WordShape][`:HAS_NO_PUNCT_OR_SYMBOL]];
 ind:where raze punc[`:to_list;<][];
 (`$raze{.nlp.parser.i.cleanUTF8 each x}each tokens[`:to_list;<][]) ind}

//Sentiment analysis using tf tokenization
tf.sent:{[txt;tk]
  valences:.nlp.sent.i.lexicon tokens:lower rawTokens:tf.i.tokenizeSent[txt;tk];
  isUpperCase:(rawTokens=upper rawTokens)& rawTokens<>tokens;
  upperIndices:where isUpperCase & not all isUpperCase;
  valences[upperIndices]+:.nlp.sent.i.ALLCAPS_INCR*signum valences upperIndices;
  valences:.nlp.sent.i.applyBoosters[tokens;isUpperCase;valences];
  valences:.nlp.sent.i.negationCheck[tokens;valences];
  valences:.nlp.sent.i.butCheck[tokens;valences];
  .nlp.sent.i.scoreValence[0f^valences;txt]}

//Wordshape dictionary with attribute callable python functions
tf.i.metaDict:(!). flip(
 (`is_punc;`IS_PUNCT_OR_SYMBOL);
 (`has_punc;`HAS_SOME_PUNCT_OR_SYMBOL);
 (`is_mixed;`IS_MIXED_CASE_LETTERS);
 (`is_numeric;`IS_NUMERIC_VALUE);
 (`has_numeric;`HAS_SOME_DIGITS);
 (`lower;`IS_LOWERCASE);
 (`title;`HAS_TITLE_CASE);
 (`symbol;`HAS_NON_LETTER);
 (`math;`HAS_MATH_SYMBOL);
 (`currency;`HAS_CURRENCY_SYMBOL);
 (`acronym;`IS_ACRONYM_WITH_PERIODS);
 (`is_emoji;`IS_EMOTICON);
 (`has_emoji;`HAS_EMOJI))

// Extrect the properties of strings 
tf.wordshape:{[txt;tk;att]
 tokenizer:tf.i.tokenopt[tk];
 tokens:tokenizer[`:tokenize][enlist txt];
 tokenTab:`$raze{.nlp.parser.i.cleanUTF8 each x}each tokens[`:to_list;<][];
 attTab:($[numAtt;enlist;]att)!$[numAtt:1~count[att];enlist;]{attrib:text[`:wordshape][y;text[`:WordShape][hsym tf.i.metaDict[x]]];
 where raze attrib[`:to_list;<][]}[;tokens]each att;
 attTab,(enlist `tokens)!enlist tokenTab}
