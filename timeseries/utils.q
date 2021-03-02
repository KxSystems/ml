// timeseries/utils.q - Timeseries Utilities
// Copyright (c) 2021 Kx Systems Inc
// 
// AR/ARMA/SARMA model utilities

\d .ml


// @private
// @kind function
// @category fitUtility
// @desc ARMA model generation
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param params {dictionary} Parameter sets used to fit the ARMA model
// @return {dictionary} Dictionary containing all information required to make 
//   predictions using an ARMA based model
ts.i.ARMA.model:{[endog;exog;params]
  n:1+max params`p`q;
  errCoeff:ts.i.estimateErrorCoeffs[endog;exog;params;n];
  ARMAvals:ts.i.ARMA.sortValues[endog;;params;;n] . errCoeff`coeffs`errors;
  dictKeys:`coefficients`trendCoeff`exogCoeff`pCoeff`qCoeff`lagVals,
    `residualVals`residualCoeffs`paramDict;
  dictVals:(errCoeff[`coeffs](::;params[`trend]-1;
    params[`trend]+til count exog 0)),ARMAvals;
  dictKeys!dictVals
  }

// @private
// @kind function
// @category fitUtility
// @desc SARMA model generation
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param params {dictionary} Parameter sets used to fit the SARMA model
// @return {dictionary} Dictionary containing all information required to make 
//   predictions using an SARMA based model
ts.i.SARMA.model:{[endog;exog;params]
  n:1+max params`p`q;
  errCoeff:ts.i.estimateErrorCoeffs[endog;exog;params;n];
  coeffs:ts.i.SARMA.coefficients[endog;exog;errCoeff[`errors]`errorVals;
    errCoeff`coeffs;params];
  SARMAvals:ts.i.SARMA.sortValues[endog;coeffs;params;errCoeff`errors;n];
  dictKeys:`coefficients`trendCoeff`exogCoeff`pCoeff`qCoeff,
    `PCoeff`QCoeff`lagVals`residualVals`residualCoeffs`paramDict;
  dictVals:(coeffs(::;params[`trend]-1;params[`trend]+til count exog 0)),
    SARMAvals;
  dictKeys!dictVals
  }

// @private
// @kind function 
// @category fitUtility
// @desc Estimate error coefficients
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param params {dictionary} Parameter sets used to estimate coefficients
// @param n {int} Number of error coefficients to estimate
// @return {dictionary} Dictionary returning coefficients and errors required
//   for model generation
ts.i.estimateErrorCoeffs:{[endog;exog;params;n]
  errors:ts.i.estimateErrors[endog;exog;n];
  coeffs:ts.i.estimateCoefficients[endog;exog;errors`errorVals;params];
  `errors`coeffs!(errors;coeffs)
  }

