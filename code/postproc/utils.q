\d .automl

// The following parameters are used in multiple locations and defined here for convenience
/* cr = column/row number to be shuffled
/* tgt  = target data
/* dt = dictionary containing date and time of run start `sttime`stdate! ...
/* prob = probability that prediction is the positive class 
/* fpath = file path to the images folder 

// Utilities for available plotting functionality

// Python functionality
plt:.p.import`matplotlib.pyplot;

// Shuffle columns of matrix/table based on col name or idx.
// This is used in impact plotting to hold all other columns stationary such
// that the importance of individual columns can be ascertained
/* tm = table or matrix which is being shuffled
/. r  > the same matrix/table with the specified row/column shuffled appropriately
post.i.shuffle:{[tm;c]
  idx:neg[n]?n:count tm;
  $[98h~type tm;tm:@[tm;c;@;idx];tm[;c]:tm[;c]idx];:tm}

// Predict output from models after shuffling
// this function should be improved, limitations are arising due to the
// number of available arguments to .automl.post.featureimpact 
/* bs   = name of the best mode
/* mdl   = mixed list containing as first element the name of the best model
/*        and second element the table of all possible models
/* data = mixed list of (xtrn;ytrn;xtst;ytst)
/* scf  = scoring function
/* cr   = column/row number depending on table/matrix
/* p    = parameter set
/. r    > score of the model with one column/row shuffled 
post.i.predshuff:{[bs;mdl;data;scf;cr;p]
  epymdl:mdl[0];mdltb:mdl[1];
  xtest:post.i.shuffle[data 2;cr];
  funcnm:string first exec fnc from mdltb where model=bs;
  preds:$[bs in i.keraslist;
        get[".automl.",funcnm,"predict"][((data 0;data 1);(xtest;data 3));epymdl];
        epymdl[`:predict][xtest]`];
  scf[;data 3]preds
  }

// Calculation of impact score for each column/row of the table/matrix
/* ps  = output from prediction/shuffle set
/* ni  = column name or index of row
/* ord = ordering to be applied to scored predictions to ensure best model is found
/. r   > a dictionary mapping the feature impact to associated column/row
post.i.impact:{[ps;ni;ord]
  asc ni!s%max s:$[ord~desc;1-;]$[any 0>ps;.ml.minmaxscaler;]ps}

// This function will plot and save the feature impact plot to an appropriate location
// the maximum number of features plotted is 20 
/* im    = impact scores
/* mdl   = model name as a symbol
/. r     > impact plot saved to disk
post.i.impactplot:{[im;mdl;dt;fpath]
  plt[`:figure][`figsize pykw 20 20];
  sub:plt[`:subplots][];
  fig:sub[@;0];ax:sub[@;1];
  num:20&count value im;
  n:til num;v:num#value im;k:num#key im;
  ax[`:barh][n;v;`align pykw`center];
  ax[`:set_yticks]n;
  ax[`:set_yticklabels]k;
  ax[`:set_title]"Feature Impact: ",string mdl;
  ax[`:set_ylabel]"Columns";
  ax[`:set_xlabel]"Relative feature impact";
  plt[`:savefig][fpath[0][`images],sv["_";string(`Impact_Plot;mdl)],".png";`bbox_inches pykw"tight"];}

post.i.displayCM:{[cm;classes;title;cmap;mdl;fpath]
  if[cmap~();cmap:plt`:cm.Blues];
  subplots:plt[`:subplots][`figsize pykw 5 5];
  fig:subplots[`:__getitem__][0];
  ax:subplots[`:__getitem__][1];
  ax[`:imshow][cm;`interpolation pykw`nearest;`cmap pykw cmap];
  ax[`:set_title][`label pykw title];
  tickMarks:til count classes;
  ax[`:xaxis.set_ticks]tickMarks;
  ax[`:set_xticklabels]classes;
  ax[`:yaxis.set_ticks]tickMarks;
  ax[`:set_yticklabels]classes;
  thresh:max[raze cm]%2;
  shape:.ml.shape cm;
  {[cm;thresh;i;j]
    plt[`:text][j;i;string cm[i;j];`horizontalalignment pykw`center;`color pykw $[thresh<cm[i;j];`white;`black]]
    }[cm;thresh;;]. 'cross[til shape 0;til shape 1];
  plt[`:xlabel]["Predicted Label";`fontsize pykw 12];
  plt[`:ylabel]["Actual label";`fontsize pykw 12];
  plt[`:savefig][fpath[0][`images],sv["_";string(`Confusion_Matrix;mdl)],".png";`bbox_inches pykw"tight"];}

// Utilities for report generation

// The following dictionary is used to make report generation more seautomless
/* cfeat = count of features
/* bm    = information about the best model returned from `.automl.proc.runmodels`
/* tm    = list with the time for feature extraction to take place returned from .automl.prep.*create
/* path  = output from ".automl.path" for the system
/* xvgs  = list of information about the models used and scores achieved for xval and grid-search
/* fpath = image file path
/* dscrb = description of input table
/. r     > dictionary with the appropriate information added
post.i.reportdict:{[cfeat;bm;tm;path;xvgs;fpath;dscrb]
  dd:(0#`)!();
  select
    feats    :cfeat,
    dict     :bm 0,
    impact   :(fpath[0][`images],"Impact_Plot_",string[bm 1],".png"),
    holdout  :bm 2,
    xvtime   :bm 3,
    bmtime   :bm 4,
    metric   :bm 5,
    feat_time:tm 1,
    gs       :xvgs 0,
    score    :xvgs 1,
    xv       :xvgs 2,
    gscfg    :xvgs 3,
    confmat  :(fpath[0][`images],"Confusion_Matrix_",string[bm 1],".png"),
    describe :dscrb
  from dd}

