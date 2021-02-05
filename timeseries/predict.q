\d .ml

// Prediction functionality for time-series models

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive model (AR)
// @param model {dict} Model parameters returned from fitting of an appropriate
//   model
// @param exog {tab;float[];(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model
// @param len {int} Number of future values to be predicted
// @return {float[]} Predicted values
ts.AR.predict:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  model[`paramDict]:`p`trend!count each model`pCoeff`trendCoeff;
  model[`residualCoeffs]:();
  model[`residuals]:();
  ts.i.predictFunction[model;exog;len;ts.i.AR.singlePredict]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive Moving Average model 
//   (ARMA)
// @param model {dict} Model parameters returned from fitting of an appropriate
//   model
// @param exog {tab;float[];(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model
// @param len {int} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARMA.predict:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  ts.i.predictFunction[model;exog;len;ts.i.ARMA.singlePredict]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive Integrated Moving
//   Average model (ARIMA)
// @param model {dict} Model parameters returned from fitting of an appropriate
//   model
// @param exog {tab;float[];(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model
// @param len {int} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARIMA.predict:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  // Calculate predictions not accounting for differencing
  preds:ts.i.predictFunction[model;exog;len;ts.i.ARMA.singlePredict];
  dVal:count model`originalData;
  // Revert data to correct scale (remove differencing if previously applied)
  $[dVal;dVal _dVal{sums x}/model[`originalData],preds;preds]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on a Seasonal AutoRegressive Integrated 
//   Moving Average model (SARIMA)
// @param model {dict} Model parameters returned from fitting of an appropriate
//   model
// @param exog {tab;float[];(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model
// @param len {int} Number of future values to be predicted
// @return {float[]} Predicted values
ts.SARIMA.predict:{[model;exog;len]
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
// @fileoverview Predictions based on an AutoRegressive Conditional 
//   Heteroskedasticity model (ARCH)
// @param model {dict} Model parameters returned from fitting of an appropriate
//   model
// @param len {int} Number of future values to be predicted
// @return {float[]} Predicted values
ts.ARCH.predict:{[model;len]
  last{x>count y 1}[len;]ts.i.ARCH.singlePredict
    [model`coefficients]/(model`residualVals;())
  }
