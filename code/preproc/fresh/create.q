\d .automl

// Create features using the FRESH algorithm
/* t = table from which features are to be extracted
/* p = parameter dictionary containing information used in the extraction of features
/. r > table with features created in accordance with the FRESH feature creation procedure
prep.freshcreate:{[t;p]
  agg:p`aggcols;prm:get p`funcs;
  // Feature extraction should be performed on all columns that are non aggregate
  cols2use:k where not(k:cols[t])in agg;
  fe_start:.z.T;
  // Apply feature creation and encode nulls with the median value of the column
  t:"f"$prep.i.nullencode[value .ml.fresh.createfeatures[t;agg;cols2use;prm];med];
  fe_end:.z.T-fe_start;
  t:.ml.infreplace t;
  `preptab`preptime!(0^.ml.dropconstant t;fe_end)}
