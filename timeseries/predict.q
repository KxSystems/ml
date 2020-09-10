\d .ml

// Prediction functionality for time-series models

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive model (AR)
// @param mdl  {dict} model parameters returned from fitting of an appropriate model
// @param exog {tab/num[][]/(::)} Exogenous variables, are additional variables which
//   required for application of model prediction 
// @param len  {integer} number of values to be predicted
// @return     {float[]} list of predicted values
ts.AR.predict:{[mdl;exog;len]
  ts.i.dictCheck[mdl;ts.i.AR.keyList;"mdl"];
  exog:ts.i.predDataCheck[mdl;exog];
  mdl[`pred_dict]:`p`tr!count each mdl`p_param`tr_param;
  mdl[`estresid]:();
  mdl[`resid]:();
  ts.i.predictFunction[mdl;exog;len;ts.i.AR.singlePredict]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive Moving Average model (ARMA)
// @param mdl  {dict} model parameters returned from fitting of an appropriate model
// @param exog {tab/num[][]/(::)} Exogenous variables, are additional variables which
//   required for application of model prediction 
// @param len  {integer} number of values to be predicted
// @return     {float[]} list of predicted values
// Predict future data using an ARMA model
/. r    > list of predicted values
ts.ARMA.predict:{[mdl;exog;len]
  ts.i.dictCheck[mdl;ts.i.ARMA.keyList;"mdl"];
  exog:ts.i.predDataCheck[mdl;exog];
  ts.i.predictFunction[mdl;exog;len;ts.i.ARMA.singlePredict]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive Integrated Moving Average 
//   model (ARIMA)
// @param mdl  {dict} model parameters returned from fitting of an appropriate model
// @param exog {tab/num[][]/(::)} Exogenous variables, are additional variables which
//   required for application of model prediction 
// @param len  {integer} number of values to be predicted
// @return     {float[]} list of predicted values
ts.ARIMA.predict:{[mdl;exog;len]
  ts.i.dictCheck[mdl;ts.i.ARIMA.keyList;"mdl"];
  exog:ts.i.predDataCheck[mdl;exog];
  // Calculate predictions not accounting for differencing
  pred:ts.i.predictFunction[mdl;exog;len;ts.i.ARMA.singlePredict];
  dval:count mdl`origd;
  // Revert data to correct scale (remove differencing if previously applied)
  $[dval;dval _dval{sums x}/mdl[`origd],pred;pred]
  }

// @kind function
// @category modelPredict
// @fileoverview Predictions based on a Seasonal AutoRegressive Integrated Moving 
//   Average model (SARIMA)
// @param mdl  {dict} model parameters returned from fitting of an appropriate model
// @param exog {tab/num[][]/(::)} Exogenous variables, are additional variables which
//   required for application of model prediction 
// @param len  {integer} number of values to be predicted
// @return     {float[]} list of predicted values
ts.SARIMA.predict:{[mdl;exog;len]
  ts.i.dictCheck[mdl;ts.i.SARIMA.keyList;"mdl"];
  exog:ts.i.predDataCheck[mdl;exog];
  // Calculate predictions not accounting for differencing
  preds:$[count raze mdl[`pred_dict];
    ts.i.predictFunction[mdl;exog;len;ts.i.SARMA.singlePredict];
    ts.i.AR.predict[mdl;exog;len]
    ];
  // Order of seasonal differencing originally applied
  sval:count mdl`origs;
  // if seasonal differenced, revert to original
  if[sval;preds:ts.i.reverseSeasonDiff[mdl[`origs];preds]];
  // Order of differencing originally applied
  dval:count mdl`origd;
  // Revert data to correct scale (remove differencing if previously applied)
  $[dval;dval _dval{sums x}/mdl[`origd],preds;preds]
  }


// @kind function
// @category modelPredict
// @fileoverview Predictions based on an AutoRegressive Conditional Heteroskedasticity 
//   model (ARCH)
// @param mdl  {dict} model parameters returned from fitting of an appropriate model
// @param len  {integer} number of values to be predicted
// @return     {float[]} list of predicted values
// Predict future volatility using an ARCH model
/. r    > list of predicted values
ts.ARCH.predict:{[mdl;len]
  ts.i.dictCheck[mdl;ts.i.ARCH.keyList;"mdl"];
  // predict and return future values
  last{x>count y 1}[len;]ts.i.ARCH.singlePredict[mdl`params]/(mdl`resid;())
  }
