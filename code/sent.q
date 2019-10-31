\d .nlp

// Create regex used for tokenizing
sent.i.tokenPattern:{
  rightFacingEmoticons:"[<>]?[:;=8][\\-o\\*\\']?[\\)\\]\\(\\[dDpP/\\:\\}\\{@\\|\\\\]"; / n.b. Left-facing rarely used
  miscEmoticons:"<3|[0o][._][0o]|</3|\\\\o/|[lr]&r|j/[jkptw]|\\*\\\\0/\\*|v\\.v|o/\\\\o";
  urlStart:"https?://";
  // Match any words
  word:"\\b(?:the shit|the bomb|bad ass|yeah right|cut the mustard|kiss of death|hand to mouth|sort of|kind of|kind-of|sort-of|cover-up|once-in-a-lifetime|self-confident|short-sighted|short-sightedness|son-of-a-bitch)\\b|[\\w]{2,}(?:'[ts])?";
  regex.compile[;1b]"(?:",urlStart,"|",rightFacingEmoticons,"|",miscEmoticons,"|",word,")"
 }[]

// Tokenizer specifically for sentiment analyzer (won't work for general purpose tokenizing)
sent.i.tokenize:{`$regex.matchAll[sent.i.tokenPattern;x][;0]}

// Start indices of occurences of seq in list (faster than looping over list for each element)
sent.i.findSequence:{[list;seq]neg[count seq]+{[list;i;x]1+i where x=list i}[list]/[til count list;seq]}

// Inc mean sentiment intensity rating from '!' (up to 4)
// Empirically derived mean sentiment intensity rating increase for exclamation points
sent.i.amplifyEP:{.292*4&sum"!"=x}

// Inc mean sentiment intensity rating from '?' (up to 4)
// Empirically derived mean sentiment intensity rating increases for question marks
sent.i.amplifyQM:{(0 0 .36 .54 .96)4&sum"?"=x}

// Increase valences (weights) for booster words e.g. "really", "very"
sent.i.posBoosters:`$(
  "absolutely"; "amazingly"; "awfully"; "completely"; "considerably"; "decidedly"; "deeply";
  "effing"; "enormously"; "entirely"; "especially"; "exceptionally"; "extremely"; "fabulously";
  "flipping"; "flippin"; "fricking"; "frickin"; "frigging"; "friggin"; "fully"; "fucking";
  "greatly"; "hella"; "highly"; "hugely"; "incredibly"; "intensely"; "majorly"; "more"; "most";
  "particularly"; "purely"; "quite"; "really"; "remarkably"; "so"; "substantially"; "thoroughly";
  "totally"; "tremendously"; "uber"; "unbelievably"; "unusually"; "utterly"; "very");
sent.i.negBoosters:`$(
  "almost"; "barely"; "hardly"; "just enough"; "kind of"; "kinda"; "kindof"; "kind-of"; "less";
  "little"; "marginally"; "occasionally"; "partly"; "scarcely"; "slightly"; "somewhat"; "sort of";
  "sorta"; "sortof"; "sort-of");
sent.i.BOOSTER_INCR: .293
sent.i.ALLCAPS_INCR: .733
sent.i.Boosters:(!). flip(sent.i.posBoosters,\:sent.i.BOOSTER_INCR),(sent.i.negBoosters,\:neg sent.i.BOOSTER_INCR)

sent.i.applyBoosters:{[tokens;isUpperCase;valences]
  weight:sent.i.Boosters tokens;
  // Inc degree of capitalized boosters
  weight[wup]+:sent.i.ALLCAPS_INCR*signum weight wup:where isUpperCase;
  // Add weight to next 3 tokens (add/remove 3 dummy vals in case booster is last token)
  boosts:-3_@[(3+count valences)#0f;i+/:1 2 3;+;weight[i:where not null weight]*/:1 .95 .9];
  // Add extra weight
  valences+boosts*signum valences}

// Decrease weight of valences before "but", and increase the weight of valences after it
sent.i.butCheck:{[tokens;valences]$[j:count[tokens]-i:tokens?`but;@[;til i;*;.5]@[;i+1+til j-1;*;1.5]@;]"f"$valences}

