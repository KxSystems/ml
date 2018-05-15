\d .nlp

// Create regex used for tokenizing
sent.tokenPattern:{
  rightFacingEmoticons:"[<>]?[:;=8][\\-o\\*\\']?[\\)\\]\\(\\[dDpP/\\:\\}\\{@\\|\\\\]"; / n.b. Left-facing rarely used
  miscEmoticons:"<3|[0o][._][0o]|</3|\\\\o/|[lr]&r|j/[jkptw]|\\*\\\\0/\\*|v\\.v|o/\\\\o";
  urlStart:"https?://";
  // Match any words
  word:"\\b(?:the shit|the bomb|bad ass|yeah right|cut the mustard|kiss of death|hand to mouth|sort of|kind of|kind-of|sort-of|cover-up|once-in-a-lifetime|self-confident|short-sighted|short-sightedness|son-of-a-bitch)\\b|[\\w]{2,}(?:'[ts])?";
  regex.compile[;1b]"(?:",urlStart,"|",rightFacingEmoticons,"|",miscEmoticons,"|",word,")"
 }[]

// Tokenizer specifically for sentiment analyzer (won't work for general purpose tokenizing)
sent.tokenize:{`$regex.matchAll[sent.tokenPattern;x][;0]}

// Start indices of occurences of seq in list (faster than looping over list for each element)
sent.findSequence:{[list;seq]neg[count seq]+{[list;i;x]1+i where x=list i}[list]/[til count list;seq]}

// Inc mean sentiment intensity rating from '!' (up to 4)
sent.amplifyEP:{.292*4&sum"!"=x}

// Inc mean sentiment intensity rating from '?' (up to 4)
sent.amplifyQM:{(0 0 .36 .54 .96)4&sum"!"=x}

// Increase valences (weights) for booster words e.g. "really", "very"
sent.posBoosters:`$(
  "absolutely"; "amazingly"; "awfully"; "completely"; "considerably"; "decidedly"; "deeply";
  "effing"; "enormously"; "entirely"; "especially"; "exceptionally"; "extremely"; "fabulously";
  "flipping"; "flippin"; "fricking"; "frickin"; "frigging"; "friggin"; "fully"; "fucking";
  "greatly"; "hella"; "highly"; "hugely"; "incredibly"; "intensely"; "majorly"; "more"; "most";
  "particularly"; "purely"; "quite"; "really"; "remarkably"; "so"; "substantially"; "thoroughly";
  "totally"; "tremendously"; "uber"; "unbelievably"; "unusually"; "utterly"; "very");
sent.negBoosters:`$(
  "almost"; "barely"; "hardly"; "just enough"; "kind of"; "kinda"; "kindof"; "kind-of"; "less";
  "little"; "marginally"; "occasionally"; "partly"; "scarcely"; "slightly"; "somewhat"; "sort of";
  "sorta"; "sortof"; "sort-of");
sent.BOOSTER_INCR: .293
sent.ALLCAPS_INCR: .733
sent.Boosters:(!). flip(sent.posBoosters,\:sent.BOOSTER_INCR),(sent.negBoosters,\:neg sent.BOOSTER_INCR)

sent.applyBoosters:{[tokens;isUpperCase;valences]
  weight:sent.Boosters tokens;
  // Inc degree of capitalized boosters
  weight[wup]+:sent.ALLCAPS_INCR*signum weight wup:where isUpperCase;
  // Add weight to next 3 tokens (add/remove 3 dummy vals in case booster is last token)
  boosts:-3_@[(3+count valences)#0f;i+/:1 2 3;+;weight[i:where not null weight]*/:1 .95 .9];
  // Add extra weight
  valences+boosts*signum valences}

// Decrease weight of valences before "but", and increase the weight of valences after it
sent.butCheck:{[tokens;valences]$[j:count[tokens]-i:tokens?`but;@[;til i;*;.5]@[;i+1+til j-1;*;1.5]@;]"f"$valences}

