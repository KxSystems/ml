\d .automl

// Run cross validated machine learning models on training data and choose the best model.
/* t     = table of features as output from preprocessing pipeline/feature extraction
/* tgt   = target data
/* mdls  = appropriate models from `.automl.proc.models` above
/* cnms  = column names for all columns required to be shuffled for feature impact
/* p     = parameter dictionary passed as default or modified by user
/* dt    = date and time that the run was initialized (this is used in the feature impact function) 
/* fpath = file paths for saving down information
/. r     > all relevant information about the running of the sets of models
/.         1. average score for all models;  2. name of best scoring model; 3. score of best model on holdout
/.         3. time for cross validation run; 4. time to complete fit, predict and score with best model
/.         5. scoring function used; 6. embedpy model which produced the best score
proc.runmodels:{[data;tgt;mdls;cnms;p;dt;fpath]
  system"S ",string p`seed;
  // Apply train test split to keep holdout for feature impact plot and testing of vanilla best model
  tt:p[`tts][data;tgt;p`hld];
  xtrn:tt`xtrain;ytrn:tt`ytrain;xtst:tt`xtest;ytst:tt`ytest;
  mdls:i.kerascheck[mdls;tt;tgt];
  xv_tstart:.z.T;
  // Complete a seeded cross validation on training sets producing the predictions with associated 
  // real values. This allows the best models to be chosen based on relevant user defined metric 
  p1:proc.xv.seed[xtrn;ytrn;p]'[mdls];
  scf:i.scfn[p;mdls];
  ord:proc.i.ord scf;
  -1"\nScores for all models, using ",string scf;
  // Score the models based on user denoted scf and ordered appropriately to find best model
  show s1:ord mdls[`model]!avg each scf .''p1;
  xv_tend:.z.T-xv_tstart;
  -1"\nBest scoring model = ",string bs:first key s1;
  // Extract the best model, fit on entire training set and predict/score on test set
  // for the appropriate scoring function
  bm_tstart:.z.T;
  $[bs in i.keraslist;
    [data:((xtrn;ytrn);(xtst;ytst));
     funcnm:string first exec fnc from mdls where model=bs;
     if[funcnm~"multi";data[;1]:npa@'reverse flip@'./:[;((::;0);(::;1))](0,count ytst)_/:
       value .ml.i.onehot1(,/)(ytrn;ytst)];
     kermdl:get[".automl.",funcnm,"mdl"][data;p`seed;`$funcnm];
     bm:get[".automl.",funcnm,"fit"][data;kermdl];
     s2:scf[;ytst]get[".automl.",funcnm,"predict"][data;bm]];
    [bm:(first exec minit from mdls where model=bs)[][];
     bm[`:fit][xtrn;ytrn];
     s2:scf[;ytst]bm[`:predict][xtst]`]
    ];
  -1"Score for validation predictions using best model = ",string[s2],"\n";
  bm_tend:.z.T-bm_tstart;
  // Feature impact graph produced on holdout data if setting is appropriate
  if[2=p[`saveopt];post.featureimpact[bs;(bm;mdls);value tt;cnms;scf;dt;fpath;p]];
  // Outputs from run models. These are used in the generation of a pdf report
  // or are used within later sections of the pipeline.
  (s1;bs;s2;xv_tend;bm_tend;scf;bm)}
