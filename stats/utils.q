// stats/utils.q - Utility functions
// Copyright (c) 2021 Kx Systems Inc
//
// Utility functions for implementations within the stats library

\d .ml

// @private
// @kind function
// @category statsUtility
// @desc Check that the length of the endog and another parameter
//   are equal 
// @param endog {float[]} The endogenous variable
// @param param {number[][]|number[]} A parameter to compare the length of
// @param paramName {string} The name of the parameter
// @returns {::;err} Return an error if they aren't equal
stats.i.checkLen:{[endog;param;paramName]
  if[not count[endog]=count param;
    '"The length of the endog variable and ",paramName," must be equal"
    ]
  }

// @private
// @kind function
// @category statsUtility
// @desc Calculate descriptive stats for an OLS regression
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param trend {boolean} Whether a trend is added to the model
// @returns {dictionary[]} The descriptive statistics
stats.i.OLSstats:{[coef;endog;exog;trend]
  n:count endog;
  p:count[coef]-trend;
  statsDict:stats.i.OLScalcs[coef;endog;exog;n;p];
  variables:stats.i.coefStats[coef;endog;exog;trend;n;p];
  `coef`variables`statsDict!(coef;variables;statsDict)
  }

// @private
// @kind function
// @category statsUtility
// @desc Calculate descriptive stats for an OLS regression
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param n {long} The number of endog variables
// @param p {long} Number of coefs not including trend value
// @returns {dictionary[]} The descriptive statistics
stats.i.OLScalcs:{[coef;endog;exog;n;p]
  coefDict:enlist[`coef]!enlist coef;
  modelInfo:enlist[`modelInfo]!enlist coefDict;
  predicted:stats.OLS.predict[modelInfo;exog];
  mseCalc:mse[predicted;endog];
  r2:r2Score[predicted;endog];
  r2Adj:r2AdjScore[predicted;endog;p];
  // Calculate degrees of freedom
  dfTotal:n-1;
  dfModel:p;
  dfResidual:dfTotal-dfModel;
  // Sum of squares
  SSTotal:sse[endog;avg endog];
  SSModel:sse[predicted;first avg predicted];
  SSResidual:sse[predicted;endog];
  // Regression mean squares are the sum squares%degrees of freedom
  MSTotal:SSTotal%dfTotal; 
  MSModel:SSModel%dfModel;
  MSResidual:SSResidual%dfResidual;
  fStat:MSModel%MSResidual;
  logLike:stats.i.logLikelihood[SSResidual;n];
  rseCalc:rse[predicted;endog;dfResidual];
  pValue:2*1-pyStats[`:t][`:cdf;<][fStat;p;dfResidual];
  dictKeys:`dfTotal`dfModel`dfResidual`sumSquares`meanSquares,
    `fStat`r2`r2Adj`mse`rse`pValue`logLike;
  dictVals:(dfTotal;dfModel;dfResidual;SSResidual;MSResidual;fStat;r2;
    r2Adj;mseCalc;rseCalc;pValue;logLike);
  dictKeys!dictVals
  }

// @private
// @kind function
// @category statsUtility
// @desc Calculate the loglikelihood of the residuals
// @param SSResiduals {float} Sum of squares of the residual
// @param n {long} The number of endog variables
// @returns {float[]} The loglikelihood value
stats.i.logLikelihood:{[SSResidual;n]
  n2:n%2;
  ((neg[n2]*log[2*3.14])-(n2*log[SSResidual%n]))-n2
  }
  
// @private
// @kind function
// @category statsUtility
// @desc Calculate descriptive stats for the calculated coefficients
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param trend {boolean} Whether a trend is added to the model
// @param n {long} The number of endog variables
// @param p {long} Number of coefs not including trend value
// @returns {dictionary[]} The descriptive statistics for the 
//   calculated coefficients
stats.i.coefStats:{[coef;endog;exog;trend;n;p]
  varNames:`$"x",'string til count coef;
  if[trend;varNames:`yIntercept,-1_varNames];
  stdErr:stats.i.coefStdErr[coef;exog;endog];
  tStat:coef%stdErr;
  pValue:2*1-pyStats[`:t][`:cdf;<][;n-p-1]each abs tStat;
  // Calculate the confidence interval
  C195:stats.i.CI95[n;p]each stdErr;
  ([name: varNames]coef;stdErr;tStat;pValue;C195)
  }
  
// @private
// @kind function
// @category statsUtility
// @desc Calculate the standard error of the coefficient
// @param coef {float[]} The calculated coefficient
// @param exog {float[][]} Values that predict the endog variable
// @param endog {float[]} The endogenous variable
// @returns {float[]} The standard error of the coefficient
stats.i.coefStdErr:{[coef;exog;endog]
  shape:count[exog]-count first exog;
  error:{x*x}endog-exog mmu coef;
  dSigmaSq:sum error%shape;
  matrixInv:inv flip[exog]mmu exog;
  mVarCovar:dSigmaSq*matrixInv;
  // Get the diagonal values from a matrix
  diag:mVarCovar ./: 2#/:til count mVarCovar;
  sqrt diag
  }

// @private
// @kind function
// @category statsUtility
// @desc Calculate the 95% confidence interval of the standard error
//   of the coefficient
// @param n {long} Number of endog values
// @param p {long} Number of coefficients
// @param stdErr {float} The standard error of the coefficient
// @returns {float} The confidence interval
stats.i.CI95:{[n;p;stdErr]
  alpha:(1-.95)%2;
  // Degrees of freedom
  df:(n-p)-1;
  // Calculate the percent point function
  ppf:pyStats[`:t][`:ppf][alpha; df]`;
  neg ppf*stdErr
  }

// @private 
// @kind dictionary
// @category statsUtility
// @desc Infinity values for different types
// @type dictionary
infTypes:`int`long`real`float`timestamp`month`date`datetime`timespan`minute`second`time
stats.i.infinity:infTypes!infTypes$\:0w

// @private 
// @kind data
// @category statsUtility
// @desc Meta type letters to symbolic names
stats.i.metaTypes:" bgxhijefcCspmdznuvt"!
  `general`boolean`guid`byte`short`int`long`real`float`char`string,
  `symbol`timestamp`month`date`datetime`timespan`minute`second`time

// @private
// @kind function
// @category statsUtility
// @desc Update the function dictionary applied to data
// @param funcs {fn[]} Functions loaded from `.ml.stats.describeFuncs`
// @param typeDict {dictionary} Indices of functions to be applied for 
//   each type
// @param funcDict {dictionary} Contains all functions to be applied 
//   for each type
// @param typ {symbol} The type of function to be extracted (
//   `num`temporal`other)
// @returns {dictionary} The updated funcDict for each `typ` 
stats.i.updFuncDict:{[funcs;typeDict;funcDict;typ]
  funcDict[typ;typeDict typ]:funcs typeDict typ;
  funcDict
  }
