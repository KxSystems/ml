// code/email.q - Nlp sentiment utilities
// Copyright (c) 2021 Kx Systems Inc
//
// Utilities for sentiment analysis 

\d .nlp

// @private
// @kind function
// @category nlpSentUtility
// @desc Create a regex patterns used for tokenization
// @returns {<} The compiled regex object
sent.i.tokenPattern:{
  rightFacingEmoticons:"[<>]?[:;=8][\\-o\\*\\']?[\\)\\]\\(\\[dDpP/\\:\\}\\{@",
    "\\|\\\\]"; / n.b. Left-facing rarely used
  miscEmoticons:"<3|[0o][._][0o]|</3|\\\\o/|[lr]&r|j/[jkptw]|\\*\\\\0/\\*|v\\",
    ".v|o/\\\\o";
  urlStart:"https?://";
  // Match any words
  word:"\\b(?:the shit|the bomb|bad ass|yeah right|cut the mustard|kiss of ",
    "death|hand to mouth|sort of|kind of|kind-of|sort-of|cover-up|once-in-a-",
    "lifetime|self-confident|short-sighted|short-sightedness|son-of-a-bitch)",
    "\\b|[\\w]{2,}(?:'[ts])?";
  text:"(?:",urlStart,"|",rightFacingEmoticons,"|",miscEmoticons,"|",word,")";
  regex.compile[;1b]text
  }[]

// @private
// @kind function
// @category nlpSentUtility
// @desc Tokenizer specifically for sentiment analyzer 
//   (won't work for general purpose tokenizing)
// @param text {string} The text to be tokenized
// @returns {symbol[]} The tokens of the text 
//   (each word/emoticon ends up in its own token)
sent.i.tokenize:{[text]
  `$regex.matchAll[sent.i.tokenPattern;text][;0]
  }

// @private
// @kind function
// @category nlpSentUtility
// @desc Check for added emphasis resulting from exclamation points 
//   (up to 4 of them) using empirically derived mean sentiment intensity. 
//   Ratings increase for exclamation points
// @param text {string} The complete sentence
// @returns {float} An amount to increase the sentiment by
sent.i.amplifyEP:{[text]
  .292*4&sum"!"=text
  }

// @private
// @kind function
// @category nlpSentUtility
// @desc Check for added emphasis resulting from question marks 
//   (2 or 3+) using empirically derived mean sentiment intensity rating. 
//   Ratings increases for question marks
// @param text {string} The complete sentence
// @returns {float} An amount to increase the sentiment by
sent.i.amplifyQM:{[text]
  (0 0 .36 .54 .96)4&sum"?"=text
  }

// @private 
// @kind data
// @category nlpSentUtility
// @desc Positive booster words. This increases positive valences
// @type symbol[]
sent.i.posBoosters:`$(
  "absolutely";"amazingly";"awfully";"completely";"considerably";"decidedly";
  "deeply";"effing";"enormously";"entirely";"especially";"exceptionally";
  "extremely";"fabulously";"flipping";"flippin";"fricking";"frickin";
  "frigging";"friggin";"fully";"fucking";"greatly";"hella";"highly";"hugely";
  "incredibly";"intensely";"majorly";"more";"most";"particularly";"purely";
  "quite";"really";"remarkably";"so";"substantially";"thoroughly";"totally";
  "tremendously";"uber";"unbelievably";"unusually";"utterly";"very");

// @private
// @kind data
// @category nlpSentUtility
// @desc Negative booster words. This increase negative valences 
// @type symbol[]
sent.i.negBoosters:`$(
  "almost";"barely";"hardly";"just enough";"kind of";"kinda";"kindof";
  "kind-of";"less";"little";"marginally";"occasionally";"partly";"scarcely";
  "slightly";"somewhat";"sort of";"sorta";"sortof";"sort-of");

// @private
// @kind data
// @category nlpSentUtility
// @desc The co-efficient how much boosters increase sentiment
// @type float
sent.i.BOOSTER_INCR:.293

// @private
// @kind data
// @category nlpSentUtility
// @desc The co-efficient how much allcaps increase sentiment
// @type float
sent.i.ALLCAPS_INCR:.733

// @private
// @kind data
// @category nlpSentUtility
// @desc A dictionary mapping all possible boosters
//   to their associated values
// @type dictionary
sent.i.Boosters:(!). flip(sent.i.posBoosters,\:sent.i.BOOSTER_INCR),
  (sent.i.negBoosters,\:neg sent.i.BOOSTER_INCR)

// @private
// @kind function
// @category nlpSentUtility
// @desc Add weight for "booster" words like "really", or "very"
// @param tokens {symbol[]} The tokenized sentence
// @param isUpperCase {boolean[]} A vector where an element is 1b if the 
//   associated token is upper case
// @param valences {float[]} The sentiment of each token
// @returns {float} The modified valences
sent.i.applyBoosters:{[tokens;isUpperCase;valences]
  weight:sent.i.Boosters tokens;
  // Inc degree of capitalized boosters
  whereUpper:where isUpperCase;
  weight[whereUpper]+:sent.i.ALLCAPS_INCR*signum weight whereUpper;
  // Add weight to next 3 tokens (add/remove 3 dummy vals in case booster 
  // is last token)
  boosts:-3_@[(3+count valences)#0f;i+/:1 2 3;+;
    weight[i:where not null weight]*/:1 .95 .9];
  // Add extra weight
  valences+boosts*signum valences
  }

// @private
// @kind function
// @category nlpSentUtility
// @desc Decrease the weight of valences before "but", and increase 
//   the weight of valences after it
// @param tokens {symbol[]} The tokenized sentence
// @param valences {number[]} The sentiment of each token
// @returns {number[]} The modified valences
sent.i.butCheck:{[tokens;valences]
  valences:"f"$valences;
  i:tokens?`but;
  j:count[tokens]-i;
  $[j;@[;til i;*;.5]@[;i+1+til j-1;*;1.5]@;]valences
  }