// Check for idioms with associated sentiment
sent.IDIOMS:flip(
  (`the`shit; 3f);
  (`the`bomb; 3f);
  (`bad`ass; 1.5f);
  (`yeah`right; -2f);
  (`cut`the`mustard; 2f); 
  (`kiss`of`death; -1.5f); 
  (`hand`to`mouth; -2f));
sent.idiomsCheck:{[tokens;valences]
  indices:raze each 0 1 2 3+/:/:sent.findSequence[lower tokens]each sent.IDIOMS 0;
  -3_@[;;:;]/[valences,3#0f;indices;sent.IDIOMS 1]}

// Check if preceding words increase, decrease, or negate the valence
sent.NEGATE:`$(
  "aint"; "arent"; "cannot"; "cant"; "couldnt"; "darent"; "didnt"; "doesnt";
  "ain't"; "aren't"; "can't"; "couldn't"; "daren't"; "didn't"; "doesn't";
  "dont"; "hadnt"; "hasnt"; "havent"; "isnt"; "mightnt"; "mustnt"; "neither";
  "don't"; "hadn't"; "hasn't"; "haven't"; "isn't"; "mightn't"; "mustn't";
  "neednt"; "needn't"; "never"; "none"; "nope"; "nor"; "not"; "nothing"; "nowhere";
  "oughtnt"; "shant"; "shouldnt"; "uhuh"; "wasnt"; "werent";
  "oughtn't"; "shan't"; "shouldn't"; "uh-uh"; "wasn't"; "weren't";
  "without"; "wont"; "wouldnt"; "won't"; "wouldn't"; "rarely"; "seldom"; "despite")
sent.N_SCALAR:-0.74 / Co-efficient for sentiments following negation
sent.negationCheck:{[tokens;valences]
  valences,:3#0f;
  // "never so/as/this" act like boosters
  posNever:where(tokens=`never)&(next next s)|next s:tokens in`so`as`this;
  valences:@[valences;posNever+/:2 3;*;1.5 1.25];
  // tokens in NEGATE or ending in "n't"
  i:where(tokens in sent.NEGATE)|tokens like"*n't";
  valences:@[valences;1 2 3+\:i except posNever;*;sent.N_SCALAR];
  // occurences of "least" that are not part of "at/very least"
  j:where(tokens=`least)&not prev tokens in`at`very;
  valences:@[valences;j+1;*;sent.N_SCALAR];
  -3_ valences}

// Load the dictionary of terms and their sentiment
// Hutto, C.J. & Gilbert, E.E. (2014). VADER: A Parsimonious Rule-based Model for Sentiment Analysis of Social Media
// Text. Eighth International Conference on Weblogs and Social Media (ICWSM-14). Ann Arbor, MI, June 2014.
sent.lexicon :(!).("SF";"\t")0:`:nlp/vader/lexicon.txt;
sent.lexicon,:(!). flip(
  (`$"the shit"; 3f);
  (`$"the bomb"; 3f);
  (`$"bad ass"; 1.5f);
  (`$"yeah right"; -2f);
  (`$"cut the mustard"; 2f);
  (`$"kiss of death"; -1.5f);
  (`$"hand to mouth"; -2f));

// Calculate sentiment of a sentence of short message
sent.score:{[text]
  valences:sent.lexicon tokens:lower rawTokens:sent.tokenize text;
  isUpperCase:(rawTokens=upper rawTokens)& rawTokens<>tokens;
  upperIndices:where isUpperCase & not all isUpperCase;
  valences[upperIndices]+:sent.ALLCAPS_INCR*signum valences upperIndices;
  valences:sent.applyBoosters[tokens;isUpperCase;valences];
  valences:sent.negationCheck[tokens;valences];
  valences:sent.butCheck[tokens;valences];
  sent.scoreValence[0f^valences;text]}

// Calculate sentiment given individual valences
sent.scoreValence:{[valences;text]
  if[not count valences;:`compound`pos`neg`neu!0 0 0 0f];
  compound:sum valences;
  // Punctuation can increase the intensity of the sentiment
  compound+:signum[compound]*punctAmplifier:sent.amplifyEP[text]+sent.amplifyQM text;
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