// @private
// @kind function 
// @category fitUtility
// @desc Estimate ARMA model parameters using ordinary least squares
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param errors {dictionary} Errors estimated using `i.estimateErrorCoeffs`
// @param params {dictionary} Parameter sets used to estimate model 
//   coefficients
// @return {float[]} Estimated ARMA model coefficients
ts.i.estimateCoefficients:{[endog;exog;errors;params]
  // Create lagged matrices for the endogenous variable and residual errors
  endogMatrix:ts.i.lagMatrix[endog ;params`p];
  residMatrix:ts.i.lagMatrix[errors;params`q];
  // Collect the data needed for estimation
  values:(exog;endogMatrix;residMatrix);
  // How many data points are required
  m:neg min raze(count[endog]-params[`p`P]),count[errors]-params[`q`Q];
  x:(,'/)m#'values;
  // Add seasonality components
  if[not 0N~params[`P];x:x,'(m #flip[params[`P]xprev\:endog])];
  if[not 0N~params[`Q];x:x,'(m #flip[params[`Q]xprev\:errors])];
  // If required add a trend line variable
  if[params`trend;x:1f,'x];
  y:m#endog;
  first enlist[y]lsq flip x
  }

// @private
// @kind function
// @category fitUtility
// @desc Durbin Levinson function to calculate the coefficients
//   in a pure AR model with no trend for a univariate dataset
//   Implementation can be found here 
//   https://www.stat.purdue.edu/~zhanghao/STAT520/handout/DurbinLevHandout.pdf
// @param data {float[]} Dataset from which to estimate the coefficients
// @param p {int} Order of the AR(p) model being fit
// @return {float[]} AR(p) coefficients for specified lagged value
ts.i.durbinLevinson:{[data;p]
  data:"f"$data;
  matrix:(1+p;1+p)#0f;
  vector:(1+p)#0f;
  matrix[1;1]:ts.i.autoCorrFunction[data;1];
  vector[1]  :var[data]*(1-xexp[matrix[1;1];2]);
  estParams:first(p-1) ts.i.durbinLevinsonEstimate[data]/(matrix;vector;1);
  reverse 1_last estParams
  }

// @private
// @kind function
// @category fitUtility
// @desc Recursive function to estimate the coefficients
//   in a pure AR model with no trend for a univariate dataset
// @param data {float[]} Dataset from which to estimate the coefficients
// @param info {number[]} Matrix, vector and n information 
// @return {float[]} New matrix,vector and n information
ts.i.durbinLevinsonEstimate:{[data;info]
  matrix:info 0;vector:info 1;n:info 2;
  k:n+1;
  dVal:sum matrix[n;1+til n]mmu ts.i.lagCovariance[data]each k-1+til n;
  matrix[k;k]:(ts.i.lagCovariance[data;k]-dVal)%vector n;
  updateMatrix:ts.i.durbinUpdateMatrix[data;n;matrix]each 1+til n;
  matrix[k;1+til n]:updateMatrix;
  vector[k]:vector[n]*(1-xexp[matrix[k;k];2]);
  (matrix;vector;n+1)
  }

// @private
// @kind function
// @category fitUtility
// @desc Update matrix values for calculating AR coefficients using
//   Durbin Levinson method
// @param data {float[]} Dataset from which to estimate the coefficients
// @param n {int} Number of iterations
// @param matrix {float[]} Matrix used to caluclate coefficients
// @param j {int} Column in the matrix
// @return {float[]} AR(p) coefficients for specified lagged value
ts.i.durbinUpdateMatrix:{[data;n;matrix;j]
  matrix[n;j]-(matrix[n+1;n+1]*matrix[n;1+n-j])
  }

// @private
// @kind function
// @category fitUtility
// @desc Estimate residual errors for the Hannan Riessanan method
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param p {int} The number/order of time lags of the model
// @return {dictionary} Residual errors and parameters for calculation of these 
//   parameters
ts.i.estimateErrors:{[endog;exog;p]
  // Construct an AR model to estimate the residual error coeffs
  estCoeffs:ts.AR.fit[endog;exog;p;0b][`modelInfo;`coefficients];
  // Convert the endogenous variable to lagged matrix
  endogMatrix:ts.i.lagMatrix[endog;p];
  // Predict future values based on estimations from AR model and use to 
  // estimate the error
  errors:(p _endog)-((neg[count endogMatrix]#exog),'endogMatrix)mmu estCoeffs;
  `estCoeffs`errorVals!(estCoeffs;errors)
  }

// @private
// @kind function
// @category fitUtility
// @desc Estimate coefficients as starting points to calculate the 
//   SARIMA coeffs
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param residuals {number[]} Residual errors estimated using 
//   i.estimateErrorCoeffs
// @param coeffs {number[]} Estimated coefficients for ARMA model using OLS
// @param params {dictionary} Information on seasonal and non seasonal lags to
//   be accounted for
// @return {dictionary} Updated optimized coefficients for SARMA model
ts.i.SARMA.coefficients:{[endog;exog;residuals;coeffs;params]
  // Data length to use
  qLen:count[residuals]-max raze params`q`Q`additionalQ;
  pLen:count[endog]-max raze params`p`P`additionalP;
  // Prediction values
  params[`true]:#[m:neg min pLen,qLen;endog];
  // Get lagged values
  lagVal:ts.i.lagMatrix[endog;params`p];
  // Get seasonal lag values
  seasLag:flip params[`P]xprev\:endog;
  // Get additional seasonal lag values
  params[`additionalLags]:$[params[`p]&count params`P;
    m#flip params[`additionalP]xprev\:endog;
    2#0f
    ];
  // Get resid vals
  residVal:ts.i.lagMatrix[residuals;params`q];
  seasResid:flip params[`Q]xprev\:residuals;
  params[`additionalResiduals]:$[params[`q]&count params`Q;
    m#flip params[`additionalQ]xprev\:residuals;
    2#0f
    ];
  // Normal arima vals
  vals:(exog;lagVal;residVal;seasLag;seasResid);
  params[`matrix]:(,'/)m#'vals;
  // Use optimizer function to improve SARMA coefficients
  .ml.optimize.BFGS[ts.i.SARMA.maxLikelihood;coeffs;params;::]`xVals
  }

