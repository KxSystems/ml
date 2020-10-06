\d .automl

// Create features for 'normal problems' -> one target for each row, no time dependency
// or fresh like structure
/* t = table from which features are to be extracted
/* p = parameter dictionary containing information used in the extraction of features
/. r > table with features created in accordance with the normal feature creation procedure
prep.normalcreate:{[t;p]
  fe_start:.z.T;
  // Time columns are extracted such that constituent parts can be used
  // but are not transformed according to remaining procedures
  tcols:.ml.i.fndcols[t;"dmntvupz"];
  tb:(cols[t]except tcols)#t;
  // apply user defined functions to the table
  tb:prep.i.applyfn/[tb;p`funcs];
  tb:.ml.dropconstant prep.i.nullencode[.ml.infreplace tb;med];
  // Apply the transform of time specific columns as appropriate
  if[0<count tcols;tb^:.ml.timesplit[tcols#t;::]];
  fe_end:.z.T-fe_start;
  `preptab`preptime!(tb;fe_end)}
