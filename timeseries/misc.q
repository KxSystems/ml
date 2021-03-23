// timeseries/misc.q - Timeseries functions
// Copyright (c) 2021 Kx Systems Inc
// 
// Miscellaneous functionality relating to time series analysis
// and model generation procedures

\d .ml

// @kind function
// @category misc
// @desc Summary of the stationarity of each vector of a multivariate 
//   time series or a single vector
// @param data {dictionary|table|number[]} a time series of interest,
//   the entries should 
//   in each case be numeric data types.
// @return {dictionary} informative outputs from the python adfuller test 
//   indicating the stationarity of each vector entry of the relevant dataset
ts.stationarity:{[data]
  dataType:type data;
  // Names to be provided to form the key for the return table
  keyNames:$[99h=dataType;key data;
    98h=dataType;cols data;
    enlist`data
    ];
  // Column names associated with the returns from the augmented Dickey Fuller
  // test
  criticalVals:`$raze each"CriticalValue_",/:string(1;5;10),\:"%";
  dataCols:`ADFstat`pvalue`stationary,criticalVals;
  scores:ts.i.stationaryScores[data;dataType];
  keyNames!flip dataCols!scores
  }

// @kind function
// @category misc
// @desc Retrieve the best parameters for an ARIMA model based on the
//   Akaike Information Criterion (AIC)
// @param train  {dictionary} training data dictionary 
//   containing `endog/`exog data
// @param test   {dictionary} testing data dictionary 
//   containing `endog/`exog data
// @param len    {int} number of steps forward to predict
// @param params {dictionary} parameter sets to fit ARIMA model with 
// @return {dictionary} parameter set which produced the lowest AIC score
ts.ARIMA.aicParam:{[train;test;len;params]
  ts.i.dictCheck[;`endog`exog;]'[(train;test);("train";"test")];
  ts.i.dictCheck[params;`p`d`q`trend;"params"];
  // Get AIC scores for each set of params
  scores:ts.i.aicFitScore[train;test;len]each flip params;
  // Return best value
  bestScore:min scores;
  scoreEntry:enlist[`score]!enlist bestScore;
  params[;scores?bestScore],scoreEntry
  }

// Time-series feature engineering functionality

// @kind function
// @category misc
// @desc Apply a set of user defined functions over variously sized 
//   sliding windows to a subset of columns within a table
// @param tab {table} dataset onto which to apply the windowed functions
// @param colNames {symbol[]} names of the columns on which to apply the 
//   functions
// @param funcs {symbol[]} names of the functions to be applied
// @param winSize {int[]} list of sliding window sizes
// @return {table} table with functions applied on specified columns over
//   appropriate windows remove the first max[winSize] columns as these are 
//   produced with insufficient information to be deemed accurate
ts.windowFeatures:{[tab;colNames;funcs;winSize]
  // Unique combinations of columns/windows and functions to be applied to the 
  // dataset
  uniCombs:(cross/)(funcs;winSize;colNames);
  // Column names for windowed functions (remove ".") to ensure that if
  // namespaced columns exist they dont jeopardize parsing of select statements
  winCols:`$ssr[;".";""]each sv["_"]each string uniCombs;
  // Values from applied functions over associated windows
  winVals:ts.i.setupWindow[tab]each uniCombs;
  max[winSize]_tab,'flip winCols!winVals
  }

// @kind function
// @category misc
// @desc Apply a set of user defined functions over variously sized 
//   sliding windows to a subset of columns within a table
// @param tab {table} Dataset from which to generate lagged data
// @param colNames {symbol[]} Names of the columns to retrieve lagged data from
// @param lags {int[]} List of lagged values to retrieve from the dataset
// @return {table} Table with columns added associated with the specied lagged
//   values 
ts.laggedFeatures:{[tab;colNames;lags]
  if[1=count colNames;colNames,:()];
  if[1=count lags;lags,:()];
  lagNames:`$raze string[colNames],/:\:"_xprev_",/:string lags;
  lagVals :raze xprev'[;tab colNames]each lags;
  tab,'flip lagNames!lagVals
  }

// Plotting functionality

// @kind function
// @category misc
// @desc Plot and display an autocorrelation plot
// @param data {number[]} Dataset from which to generate the autocorrelation 
//   plot
// @param n {int} Number of lags to include in the graph
// @return {graph} display to standard out the autocorrelation bar plot
ts.acfPlot:{[data;n;width]
  acf:ts.i.autoCorrFunction[data;]each n;
  ts.i.plotFunction[data;acf;n;width;"AutoCorrelation"];
  }

// @kind function
// @category misc
// @desc Plot and display an autocorrelation plot
// @param data {number[]} Dataset from which to generate the partial 
//   autocorrelation plot
// @param n {int} Number of lags to include in the graph
// @return {graph} display to standard out the partial autocorrelation bar plot
ts.pacfPlot:{[data;n]
  pacf:.ml.fresh.i.pacf[data;neg[1]+m:n&count data]`;
  ts.i.plotFunction[data;1_pacf;1_til m;1;"Partial AutoCorrelation"];
  }