// @private
// @kind data
// @category nlpSentUtility
// @desc These are terms that negate what follows them
// @type symbol[]
sent.i.NEGATE:`$(
  "aint";"arent";"cannot";"cant";"couldnt";"darent";"didnt";"doesnt";
  "ain't";"aren't";"can't";"couldn't";"daren't";"didn't";"doesn't";
  "dont";"hadnt";"hasnt";"havent";"isnt";"mightnt";"mustnt";"neither";
  "don't";"hadn't";"hasn't";"haven't";"isn't";"mightn't";"mustn't";
  "neednt";"needn't";"never";"none";"nope"; "nor";"not";"nothing"; 
  "nowhere";"oughtnt";"shant";"shouldnt";"uhuh";"wasnt";"werent";
  "oughtn't";"shan't";"shouldn't";"uh-uh";"wasn't";"weren't";"without";
  "wont";"wouldnt";"won't";"wouldn't";"rarely";"seldom";"despite")

// @private
// @kind data
// @category nlpSentUtility
// @desc The co-efficient for sentiments following a negation
// @type float
sent.i.N_SCALAR:-0.74 

// @private
// @kind function
// @category nlpSentUtility
// @desc Check if the preceding words increase, decrease, 
//   or negate the valence
// @param tokens {symbol[]} The tokenized sentence
// @param valences {float[]} The sentiment of each token
// @returns {float} The modified valences
sent.i.negationCheck:{[tokens;valences]
  valences,:3#0f;
  // "never so/as/this" act like boosters
  s:tokens in`so`as`this; 
  posNever:where(tokens=`never)&(next next s)|next s; 
  valences:@[valences;posNever+/:2 3;*;1.5 1.25];
  // Tokens in NEGATE or ending in "n't"
  i:where(tokens in sent.i.NEGATE)|tokens like"*n't";
  valences:@[valences;1 2 3+\:i except posNever;*;sent.i.N_SCALAR];
  // Occurences of "least" that are not part of "at/very least"
  j:where(tokens=`least)&not prev tokens in`at`very;
  valences:@[valences;j+1;*;sent.i.N_SCALAR];
  -3_ valences
  }

// @private
// @kind data
// @category nlpSentUtility
// @desc Load the dictionary of terms and their sentiment
//   Hutto, C.J. & Gilbert, E.E. (2014). VADER: A Parsimonious Rule-based Model
//   for Sentiment Analysis of Social Media Text. Eighth International
//   Conference on Weblogs and Social Media (ICWSM-14). Ann Arbor, MI,June 2014
// @type dictionary
sent.i.lexicon :(!).("SF";"\t")0: hsym `$.nlp.path,"/vader/lexicon.txt";

// @private
// @kind data
// @category nlpSentUtility
// @desc Additional lexicon sentiments
// @type dictionary
sent.i.lexicon,:(!). flip(
  (`$"the shit"; 3f);
  (`$"the bomb"; 3f);
  (`$"bad ass"; 1.5f);
  (`$"yeah right"; -2f);
  (`$"cut the mustard"; 2f);
  (`$"kiss of death"; -1.5f);
  (`$"hand to mouth"; -2f));

// @private
// @kind function
// @category nlpSentUtility
// @desc Calculate the sentiment, given the individual valences
// @param valences {float[]} The sentiment of each token
// @param text {string} A piece of text
// @returns {dictionary} The sentiment of the text along the dimensions
//   `pos`neg`neu and`compound
sent.i.scoreValence:{[valences;text]
  if[not count valences;:`compound`pos`neg`neu!0 0 0 0f];
  compound:sum valences;
  // Punctuation can increase the intensity of the sentiment
  punctAmplifier:sent.i.amplifyEP[text]+sent.i.amplifyQM text;
  compound+:signum[compound]*punctAmplifier;
  // Normalize score
  compound:{x%sqrt 15+x*x}compound;
  // Discriminate between positive, negative and neutral sentiment scores
  positive:sum 1+valences where valences>0;
  negative:sum -1+valences where valences<0;
  neutral:count where valences=0;
  // If punctuation affects the sentiment, apply emphasis to dominant sentiment
  if[positive>abs negative;positive+:punctAmplifier];
  if[positive<abs negative;negative-:punctAmplifier];
  // Used to noramlize the pos, neg and neutral sentiment
  total:positive+neutral+abs negative;
  `compound`pos`neg`neu!(compound,abs(positive;negative;neutral)%total)
  }