// Check for idioms with associated sentiment
sent.i.IDIOMS:flip(
  (`the`shit; 3f);
  (`the`bomb; 3f);
  (`bad`ass; 1.5f);
  (`yeah`right; -2f);
  (`cut`the`mustard; 2f); 
  (`kiss`of`death; -1.5f); 
  (`hand`to`mouth; -2f));
sent.i.idiomsCheck:{[tokens;valences]
  indices:raze each 0 1 2 3+/:/:sent.i.findSequence[lower tokens]each sent.IDIOMS 0;
  -3_@[;;:;]/[valences,3#0f;indices;sent.i.IDIOMS 1]}

// Check if preceding words increase, decrease, or negate the valence
sent.i.NEGATE:`$(
  "aint"; "arent"; "cannot"; "cant"; "couldnt"; "darent"; "didnt"; "doesnt";
  "ain't"; "aren't"; "can't"; "couldn't"; "daren't"; "didn't"; "doesn't";
  "dont"; "hadnt"; "hasnt"; "havent"; "isnt"; "mightnt"; "mustnt"; "neither";
  "don't"; "hadn't"; "hasn't"; "haven't"; "isn't"; "mightn't"; "mustn't";
  "neednt"; "needn't"; "never"; "none"; "nope"; "nor"; "not"; "nothing"; "nowhere";
  "oughtnt"; "shant"; "shouldnt"; "uhuh"; "wasnt"; "werent";
  "oughtn't"; "shan't"; "shouldn't"; "uh-uh"; "wasn't"; "weren't";
  "without"; "wont"; "wouldnt"; "won't"; "wouldn't"; "rarely"; "seldom"; "despite")
sent.i.N_SCALAR:-0.74 / Co-efficient for sentiments following negation
sent.i.negationCheck:{[tokens;valences]
  valences,:3#0f;
  // "never so/as/this" act like boosters
  posNever:where(tokens=`never)&(next next s)|next s:tokens in`so`as`this;
  valences:@[valences;posNever+/:2 3;*;1.5 1.25];
  // tokens in NEGATE or ending in "n't"
  i:where(tokens in sent.i.NEGATE)|tokens like"*n't";
  valences:@[valences;1 2 3+\:i except posNever;*;sent.i.N_SCALAR];
  // occurences of "least" that are not part of "at/very least"
  j:where(tokens=`least)&not prev tokens in`at`very;
  valences:@[valences;j+1;*;sent.i.N_SCALAR];
  -3_ valences}

// Load the dictionary of terms and their sentiment
// Hutto, C.J. & Gilbert, E.E. (2014). VADER: A Parsimonious Rule-based Model for Sentiment Analysis of Social Media
// Text. Eighth International Conference on Weblogs and Social Media (ICWSM-14). Ann Arbor, MI, June 2014.
sent.i.lexicon :(!).("SF";"\t")0: hsym `$.nlp.path,"/vader/lexicon.txt";
sent.i.lexicon,:(!). flip(
  (`$"the shit"; 3f);
  (`$"the bomb"; 3f);
  (`$"bad ass"; 1.5f);
  (`$"yeah right"; -2f);
  (`$"cut the mustard"; 2f);
  (`$"kiss of death"; -1.5f);
  (`$"hand to mouth"; -2f));

// Calculate sentiment given individual valences
sent.i.scoreValence:{[valences;text]
  if[not count valences;:`compound`pos`neg`neu!0 0 0 0f];
  compound:sum valences;
  // Punctuation can increase the intensity of the sentiment
  compound+:signum[compound]*punctAmplifier:sent.i.amplifyEP[text]+sent.i.amplifyQM text;
  // Normalize score
  compound:{x%sqrt 15+x*x}compound;
  // Discriminate between positive, negative and neutral sentiment scores
  positive:sum  1+valences where valences>0;
  negative:sum -1+valences where valences<0;
  neutral:count where valences=0;
  // If punctuation affects the sentiment, apply emphasis to dominant sentiment
  if[positive>abs negative;positive+:punctAmplifier];
  if[positive<abs negative;negative-:punctAmplifier];
  // Used to noramlize the pos, neg and neutral sentiment
  total:positive+neutral+abs negative;
  `compound`pos`neg`neu!(compound,abs(positive;negative;neutral)%total)}

// Calculate sentiment of a sentence of short message
sent.score:{[text]
  valences:sent.i.lexicon tokens:lower rawTokens:sent.i.tokenize text;
  isUpperCase:(rawTokens=upper rawTokens)& rawTokens<>tokens;
  upperIndices:where isUpperCase & not all isUpperCase;
  valences[upperIndices]+:sent.i.ALLCAPS_INCR*signum valences upperIndices;
  valences:sent.i.applyBoosters[tokens;isUpperCase;valences];
  valences:sent.i.negationCheck[tokens;valences];
  valences:sent.i.butCheck[tokens;valences];
  sent.i.scoreValence[0f^valences;text]}

