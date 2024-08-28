// code/utils.q - NLP utilities
// Copyright (c) 2021 Kx Systems Inc
//
// General nlp utility functions

\d .nlp

// @private
// @kind function
// @category nlpUtility
// @desc Import python functions
i.np:.p.import`numpy
i.str:.p.import[`builtins]`:str
i.bool:.p.import[`builtins]`:bool

// @private
// @kind function
// @category nlpUtility
// @desc A fast way to sum a list of dictionaries in
//   certain cases
// @param iter {long} The number of iterations. Note that within this
//   library iter is set explicitly to 2 for all present invocations
// @param dict {dictionary[]} A list of dictionaries
// @returns {dictionary} The dictionary values summed together
i.fastSum:{[iter;dict]
  // Summing a large number of dictionaries is expensive if there are many
  // distinct keys.
  // This splits them into groups, which have fewer distinct keys, and then
  // adds those groups.
  dictGroup:(ceiling sqrt count dict)cut dict;
  sum$[iter;.z.s iter-1;sum]each dictGroup
  }[2]

// @private
// @kind function
// @category nlpUtility
// @desc Replace empty dicts with (,`)!,0f
// @param docs {dictionary[]} Documents of text
// @returns {dictionary[]} Any empty dictionaries are filled
i.fillEmptyDocs:{[docs]
  $[98=type docs;
    0^docs;
    @[docs;i;:;count[i:where not count each docs]#enlist(1#`)!1#0f]
    ]
  }

// @private
// @kind function
// @category nlpUtility
// @desc Given a monotonically increasing list of integral numbers,
//   this finds any runs of consecutive numbers
// @param array {number[]} Array of values
// @returns {long[][]} A list of runs of consecutive indices
i.findRuns:{[array]
  prevVals:array=1+prev array;
  inRun:where prevVals|next prevVals;
  (where array<>1+prev array)_ array@:inRun
  }

// @private
// @kind function
// @category nlpUtility
// @desc Index of the first occurrence of the minimum
//   value of an array
// @param array {number[]} Array of values
// @return {number} The index of the minimum element of the array
i.minIndex:{[array]
  array?min array
  }

// @private
// @kind function
// @category nlpUtility
// @desc Index of the first occurrence of the maximum
//   value of the array
// @param array {number[]} Array of values
// @return {number} The index of the maximum element of the array
i.maxIndex:{[array]
  array?max array
  }

// @private
// @kind function
// @category nlpUtility
// @desc Calculate the harmonic mean
// @param array {number[]} Array of values
// @returns {float} The harmonic mean of the input
i.harmonicMean:{[array]
  1%avg 1%array
  }

// @private
// @kind function
// @category nlpUtility
// @desc Calculate a vector's magnitude
// @param array {number[]} Array of values
// @returns {float} The magnitude of the vector
i.magnitude:{[array]
  sqrt sum array*array
  }

// @private
// @kind function
// @category nlpUtility
// @desc Normalize a list or dictionary so the highest value is 1f
// @param vals {float[]|dictionary} A list or dictionary of numbers
// @returns {float[]|dictionary} The input, normalized
i.normalize:{[vals]
  vals%max vals
  }

// @private
// @kind function
// @category nlpUtility
// @desc Takes the largest N values
// @param n {long} The number of elements to take
// @param vals {any[]} A list of values
// @returns {any[]} The largest N values
i.takeTop:{[n;vals]
  n sublist desc vals
  }

// @private
// @kind function
// @category nlpUtility
// @desc Calculate the Jaro similarity score of two strings
// @param str1 {string|string[]} A string of text
// @param str2 {string|string[]} A string of text
// @returns {Float} The similarity score of two strings
i.jaro:{[str1;str2]
  lenStr1:count str1;
  lenStr2:count str2;
  if[0=lenStr1;:0f];
  // The range to search for matching characters
  range:1|-1+floor .5*lenStr1|lenStr2;
  // The low end of each window
  lowWin:deltas 0|til[lenStr1]+/:(-1 1)*range;
  k:lowWin[0]+where each str1='sublist\:[flip lowWin]str2;
  j:raze k[0;0]{x,(y except x)0}/1_k;
  nonNull:where not null j;
  n:count nonNull;
  // Find the number of transpositions
  trans:.5*sum str1[nonNull]<>str2 asc j nonNull;
  avg(n%lenStr1;n%lenStr2;(n-trans)%n)
  }

// @private
// @kind function
// @category nlpUtility
// @desc Generating symmetric matrix from triangle (ragged list)
//   This is used to save time when generating a matrix where the upper
//   triangular component is the mirror of the lower triangular component
// @param raggedList {float[][]} A list of lists of floats representing
//   an upper triangular matrix where the diagonal values are all 0.
//   eg. (2 3 4f; 5 6f; 7f) for a 4x4 matrix
// @returns {float[][]} An n x n two dimensional array
//   The input, mirrored across the diagonal, with all diagonal values being 1
i.matrixFromRaggedList:{[raggedList]
  // Pad the list with 0fs to make it an array,and set the diagonal values to
  // .5 which become 1 when the matrix is added to its flipped value
  matrix:((til count raggedList)#'0.),'.5,'raggedList;
  matrix+flip matrix
  }

// @private
// @kind data
// @category nlpUtility
// @desc Parts-of-speech not useful as keywords
// @type symbol[]
i.stopUniPOS:asc`ADP`PART`AUX`CONJ`DET`SYM`NUM`PRON`SCONJ
i.stopPennPOS:asc`CC`CD`DT`EX`IN`LS`MD`PDT`POS`PRP`SYM`TO`WDT`WP`WRB`,
  `$("PRP$";"WP$";"$")

// @private
// @kind function
// @category nlpUtility
// @desc Get the count of individual terms in a corpus
// @param parsedTab {table} A parsed document containing keywords and their
//   associated significance scores
// @returns {dictionary} The count of terms in the corpus
i.getTermCount:{[parsedTab]
  tokens:parsedTab[`tokens]@'where each not parsedTab`isStop;
  i.fastSum{1+log count each group x}each tokens
  }

// @kind function
// @category nlpUtility
// @desc Calculate the probability of words appearing in a text
// @param tokens {symbol[]} The tokens in the text
// @param occurance {dictionary} The total times a token appears in the text
// @param token {symbol} A single token
// @param nextToken {symbol} The next token in the list of tokens
// @returns {dictionary} The probability that the secondary word in the
//   sequence follows the primary word.
i.biGram:{[tokens;occurance;token;nextToken]
  returnKeys:enlist(token;nextToken);
  countToken:count where nextToken=tokens 1+where token=tokens;
  returnVals:countToken%occurance[token];
  returnKeys!enlist returnVals
  }
