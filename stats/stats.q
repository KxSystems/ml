\d .ml

// @kind function
// @category stats
// @fileoverview Train an ordinary least squares model on data
// @param endog {num[][];num[]} The endogenous variable
// @param exog {num[][];num[]} A variables that predict the 
//   endog variable
// @param trend {bool} Whether a trend is added to the model
// @returns {dict} Contains the following information:
//   modelInfo - Coeffients and statistical values calculated during the 
//   fitting process
//   predict - A projection allowing for prediction on new input data
stats.OLS.fit:{[endog;exog;trend]
  stats.i.checkLen[endog;exog;"exog"];
  endog:"f"$endog;
  exog:"f"$$[trend;1f,'exog;exog];
  if[1=count exog[0];exog:flip enlist exog];
  coef:first enlist[endog]lsq flip exog;
  modelInfo:stats.i.OLSstats[coef;endog;exog;trend];
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predict:stats.OLS.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @fileOverview Predict values using coefficients calculated via OLS
// @param config {dict} Information returned from `OLS.fit`
//   including:
//   modelInfo - Coeffients and statistical values calculated during the 
//   fitting process
//   predict - A projection allowing for prediction on new input data
// @param exog {tab;num[][];num[]} The exogenous variables
// @returns {number[]} The predicted values
stats.OLS.predict:{[config;exog]
  modelInfo:config`modelInfo;
  trend:`yIntercept in key modelInfo`variables;
  exog:"f"$$[trend;1f,'exog;exog];
  coef:modelInfo`coef;
  if[1=count exog[0];exog:flip enlist exog];
  sum coef*flip exog
  }

// @kind function
// @category stats
// @fileoverview Train an ordinary least squares model on data
// @param endog {num[][];num[]} The endogenous variable
// @param exog {num[][];num[]} A variables that predict the 
//   endog variable
// @param weights {float[]} The weights to be applied to the endog variable
// @param trend {bool} Whether a trend is added to the model
// @returns {dict} Contains the following information:
//   modelInfo - Coeffients and statistical values calculated during the 
//   fitting process
//   predict - A projection allowing for prediction on new input data
stats.WLS.fit:{[endog;exog;weights;trend]
  stats.i.checkLen[endog;exog;"exog"];
  if[weights~(::);weights:()];
  if[count weights;stats.i.checkLen[endog;weights;"weights"]];
  endog:"f"$endog; 
  // Calculate the weights if not given
  // Must be inversely proportional to the error variance
  if[not count weights;
    trained:stats.OLS.fit[endog;exog;0b];
    residuals:endog-trained[`predict]exog;
    trained:stats.OLS.fit[abs residuals;exog;0b];
    weights:1%{x*x}trained[`predict]exog
    ];
  exog:"f"$$[trend;1f,'exog;exog];
  if[1=count exog[0];exog:flip enlist exog];
  updDependent:flip[exog]mmu weights*'endog;
  updPredictor:flip[exog]mmu weights*'exog;
  coef:raze inv[updPredictor]mmu updDependent;
  modelInfo:stats.i.OLSstats[coef;endog;exog;trend];
  modelInfo,:enlist[`weights]!enlist weights;
  returnInfo:enlist[`modelInfo]!enlist modelInfo;
  predict:stats.WLS.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @fileOverview Predict values using coefficients calculated via WLS
// @param config {dict} Information returned from `WLS.fit`
//   including:
//   modelInfo - Coeffients and statistical values calculated during the 
//   fitting process
//   predict - A projection allowing for prediction on new input data
// @param exog {tab;num[][];num[]} The exogenous variables
// @returns {number[]} The predicted values
stats.WLS.predict:stats.OLS.predict

// @kind data
// @category stats
// @fileoverview Load in functions defined within `describe.json`
stats.describeFuncs:.j.k raze read0`$path,"/stats/describe.json"

// @kind function
// @category stats
// @fileoverview Descriptive information
// @param tab {tab} A simple table
// @returns {dict} A tabular description of aggregate information column
stats.describe:{[tab]
  funcTab:stats.describeFuncs;
  if[not`func in cols value funcTab;'"Keyed table must contain a func column"];
  descKeys:key funcTab;
  funcs:get each value[funcTab]`func;
  // Get indices of where each type of function is in the function list
  typeKeys:`num`temporal`other;
  typeDict:typeKeys!where@'(string each typeKeys) in/:\:value[funcTab]`type;
  numTypes:"hijef";
  temporalTypes:"pmdznuvt";
  numCols:exec c from meta[tab]where t in numTypes;
  temporalCols:exec c from meta[tab]where t in temporalTypes;
  otherCols:cols[tab]except numCols,temporalCols;
  colDict:typeKeys!(numCols;temporalCols;otherCols);
  applyInd:where 0<count each colDict;
  inds:asc distinct raze typeDict applyInd;
  n:count funcs;
  m:count applyInd;
  // Create empty list so num/other have same amount of funcs
  // so that they can be joined later
  funcDict:applyInd!(m,n)#{(::)};
  funcUpd:stats.i.updFuncDict[funcs;typeDict]/[funcDict;applyInd];
  tabUpd:colDict[applyInd]#\:tab;
  descVals:(,'/){flip x@\:/:flip y}'[funcUpd;tabUpd];
  // Reorder columns to original order
  descVals:cols[tab]xcols descVals;
  descKeys[inds]!descVals[inds]
  }

// @kind function
// @category utilities
// @fileoverview Percentile calculation for an array
// @param array {num[]} A numerical array
// @param perc {float} Percentile of interest
// @returns {float} The value below which `perc` percent of the observations
//   within the array are found
stats.percentile:{[array;perc]
  percent:perc*-1+count array;
  i:0 1+\:floor percent;
  iDiff:0^deltas asc[array]i;
  iDiff[0]+(percent-i 0)*last iDiff
  }
