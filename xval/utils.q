\d .ml

// Utilities for cross validation library

// Cross validation indexing

// @private
// @kind function
// @category xvUtility
// @fileoverview Shuffle data point indices
// @param data {#any} Table, matrix or list
// @return {long[]} Indices of data shuffled
xv.i.shuffle:{[data]
  0N?count data
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Find indices required to split data into k-folds
// @param k {int} Number of folds
// @param data {#any} Table, matrix or list
// @return {long[][]} Indices required to split data into k sub-sets
xv.i.splitIdx:{[k;data]
  (k;0N)#til count data
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Find shuffled indices required to split data into k-folds
// @param k {int} Number of folds
// @param data {#any} Table, matrix or list
// @return {long[][]} Shuffled indices required to split data into k 
//   sub-sets
xv.i.shuffIdx:{[k;data]
  (k;0N)#xv.i.shuffle data
  }

// @private
// @kind function 
// @category xvUtility
// @fileoverview Split target data ensuring that each distinct value appears in
//   each fold
// @param k {int} Number of folds
// @param data {#any} Table, matrix or list
// @return {long[][]} Data split into k-folds with distinct values 
//   appearing in each
xv.i.stratIdx:{[k;data]
  // Find indices for each distinct group
  idx:group data;
  // Shuffle/split groups into folds with distinct groups present in each fold
  fold:(,'/)(k;0N)#/:value idx@'xv.i.shuffle each idx;
  // Shuffle each fold
  fold@'xv.i.shuffle each fold
  }

// @private
// @kind function 
// @category xvUtility
// @fileoverview Get training and testing indices for each fold
// @param k {int} Number of folds
// @return {long[][]} Training and testing indices for each fold
xv.i.groupIdx:{[k]
  (0;k-1)_/:rotate[-1]\[til k]
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Get training/testing indices for equi-distanced bins of data 
//   across k-folds
// @param k {int} Number of folds
// @return {long[][]} Indices for equi-distanced bins of data based on k
xv.i.tsRollsIdx:{[k]
  enlist@''0 1+/:til k-1
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Get training/testing indices for equi-distanced bins of data 
//   across k-folds with increasing amounts of data added to the training set 
//   at each stage
// @param k {int} Number of folds
// @return {long[][]} Indices for equi-distanced bins of data based on k
xv.i.tsChainIdx:{[k]
  flip(til each j;enlist@'j:1+til k-1)
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Creates projection contining data split according to k
//   in ((xtrain;ytrain);(xtest;ytest)) format for each fold
// @param func1 {func} Function to be applied to x data
// @param func2 {func} Function to be applied to k
// @param k {int} Number of folds
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @return {func} Projection of data split per fold
xv.i.idx1:{[func1;func2;k;features;target]
  dataSplit:flip@'((features;target)@/:\:func1[k;target])@\:/:func2 k;
  {{raze@''y}[;x]}each dataSplit
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Creates projection contining data split according to k
//   in ((xtrain;ytrain);(xtest;ytest)) format for each fold
// @param func1 {func} Function to be applied to x data
// @param func2 {func} Function to be applied to k
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @return {func} Projection of data split per fold
xv.i.idxR:{[func1;func2;k;n;features;target]
  n#enlist xv.i.idx1[func1;func2;k;features;target]
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Creates projection contining data split according to k
//   in ((xtrain;ytrain);(xtest;ytest)) format for each fold
// @param func1 {func} Function to be applied to x data
// @param func2 {func} Function to be applied to k
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @return {func} Projection of data split per fold
xv.i.idxN:{[func1;func2;k;n;features;target]
  xv.i.idx1[func1;func2;;features;target]@'n#k
  }

// @private
// @kind function
// @category xvUtility
// @fileoverview Apply funct to data split using specified indexing functions
// @param idx {long[][]} Indicies to apply to data
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param function {fn} Function which takes data as input
// @return {#any} Output of func with idx applied to data
xv.i.applyIdx:{[idx;k;n;features;target;function]
  splitData:raze idx[k;n;features;target];
  {[function;data]function data[]}[function]peach splitData
  }

// Python utilities required for xval.q

// @private
// @kind function
// @category xvUtility
// @fileoverview Convert q list to numpy array
// @param x {#any[]} q list to be converted
// @return {<} embedPy object following numpy array conversion
numpyArray:.p.import[`numpy]`:array

// Hyperparameter search functionality

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Perform hyperparameter generation and cross validation
// @param paramFunc {func} Parameter function
// @param xvalFunc {fn} Cross validation function
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param dataFunc {func} Function which takes data as input
// @param hyperparams {dict} Hyperparameters
// @return {table} Cross validation scores for each hyperparameter set
hp.i.xvScore:{[paramFunc;xvalFunc;k;n;features;target;dataFunc;hyperparams]
  // Generate hyperparameter sets
  hyperparams:paramFunc hyperparams;
  // Perform cross validation for each set
  hyperparams!(xvalFunc[k;n;features;target]dataFunc pykwargs@)@'hyperparams
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Hyperparameter search with option to test final model 
// @param scoreFunc {func} Scoring function
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param dataFunc {func} Function which takes data as input
// @param hyperparams {dict} Dictionary of hyperparameters
// @param testType {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Either validation or testing results from 
//   hyperparameter search with (full results;best set;testing score)
hp.i.search:{[scoreFunc;k;n;features;target;dataFunc;hyperparams;testType]
  if[testType=0;:scoreFunc[k;n;features;target;dataFunc;hyperparams]];
  idxTarget:$[testType<0;xv.i.shuffle;til count@]target;
  i:(0,floor count[target]*1-abs testType)_ idxTarget;
  r:scoreFunc[k;n;features i 0;target i 0;dataFunc;hyperparams];
  res:dataFunc[pykwargs pr:first key desc avg each r](features;target)@\:/:i;
  (r;pr;res)
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Hyperparameter generation for .ml.gs
// @param hyperparams {dict} Hyperparameters with all possible values for a
//   given parameter specified by the user, e.g.
//   pdict = `random_state`max_depth!(42 72 84;1 3 4 7)
// @return {table} All possible hyperparameter sets
hp.i.gsGen:{[hyperparams]
  key[hyperparams]!/:1_'(::)cross/value hyperparams
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Hyperparameter generation for .ml.rs
// @param params {dict} Parameters with form `random_state`n`typ`p where 
//   random_state is the seed, n is the number of hyperparameters to generate 
//   (must equal 2^n for sobol), typ is the type of search (random/sobol) and p
//   is a dictionary of hyperparameter spaces - see documentation for more info
// @return {tab} Hyperparameters
hp.i.rsGen:{[params]
  // Set default number of trials
  if[(::)~n:params`n;n:16];
  // Check sobol trials = 2^n
  if[(`sobol=params`typ)&k<>floor k:xlog[2]n;
    '"trials must equal 2^n for sobol search"
    ];
  // Find numerical hyperparameter spaces
  num:where any`uniform`loguniform=\:first each p:params`p;
  // Set random seed
  system"S ",string$[(::)~params`random_state;42;params`random_state];
  // Import sobol sequence generator and check requirements
  pySobol:.p.import[`sobol_seq;`:i4_sobol_generate;<];
  genPts:$[`sobol~typ:params`typ;
      enlist each flip pySobol[count num;n];
    `random~typ;
      n;
    '"hyperparam type not supported"
    ];
  // Generate hyperparameters
  hyperparams:distinct flip hp.i.hpGen[typ;n]each p,:num!p[num],'genPts;
  // Take distinct sets
  if[n>dst:count hyperparams;
    -1"Distinct hp sets less than n - returning ",string[dst]," sets."
    ];
  hyperparams
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Random/sobol hyperparameter generation for .ml.rs
// @param randomType {sym} Type of random search, denoting the namespace to use
// @param n {long} Number of hyperparameter sets
// @param params {dict} Parameters
// @return {#any} Hyperparameters
hp.i.hpGen:{[randomType;n;params]
  // Split parameters
  params:@[;0;first](0;1)_params,();
  // Respective parameter generation
  $[(typ:params 0)~`boolean;n?0b;
    typ in`rand`symbol;
      n?(),params[1]0;
    typ~`uniform;
      hp.i.uniform[randomType]. params 1;
    typ~`loguniform;
      hp.i.logUniform[randomType]. params 1;
    '"please enter a valid type"
    ]
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Uniform number generator 
// @param randomType {sym} Type of random search, denoting the namespace to use
// @param low {long} Lower bound
// @param high {long} Higher bound
// @param paramType {char} Type of parameter, e.g. "i", "f", etc
// @param params {num[]} Parameters
// @return {num[]} Uniform numbers
hp.i.uniform:{[randomType;low;high;paramType;params]
  if[high<low;'"upper bound must be greater than lower bound"];
  hp.i[randomType][`uniform][low;high;paramType;params]
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Generate list of log uniform numbers
// @param randomType {sym} Type of random search, denoting the namespace to use
// @param low {num} Lower bound as power of 10
// @param high {num} Higher bound as power of 10
// @param paramType {char} Type of parameter, e.g. "i", "f", etc
// @param params {num[]} Parameters
// @return {num[]} Log uniform numbers
hp.i.logUniform:xexp[10]hp.i.uniform::

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Random uniform generator
// @param low {num} Lower bound as power of 10
// @param high {num} Higher bound as power of 10
// @param paramType {char} Type of parameter, e.g. "i", "f", etc
// @param n {long} Number of hyperparameter sets
// @return {num[]} Random uniform numbers
hp.i.random.uniform:{[low;high;paramType;n]
  low+n?paramType$high-low
  }

// @private
// @kind function
// @category hyperparameterUtility
// @fileoverview Sobol uniform generator
// @param low {num} Lower bound as power of 10
// @param high {num} Higher bound as power of 10
// @param paramType {char} Type of parameter, e.g. "i", "f", etc
// @param sequence {float[]} Sobol sequence
// @return {num[]} Uniform numbers from sobol sequence
hp.i.sobol.uniform:{[low;high;paramType;sequence]
  paramType$low+(high-low)*sequence
  }
