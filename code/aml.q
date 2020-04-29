\d .automl

// The functions contained in this file are all those that are expected to be executable
// by a user, this includes the function to run the full pipeline and one for running on new data

// This is a prototype of the workflow for the automated machine learning pipeline
/* tb    = input table
/* tgt   = target vector
/* ftype = type of feature extraction being completed (`fresh/`normal)
/* ptype = type of problem regression/class (`reg/`class)
/* p     = parameters (::) produces default other changes are user dependent dict/flat-file
/. r     > returns date and time of run
run:{[tb;tgt;ftype;ptype;p]
  dtdict:`stdate`sttime!(.z.D;.z.T);
  // Extract & update the dictionary used to define the workflow
  dict:i.updparam[tb;p;ftype],enlist[`typ]!enlist ftype;
  // Check that the functions to overwrite default behaviour exist in process
  i.checkfuncs[dict];
  // update the seed based on time of day if user does not specify the seed in p
  if[`rand_val~dict[`seed];dict[`seed]:"j"$.z.t];
  // if required to save data construct the appropriate folders
  if[dict[`saveopt]in 1 2;spaths:i.pathconstruct[dtdict;dict`saveopt]];
  // dictionaries allowing parameters and values to be assigned throughout this function
  // this ensures that the number of local variables does not exceed allowed levels
  params:()!();
  vals:()!();
  params[`mdls]:i.models[ptype;tgt;dict];
  system"S ",string dict`seed;
  tb:prep.i.autotype[tb;ftype;dict];
  -1 i.runout`col;
  // This provides an encoding map which can be used in reruns of automl even
  // if the data is no longer in the appropriate format for symbol encoding
  params[`symencode]:prep.i.symencode[tb;10;1;dict;::];
  // Encode target data if target is a symbol vector
  if[11h~type tgt;tgt:.ml.labelencode tgt];
  // Preprocess the dataset and provide insights into initial data structure
  prep:preproc[tb;tgt;ftype;dict];
  tb:prep`table;
  params[`describe]:prep`describe;
  -1 i.runout`pre;
  tb:prep.create[tb;dict;ftype];
  // assign the returned values from the feature extraction phase
  vals[`feat_tab]:tb`preptab;
  params[`feat_time]:tb`preptime;
  params[`features]:get[dict[`sigfeats]][vals`feat_tab;tgt];
  // Apply the appropriate train/test split to the data
  // the following currently runs differently if the parameters are defined
  // in a file or through the more traditional dictionary/(::) format
  tts:($[-11h=type dict`tts;get;]dict[`tts])[;tgt;dict`sz]tab:params[`features]#vals`feat_tab;
  // Centralizing the table to matrix conversion makes it easier to avoid
  // repetition of this task which can be computationally expensive
  vals[`xtrn]:flip value flip tts`xtrain;vals[`xtst]:flip value flip tts`xtest;
  vals[`ytrn]:tts`ytrain;vals[`ytst]:tts`ytest;
  params[`mdls]:i.kerascheck[params`mdls;tts;tgt];
  // Check if Tensorflow/Keras not available for use, NN models removed
  if[1~checkimport[];params[`mdls]:?[params`mdls;enlist(<>;`lib;enlist `keras);0b;()]];
  -1 i.runout`sig;-1 i.runout`slct;
  -1 i.runout[`tot],string[params[`cnt_feats]:count cols tab];
  // Set numpy random seed if multiple prcoesses
  if[0<abs[system "s"];.p.import[`numpy][`:random.seed][dict`seed]];
  // Run the initial model selection procedure
  bm:proc.runmodels[vals`xtrn;vals`ytrn;params`mdls;cols tts`xtrain;dict;dtdict;spaths];
  // extract information to be used in this function
  params[`best_scoring_name]:bm`best_scoring_name;
  vals[`best_mdl]:bm`best_model;
  data:vals`xtrn`ytrn`xtst`ytst;
  // Run optimization procedure or finalize models in case of deterministic models
  optim:proc.optimize[data;dict;ptype;;;vals`best_mdl]. params`mdls`best_scoring_name;
  vals[`best_mdl]:optim`best_model;
  params[`test_score]:optim`score;
  params[`pred]:optim`preds;
  -1 i.runout[`sco],string[params`test_score],"\n";
  // Print confusion matrix for classification problems
  if[(ptype~`class);post.confmat[;vals`ytst;;spaths;dict]. params`pred`best_scoring_name];
  // Set up required information for saving and save as appropriate
  hp:$[params[`best_scoring_name]in i.excludelist;()!();enlist[`hyper_params]!enlist optim`hyper_params];
  dict:params,hp,dict;
  if[dict[`saveopt] = 2;
    post.save_report[;spaths;ptype;dtdict]post.i.reportdict[dict;bm;spaths]];
  if[dict[`saveopt]in 1 2;
    post.save_info[;dict;;vals`best_mdl;spaths;dtdict]. params`mdls`best_scoring_name];
  // return (date;time) for .automl.new
  value dtdict
  }


// Function for the processing of new data based on a previous run and return of predicted target
/* t = table of new data to be predicted
/* dt = run date as date (yyyy.mm.dd) or string (format "yyyy.mm.dd")
/* tm = run timestamp as timestamp (hh:mm:ss.xxx) or string (format "hh:mm:ss.xxx"/"hh.mm.ss.xxx")
/. r  > returns new predictions
new:{[t;dt;tm]
  // check date and time input
  dt_tm:i.new_datetime[dt;tm];
  // get file path
  fp:dt_tm[0],"/run_",dt_tm 1;
  // Relevant python functionality for loading of models
  skload:.p.import[`joblib][`:load];
  if[0~checkimport[];krload:.p.import[`keras.models][`:load_model]];
  // Retrieve the metadata from a file path based on the run date/time
  metadata:i.getmeta[i.ssrwin[path,"/outputs/",fp,"/config/metadata"]];
  typ:metadata`typ;
  data:$[`normal=typ;
    i.normalproc[t;metadata];
    `fresh=typ;
    i.freshproc[t;metadata];
    '`$"This form of operation is not currently supported"
    ];
  $[(mp:metadata[`pylib])in `sklearn`keras;
    // Apply the relevant saved down model to new data
    [fp_upd:i.ssrwin[path,"/outputs/",fp,"/models/",string metadata[`best_scoring_name]];
     if[bool:(mdl:metadata[`best_scoring_name])in i.keraslist;fp_upd,:".h5"];
     model:$[mp~`sklearn;skload;krload]fp_upd;
     $[bool;
       [fnm:neg[5]_string lower mdl;get[".automl.",fnm,"predict"][(0n;(data;0n));model]];
       model[`:predict;<]data]];
    '`$"The current model type you are attempting to apply is not currently supported"]
  }


// Saves down flatfile of default dict
/* fn    = filename as string, symbol or hsym
/* ftype = type of feature extraction, e.g. `fresh or `normal
/. r     > flatfile of representing default dictionary saved to code/models
savedefault:{[fn;ftype]
  // Check type of filename and convert to string
  fn:$[10h~typf:type fn;fn;
      -11h~typf;$[":"~first strf;1_;]strf:string typf;
      '`$"filename must be string, symbol or hsym"];
  // Open handle to file fn
  h:hopen hsym`$i.ssrwin[raze[path],"/code/models/",fn];
  // Set d to default dictionary for feat_typ
  d:$[`fresh ~ftype;i.freshdefault[];
      `normal~ftype;i.normaldefault[];
      '`$"feature extraction type not supported"];
  // String values for file
  vals:{$[1=count x;
            string x;
          11h~abs typx:type x;
            ";"sv{raze$[1=count x;y;"`"sv y]}'[x;string x];
          99h~typx;
            ";"sv{string[x],"=",string y}'[key x;value x];
          0h~typx;
            ";"sv string x;x]}each value d;
  // Add ` to the beginning of functions
  vals:@[vals;key[d]?`funcs`prf`seed`tts`sigfeats;{$[any[x in .Q.a]&not"{"in x;enlist["`"],;]x}];
  // Add key, pipe and newline indicator
  strd:{(" |" sv x),"\n"}each flip(8#'string[key d],\:6#" ";vals);
  // Write dictionary entries to file
  {x y}[h]each strd;
  hclose h;}
