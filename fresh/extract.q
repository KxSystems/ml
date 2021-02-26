// fresh/extract.q - Extract features
// Copyright (c) 2021 Kx Systems Inc
//   
// Generate features based on params

\d .ml 

// @kind table
// @category fresh
// @desc Table containing .ml.fresh.feat functions
fresh.params:update pnum:{count 1_get[fresh.feat x]1}each f,pnames:count[i]#(),
  pvals:count[i]#()from([]f:1_key fresh.feat) 
fresh.params:1!`pnum xasc update valid:pnum=count each pnames from fresh.params

// @kind function
// @category fresh
// @desc Load in hyperparameters for FRESH functions and add to 
//   .ml.fresh.params table
// @param filePath {string} File path within ML where hyperparameter JSON 
//   file is
// @return {::} Null on success with .ml.fresh.params updated
fresh.loadparams:{[filePath]
  hyperparamFile:.ml.path,filePath;
  p:.j.k raze read0`$hyperparamFile;
  p:inter[kp:key p;exec f from fresh.params]#p;
  fresh.params[([]f:kp);`pnames]:key each vp:value p;
  fresh.params[([]f:kp);`pvals]:{(`$x`type)$x`value}each value each vp;
  fresh.params:update valid:pnum=count each pnames from fresh.params 
    where f in kp;
  }

// @kind function
// @category fresh
// @desc Add hyperparameter values to .ml.fresh.params
fresh.loadparams"/fresh/hyperparameters.json";

// @kind fucntion
// @category fresh
// @desc Extract features using FRESH
// @param data {table} Input data
// @param idCol {symbol[]} ID column(s) name
// @param cols2Extract {symbol[]} Columns on which extracted features will
//   be calculated (these columns must be numerical)
// @param params {table} Functions/parameters to be applied to cols2Extract.
//   This should be a modified version of .ml.fresh.params
// @return {table} Table keyed by ID column and containing the features 
//   extracted from the subset of the data identified by the ID column.
fresh.createFeatures:{[data;idCol;cols2Extract;params]
  param0:exec f from params where valid,pnum=0;
  param1:exec f,pnames,pvals from params where valid,pnum>0;
  allParams:(cross/)each param1`pvals;
  calcs:param0,raze param1[`f]cross'param1[`pnames],'/:'allParams;
  cols2Extract:$[n:"j"$abs system"s";
    $[n<count cols2Extract;(n;0N);(n)]#;
    enlist
    ]cols2Extract;
  calcs:cols2Extract cross\:calcs;
  colMapping:fresh.i.colMap each calcs;
  colMapping:(`$ssr[;".";"o"]@''"_"sv''string raze@''calcs)!'colMapping;
  toApply:((cols2Extract,\:idCol:idCol,())#\:data;colMapping);
  res:(uj/).[?[;();idCol!idCol;]]peach flip toApply;
  idCol xkey fresh.i.expandResults/[0!res;exec c from meta[res]where null t]
  }

// Multi-processing functionality

loadfile`:util/mproc.q
if[0>system"s";multiProc.init[abs system"s"]enlist".ml.loadfile`:fresh/init.q"];
