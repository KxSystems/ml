// code/nodes/featureCreation/normal/funcs.q - Normal feature creation
// Copyright (c) 2021 Kx Systems Inc
//
// The functionality contained in this file covers the required and optional
// utilities for normal feature creation within the automated machine 
// learning library.

\d .automl

// @kind function
// @category featureCreation
// @desc Used in the recursive application of functions to data 
// @param features {table} Feature data as a table 
// @param func {fn|string} Function to be applied to the table
// return {table} Data with the desired transforms applied recursively
featureCreation.normal.applyFunc:{[features;func]
  typ:type func;
  func:$[-11h=typ;
      utils.qpyFuncSearch func;
    typ in 100 104h;
      func;
    .automl.featureCreation.normal.default
    ];
  returnTab:func features;
  $[98h~type returnTab;
      returnTab;
    98h~type dfTab:@[.ml.df2tab;returnTab;returnTab];
      dfTab;
    '"Normal feature creation function did not return a simple table"
    ]
  }

// @kind function
// @category featureCreation
// @desc Default behaviour for the system is to pass through the table
//   without the application of any feature extraction procedures, this is for
//   computational efficiency in initial builds of the system and may be 
//   augmented with a more intelligent system moving forward.
// @param features {table} Feature data as a table
// return {table} Original table
featureCreation.normal.default:{[features]
  features
  }

// Optional functionality:
//   The functions beyond this point form the basis for demonstrations and
//   operate as starting points for a number of potential workflows. These may
//   form the basis for more central components to the workflow in the future.

// @kind function
// @category featureCreation
// @desc Perform bulk transformations of hij columns for all unique 
//   linear combinations of such columns
// @param features {table} Feature data as a table
// return {table} Bulk transformtions applied to appropriate columns
featureCreation.normal.bulkTransform:{[features]
  bulkCols:.ml.i.findCols[features;"hij"];
  stringFunc:("_multi";"_sum";"_div";"_sub");
  // Name the columns based on the unique combinations
  bulkCols@:.ml.combs[count bulkCols;2];
  joinCols:raze(,'/)`$("_"sv'string each bulkCols),\:/:stringFunc;
  // Apply transforms based on naming conventions chosen and re-form the table 
  // with these appended
  funcList:(prd;sum;{first(%)x};{last deltas x});
  flip flip[features],joinCols!(,/)funcList@/:\:features bulkCols
  }

// @kind function
// @category featureCreation
// @desc Perform a truncated single value decomposition on unique 
//   linear combinations of float columns
//   https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html
// @param features {table} Feature data as a table
// return {table} Truncated single value decomposition applied to feature table
featureCreation.normal.truncSingleDecomp:{[features]
  truncCols:.ml.i.findCols[features;"f"];
  truncCols@:.ml.combs[count truncCols,:();2];
  decomposition:.p.import[`sklearn.decomposition;`:TruncatedSVD;
     `n_components pykw 1];
  fitTransform:{raze x[`:fit_transform][flip y]`};
  fitDecomp:fitTransform[decomposition]each features truncCols;
  colsDecomp:`$("_" sv'string each truncCols),\:"_trsvd";
  flip flip[features],colsDecomp!fitDecomp
  }