// @private
// @kind function
// @category fitUtility
// @desc Calculation of the error when finding the SARIMA coefficients
// @param coeffs {dictionary} Coefficients of SARIMA model
// @param dict {dictionary} Additional parameters required in calculation
// @return {float} The square root of the summed, squared errors
ts.i.SARMA.maxLikelihood:{[coeffs;dict]
  // Get additional seasonal parameters 
  dict,:ts.i.SARMA.preproc[coeffs;dict];
  // Calculate SARIMA model including the additional seasonal coeffs
  preds:ts.i.SARMA.eval[coeffs;dict];
  // Calculate error
  sqrt sum n*n:preds-dict`true
  }

// @private
// @kind function
// @category fitUtility
// @desc Sort ARMA coefficients and parameters into correct order
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param coeff {number[]} Coefficients for calculating residuals
// @param params {dictionary} Parameter sets used to fit the ARMA model
// @param errors {dictionary} Error and coefficient dictionary
// @param n {int} The number/order of time lags in estimated AR model
// @return {number[]} Information needed for future predictions
ts.i.ARMA.sortValues:{[endog;coeff;params;errors;n]
  (params[`p]#neg[sum params`q`p]#coeff;neg[params`q]#coeff),
  (neg[n]#endog;neg[params`q]#errors`errorVals;errors`estCoeffs),
  enlist params
  }

// @private
// @kind function
// @category fitUtility
// @desc Sort SARMA coefficients and parameters into correct order 
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model this is the target variable from which a value is to be 
//   predicted
// @param coeff {number[]} Coefficients for calculating residuals
// @param params {dictionary} Parameter sets used to fit the SARMA model
// @param errors {dictionary} Error and coefficient dictionary
// @param n {int} The number/order of time lags in estimated AR model
// @return {dictionary} Information needed for future predictions
ts.i.SARMA.sortValues:{[endog;coeff;params;errors;n]
  // Number of seasonal components
  seasParams:count raze params`P`Q;
  // Separate coeffs into normal and seasonal componants
  coeffNorm:neg[seasParams]_coeff;
  coeffSeas:neg[seasParams]#coeff;
  SARMAparams:(params[`p]#neg[sum params`q`p]#coeffNorm;
    neg[params`q]#coeffNorm;count[params`P]#coeffSeas;
    neg count[params`Q]#coeffSeas),
    (#[neg n|max raze params`P`additionalP;endog];
     #[neg max raze params`p`Q`additionalQ;errors`errorVals];errors`estCoeffs);
  // Update dictionary values for seasonality funcs
  paramKeys:`P`Q`additionalP`additionalQ;
  params[paramKeys]:params[paramKeys]-min params`m;
  SARMAparams,enlist params,`trend`n!params[`trend],n
  }

// Prediction function utilities

