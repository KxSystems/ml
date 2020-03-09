\d .automl

// The following parameters are used through this file and are outlined here to avoid duplication
/* xtrn = Training features (matrix)
/* ytrn = Training target (vector)
/* p    = parameter dictionary passed as default or modified by user
/* mdls = appropriate models as produced using `.automl.proc.models`


// Seeded cross-validation function, designed to ensure that models will be consistent
// from run to run in order to accurately assess the benefit of updates to parameters
/. r > predictions and associated actual values for each cross validation fold
proc.xv.seed:{[xtrn;ytrn;p;mdls]
  sk:mdls[`lib]~`sklearn;
  system"S ",string p`seed;
  // Add a random state to a model if denoted by the flat file definition of the models
  // this needs to be handled differently for sklearn and keras models
  s:$[ms:mdls[`seed]~`seed;
      $[sk;enlist[`random_state]!enlist p`seed;(p[`seed],mdls[`typ])];
      ::];
  $[ms&sk;
    // Grid search version of the cross-validation is completed if a random seed
    // and the model is from sklearn, this is in order to incorporate the random state definition.
    // Final parameter upd was required as dict for grid search to be as flexible as possible
    first value get[p[`gs]0][p[`gs]1;1;xtrn;ytrn;p[`prf]mdls`minit;s;enlist[`val]!enlist 0];
    // Otherwise a vanilla cross validation is performed
    get[p[`xv]0][p[`xv]1;1;xtrn;ytrn;p[`prf][mdls`minit;s]]]}


// Grid search over the set of all hyperparameters outlined in code/models/hyperparams.txt
/* xtst = Testing features (matrix)
/* ytst = Testing target (vector)
/* bm   = name of the best model as on which a grid search should be completed as a symbol
/*        derived from initial cross validation
/* typ  = type of the problem being solved, this can be either `class or `reg
/. r    > a mixed list containing:
/.        1. the score achieved for the best model; 2. the hyperparameters from the best model
/.        3. the fitted best model; 4. predicted values based on testing set
proc.gs.psearch:{[xtrn;ytrn;xtst;ytst;bm;p;typ;mdls]
  dict:proc.i.extractdict[bm];
  // Extract the required sklearn module name
  module:` sv 2#proc.i.txtparse[typ;"/code/models/"]bm;
  fn:i.scfn[p;mdls];
  o :proc.i.ord fn;
  // Import the required embedPy module
  epymdl:.p.import[module][hsym bm];
  // Projection for fitting and prediction grid search
  fitpred:gs.fitpredict[get fn]{y;x}[epymdl;];
  // Split the training data into a representation of the breakdown of data for the grid search.
  // This is used to ensure that if a grid search is done on KNN that there are sufficient,
  // data points in the validation set for all hyperparameter nearest neighbour calculations.
  spltcnt:$[p[`gs;0]in`mcsplit`pcsplit;1-p[`gs]1;(p[`gs;1]-1)%p[`gs]1]*count[xtrn]*1-p`hld;
  if[bm in `KNeighborsClassifier`KNeighborsRegressor;
    if[0<count where n:spltcnt<dict`n_neighbors;
      dict[`n_neighbors]@:where not n]];
  // Complete an appropriate grid search, returning scores for each validation fold
  bm:first exec minit from mdls where model=bm;
  // modification of final grid search parameter required to allow modified
  // results ordering and function definition to take place
  gsprms:get[p[`gs]0][p[`gs]1;1;xtrn;ytrn;p[`prf]bm;dict;`val`ord`scf!(p`hld;o;fn)];
  // Extract the best hyperparameter set based on scoring function
  hyp:first key first gsprms;
  bmdl:epymdl[pykwargs hyp][`:fit][xtrn;ytrn];
  pred:bmdl[`:predict][xtst]`;
  score:fn[pred;ytst];
  (score;hyp;bmdl;pred)
  }


// Defaulted fitting and prediction functions for automl cross-validation and grid search,
// both models fit on a training set and return the predicted scores based on supplied
// scoring function.
/* f  = function taking in parameters and data as input, returns appropriate score
/* hp = dictionary of hyperparameters on which to complete hyperparameter search
/* d  = data as a list of ((xtrn;ytrn);(xval;yval)), this structure is defined from the data
/*      within the cross-validation/grid search procedures from the xtrain and ytrain data supplied

/. r > The value predicted on the validation set and the true value
xv.fitpredict:{[f;hp;d]($[0h~type hp;f[d;hp[0];hp[1]];@[.[f[][hp]`:fit;d 0]`:predict;d[1]0]`];d[1]1)}

/* fn = The scoring function which is to be used for evaluating the performance of the grid search
/. r  > The score achieved for each cross validation set based on the user defined scoring function
gs.fitpredict:{[fn;f;hp;d]fn . xv.fitpredict[f;hp;d]}
