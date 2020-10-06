\d .ml

// AR/ARMA/SARMA model utilities

// @private
// @kind function
// @category fitUtility
// @fileoverview ARMA model generation
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param params {dict}  parameter sets used to fit the ARMA model
// @return {dict} dictionary containing all information required to make predictions
//   using an ARMA based model
ts.i.ARMA.model:{[endog;exog;params]
  n:1+max params`p`q;
  errCoeff:ts.i.estimateErrorCoeffs[endog;exog;params;n];
  ARMAparams:ts.i.ARMA.parameters[endog;errCoeff`coeffs;params;errCoeff`errors;n];
  mdlKeys:`params`tr_param`exog_param`p_param`q_param`lags`resid`estresid`pred_dict;
  mdlParams:(errCoeff[`coeffs](::;params[`tr]-1;params[`tr]+til count exog 0)),ARMAparams;
  mdlKeys!mdlParams
  }

// @private
// @kind function
// @category fitUtility
// @fileoverview SARMA model generation
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param params {dict}  parameter sets used to fit the SARMA model
// @return {dict} dictionary containing all information required to make predictions
//   using an SARMA based model
ts.i.SARMA.model:{[endog;exog;params]
  n:1+max params`p`q;
  errCoeff:ts.i.estimateErrorCoeffs[endog;exog;params;n];
  coeffs:ts.i.SARMA.coefficients[endog;exog;errCoeff[`errors]`err;errCoeff`coeffs;params];
  SARMAparams:ts.i.SARMA.parameters[endog;coeffs;params;errCoeff`errors;n];
  modelKeys:`params`tr_param`exog_param`p_param`q_param,
    `P_param`Q_param`lags`resid`estresid`pred_dict;
  modelParams:(coeffs(::;params[`tr]-1;params[`tr]+til count exog 0)),SARMAparams;
  modelKeys!modelParams
  }

// @private
// @kind function 
// @category fitUtility
// @fileoverview Estimate error coefficients
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param params {dict}  parameter sets used to estimate error coefficients
// @param n      {integer} number of error coefficients to estimate
// @return {dict} dictionary returning coefficients and errors required for 
//   model generation
ts.i.estimateErrorCoeffs:{[endog;exog;params;n]
  errs :ts.i.estimateErrors[endog;exog;n];
  coeff:ts.i.estimateParams[endog;exog;errs`err;params];
  `errors`coeffs!(errs;coeff)
  }

