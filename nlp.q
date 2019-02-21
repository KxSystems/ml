\d .nlp
version:@[{NLPVERSION};0;`development]
// Find TFIDF scores for all terms in all documents
TFIDF:{[corpus]
  tokens:corpus[`tokens]@'where each not corpus[`isStop]|corpus[`tokens]like\:"[0-9]*";
  tab:{x!{sum[x in y]%count x}[y]each x}'[words:distinct each tokens;tokens];
  tab*idf:1+log count[tokens]%{sum{x in y}[y]each x}[tokens]each words}

TFIDF_tot:{[corpus]desc sum t%'sum each t:TFIDF corpus}


// On a conceptually single doc (e.g. novel), gives better results than TF-IDF
// This algorithm is explained in the paper
// Carpena, P., et al. "Level statistics of words: Finding keywords in literary texts and symbolic sequences."
// Physical Review E 79.3 (2009): 035102.
keywordsContinuous:{[docs]
  n:count each gt:group text:raze docs[`tokens]@'where each not docs`isStop;
  words:where n>=4|.00002*count text;
  dist:deltas each words#gt;
  sigma:(dev each dist)%(avg each dist)*sqrt 1-(n:words#n)%count text;
  std_sigma:1%sqrt[n]*1+2.8*n xexp -0.865;
  chev_sigma:((2*n)-1)%2*n+1;
  desc(sigma-chev_sigma)%std_sigma}

// Give 2 dicts of each term's affinity to each corpus
// Algorithm from Rayson, Paul, and Roger Garside. "Comparing corpora using frequency profiling."
// Proceedings of the workshop on Comparing Corpora. Association for Computational Linguistics, 2000 
compareCorpora:{[corp1;corp2]
  if[(not count corp1)|(not count corp2);:((`$())!();(`$())!())];
  getTermCount:{[corp]
    i.fastSum{1+log count each group x}each corp[`tokens]@'where each not corp`isStop};
  totalWordCountA:sum termCountA:getTermCount corp1;
  totalWordCountB:sum termCountB:getTermCount corp2;
  // The expected termCount of each term in each corpus
  coef:(termCountA+termCountB)%(totalWordCountA+totalWordCountB);
  expectedA:totalWordCountA*coef;
  expectedB:totalWordCountB*coef;
  // Return the differences between the corpora
  (desc termCountA*log termCountA%expectedA;desc termCountB*log termCountB%expectedB)}

// Calc cosine similarity of two docs
compareDocs:{cosineSimilarity .(x;y)@\:distinct raze key each(x;y)}

// Compare similarity of 2 vectors
cosineSimilarity:{sum[x*y]%(sqrt sum x*x)*sqrt sum y*y}

// How much each term contributes to the cosine similarity
explainSimilarity:{[doc1;doc2]
  alignedKeys:inter[key doc1;key doc2];
  doc1@:alignedKeys;
  doc2@:alignedKeys;
  product:(doc1%i.magnitude doc1)*(doc2%i.magnitude doc2);
  desc alignedKeys!product%sum product}

// Find runs containing term where each word has above average co-ocurrance with term
extractPhrases:{[corpus;term]
  relevant:term,sublist[150]where 0<findRelatedTerms[corpus]term:lower term;
  runs:(i.findRuns where@)each(tokens:corpus`tokens)in\:relevant;
  desc(where r>1)#r:count each group r where term in/:r:raze tokens@'runs}

// Find all dates : list of 5-tuples (startDate; endDate; dateText; startIndex; 1+endIndex)
findDates:tm.findDates

// Find all times : list of 4-tuples (time; timeText; startIndex; 1+endIndex)
findTimes:tm.findTimes

// Get all sentences for a doc
getSentences:i.getSentences

// Find runs of tokens whose POS tags are in the set passed in
// Returns pair (text; firstIndex)
findPOSRuns:{[tagType;tags;doc]
  start:where 1=deltas matchingTag:doc[tagType]in tags;
  ii:start+til each lengths:sum each start cut matchingTag;
  runs:`$" "sv/:string each doc[`tokens]start+til each lengths;
  flip(runs;ii)}

// Generate feature vector (of stemmed tokens) for a term
findRelatedTerms:{[docs;term]
  sent:raze docs[`sentIndices]cut'@'[docs[`tokens];where each docs`isStop;:;`];
  sent@:asc distinct raze 0|-1 0 1+\:where(term:lower term)in/:sent;
  ccur:` _ count each group raze distinct each sent;
  tcur:idx@'group each docs[`tokens]@'idx:where each docs[`tokens]in\:key ccur;
  tcur:i.fastSum((count distinct@)each)each docs[`sentIndices]bin'tcur;
  ccur%:tcur term;
  tcur%:sum count each docs`sentIndices;
  desc except[where r>0;term]#r:(ccur-tcur)%sqrt tcur*1-tcur}

// Jaro-Winkler distance between 2 strings
jaroWinkler:{i.jaroWinkler[lower x;lower y]}

// Import all files in a dir recursively
loadTextFromDir:{[fp]
  path:{[fp]raze$[-11=type k:key fp:hsym fp;fp;.z.s each` sv'fp,'k]}`$fp;
  ([]fileName:(` vs'path)[;1];path;text:"\n"sv'read0 each path)}

// Read an mbox file, converting it to a table with the parsed metadata
loadEmails:email.i.getMboxText

// Create a new parser using a spaCy model (must already be installed)
newParser:parser.i.newParser

// Detect language from text
detectLang:{[text]`$.p.import[`langid][`:classify;<][raze text]0}

// Parse urls to dictionaries
parseURLs:{`scheme`domainName`path`parameters`query`fragment!i.parseURLs x}

// Calculate sentiment of sentence of short message
sentiment:sent.score

// Phonological representation of string (commented out for now)
/doubleMetaphone:.p.import[`metaphone;`:doublemetaphone;<]
