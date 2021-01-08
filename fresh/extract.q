\d .ml 

// FRESH feature extraction

// Table containing .ml.fresh.feat functions
fresh.params:update pnum:{count 1_get[fresh.feat x]1}each f,pnames:count[i]#(),
  pvals:count[i]#()from([]f:1_key fresh.feat) 
fresh.params:1!`pnum xasc update valid:pnum=count each pnames from fresh.params

// @kind function
// @category fresh
// @fileoverview Load in hyperparameters for FRESH functions and add to 
//   .ml.fresh.params table
// @param filePath {str} File path within ML where hyperparameter JSON file is
// @return {null} Null on success with .ml.fresh.params updated
fresh.loadparams:{[x]
  hyperparamFile:.ml.path,x;
  p:.j.k raze read0`$hyperparamFile;
  p:inter[kp:key p;exec f from fresh.params]#p;
  fresh.params[([]f:kp);`pnames]:key each vp:value p;
  fresh.params[([]f:kp);`pvals]:{(`$x`type)$x`value}each value each vp;
  fresh.params:update valid:pnum=count each pnames from fresh.params 
    where f in kp;
  }

// Add hyperparameter values to .ml.fresh.params
fresh.loadparams"/fresh/hyperparameters.json";

// @kind fucntion
// @category fresh
// @fileoverview Extract features using FRESH
// @param data {table} Input data in the form of a simple table
// @param idCol {sym[]} ID column(s) name
// @param cols2Extract {sym[]} Columns on which extracted features will be calculated 
//   (these columns must be numerical)
// @param params {table} Functions/parameters to be applied to cols2Extract. This 
//   should be a modified version of .ml.fresh.params
// @return {table} Table keyed by ID column and containing the features 
//   extracted from the subset of the data identified by the ID column.
fresh.createfeatures:{[data;idCol;cols2Extract;params]
  p0:exec f from params where valid,pnum=0;
  p1:exec f,pnames,pvals from params where valid,pnum>0;
  calcs:p0,raze p1[`f]cross'p1[`pnames],'/:'(cross/)each p1`pvals;
  calcs:(cols2Extract:$[n:"j"$abs system"s";$[n<count cols2Extract;(n;0N);(n)]#;enlist]cols2Extract)cross\:calcs;
  q:{flip[(` sv'`.ml.fresh.feat,'x[;1];x[;0])],'last@''2_'x}each calcs;
  q:(`$ssr[;".";"o"]@''"_"sv''string raze@''calcs)!'q;
  r:(uj/).[?[;();idCol!idCol;]]peach flip((cols2Extract,\:idCol:idCol,())#\:data;q);
  idCol xkey{[r;c]
    ![r;();0b;enlist c],'(`$"_"sv'string c,'cols t)xcol t:r c
    }/[0!r;exec c from meta[r]where null t]
  }

// Multi-processing functionality

loadfile`:util/mproc.q
if[0>system"s";mproc.init[abs system"s"]enlist".ml.loadfile`:fresh/init.q"];
