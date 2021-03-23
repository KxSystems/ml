// xval/xval.q - Cross validation
// Copyright (c) 2021 Kx Systems Inc
//
// Cross validation, grid/random/Sobol-random hyperparameter search and multi-
// processing procedures

\d .ml

// @kind function
// @category xv
// @desc Cross validation for ascending indices split into k-folds
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the k-folds
xv.kfSplit:xv.i.applyIdx xv.i.idxR . xv.i`splitIdx`groupIdx

// @kind function
// @category xv
// @desc Cross validation for randomized non-repeating indices split 
//   into k-folds
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the k-folds
xv.kfShuff:xv.i.applyIdx xv.i.idxN . xv.i`shuffIdx`groupIdx

// @kind function
// @category xv
// @desc Stratified k-fold cross validation with an approximately equal
//   distribution of classes per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the k-folds
xv.kfStrat:xv.i.applyIdx xv.i.idxN . xv.i`stratIdx`groupIdx

// @kind function
// @category xv
// @desc Roll-forward cross validation procedure
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the chained 
//   iterations
xv.tsRolls:xv.i.applyIdx xv.i.idxR . xv.i`splitIdx`tsRollsIdx

// @kind function
// @category xv
// @desc Chain-forward cross validation procedure
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the chained 
//   iterations
xv.tsChain:xv.i.applyIdx xv.i.idxR . xv.i`splitIdx`tsChainIdx

// @kind function
// @category xv
// @desc Percentage split cross validation procedure
// @param pc {float} (0-1) representing the percentage of validation data
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the k-folds
xv.pcSplit:xv.i.applyIdx{[pc;n;features;target]
  split:{[pc;x;y;z](x;y)@\:/:(0,floor n*1-pc)_til n:count y};
  n#split[pc;features;target]
  }

// @kind function
// @category xv
// @desc Monte-Carlo cross validation using randomized non-repeating 
//   indices
// @param pc {float} (0-1) representing the percentage of validation data
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {any} Output of function applied to each of the k-folds
xv.mcSplit:xv.i.applyIdx{[pc;n;features;target]
  split:{[pc;x;y;z](x;y)@\:/:(0,floor count[y]*1-pc)_{neg[n]?n:count x}y};
  n#split[pc;features;target]
  }

// @kind function
// @category xv
// @desc Default scoring function used in conjunction with .ml.xv/gs/rs
//   methods
// @param function {fn} Takes empty list, parameters and data as input
// @param p {dictionary} Hyperparameters
// @param data {any[][]} ((xtrain;xtest);(ytrain;ytest)) format
// @return {float[]} Scores outputted by function applied to p and data
xv.fitScore:{[function;p;data]
  fitFunc:function[][p]`:fit;
  scoreFunc:.[fitFunc;numpyArray each data 0]`:score;
  .[scoreFunc;numpyArray each data 1]`
  }

// Hyperparameter search procedures

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to data with 
//   ascending split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input 
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on 
//   each of the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfSplit:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.kfSplit]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to data with 
//   shuffled split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfShuff:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.kfShuff]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to data with an 
//   equi-distributions of targets per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfStrat:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.kfStrat]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to roll forward 
//   time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.tsRolls:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.tsRolls]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to chain forward 
//   time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.tsChain:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.tsChain]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to percentage 
//   split dataset
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.pcSplit:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.pcSplit]

// @kind function
// @category gs
// @desc Cross validated parameter grid search applied to randomly 
//   shuffled data and validated on a percentage holdout set
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.mcSplit:hp.i.search hp.i.xvScore[hp.i.gsGen;xv.mcSplit]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to data with
//   ascending split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfSplit:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.kfSplit]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to data with 
//   shuffled split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfShuff:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.kfShuff]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to data with 
//   an equi-distributions of targets per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfStrat:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.kfStrat]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to roll 
//   forward time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.tsRolls:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.tsRolls]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to chain 
//   forward time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.tsChain:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.tsChain]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to percentage 
//   split dataset
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.pcSplit:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.pcSplit]

// @kind function
// @category rs
// @desc Cross validated parameter random search applied to randomly 
//   shuffled data and validated on a percentage holdout set
// @param pc {float} (0-1) representing percentage of validation data
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {any[][]} Matrix of features
// @param target {any[]} Vector of targets
// @param function {fn} Function that takes parameters and data as input
//   and returns a score
// @param p {dictionary} Dictionary of hyperparameters to be searched with 
//   format `typ`randomState`n`p where typ is the type of search 
//   (random/sobol), randomState is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tstTyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table|list} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.mcSplit:hp.i.search hp.i.xvScore[hp.i.rsGen;xv.mcSplit]

// Multi-processing functionality

//  Load multi-processing modules
loadfile`:util/mproc.q
loadfile`:util/pickle.q

//  If multiple processes are available, multi-process cross validation library
if[0>system"s";multiProc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];
xv.picklewrap:{picklewrap[(0>system"s")&.p.i.isw x]x}