// @private
// @kind function
// @category predictUtility
// @desc Predict a set number of future values based on a fit model 
//   AR/ARMA/SARMA
// @param model {dictionary} All information regarding model coefficients and 
//   required residual information
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param len {int} The number of future data points to be predicted
// @param predFunc {fn} The function to be used for prediction
// @return {number[]} Predicted values based on fit model
ts.i.predictFunction:{[model;exog;len;predFunc]
  vals:(model`lagVals;model`residualVals;());
  last{x>count y 2}[len;]predFunc
    [model`coefficients;exog;model`paramDict;;model`residualCoeffs]/vals
  }

// ARMA/AR model prediction functionality

// @private
// @kind function
// @category predictUtility
// @desc Prediction function for ARMA model
// @param model {dictionary} All information regarding model coefficients and
//   required residual information
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param len {int} The number of future data points to be predicted
// @return {number[]} Predicted values based on fit ARMA model
ts.i.ARMA.predictFunction:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  ts.i.predictFunction[model;exog;len;ts.i.ARMA.singlePredict]
  }

// @private
// @kind function
// @category predictUtility
// @desc Predict a single ARMA value
// @param coeffs {number[]} Model coefficients retrieved from initial fit model
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param dict {dictionary} Additional information which can dictate the 
//   behaviour when making a prediction
// @param pastPreds {number[]} Previously predicted values
// @param residualCoeffs {number[]} Coefficients to estimate the residuals
// @return {number[]} Information required for the prediction of a set of ARMA
//   values
ts.i.ARMA.singlePredict:{[coeffs;exog;dict;pastPreds;residualCoeffs]
  exog:exog count pastPreds 2;
  matrix:exog,raze#[neg dict`p;pastPreds 0],pastPreds 1;
  preds:$[dict`trend;
    coeffs[0]+matrix mmu 1_coeffs;
    coeffs mmu matrix
    ];
  if[count pastPreds 1;
    estVals:exog,pastPreds 0;
    pastPreds[1]:(1_pastPreds 1),preds-mmu[residualCoeffs;estVals]
    ];
  ((1_pastPreds 0),preds;pastPreds 1;pastPreds[2],preds)
  }

// @private
// @kind function
// @category predictUtility
// @desc Prediction function for AR model
// @param model {dictionary} All information regarding model coefficients and
//   required residual information
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param len {int} The number of future data points to be predicted
// @return {number[]} Predicted values based on fit AR model
ts.i.AR.predictFunction:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  model[`paramDict]:enlist[`p]!enlist count model`pCoeff;
  model[`residualCoeffs]:();
  model[`residualVals]:();
  ts.i.predictFunction[model;exog;len;ts.i.AR.singlePredict]
  }

// Predict a single AR value
ts.i.AR.singlePredict:ts.i.ARMA.singlePredict

// SARIMA model calculation functionality

// @private
// @kind function
// @category predictUtility
// @desc Prediction function for SARMA model
// @param model  {dictionary} All information regarding model coefficientss and
//   required residual information
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param len {int} The number of future data points to be predicted
// @return {number[]} Predicted values based on fit SARMA model
ts.i.SARMA.predictFunction:{[model;exog;len]
  exog:ts.i.predDataCheck[model;exog];
  $[count raze model`paramDict;
    ts.i.predictFunction[model;exog;len;ts.i.SARMA.singlePredict];
    ts.i.AR.predictFunction[model;exog;len]
    ]
  }

// @private
// @kind function
// @category predictUtility
// @desc Predict a single SARMA value
// @param coeffs {dictionary} Model coefficients retrieved from initial fit 
//   model
// @param exog {float[]|(::)} Exogenous variables, are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param dict {dictionary} Additional information which can dictate the 
//   behaviour when making a prediction
// @param pastPreds {number[]} Previously predicted values
// @param residualCoeffs {number[]} Coefficients to calculate the residual 
//   errors
// @return {number[]} Information required for the prediction of SARMA values
ts.i.SARMA.singlePredict:{[coeffs;exog;dict;pastPreds;residualCoeffs];
  exog:exog count pastPreds 2;
  dict,:ts.i.SARMA.preproc[coeffs;dict];
  preds:ts.i.SARMA.predictVal[coeffs;pastPreds;exog;dict];
  if[count pastPreds 1;
    estVals:exog,neg[dict`n]#pastPreds 0;
    pastPreds[1]:(1_pastPreds 1),preds-mmu[residualCoeffs;estVals]
    ];
  // Append new lag values, for next step calculations
  ((1_pastPreds 0),preds;pastPreds 1;pastPreds[2],preds)
  }

