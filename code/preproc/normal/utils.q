// The functionality contained in this file covers the required and optional utilities for
// normal feature creation within the automated machine learning library. This file should
// be extended as additional functionality is made available for this form of feature creation

\d .automl

// Used in the recursive application of functions to a kdb+ table 
/* t  = simple table to which functions are to be applied
/* fn = function to be applied to the table
/. r  > table with the desired transforms applied recursively
prep.i.applyfn:{[t;fn]typ:type fn;@[;t]$[-11h=typ;get[fn];100h=typ;fn;.automl.prep.i.default]}

// Default behaviour for the system is to pass through the table without the application of
// any feature extraction procedures, this is for computational efficiency in initial builds
// of the system and may be augmented with a more intelligent system moving forward
prep.i.default:{[t]t}


// Optional functionality:
// The functions beyond this point form the basis for demonstrations and operate as
// starting points for a number of potential workflows. These may form the basis for more
// central components to the workflow at a future point 

// Perform bulk transformations of hij columns for all unique linear combinations of such columns
/. r > table with bulk transformtions applied appropriately
prep.i.bulktransform:{[t]
  c:.ml.i.fndcols[t;"hij"];
  // Name the columns based on the unique combinations
  n:raze(,'/)`$(raze each string c@:.ml.combs[count c;2]),\:/:("_multi";"_sum";"_div";"_sub");
  // Apply transforms based on naming conventions chosen and re-form the table with these appended
  flip flip[t],n!(,/)(prd;sum;{first(%)x};{last deltas x})@/:\:t c}

// Perform a truncated single value decomposition on unique linear combinations of float columns
// https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html
prep.i.truncsvd:{[t]
  c:.ml.i.fndcols[t;"f"];
  c@:.ml.combs[count c,:();2];
  svd:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
  flip flip[t],(`$(raze each string c),\:"_trsvd")!{raze x[`:fit_transform][flip y]`}[svd]each t c}

