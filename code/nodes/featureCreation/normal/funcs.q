\d .automl

// The functionality contained in this file covers the required and optional
//   utilities for normal feature creation within the automated machine 
//   learning library.

// @kind function
// @category featureCreation
// @fileoverview Used in the recursive application of functions to data 
// @param features {tab} Feature data as a table 
// @param func {(lambda;str)} Function to be applied to the table
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
// @fileoverview Default behaviour for the system is to pass through the table
//   without the application of any feature extraction procedures, this is for
//   computational efficiency in initial builds of the system and may be 
//   augmented with a more intelligent system moving forward.
// @param features {tab} Feature data as a table
// return {tab} Original table
featureCreation.normal.default:{[features]
  features
  }

// Optional functionality:
//   The functions beyond this point form the basis for demonstrations and
//   operate as starting points for a number of potential workflows. These may
//   form the basis for more central components to the workflow in the future.

// @kind function
// @category featureCreation
// @fileoverview Perform bulk transformations of hij columns for all unique 
//   linear combinations of such columns
// @param features {tab} Feature data as a table
// return {tab} Bulk transformtions applied to appropriate columns
featureCreation.normal.bulkTransform:{[features]
  bulkCols:.ml.i.fndcols[features;"hij"];
  stringFunc:("_multi";"_sum";"_div";"_sub");
  // Name the columns based on the unique combinations
  bulkCols@:.ml.combs[count bulkCols;2];
  joinCols:raze(,'/)`$("_"sv'string each bulkCols),\:/:stringFunc;
  // Apply transforms based on naming conventions chosen and re-form the table 
  //   with these appended
  funcList:(prd;sum;{first(%)x};{last deltas x});
  flip flip[features],joinCols!(,/)funcList@/:\:features bulkCols
  }

// @kind function
// @category featureCreation
// @fileoverview Perform a truncated single value decomposition on unique 
//   linear combinations of float columns
//   https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html
// @param features {tab} Feature data as a table
// return {tab} Truncated single value decomposition applied to feature table
featureCreation.normal.truncSingleDecomp:{[features]
  truncCols:.ml.i.fndcols[features;"f"];
  truncCols@:.ml.combs[count truncCols,:();2];
  decomposition:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
  fitTransform:{raze x[`:fit_transform][flip y]`};
  fitDecomp:fitTransform[decomposition]each features truncCols;
  colsDecomp:`$("_" sv'string each truncCols),\:"_trsvd";
  flip flip[features],colsDecomp!fitDecomp
  }
