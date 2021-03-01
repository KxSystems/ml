// timeseries/fit.q - Fit timeseries models 
// Copyright (c) 2021 Kx Systems Inc
// 
// Fitting functionality for time series models. 
// Models include AR, ARCH, ARMA, ARIMA, and SARIMA.

\d .ml

// @kind function
// @category modelFit
// @desc Fit an AutoRegressive model (AR)
// @param endog {float[]} Endogenous variable (time-series) from which to build
//  a model. This is the target variable from which a value is to be predicted
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model, if (::)/()
//   this will be ignored
// @param p {int} The number/order of time lags of the model
// @param trend {boolean} Is a trend line to be accounted for when fitting 
//   the model
// @return {dictionary} Contains the following information:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
ts.AR.fit:{[endog;exog;p;trend]
  // Cast endog to floating value
  endog:"f"$endog;
  exog:ts.i.fitDataCheck[endog;exog];
  // Estimate coefficients
  coeffs:$[sum trend,count exog;
    ts.i.estimateCoefficients[endog;exog;endog;`p`q`trend!p,0,trend];
    ts.i.durbinLevinson[endog;p]
    ];
  // Get lagged values needed for future predictions
  lagVals:neg[p]#endog;
  // Return dictionary with required info for predictions
  dictKeys:`coefficients`trendCoeff`exogCoeff`pCoeff`lagVals;
  dictVals:(coeffs;trend#coeffs;coeffs trend +til count exog 0;
    neg[p]#coeffs;lagVals);
  modelDict:dictKeys!dictVals;
  returnInfo:enlist[`modelInfo]!enlist modelDict;
  predictFunc:ts.AR.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category modelFit
// @desc Fit an AutoRegressive Moving Average model (ARMA)
// @param endog {float[]} Endogenous variable (time-series) from which to build
// a model. This is the target variable from which a value is to be predicted
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model, if (::)/() 
//   this will be ignored
// @param p {int} The number/order of time  lags of the model
// @param q {int} The number of residual errors to be accounted for
// @param trend {boolean} Is a trend line to be accounted for when fitting 
//   the model
// @return {dictionary} Contains the following information:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
ts.ARMA.fit:{[endog;exog;p;q;trend]
  // Cast endog to floating value
  endog:"f"$endog;
  exog:ts.i.fitDataCheck[endog;exog];
  paramDict:`p`q`trend!p,q,trend;
  modelDict:$[q~0;
    // If q = 0 then model is an AR model
    [dictKeys:`qCoeff`residualVals`residualCoeffs`paramDict;
     dictVals:(();();();paramDict);
     ts.AR.fit[endog;exog;p;trend][`modelInfo],dictKeys!dictVals
     ];
    ts.i.ARMA.model[endog;exog;paramDict]
    ];
  returnInfo:enlist[`modelInfo]!enlist modelDict;
  predictFunc:ts.ARMA.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category modelFit
// @desc Fit an AutoRegressive Integrated Moving Average model (ARIMA)
// @param endog {float[]} Endogenous variable (time-series) from which to build
//   a model. This is the target variable from which a value is to be predicted
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model, if (::)/()
//   this will be ignored
// @param p {int} The number/order of time  lags of the model
// @param d {int} The order of time series differencing used in integration
// @param q {int} The number of residual errors to be accounted for
// @param trend {boolean} Is a trend line to be accounted for in fitting of 
//   model
// @return {dictionary} Contains the following information:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
ts.ARIMA.fit:{[endog;exog;p;d;q;trend]
  exog:ts.i.fitDataCheck[endog;exog];
  // Apply integration (non seasonal)
  I:ts.i.differ[endog;d;()!()]`final;
  // Fit an ARMA model on the differenced time series
  modelDict:ts.ARMA.fit[I;d _exog;p;q;trend]`modelInfo;
  // Retrieve the original data to be used when fitting on new data
  originalData:neg[d]#endog;
  // Produce the relevant differenced data for use in future predictions
  originalDiff:enlist[`originalData]!enlist d{deltas x}/originalData;
  // return relevant data
  modelDict,:originalDiff;
  returnInfo:enlist[`modelInfo]!enlist modelDict;
  predictFunc:ts.ARIMA.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category modelFit
// @desc Fit a Seasonal AutoRegressive Integrated Moving Average model 
//   (SARIMA)
// @param endog {float[]} Endogenous variable (time-series) from which to build
//   a model. This is the target variable from which a value is to be predicted
// @param exog  {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model, if (::)/()
//   this will be ignored
// @param p {int} The number/order of time  lags of the model
// @param d {int} The order of time series differencing used in integration
// @param p {int} The number of residual errors to be accounted for
// @param trend {boolean} Is a trend line to be accounted for in fitting of 
//   model
// @param season {dictionary} Is a dictionary containing required seasonal 
//   components
// @return {dictionary} Contains the following information:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
ts.SARIMA.fit:{[endog;exog;p;d;q;trend;season]
  // Cast endog to floating value
  endog:"f"$endog;
  ts.i.dictCheck[season;`P`Q`D`m;"seas"];
  // Apply error checking (exogenous data not converted to matrix?)
  exog:ts.i.fitDataCheck[endog;exog];
  // Apply appropriate seasonal+non seasonal differencing
  I:ts.i.differ[endog;d;season];
  // Create dictionary with p,q and seasonal components
  seasonInfo:((1+til each season`P`Q)*season`m),season[`m],trend;
  dict:`p`q`P`Q`m`trend!p,q,seasonInfo;
  // Add additional seasonal components
  dict[`additionalP`additionalQ]:(raze'){1+til[x]+/:y}'[(p;q);dict`P`Q];
  // Generate data for regenerate data following differencing
  diffKeys:`originalData`seasonData;
  diffVals:(d{deltas x}/neg[d]#endog;neg[prd season`D`m]#I`init);
  diffDict:diffKeys!diffVals;
  // Apply SARMA model and postpend differenced original data
  modelDict:ts.i.SARMA.model[I`final;exog;dict],diffDict;
  returnInfo:enlist[`modelInfo]!enlist modelDict;
  predictFunc:ts.SARIMA.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }

// @kind function
// @category modelFit
// @desc Fit an AutoRegressive Conditional Heteroscedasticity model
//   (ARCH)
// @param residuals {number[]} Residual errors from fitted time series model
// @param p {int} The number/order of time  lags of the model
// @return {dictionary} Contains the following information:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
ts.ARCH.fit:{[residuals;p]
  // Cast to floating value
  residuals:"f"$residuals;
  // Cast endog to floating value
  squareResiduals:residuals*residuals;
  paramDict:`p`q`trend!p,0,1b;
  // Using the residuals errors calculate coefficients
  coeff:ts.i.estimateCoefficients[squareResiduals;();squareResiduals;paramDict];
  // Get lagged values needed for future predictions
  lastResiduals:neg[p]#squareResiduals;
  // Return dictionary with required info for predictions
  dictKeys:`coefficients`trendCoeff`pCoeff`residualVals;
  dictVals:(coeff;coeff 0;1_coeff;lastResiduals);
  modelDict:dictKeys!dictVals;
  returnInfo:enlist[`modelInfo]!enlist modelDict;
  predictFunc:ts.ARCH.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predictFunc
  }
