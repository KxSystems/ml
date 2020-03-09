\d .automl

// For the following code the parameter naming convention
// defined here is applied to avoid repetition throughout the file
/* t   = input table
/* p   = parameter dictionary passed as default or modified by user
/* tgt = target data

// Create features using the FRESH algorithm
/. r > table of fresh created features and the time taken to complete extraction as a mixed list
prep.freshcreate:{[t;p]
  agg:p`aggcols;prm:get p`funcs;
  // Feature extraction should be performed on all columns that are non aggregate
  cols2use:k where not(k:cols[t])in agg;
  fe_start:.z.T;
  // Apply feature creation and encode nulls with the median value of the column
  t:"f"$prep.i.nullencode[value .ml.fresh.createfeatures[t;agg;cols2use;prm];med];
  fe_end:.z.T-fe_start;
  t:.ml.infreplace t;
  (0^.ml.dropconstant t;fe_end)}


// In all cases feature significance currently returns the top 25% of important features
// if no features are deemed important it currently continues with all available features
// at present
/. r > table with only the significant features available or all features as above
prep.freshsignificance:{[t;tgt]
  $[0<>count k:.ml.fresh.significantfeatures[t;tgt;.ml.fresh.percentile 0.25];
    k;[-1 prep.i.freshsigerr;cols t]]}


// Create features for 'normal problems' -> one target for each row, no time dependency
// or fresh like structure
/. r > table with features created in accordance with the normal feature creation procedure 
prep.normalcreate:{[t;p]
  fe_start:.z.T;
  // Time columns are extracted such that constituent parts can be used 
  // but are not transformed according to remaining procedures
  tcols:.ml.i.fndcols[t;"dmntvupz"];
  tb:(cols[t]except tcols)#t;
  tb:prep.i.applyfn/[tb;p`funcs];
  tb:.ml.dropconstant prep.i.nullencode[.ml.infreplace tb;med];
  // Apply the transform of time specific columns as appropriate
  if[0<count tcols;tb^:.ml.timesplit[tcols#t;::]];
  fe_end:.z.T-fe_start;
  (tb;fe_end)}

