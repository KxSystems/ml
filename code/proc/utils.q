\d .automl

// The following naming convention holds throughout this file
/* mdl = the model being applied from within the module as a symbol
/* fn  = name of a file as a string
/* fp  = file path relative to .automl.path as a string

// Utilities for proc.q

// Text files that can be parsed from within the models folder
proc.i.files:`class`reg`score!("models/classmodels.txt";"models/regmodels.txt";"scoring/scoring.txt")

// Build up the model to be applied based on naming convention
/* lib = library which forms the basis for the definition
/* fnc = function name if keras or module from which model is derived for keras
/. r   > the appropriate function or projection in the case of sklearn
proc.i.mdlfunc:{[lib;fnc;mdl]
  $[lib in `keras`pytorch;
    // retrieve keras model from the .automl namespace eg '.automl.regfitscore'
    proc.i.fitscore;
    // construct the projection used for sklearn models eg '.p.import[`sklearn.svm][`:SVC]'
    {[x;y;z].p.import[x]y}[` sv lib,fnc;hsym mdl]]}

proc.i.fitscore:{[d;s;mtype]
  // encode multi-class labels appropriately
  if[mtype~`multi;
    d[;1]:npa@'flip@'./:[;((::;0);(::;1))](0,count d[0]1)_/:value .ml.i.onehot1(,/)d[;1]];
  m:get[".automl.",string[mtype],"mdl"][d;s;mtype];
  m:get[".automl.",string[mtype],"fit"][d;m];
    get[".automl.",string[mtype],"predict"][d;m]}

// Update models available for use based on the number of rows in the data set
/* mdls = table defining models which are to be applied to the dataset
/* tgt  = target vector
/. r    > model table with appropriate models removed if needed and model removal highlighted
proc.i.updmodels:{[mdls;tgt]
 $[10000<count tgt;
   [-1"\nLimiting the models being applied due as the number targets exceeds 100,000";
    -1"No longer running neural nets or svms\n";
    select from mdls where(lib<>`keras),not fnc in`neural_network`svm];mdls]}

// Utilities for xvgs.q

// parse the hyperparameter flatfile
/. r  > dict mapping model name to possible hyper parameters
proc.i.paramparse:{[fn;fp]key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,fp,fn}

// The following two functions together extract the hyperparameter dictionaries
// based on the applied model
/. r   > the hyperparameters appropriate for the model being used
proc.i.extractdict:{[bm;p]
  // get grid/random hyperparameter file name
  fn:$[`grid=p`hp;[hptyp:`gs;"grid"];p[`hp]in`random`sobol;[hptyp:`rs;"random"];'"unsupported hyperparameter generation method"];
  // load in table of hyperparameters to dictionary with (hyperparameter!values)
  system"l ",path,"/code/models/hyper_parameters/",fn,"_hyperparameters.q";
  (hptyp;h[`hyperparams]!(h:hyperparams bm)`values)}

// Utilities for both scripts

// Extraction of an appropriately valued dictionary from a non complex flat file
/* sn = name mapping to appropriate text file in, as a symbol
/. r  > dictionary parsed from an appropriate flat file
proc.i.txtparse:{[sn;fp]{key(!).("S=;")0:x}each(!).("S*";"|")0:hsym`$path,fp,proc.i.files sn}

// Extract the appropriate ordering of output scores to allow the best model to be chosen
// these are defined in "scoring.txt"
/* scf = scoring function
/. r   > the function to order the dictionary output from cross validation search (asc/desc)
proc.i.ord:{[scf]get string first proc.i.txtparse[`score;"/code/models/"]scf}