// @private
// @kind function
// @category predictUtility
// @desc Calculate additional coefficients for SARMA prediction 
//   surrounding seasonal components
// @param coeffs {dictionary} Model coefficients retrieved from initial fit 
//   model
// @param dict {dictionary} Additional information which can dictate the 
//   behaviour in different situations where predictions are being made 
// @return {dictionary} Seasonal parameters for prediction in SARMA models
ts.i.SARMA.preproc:{[coeffs;dict]
  // Calculate or retrieve all necessary seasonal lagged values for SARMA 
  // prediction and split up the coefficients to their respective p,q,P,Q parts
  pVals:(dict[`trend] _coeffs)til dict`p;
  qVals:((dict[`trend]+dict`p)_coeffs)til dict`q;
  pSeasonVals:((dict[`trend]+sum dict`q`p)_coeffs)til count dict`P;
  qSeasonVals:neg[count dict`Q]#coeffs;
  // Append new lags to original dictionary
  dictKeys:`additionalpCoeff`additionalqCoeff;
  dictVals:(ts.i.SARMA.multiplySeason[`p;pVals;pSeasonVals;dict];
   ts.i.SARMA.multiplySeason[`q;qVals;qSeasonVals;dict]);
  dictKeys!dictVals
  }

// @private
// @kind function
// @category predictUtility
// @desc Function to extract additional seasonal multiplied 
//   coefficients. These coefficients multiply p x P vals and q x Q vals
// @param dictKeys {symbol} Key of dictionary to extract info from 
// @param normVals {number[]} Non seasonal coefficients
// @param seasonVals {number[]} Seasonal coefficients
// @param dict {dictionary} Model parameters retrieved from initial fit model
// @return {dictionary} Seasonal coefficients multiplied by non seasonal 
//   coefficients
ts.i.SARMA.multiplySeason:{[dictKey;normVals;seasonVals;dict]
  $[dict[dictKey]&min count dict upper dictKey;
    (*/)flip normVals cross seasonVals;
    2#0f
    ]
  }