// @private
// @kind function 
// @category fitUtility
// @fileoverview Estimate ARMA model parameters using ordinary least squares
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param errors {dict}  errors estimated using `i.estimateErrorCoeffs`
// @param params {dict}  parameter sets used to estimate model parameters
// @return {float[]} estimated ARMA model parameters
ts.i.estimateParams:{[endog;exog;errors;params]
  // Create lagged matrices for the endogenous variable and residual errors
  endogm:ts.i.lagMatrix[endog ;params`p];
  resid :ts.i.lagMatrix[errors;params`q];
  // Collect the data needed for estimation
  vals:(exog;endogm;resid);
  // How many data points are required
  m:neg min raze(count[endog]-params[`p`P]),count[errors]-params[`q`Q];
  x:(,'/)m#'vals;
  // add seasonality components
  if[not 0N~params[`P];x:x,'(m #flip[params[`P]xprev\:endog])];
  if[not 0N~params[`Q];x:x,'(m #flip[params[`Q]xprev\:errors])];
  // If required add a trend line variable
  if[params`tr;x:1f,'x];
  y:m#endog;
  first enlist[y]lsq flip x
  }

// @private
// @kind function
// @category fitUtility
// @fileoverview Durbin Levinson function to calculate the coefficients
//   in a pure AR model with no trend for a univariate dataset
//   Implementation can be found here 
//   https://www.stat.purdue.edu/~zhanghao/STAT520/handout/DurbinLevHandout.pdf
// @param data {float[][]} dataset from which to estimate the coefficients
// @param lags {integer} order of the AR(p) model being fit
// @return {float[]} AR(p) coefficients for specified lagged value
ts.i.durbinLevinson:{[data;lags]
  // cast to float
  data:"f"$data;
  mat:(1+lags;1+lags)#0f;
  vec:(1+lags)#0f;
  mat[1;1]:ts.i.autoCorrFunction[data;1];
  vec[1]  :var[data]*(1-xexp[mat[1;1];2]);
  reverse 1_last first(lags-1){[data;d]
    mat:d[0];vec:d[1];n:d[2];
    k:n+1;
    dval:sum mat[n;1+til n]mmu ts.i.lagCovariance[data]each k-1+til n;
    mat[k;k]:(ts.i.lagCovariance[data;k]-dval)%vec[n];
    upd:{[data;n;mat;j]mat[n;j]-(mat[n+1;n+1]*mat[n;1+n-j])}[data;n;mat]each 1+til n;
    mat[k;1+til n]:upd;
    vec[k]:vec[n]*(1-xexp[mat[k;k];2]);
    (mat;vec;n+1)
    }[data]/(mat;vec;1)
  }


// @private
// @kind function
// @category fitUtility
// @fileoverview Estimate residual errors for the Hannan Riessanan method
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab/num[][]} Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param lags   {integer} The number/order of time lags of the model
// @return {dict} Residual errors and parameters for calculation of these parameters
ts.i.estimateErrors:{[endog;exog;lags]
  // Construct an AR model to estimate the residual error parameters
  estresid:ts.AR.fit[endog;exog;lags;0b]`params;
  // Convert the endogenous variable to lagged matrix
  endogm:ts.i.lagMatrix[endog;lags];
  // Predict future values based on estimations from AR model and use to estimate error
  err:(lags _endog)-((neg[count endogm]#exog),'endogm)mmu estresid;
  `params`err!(estresid;err)
  }


// @private
// @kind function
// @category fitUtility
// @fileoverview Estimate coefficients as starting points to calculate the sarima coeffs
// @param endog  {num[]} Endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param exog   {tab} Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param resid  {num[][]} residual errors estimated using i.estimateErrorCoeffs 
// @param coeff  {num[][]} Estimated coefficients for ARMA model using OLS
// @param params {dict} Information on seasonal and non seasonal lags to be accounted for
// @return {dict} updated optimized coefficients for SARMA model
ts.i.SARMA.coefficients:{[endog;exog;resid;coeff;params]
  // data length to use
  lenq:count[resid]-max raze params[`q`Q`seas_add_Q];
  lenp:count[endog]-max raze params[`p`P`seas_add_P];
  // prediction values
  params[`real]:#[m:neg min lenp,lenq;endog];
  // get lagged values
  lagVal:ts.i.lagMatrix[endog;params`p];
  // get seasonal lag values
  seasLag:flip params[`P]xprev\:endog;
  // get additional seasonal lag values
  params[`seas_lag_add]:$[params[`p]&min count params`P;
    m#flip params[`seas_add_P]xprev\:endog;
    2#0f
    ];
  // get resid vals
  residVal:ts.i.lagMatrix[resid;params`q];
  seasResid:flip params[`Q]xprev\:resid;
  params[`seas_resid_add]:$[params[`q]&min count params`Q;
    m#flip params[`seas_add_Q]xprev\:resid;
    2#0f
    ];
  // normal arima vals
  vals:(exog;lagVal;residVal;seasLag;seasResid);
  params[`norm_mat]:(,'/)m#'vals;
  optD:`xk`args!(coeff;params);
  // use optimizer function to improve SARMA coefficients
  .ml.optimize.BFGS[ts.i.SARMA.maxLikelihood;coeff;params;::]`xVals
  }

// @private
// @kind function
// @category fitUtility
// @fileoverview Calculation of the errors in calculation of the SARIMA coefficients 
// @param params {dict} Parameters required for calculation of SARIMA coefficients
// @param dict {dict} Additional parameters required in calculation
// @return {float} returns the square root of the summed, squared errors
ts.i.SARMA.maxLikelihood:{[params;dict]
  // get additional seasonal parameters 
  dict,:ts.i.SARMA.preproc[params;dict];
  // calculate sarima model including the additional seasonal coeffs
  preds:ts.i.SARMA.eval[params;dict];
  // calculate error
  sqrt sum n*n:preds-dict`real
  }

// @private
// @kind function
// @category fitUtility
// @fileoverview Extract fitted ARMA model params to return
// @param endog  {num[]} endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param coeff  {num[]} error coefficients
// @param params {dict}  information on setup of ARMA model
// @param errors {dict} error and parameter dictionary information
// @param lags {integer} the number/order of time lags of the model
// @return {num[]} list of parameters needed for future predictions
ts.i.ARMA.parameters:{[endog;coeff;params;errors;lags]
  (params[`p]#neg[sum params`q`p]#coeff;neg[params`q]#coeff),
  (neg[lags]#endog;neg[params`q]#errors`err;errors`params),
  enlist params
  }

// @private
// @kind function
// @category fitUtility
// @fileoverview Extract fitted SARMA model params to return
// @param endog  {num[]} endogenous variable (time-series) from which to build a model
//   this is the target variable from which a value is to be predicted
// @param coeff  {num[]} error coefficients
// @param params {dict}  information on setup of ARMA model
// @param errors {dict} error and parameter dictionary information
// @param lags {integer} the number/order of time lags of the model
// @return {dict} parameters needed for future predictions
ts.i.SARMA.parameters:{[endog;coeff;params;errors;lags]
  // number of seasonal components
  ns:count raze params`P`Q;
  // Separate coeffs into normal and seasonal componants
  coefn:neg[ns]_coeff;coefs:neg[ns]#coeff;
  sarmaParams:(params[`p]#neg[sum params`q`p]#coefn;
               neg[params`q]#coefn;count[params`P]#coefs;
               neg count[params`Q]#coefs),
              (#[neg lags|max raze params`P`seas_add_P;endog];
               #[neg max raze params`p`Q`seas_add_Q;errors`err];
               errors`params);
  // Update dictionary values for seasonality funcs
  params[`P`Q`seas_add_P`seas_add_Q]:params[`P`Q`seas_add_P`seas_add_Q]-min params[`m];
  sarmaParams,enlist params,`tr`n!params[`tr],lags
  }


// Prediction function utilities

// @private
// @kind list
// @category predictUtility
// @fileoverview lists of keys which must be present in each application of the
//   various prediction functions to ensure the application of prediction is valid
ts.i.AR.keyList    :`params`tr_param`exog_param`p_param`lags
ts.i.ARMA.keyList  :ts.i.AR.keyList,`q_param`resid`estresid`pred_dict
ts.i.ARIMA.keyList :ts.i.ARMA.keyList,`origd
ts.i.SARIMA.keyList:ts.i.ARIMA.keyList,`origs`P_param`Q_param
ts.i.ARCH.keyList  :`params`tr_param`p_param`resid

// @private
// @kind function
// @category predictUtility
// @fileoverview predict a set number of values based on a fit model AR/ARMA/SARMA
// @param mdl    {dict} contains all information regarding model parameters and required
//   residual information
// @param exog   {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param len    {integer} the number of data points to be predicted
// @param predfn {function} the function to be used for prediction
// @return {num[]} predicted values based on fit model
ts.i.predictFunction:{[mdl;exog;len;predfn]
  vals:(mdl`lags;mdl`resid;());
  last{x>count y 2}[len;]predfn[mdl`params;exog;mdl`pred_dict;;mdl`estresid]/vals
  }


// ARMA/AR model prediction functionality

// @private
// @kind function
// @category predictUtility
// @fileoverview prediction function for ARMA model
// @param mdl  {dict} contains all information regarding model parameters and required
//   residual information
// @param exog {tab} exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param len  {integer} the number of data points to be predicted
// @return     {num[]} predicted values based on fit ARMA model
ts.i.ARMA.predictFunction:{[mdl;exog;len]
  exog:ts.i.predDataCheck[mdl;exog];
  ts.i.predictFunction[mdl;exog;len;ts.i.ARMA.singlePredict]
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview predict a single ARMA value
// @param params   {num[]} model parameters retrieved from initial fit model
// @param exog     {tab} exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param dict     {dict} additional information which can dictate the behaviour
//   when making a prediction
// @param pvals    {num[]} previously predicted values
// @param estresid {num[]} estimates of the residual errors
// @return {num[]} information required for the prediction of a set of ARMA values
ts.i.ARMA.singlePredict:{[params;exog;dict;pvals;estresid]
  exog:exog count pvals 2;
  normmat:exog,raze#[neg[dict`p];pvals[0]],pvals[1];
  pred:$[dict`tr;
    params[0]+normmat mmu 1_params;
    params mmu normmat
    ];
  if[count pvals 1;
    estvals:exog,pvals[0];
    pvals[1]:(1_pvals[1]),pred-mmu[estresid;estvals]
    ];
  ((1_pvals[0]),pred;pvals[1];pvals[2],pred)
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview prediction function for AR model
// @param mdl  {dict} contains all information regarding model parameters and required
//   residual information
// @param exog {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param len  {integer} the number of data points to be predicted
// @return     {num[]} predicted values based on fit AR model
ts.i.AR.predictFunction:{[mdl;exog;len]
  exog:ts.i.predDataCheck[mdl;exog];
  mdl[`pred_dict]:enlist[`p]!enlist count mdl`p_param;
  mdl[`estresid]:();
  mdl[`resid]:();
  ts.i.predictFunction[mdl;exog;len;ts.i.AR.singlePredict]
  }

// Predict a single AR value
ts.i.AR.singlePredict:ts.i.ARMA.singlePredict


// SARIMA model calculation functionality

// @private
// @kind function
// @category predictUtility
// @fileoverview prediction function for SARMA model
// @param mdl  {dict} contains all information regarding model parameters and required
//   residual information
// @param exog {tab}   Exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param len  {integer} the number of data points to be predicted
// @return     {num[]} predicted values based on fit SARMA model
ts.i.SARMA.predictFunction:{[mdl;exog;len]
  exog:ts.i.predDataCheck[mdl;exog];
  $[count raze mdl[`pred_dict];
    ts.i.predictFunction[mdl;exog;len;ts.i.SARMA.singlePredict];
    ts.i.AR.predictFunction[mdl;exog;len]
    ]
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview predict a single SARMA value
// @param params   {num[]} model parameters retrieved from initial fit model
// @param exog     {tab} exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param dict     {dict} additional information which can dictate the behaviour
//   when making a prediction
// @param pvals    {num[]} previously predicted values
// @param estresid {num[]} estimates of the residual errors
// @return {num[]} information required for the prediction of SARMA values
ts.i.SARMA.singlePredict:{[params;exog;dict;pvals;estresid];
  exog:exog count pvals 2;
  dict,:ts.i.SARMA.preproc[params;dict];
  pred:ts.i.SARMA.predictValue[params;pvals;exog;dict];
  if[count pvals 1;
    estvals:exog,neg[dict`n]#pvals 0;
    pvals[1]:(1_pvals[1]),pred-mmu[estresid;estvals]
    ];
  // append new lag values, for next step calculations
  ((1_pvals[0]),pred;pvals[1];pvals[2],pred)
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview Calculate new required lags for SARMA prediction surrounding
//   seasonal components
// @param params {dict} model parameters retrieved from initial fit model
// @param dict   {dict} additional information which can dictate the behaviour
//   in different situations where predictions are being made 
// @return       {dict} seasonal parameters for prediction in SARMA models
ts.i.SARMA.preproc:{[params;dict]
  // 1. Calculate or retrieve all necessary seasonal lagged values for SARMA prediction
  // split up the coefficients to their respective p,q,P,Q parts
  lagp:(dict[`tr] _params)[til dict`p];
  lagq:((dict[`tr]+dict`p)_params)[til dict`q];
  lagSeasp:((dict[`tr]+sum dict`q`p)_params)[til count[dict`P]];
  lagSeasq:neg[count dict`Q]#params;
  // Function to extract additional seasonal multiplied coefficients
  // These coefficients multiply p x P vals and q x Q vals
  seas_multi:{[x;y;z;d]$[d[x]&min count d upper x;(*/)flip y cross z;2#0f]};
  // append new lags to original dictionary
  dictKeys:`add_lag_param`add_resid_param;
  dictVals:(seas_multi[`p;lagp;lagSeasp;dict];seas_multi[`q;lagq;lagSeasq;dict]);
  dictKeys!dictVals
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview predict a single SARMA value
// @param params   {num[]} model parameters retrieved from initial fit model
// @param pvals    {num[]} previously predicted values
// @param exog     {tab} exogenous variables, are additional variables which
//   may be accounted for to improve the model
// @param dict     {dict} additional information which can dictate the behaviour
//   when making a prediction
// @return {num[]} information required for the prediction of a set of SARMA values
ts.i.SARMA.predictValue:{[params;pvals;exog;dict]
  dict[`seas_resid_add]:$[dict[`q]&min count dict`Q;
    pvals[1]dict[`seas_add_Q];
    2#0f
    ];
  dict[`seas_lag_add]:$[dict[`p]&min count dict`P;
    pvals[0]dict[`seas_add_P];
    2#0f
    ];
  sarmavals:raze#[neg dict`p;pvals 0],#[neg dict`q;pvals 1],pvals[0][dict`P],pvals[1][dict`Q];
  dict[`norm_mat]:exog,sarmavals;
  ts.i.SARMA.eval[params;dict]
  }

// @private
// @kind function
// @category predictUtility
// @fileoverview calculate the value of a SARMA prediction based on 
//   provided params/dictionary
// @param params {num[]} model parameters retrieved from initial fit model
// @param dict   {dict} additional information which can dictate the behaviour
//   when making a prediction
// @return {num[]} the SARMA prediction values 
ts.i.SARMA.eval:{[params;dict]
  normVal  :mmu[dict`norm_mat;dict[`tr] _params];
  seasResid:mmu[dict`seas_resid_add;dict`add_resid_param];
  seasLag  :mmu[dict`seas_lag_add;dict`add_lag_param];
  $[dict`tr;params[0]+;]normVal+seasResid+seasLag
  }


// @private
// @kind function
// @category predictUtility
// @fileoverview calculate a single ARCH value, 
// @param params   {dict}   model parameters retrieved from initial fit model
// @param pvals    {num[]}  list of values over which predictions are composed
// @return {num[]} list containing residuals and predicted values
ts.i.ARCH.singlePredict:{[params;pvals]
  predict:params[0]+pvals[0] mmu 1_params;
  ((1_pvals 0),predict;pvals[1],predict)
  }

// Akaike Information Criterion

// @private
// @kind function
// @category aicUtility
// @fileoverview calculate the Akaike Information Criterion
// @param true   {num[]} true values
// @param pred   {num[]} predicted values
// @param params {num[]} list of the lag/residual parameters
// @return {float} Akaike Information Criterion score
ts.i.aicScore:{[true;pred;params]
  // Calculate residual sum of squares, normalised for number of values
  rss:{wsum[x;x]%y}[true-pred;n:count pred];
  // Number of parameter
  k:sum params;
  aic:(2*k)+n*log rss;
  // if k<40 use the altered aic score
  $[k<40;aic+(2*k*k+1)%n-k-1;aic]
  }

// @private
// @kind function
// @category aicUtility
// @fileoverview Fit a model, predict the test, return AIC score 
//   for a single set of input params
// @param train  {dict}    training data as a dictionary with endog and exog data
// @param test   {dict}    testing data as a dictionary with endog and exog data
// @param len    {integer} number of steps in the future to be predicted
// @param params {dict}    parameters used in prediction
// @return {float} Akaike Information Criterion score
ts.i.aicFitScore:{[train;test;len;params]
  // Fit an model using the specified parameters
  mdl :ts.ARIMA.fit[train`endog;train`exog;;;;]. params`p`d`q`tr;
  // Predict using the fitted model
  pred:ts.ARIMA.predict[mdl;test`exog;len];
  // Score the predictions
  ts.i.aicScore[len#test`endog;pred;params]
  }


// Autocorrelation functionality

// @private
// @kind function
// @category autocorrelationUtility
// @fileoverview Lagged covariance between a dataset at time t and time t-lag
// @param data {num[]}   vector on which to calculate the lagged covariance
// @param lag  {integer} size of the lag to use when calculating covariance
// @return {float} covariance between a time series and lagged version of itself
ts.i.lagCovariance:{[data;lag]
  cov[neg[lag] _ data;lag _ data]
  }

// @private
// @kind function
// @category autocorrelationUtility
// @fileoverview Calculate the autocorrelation between a series
//   and lagged version of itself
// @param data {num[]}   vector on which to calculate the lagged covariance
// @param lag  {integer} size of the lag to use when calculating covariance
// @return {float} autocorrelation between a time series and lagged version of itself
ts.i.autoCorrFunction:{[data;lag]
  ts.i.lagCovariance[data;lag]%var data
  }


// Matrix creation/manipulation functionality

// @private
// @kind function
// @category matrixUtilities
// @fileoverview create a lagged matrix with each row containing the original
//   data as its first element and the remaining 'lag' values as additional row
//   elements
// @param data {num[]} vector from which to create the lagged matrix
// @param lag  {integer} size of the lag to use when creating lagged matrix
// @return {num[][]} a numeric matrix containing original data augmented with
//   lagged versions of the original dataset.
ts.i.lagMatrix:{[data;lag]
  data til[count[data]-lag]+\:til lag
  }

// @private
// @kind function
// @category matrixUtilities
// @fileoverview convert a simple table into a matrix
// @param data {tab} simple table to be converted to a matrix representation
// @return {num[][]} matrix representation of the input table in the same 'configuration'
ts.i.tabToMatrix:{[data]
  flip value flip data
  }


// Stationarity functionality used to test if datasets are suitable for application of the ARIMA
// and to facilitate transformation of the data to a more suitable form if relevant

// @private
// @kind function
// @category stationaryUtilities
// @fileoverview calculate relevant augmented dickey fuller statistics using python
// @param data  {dict/tab/num[]} dataset to be testing for stationarity
// @param dtype {short} type of the dataset that's being passed to the function
// @return {num[]/num[][]} all relevant scores from an augmented dickey fuller test
ts.i.stationaryScores:{[data;dtype]
  // Calculate the augmented dickey-fuller scores for a dict/tab/vector input
  scores:{.ml.fresh.i.adfuller[x]`}@'
    $[98h=dtype;flip data;
      99h=dtype;data;
      dtype in(6h;7h;8h;9h);enlist data;
      '"Inappropriate type provided"];
  flip{x[0 1],(0.05>x 1),value x 4}each$[dtype in 98 99h;value::;]scores
  }

// @private
// @kind function
// @category stationaryUtilities
// @fileoverview Are all of the series provided by a user stationary,
//   determined using augmented dickey fuller?
// @param data  {dict/tab/num[]} dataset to be testing for stationarity
// @return {bool} indicate if all time series are stationary or not
ts.i.stationary:{[data]
  (all/)ts.i.stationaryScores[data;type data][2]
  }


// Differencing utilities

// @private
// @kind function
// @category differUtility
// @fileoverview apply time-series differencing and remove first diff elements
// @param data  {num[]/num[][]} dataset to apply differencing to
// @param diff  {integer} order of time series differencing
// @return {num[]/num[][]} differenced time series
ts.i.diff:{[data;diff]
  diffData:diff{deltas x}/data;
  diff _ diffData
  }

// @private
// @kind function
// @category differUtility
// @fileoverview apply seasonal differencing and remove first diff elements
// @param diff  {integer} how many points in the past does data need to be
//   differenced with respect to
// @param data {num[]/num[][]} dataset to apply differencing to 
// @return {num[]/num[][]} differenced time series
ts.i.seasonDiff:{[diff;data]
  diffData:data - xprev[diff;data];
  diff _ diffData
  }

// @private
// @kind function
// @category differUtility
// @fileoverview revert seasonally differenced data to correct representation
// @param origd  {num[]} set of original dataset saved before being differenced
// @param dfdata {num[]} differenced dataset
// @return {num[]} the data reverted back to its original format before differencing 
ts.i.reverseSeasonDiff:{[origd;dfdata]
  seasd:origd,dfdata;
  n:count origd;
  [n]_first{x[1]<y}[;count[seasd]]{[n;sdi]
  sd:sdi[0];
  i:sdi[1];
  sd[i]:sd[i-n]+sd[i];
  (sd;i+1)}[n]/(seasd;n)
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
// @fileoverview check that the lengths of endogenous and exogenous data when
//   fitting the model are consistent, in the case they are not flag an error,
//   ensure that the exogenous data is returned as a matrix
// @param endog {num[]} endogenous dataset
// @param exog  {tab/num[][]} exogenous dataset
// @return {num[][]} exogenous data as a matrix
ts.i.fitDataCheck:{[endog;exog]
  // Accept null as input
  if[exog~(::);exog:()];
  // check that exogenous variable length is appropriate
  if[not[()~exog]&(count[endog])>count exog;ts.i.err.len[]];
  // convert exon table to matrix
  $[98h~type exog;:"f"$ts.i.tabToMatrix exog;()~exog;:exog;:"f"$exog];
  }

// @private
// @kind function
// @category dataCheckUtility
// @fileoverview ensure that all required keys are present for the application of
//   the various prediction functions
// @param dict    {dict}   the dictionary parameter to be validated
// @param keyvals {sym[]}  list of the keys which should be present in order to
//   fully execute the logic of the function
// @param input   {string} name of the input dictionary which issue is
//   highlighted in
// @return {err/(::)} will error on incorrect inputs otherwise run silently
ts.i.dictCheck:{[dict;keyvals;input]
  if[99h<>type dict;'input," must be a dictionary input"];
  validKeys:keyvals in key dict;
  if[not all validKeys;
    invalid:sv[", ";string[keyvals]where not validKeys];
    '"The following required dictionary keys for '",input,"' are not provided: ",invalid
    ];
  }
 
// @private
// @kind function
// @category dataCheckUtility
// @fileoverview check that the exogenous data match the expected input when
//   predicting data using a the model are consistent, in the case they are not,
//   flag an error ensure that the exogenous data is returned as a matrix
// @param mdl  {dict} dictionary containing required information to predict
//   future values
// @param exog {tab/num[][]} exogenous dataset
// @return {num[][]} exogenous data as a matrix
ts.i.predDataCheck:{[mdl;exog]
  // allow null to be provided as exogenous variable
  if[exog~(::);exog:()];
  // check that the fit and new params are equivalent
  if[not count[mdl`exog_param]~count exog[0];ts.i.err.exog[]];
  // convert exogenous variable to a matrix if required
  $[98h~type exog;"f"$ts.i.tabToMatrix exog;()~exog;:exog;"f"$exog]
  }

// @private
// @kind function
// @category dataCheckUtility
// @fileoverview Apply seasonal and non-seasonal time-series differencing,
//   error checking stationarity of the dataset following application of differencing
// @param endog {num[]}   endogenous dataset
// @param diff  {integer} non seasonal differencing component (integer)
// @param sdict {dict}    dictionary containing relevant seasonal differencing components
// @return {num[]} Seasonal and non-seasonally differenced stationary time-series
ts.i.differ:{[endog;d;s]
  // Apply non seasonal differencing if appropriate (handling of AR/ARMA)
  if[s~()!();s[`D]:0b];
  I:ts.i.diff[endog;d];
  // Apply seasonal differencing if appropriate
  if[s[`D];I:s[`D]ts.i.seasonDiff[s`m]/I];
  // Check stationarity
  if[not ts.i.stationary[I];ts.i.err.stat[]];
  // Return integrated data
  I
  }


// Feature extraction utilities

// @private
// @kind function
// @category featureExtractUtilities
// @fileoverview Apply a user defined unary function across a dataset 
//   using a sliding window of specified length
//   Note: this is a modified version of a function provided in qidioms
//   using floating point windows instead
//   of long windows to increase the diversity of functions that can be applied
// @param func {lambda}  unary function to be applied with the data in the sliding window
// @param win  {integer} size of the sliding window 
// @param data {num[]}   data on which the sliding window and associated function
//   are to be applied
// @return {num[]} result of the application of the function on each of the sliding window
//   components over the data vector
ts.i.slidingWindowFunction:{[func;win;data]
  0f,-1_func each{ 1_x,y }\[win#0f;data]
  }


// Plotting utilities 

// @private
// @kind function
// @category plottingUtility
// @fileoverview Plotting function used in the creation of plots
//   for both full and partial autocorrelation graphics
// @param data  {num[]} x-axis original dataset
// @param vals  {num[]} calculated values
// @param m     {num[]} bar plot indices
// @param title {string} title to be given to the plot
// @return {graph} presents a plot to screen associated with relevant analysis
ts.i.plotFunction:{[data;vals;m;width;title]
  plt:.p.import[`matplotlib.pyplot];
  conf:count[m]#1.95%sqrt count data;
  plt[`:bar][m;vals;`width pykw width%2];
  cfgkeys:`linewidth`linestyle`color`label;
  cfgvals:3,`dashed`red`conf_interval;
  plt[`:plot][m;conf;pykwargs cfgkeys!cfgvals];
  if[0>min vals;
    plt[`:plot][m;neg conf;pykwargs -1_cfgkeys!cfgvals]
    ];
  plt[`:legend][];
  plt[`:xlabel][`lags];
  plt[`:ylabel][`acf];
  plt[`:title][title];
  plt[`:show][];}
