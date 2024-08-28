\l nlp.q
\l init.q
\d .nlp
basicParser:newParser[`en_core_web_sm;`tokens]; //~ this will warn about only having a tokeniser on first call: [W108] The rule-based lemmatizer did not find POS annotation for one or more tokens.
keywordParser:newParser[`en_core_web_sm;`keywords]
allSpacyOptionsParser:newParser[`en_core_web_sm;`likeEmail`likeURL`likeNumber`isStop`tokens`lemmas`uniPOS`pennPOS`starts];
allQOptionsParser:newParser[`en_core_web_sm; `keywords`sentChars`sentIndices];
textPreservingParser:newParser[`en_core_web_sm; `tokens`text];
sentenceParser:newParser[`en_core_web_sm; `tokens`sentChars`sentIndices];
sentCharsParser:newParser[`en_core_web_sm; `tokens`sentChars];
everythingParser:newParser[`en_core_web_sm; `tokens`sentChars`sentIndices`likeEmail`likeURL`likeNumber`isStop`tokens`lemmas`uniPOS`pennPOS`starts];
basicParser[enlist"This is my string"]~([]tokens:enlist`this`is`my`string)
basicParser[("Those were the days that I could master"; "the pace was slower and I was faster")]~([]tokens: (`those`were`the`days`that`i`could`master; `the`pace`was`slower`and`i`was`faster))
(first basicParser[enlist"НАТО"][`tokens])~enlist`$"нато"
docs:("Lacrosse teams will be playing in the tournament"; "The hockey tournament has ended"; "Hockey teams don't play on grass";"What games will they be playing?";"hoser");
keywords: keywordParser[docs] `keywords;
all(keywords[0;`lacrosse] > keywords[0;`team];keywords[0;`lacrosse] < keywords[4;`hoser])
docs: ("The great Québec maple syrup heist"; "Québec is great");
cols[keywordParser docs] ~ enlist `keywords
result:allSpacyOptionsParser enlist"Email Jeff Bezos at jeff@amazon.com. He gets 65,536 emails a day from people asking about www.blueorigin.com or https://amazon.ca.";
all(cols[result] ~`likeEmail`likeURL`likeNumber`isStop`tokens`lemmas`uniPOS`pennPOS`starts;result[`likeEmail] ~enlist 000010000000000000b;result[`likeURL]~enlist 000000000000000101b;result[`likeNumber]~enlist 000000010000000000b;result[`isStop]~enlist 000101110101001010b;result[`tokens]~enlist `email`jeff`bezos`at,(`$"jeff@amazon.com"),`he`gets,(`$"65,536"),`emails`a`day`from`people`asking`about`www.blueorigin.com`or`https://amazon.ca;result[`lemmas]~ enlist `Email`Jeff`Bezos`at,(`$"jeff@amazon.com"),`he`get,(`$"65,536"),`email`a`day`from`people`ask`about`www.blueorigin.com`or`https://amazon.ca;result[`uniPOS]~ enlist `PROPN`PROPN`PROPN`ADP`X`PRON`VERB`NUM`NOUN`DET`NOUN`ADP`NOUN`VERB`ADP`X`CCONJ`PROPN;result[`pennPOS] ~ enlist `NNP`NNP`NNP`IN`ADD`PRP`VBZ`CD`NNS`DT`NN`IN`NNS`VBG`IN`ADD`CC`NNP;result[`starts]~enlist 0 6 11 17 20 37 40 45 52 59 61 65 70 77 84 90 109 112)
result:allQOptionsParser[enlist"O, the year was 1778 how I wish I was in Sherbrooke now. A letter of marque came from the king."];
all(cols[result]~`keywords`sentChars`sentIndices;result[`keywords]~ enlist `o`year`wish`sherbrooke`letter`marque`came`king!8#0.125;result[`sentChars] ~ enlist (0 56; 57 95);result[`sentIndices] ~ enlist 0 13)
result:first sentenceParser enlist" Hornpipe, jig, and reel. \nThis is a good song"
all((cols result)~`tokens`sentChars`sentIndices;(result[`sentIndices] cut result[`tokens])~ (`hornpipe`jig`and`reel;`this`is`a`good`song))
\d .
