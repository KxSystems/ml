\d .ml

// Cross validation, grid/random/Sobol-random hyperparameter search and multi-
//   processing procedures

// Cross validation

// @kind function
// @category xv
// @fileoverview Cross validation for ascending indices split into k-folds
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the k-folds
xv.kfsplit:xv.i.applyidx xv.i.idxR . xv.i`splitidx`groupidx

// @kind function
// @category xv
// @fileoverview Cross validation for randomized non-repeating indices split 
//   into k-folds
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the k-folds
xv.kfshuff:xv.i.applyidx xv.i.idxN . xv.i`shuffidx`groupidx

// @kind function
// @category xv
// @fileoverview Stratified k-fold cross validation with an approximately equal
//   distribution of classes per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the k-folds
xv.kfstrat:xv.i.applyidx xv.i.idxN . xv.i`stratidx`groupidx

// @kind function
// @category xv
// @fileoverview Roll-forward cross validation procedure
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the chained 
//   iterations
xv.tsrolls:xv.i.applyidx xv.i.idxR . xv.i`splitidx`tsrollsidx

// @kind function
// @category xv
// @fileoverview Chain-forward cross validation procedure
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the chained 
//   iterations
xv.tschain:xv.i.applyidx xv.i.idxR . xv.i`splitidx`tschainidx

// @kind function
// @category xv
// @fileoverview Percentage split cross validation procedure
// @param pc {float} (0-1) representing the percentage of validation data
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the k-folds
xv.pcsplit:xv.i.applyidx{[pc;n;features;target]
  split:{[pc;x;y;z](x;y)@\:/:(0,floor n*1-pc)_til n:count y};
  n#split[pc;features;target]
  }

// @kind function
// @category xv
// @fileoverview Monte-Carlo cross validation using randomized non-repeating 
//   indices
// @param pc {float} (0-1) representing the percentage of validation data
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function which takes data as input
// @return {#any} Output of function applied to each of the k-folds
xv.mcsplit:xv.i.applyidx{[pc;n;features;target]
  split:{[pc;x;y;z](x;y)@\:/:(0,floor count[y]*1-pc)_{neg[n]?n:count x}y};
  n#split[pc;features;target]
  }

// @kind function
// @category xv
// @fileoverview Default scoring function used in conjunction with .ml.xv/gs/rs
//   methods
// @param function {func} Takes empty list, parameters and data as input
// @param p {dict} Hyperparameters
// @param data {#any[][]} ((xtrain;xtest);(ytrain;ytest)) format
// @return {float[]} Scores outputted by function applied to p and data
xv.fitscore:{[function;p;data]
  fitFunc:function[][p]`:fit;
  scoreFunc:.[fitFunc;numpyArray each data 0]`:score;
  .[scoreFunc;numpyArray each data 1]`
  }

// Hyperparameter search procedures

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to data with 
//   ascending split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input 
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfsplit:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.kfsplit]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to data with 
//   shuffled split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfshuff:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.kfshuff]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to data with an 
//   equi-distributions of targets per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.kfstrat:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.kfstrat]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to roll forward 
//   time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.tsrolls:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.tsrolls]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to chain forward 
//   time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.tschain:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.tschain]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to percentage 
//   split dataset
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.pcsplit:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.pcsplit]

// @kind function
// @category gs
// @fileoverview Cross validated parameter grid search applied to randomly 
//   shuffled data and validated on a percentage holdout set
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
gs.mcsplit:hp.i.search hp.i.xvpf[hp.i.gsgen;xv.mcsplit]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to data with
//   ascending split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfsplit:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.kfsplit]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to data with 
//   shuffled split indices
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfshuff:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.kfshuff]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to data with 
//   an equi-distributions of targets per fold
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.kfstrat:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.kfstrat]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to roll 
//   forward time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.tsrolls:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.tsrolls]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to chain 
//   forward time-series sets
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.tschain:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.tschain]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to percentage 
//   split dataset
// @param pc {float} (0-1) representing percentage of validation data
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.pcsplit:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.pcsplit]

// @kind function
// @category rs
// @fileoverview Cross validated parameter random search applied to randomly 
//   shuffled data and validated on a percentage holdout set
// @param pc {float} (0-1) representing percentage of validation data
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {func} Function that takes parameters and data as input
//   and returns a score
// @param p {dict} Dictionary of hyperparameters to be searched with 
//   format `typ`random_state`n`p where typ is the type of search 
//   (random/sobol), random_state is the seed, n is the number of 
//   hyperparameter sets and p is a dictionary of parameters - see 
//   documentation for more info.
// @param tsttyp {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Scores for hyperparameter sets on each of
//   the k folds for all values of h and additionally returns the best 
//   hyperparameters and score on the holdout set for 0 < h <=1.
rs.mcsplit:hp.i.search hp.i.xvpf[hp.i.rsgen;xv.mcsplit]

// Multi-processing functionality

//  Load multi-processing modules
loadfile`:util/mproc.q
loadfile`:util/pickle.q

//  If multiple processes are available, multi-process cross validation library
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:util/pickle.q"];
xv.picklewrap:{picklewrap[(0>system"s")&.p.i.isw x]x}
