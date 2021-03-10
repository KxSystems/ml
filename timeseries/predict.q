// timeseries/predict.q - Timeseries prediction 
// Copyright (c) 2021 Kx Systems Inc
// 
// Prediction functionality for time-series models

\d .ml

// @kind function
// @category modelPredict
// @desc Predictions based on an AutoRegressive model (AR)
// @params config {dictionary} Information returned from `ml.ts.AR.fit` 
//   including:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model
// @param len {long} Number of future values to be predicted
// @return {float[]} Predicted values
ts.AR.predict:{[config;exog;len]
  model:config`modelInfo;
  exog:ts.i.predDataCheck[model;exog];
  model[`paramDict]:`p`trend!count each model`pCoeff`trendCoeff;
  model[`residualCoeffs]:();
  model[`residuals]:();
  ts.i.predictFunction[model;exog;len;ts.i.AR.singlePredict]
  }

// @kind function
// @category modelPredict
// @desc Predictions based on an AutoRegressive Moving Average model 
//   (ARMA)
// @params config {dictionary} Information returned from `ml.ts.ARMA.fit`
//   including:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model
// @param len {long} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARMA.predict:{[config;exog;len]
  model:config`modelInfo;
  exog:ts.i.predDataCheck[model;exog];
  ts.i.predictFunction[model;exog;len;ts.i.ARMA.singlePredict]
  }

// @kind function
// @category modelPredict
// @desc Predictions based on an AutoRegressive Integrated Moving
//   Average model (ARIMA)
// @params config {dictionary} Information returned from `ml.ts.ARIMA.fit`
//   including:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model
// @param len {long} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARIMA.predict:{[config;exog;len]
  model:config`modelInfo;
  exog:ts.i.predDataCheck[model;exog];
  // Calculate predictions not accounting for differencing
  preds:ts.i.predictFunction[model;exog;len;ts.i.ARMA.singlePredict];
  dVal:count model`originalData;
  // Revert data to correct scale (remove differencing if previously applied)
  $[dVal;dVal _dVal{sums x}/model[`originalData],preds;preds]
  }

// @kind function
// @category modelPredict
// @desc Predictions based on a Seasonal AutoRegressive Integrated 
//   Moving Average model (SARIMA)
// @params config {dictionary} Information returned from `ml.ts.SARIMA.fit`
//   including:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
// @param exog {table|float[]|(::)} Exogenous variables are additional 
//   variables which may be accounted for to improve the model
// @param len {long} Number of future values to be predicted
// @return {float[]} Predicted values
ts.SARIMA.predict:{[config;exog;len]
  model:config`modelInfo;
  exog:ts.i.predDataCheck[model;exog];
  // Calculate predictions not accounting for differencing
  preds:$[count raze model`paramDict;
    ts.i.predictFunction[model;exog;len;ts.i.SARMA.singlePredict];
    ts.i.AR.predict[model;exog;len]
    ];
  // Order of seasonal differencing originally applied
  dSeasVal:count model`seasonData;
  // If seasonal differenced, revert to original
  if[dSeasVal;preds:ts.i.reverseSeasonDiff[model`seasonData;preds]];
  // Order of differencing originally applied
  dVal:count model`originalData;
  // Revert data to correct scale (remove differencing if previously applied)
  $[dVal;dVal _dVal{sums x}/model[`originalData],preds;preds]
  }

// @kind function
// @category modelPredict
// @desc Predictions based on an AutoRegressive Conditional 
//   Heteroskedasticity model (ARCH)
// @params config {dictionary} Information returned from `ml.ts.ARCH.fit`
//   including:
//   modelInfo - Model coefficients and data needed for future predictions
//   predict - A projection allowing for prediction of future values
// @param len {long} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARCH.predict:{[config;len]
  model:config`modelInfo;
  last{x>count y 1}[len;]ts.i.ARCH.singlePredict
    [model`coefficients]/(model`residualVals;())
  }