// @private
// @kind function
// @category predictUtility
// @desc Predict a single SARMA value
// @param coeffs {number[]} Model coefficiants retrieved from initial fit model
// @param pastPreds {number[]} Previously predicted values
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @param dict {dictionary} Additional information which can dictate the 
//   behaviour when making a prediction
// @return {number[]} information required for the prediction of a set of SARMA 
//   values
ts.i.SARMA.predictVal:{[coeffs;pastPreds;exog;dict]
  dict[`additionalResiduals]:$[dict[`q]&min count dict`Q;
    pastPreds[1]dict`additionalQ;
    2#0f
    ];
  dict[`additionalLags]:$[dict[`p]&min count dict`P;
    pastPreds[0]dict`additionalP;
    2#0f
    ];
  SARMAvals:raze#[neg dict`p;pastPreds 0],#[neg dict`q;pastPreds 1],
    pastPreds[0][dict`P],pastPreds[1]dict`Q;
  dict[`matrix]:exog,SARMAvals;
  ts.i.SARMA.eval[coeffs;dict]
  }

// @private
// @kind function
// @category predictUtility
// @desc Calculate the value of a SARMA prediction based on 
//   provided coeffs/dictionary
// @param coeffs {number[]} Model coefficients retrieved from initial fit model
// @param dict {dictionary} Additional information which can dictate the 
//   behaviour when making a prediction
// @return {number[]} The SARMA prediction values 
ts.i.SARMA.eval:{[coeffs;dict]
  normVals  :mmu[dict`matrix;dict[`trend] _coeffs];
  seasResids:mmu[dict`additionalResiduals;dict`additionalqCoeff];
  seasLags  :mmu[dict`additionalLags;dict`additionalpCoeff];
  $[dict`trend;coeffs[0]+;]normVals+seasResids+seasLags
  }

// @private
// @kind function
// @category predictUtility
// @desc Calculate a single ARCH value, 
// @param coeffs {dictionary} Model coefficients retrieved from 
//   initial fit model
// @param pastPreds {number[]} Previously predicted values
// @return {number[]} Residuals and predicted values
ts.i.ARCH.singlePredict:{[coeffs;pastPreds]
  predict:coeffs[0]+pastPreds[0] mmu 1_coeffs;
  ((1_pastPreds 0),predict;pastPreds[1],predict)
  }

// Akaike Information Criterion

// @private
// @kind function
// @category aicUtility
// @desc Calculate the Akaike Information Criterion
// @param true {number[]} True values
// @param pred {number[]} Predicted values
// @param params {number[]} The lag/residual parameters
// @return {float} Akaike Information Criterion score
ts.i.aicScore:{[true;pred;params]
  // Calculate residual sum of squares, normalised for number of values
  sumSquares:{wsum[x;x]%y}[true-pred;n:count pred];
  // Number of parameter
  k:sum params;
  aic:(2*k)+n*log sumSquares;
  // If k<40 use the altered aic score
  $[k<40;aic+(2*k*k+1)%n-k-1;aic]
  }

// @private
// @kind function
// @category aicUtility
// @desc Fit a model, predict the test, return AIC score 
//   for a single set of input params
// @param train {dictionary} Training data as a dictionary with 
//   endog and exog data
// @param test {dictionary} Testing data as a dictionary with 
//   endog and exog data
// @param len {integer} Number of steps in the future to be predicted
// @param params {dictionary} Parameters used in prediction
// @return {float} Akaike Information Criterion score
ts.i.aicFitScore:{[train;test;len;params]
  // Fit an model using the specified parameters
  model:ts.ARIMA.fit[train`endog;train`exog]. params`p`d`q`trend;
  // Predict using the fitted model
  preds:model[`predict][test`exog;len];
  // Score the predictions
  ts.i.aicScore[len#test`endog;preds;params]
  }

// Autocorrelation functionality

// @private
// @kind function
// @category autocorrelationUtility
// @desc Lagged covariance between a dataset at time t and time t-lag
// @param data {number[]} Vector on which to calculate the lagged covariance
// @param lag {int} Size of the lag to use when calculating covariance
// @return {float} Covariance between a time series and lagged version of 
//   itself
ts.i.lagCovariance:{[data;lag]
  cov[neg[lag] _ data;lag _ data]
  }

// @private
// @kind function
// @category autocorrelationUtility
// @desc Calculate the autocorrelation between a time series
//   and lagged version of itself
// @param data {number[]} Vector on which to calculate the lagged covariance
// @param lag {int} Size of the lag to use when calculating covariance
// @return {float} Autocorrelation between a time series and lagged version of
//   itself
ts.i.autoCorrFunction:{[data;lag]
  ts.i.lagCovariance[data;lag]%var data
  }

// Matrix creation/manipulation functionality

// @private
// @kind function
// @category matrixUtilities
// @desc Create a lagged matrix with each row containing the original
//   data as its first element and the remaining 'lag' values as additional row
//   elements
// @param data {number[]} Vector from which to create the lagged matrix
// @param lag {int} Size of the lag to use when creating lagged matrix
// @return {number[][]} A numeric matrix containing original data augmented 
//   with lagged versions of the original dataset.
ts.i.lagMatrix:{[data;lag]
  data til[count[data]-lag]+\:til lag
  }

// @private
// @kind function
// @category matrixUtilities
// @desc Convert a simple table into a matrix
// @param data {table} Simple table to be converted to a matrix representation
// @return {number[]} Matrix representation of the input table in the same 
//   'configuration'
ts.i.tabToMatrix:{[data]
  flip value flip data
  }

// Stationarity functionality used to test if datasets are suitable for 
// application of the ARIMA and to facilitate transformation of the data to a
// more suitable form if relevant

// @private
// @kind function
// @category stationaryUtilities
// @desc Calculate relevant augmented dickey fuller statistics using
//   python
// @param data {dictionary|table|number[]} Dataset to be testing for 
//   stationarity
// @param dtype {short} Type of the dataset that's being passed to the function
// @return {number[]} All relevant scores from an augmented dickey fuller test
ts.i.stationaryScores:{[data;dtype]
  // Calculate the augmented dickey-fuller scores for a dict/tab/vector input
  scores:{.ml.fresh.i.adFuller[x]`}@'
    $[98h=dtype;
        flip data;
      99h=dtype;
        data;
      dtype in(6h;7h;8h;9h);
        enlist data;
      '"Inappropriate type provided"
      ];
  flip{x[0 1],(0.05>x 1),value x 4}each$[dtype in 98 99h;value::;]scores
  }

// @private
// @kind function
// @category stationaryUtilities
// @desc Are all of the series provided by a user stationary,
//   determined using augmented dickey fuller?
// @param data {dictionary|table|number[]} Dataset to be testing for 
//   stationarity
// @return {boolean} Indicate if all time series are stationary or not
ts.i.stationary:{[data]
  (all/)ts.i.stationaryScores[data;type data][2]
  }

// Differencing utilities

// @private
// @kind function
// @category differUtility
// @desc Apply time-series differencing and remove first d elements
// @param data {number[]} Dataset to apply differencing to
// @param d {int} Order of time series differencing
// @return {number[]} Differenced time series
ts.i.diff:{[data;d]
  diffData:d{deltas x}/data;
  d _ diffData
  }

// @private
// @kind function
// @category differUtility
// @desc Apply seasonal differencing and remove first d elements
// @param d {int} How many points in the past does data need to be
//   differenced with respect to
// @param data {number[]} Dataset to apply differencing to 
// @return {number[]} Differenced time series
ts.i.seasonDiff:{[d;data]
  diffData:data - xprev[d;data];
  d _ diffData
  }

// @private
// @kind function
// @category differUtility
// @desc Revert seasonally differenced data to correct representation
// @param originData {number[]} Set of original dataset saved before being 
//   differenced
// @param diffData {number[]} Differenced dataset
// @return {number[]} Data reverted back to its original format before 
//   differencing 
ts.i.reverseSeasonDiff:{[originData;diffData]
  seasonData:originData,diffData;
  n:count originData;
  [n]_first{x[1]<y}[;count seasonData]ts.i.revertDiffFunc[n]/(seasonData;n)
  }

// @private
// @kind function
// @category differUtility
// @desc Revert each individual seasonally differenced data to correct 
//   representation one by one
// @param n {int} Number of datapoints to revert
// @param diffInfo {number[]} The differenced dataset along with what index in
//   the dataset is currently being reverted to its original state
// @return {number[]} The updated dataset along with the next index of the list 
//  that's to be updated next
ts.i.revertDiffFunc:{[n;diffInfo]
  seasonDiff:diffInfo 0;
  i:diffInfo 1;
  seasonDiff[i]:seasonDiff[i-n]+seasonDiff i;
  (seasonDiff;i+1)
  }

// Error flags

// @private
// Functions used to flag errors
ts.i.err.stat:{'`$"Time series not stationary, try another value of d"}
ts.i.err.len:{'`$"Endog length less than length"}
ts.i.err.exog:{'`$"Test exog length does not match train exog length"}

// Checks on suitability of datasets for application of time-series analysis

// @private
// @kind function
// @category dataCheckUtility
// @desc Check that the lengths of endogenous and exogenous data when
//   fitting the model are consistent, in the case they are not flag an error,
//   ensure that the exogenous data is returned as a matrix
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param exog {float[]|(::)} Exogenous variables are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @return {number[]} Exogenous data as a matrix
ts.i.fitDataCheck:{[endog;exog]
  // Accept null as input
  if[exog~(::);exog:()];
  // check that exogenous variable length is appropriate
  if[not[()~exog]&count[endog]>count exog;ts.i.err.len[]];
  // convert exon table to matrix
  $[98h~type exog;:"f"$ts.i.tabToMatrix exog;()~exog;:exog;:"f"$exog];
  }

// @private
// @kind function
// @category dataCheckUtility
// @desc Ensure that all required keys are present for the application
//   of the various prediction functions
// @param dict {dictionary} dictionary parameter to be validated
// @param keyVals {symbol[]} Keys which should be present in order to fully 
//   execute the logic of the function
// @param input {string} Name of input dictionary which issue is highlighted in
// @return {err|::} Will error on incorrect inputs otherwise run silently
ts.i.dictCheck:{[dict;keyVals;input]
  if[99h<>type dict;'input," must be a dictionary input"];
  validKeys:keyVals in key dict;
  if[not all validKeys;
    invalid:sv[", ";string[keyVals]where not validKeys];
    '"The following required dictionary keys for '",input,
     "' are not provided: ",invalid
    ];
  }
 
// @private
// @kind function
// @category dataCheckUtility
// @desc Check that the exogenous data match the expected input when
//   predicting data using a the model are consistent, in the case they are 
//   not, flag an error ensure that the exogenous data is returned as a matrix
// @param model {dictionary} Dictionary containing required information to 
//   predict future values
// @param exog {float[]|(::)} Exogenous variables, are additional variables 
//   which may be accounted for to improve the model, if (::)/()
// @return {number[]} Exogenous data as a matrix
ts.i.predDataCheck:{[model;exog]
  // Allow null to be provided as exogenous variable
  if[exog~(::);exog:()];
  // Check that the fit and new params are equivalent
  if[not count[model`exogCoeff]~count exog 0;ts.i.err.exog[]];
  // Convert exogenous variable to a matrix if required
  $[98h~type exog;"f"$ts.i.tabToMatrix exog;()~exog;:exog;"f"$exog]
  }

// @private
// @kind function
// @category dataCheckUtility
// @desc Apply seasonal and non-seasonal time-series differencing,error
//   checking stationarity of the dataset following application of differencing
// @param endog {number[]} Endogenous variable (time-series) from which to 
//   build a model. This is the target variable from which a value is to be 
//   predicted
// @param d {int} Non seasonal differencing component
// @param seasonDict {dictionary} Dictionary containing relevant seasonal
//  differencing components
// @return {dictionary} Seasonal and nonseasonally differenced stationary 
//   time-series
ts.i.differ:{[endog;d;seasonDict]
  // Apply non seasonal differencing if appropriate (handling of AR/ARMA)
  if[seasonDict~()!();seasonDict[`D]:0b];
  initDiff:ts.i.diff[endog;d];
  // Apply seasonal differencing if appropriate
  finalDiff:$[seasonDict[`D];
    seasonDict[`D]ts.i.seasonDiff[seasonDict`m]/initDiff;
    initDiff];
  // Check stationarity
  if[not ts.i.stationary[finalDiff];ts.i.err.stat[]];
  // Return integrated data
  `final`init!(finalDiff;initDiff)
  }

// Feature extraction utilities

// @private
// @kind function
// @category featureExtractUtilities
// @desc Apply a user defined unary function across a dataset 
//   using a sliding window of specified length
//   Note: this is a modified version of a function provided in qidioms
//   using floating point windows instead of long windows to increase the 
//   diversity of functions that can be applied
// @param func {fn} Unary function to be applied with the data in the sliding
//  window
// @param winSize {int} Size of the sliding window 
// @param data {number[]} Data on which the sliding window and associated 
//   function are to be applied
// @return {number[]} Result of the application of the function on each of the 
//   sliding window components over the data vector
ts.i.slidingWindowFunction:{[func;winSize;data]
  0f,-1_func each{1_x,y}\[winSize#0f;data]
  }

// @private
// @kind function
// @category featureExtractUtilities
// @desc Set up the order for the inputs of the sliding window function
// @param tab {table} Dataset onto which to apply the windowed functions 
// @param uniCombs {number[]} Unique combinations of columns/windows and 
//   functions to be applied to the dataset  
// @return {number[]} Result of the application of the function on each of the 
//   sliding window components over the data vector
ts.i.setupWindow:{[tab;uniCombs]
  ts.i.slidingWindowFunction[get string uniCombs 0;uniCombs 1;tab uniCombs 2]
  }

// Plotting utilities 

// @private
// @kind function
// @category plottingUtility
// @desc Plotting function used in the creation of plots
//   for both full and partial autocorrelation graphics
// @param data {number[]} x-axis original dataset
// @param vals {number[]} Calculated values
// @param m {number[]} Bar plot indices
// @param title {string} Title to be given to the plot
// @return {graph} Presents a plot to screen associated with relevant analysis
ts.i.plotFunction:{[data;vals;m;width;title]
  plt:.p.import`matplotlib.pyplot;
  conf:count[m]#1.95%sqrt count data;
  plt[`:bar][m;vals;`width pykw width%2];
  configKeys:`linewidth`linestyle`color`label;
  configVals:3,`dashed`red`conf_interval;
  plt[`:plot][m;conf;pykwargs configKeys!configVals];
  if[0>min vals;
    plt[`:plot][m;neg conf;pykwargs -1_configKeys!configVals]
    ];
  plt[`:legend][];
  plt[`:xlabel]`lags;
  plt[`:ylabel]`acf;
  plt[`:title]title;
  plt[`:show][];
  }
