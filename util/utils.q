\d .ml

// Utility functions

// @kind function
// @category utilitiesUtility
// @fileoverview Unique combinations of a vector or matrix
// @param n {int} Number of values required for combinations
// @param vals {int[]} Indexes involved in the combination 
// @return {int[]} Unique combinations of values from the data 
i.combFunc:{[n;vals]
  j@:i:where 0<>k:n-j:1+last vals;
  sumVals:-1_sums@[(1+sum k i)#1;0,sums k i;:;(j,0)-0,-1+j+k i];
  (vals@\:where k),enlist sumVals
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Transform q object to numpy date
// @param date {date} q datetime object
// @return {<} Numpy datetime object
i.q2npDate:{[date]
  dateConvert:("p"$@[4#+["d"$0];-16+type date]date)-"p"$1970.01m;
  .p.import[`numpy;`:array;dateConvert;"datetime64[ns]"]`.
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview  Convert python float32 function to produce correct precision
//   Note check for x~()!() which is required in cases where underlying 
//   representation is float32 for dates/times
// @param data {float[]} Floating point data from the dataFrame
// @param local {bool} Indicates if timezone objects are to be converted
//   to local time (1b) or UTC (0b)
// @return {float[]} Python float32 objects converted to correct precision 
//   in kdb
i.float32Convert:{[data;local]
  $[(local~0b)|data~()!();
    data;
    ?[0.000001>data;"F"$string data;0.000001*floor 0.5+data*1000000]
    ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Convert datetime.timezone types to kdb+ date/time
// @param tab {<} Contains columns with datetime timezone objects
// @param local {bool} Indicates if timezone objects are to be converted
//   to local time (1b) or UTC (0b)
// @return {dict} Datetime objects are converted to kdb date/time objects
i.timezoneConvert:{[tab;local]
  $[local~0b;
    i.dateConvert tab;
    "P"$neg[6]_/:'tab[`:astype;`str][`:to_dict;<;`list]
    ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Convert datetime/datetimetz objects to kdb timestamp
// @param dataFrame {<} Pandas dataFrame containing datetime data
// @return {dict} Datetime objects are converted to timestamps in kdb
i.dateConvert:{[dataFrame]
  nullCols:where any each dataFrame[`:isnull;::][`:to_dict;<;`list];
  $[count nullCols;
    [npCols:`$dateFrame[`:columns.to_numpy][]`;
     dropCols:dataFrame[`:drop;npCols except nulCols;`axis pykw 1];
     nullData:"P"$dropCols[`:astype;`str][`:to_dict;<;`list];
     nonNullData:i.dateDict dataFrame[`:drop;nullCols;`axis pykw 1];
     nullData,nonNullData+1970.01.01D0
    ];
    i.dateDict[dataFrame]+1970.01.01D0
   ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Convert datetime data to integer representation
// @param data {<} Pandas dataframe object containing timedelta objects
// @return {dict} Datetime objects are converted to integer values
i.dateDict:{[data]
  data[`:astype;`int64][`:to_dict;<;`list]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Convert datetime.date/time objects to kdb+ date/time
// @param dateTime {<} Python datetime object
// @param qObj {bool} Indicates if python datetime.date/datetime.time objects
//   are returned as q (1b) or foreign objects (0b)
// @return {datetime;<} kdb date/time format or embedpy object
i.dateTimeConvert:{[dateTime;qObj]
  $[qObj~0b;
    dateTime;
    [firstVal:.p.wrap first dateTime;
     // Convert datetime.time/date to iso string format and convert to kdb+
     // otherwise return foreign
     $[i.isInstance[firstVal;i.dateTime`:time];
       i.isoFormat["N"]each dateTime;
       i.isInstance[firstVal;i.dateTime`:date];
       i.isoFormat["D"]each dateTime;
       dateTime
       ]
     ]
    ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Cast python datetime object to a kdb datatype
// @param cast {str} Data type in which python object will be cast to
// @param dateTime {<} Python datetime object
// @return {any} Python datetime object casted to kdb datatype 
i.isoFormat:{[cast;dateTime]
  cast$.p.wrap[dateTime][`:isoformat][]`
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Apply function to data of various types
// @param func {func} Function to apply to data
// @param data {any} Data of various types
// @return {func} function to apply to data
i.ap:{[func;data] 
  $[0=type data;
      func each data;
    98=type data;
      flip func each flip data;
    99<>type data;
      func data;
    98=type key data;
      key[data]!.z.s value data;
    func each data
    ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Apply function to data of various types
// @param func {func} Function to apply to data
// @param data {any} Data of various types
// @return {func} function to apply to data
i.apUpd:{[func;data] 
  $[0=type data;
      func data;
    98=type data;
      func each data;
    99<>type data;
      func data;
    98=type key data;
      key[data]!.z.s value data;
    func data
    ]
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Find columns of certain types
// @param tab {tab} Data in tabular format
// @param char {char[]} Type of column to find  
// @return {sym[]} Columns containing the type being searched 
i.findCols:{[tab;char]
  metaTab:0!meta tab;
  metaTab[`c]where metaTab[`t]in char
  }

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Checks if object is of a specified type
i.isInstance:.p.import[`builtins][`:isinstance;<]

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Python datetime module
i.dateTime:.p.import`datetime

// @private
// @kind function
// @category utilitiesUtility
// @fileoverview Python pandas dataframe module
i.pandasDF:.p.import[`pandas]`:DataFrame

// Metric utility functions

// @private
// @kind function
// @category metricUtility
// @fileoverview Exclude collinear points 
// @param x {num[]} X coordinate of true positives and false negatives
// @param y {num[]} Y coorfinate of true positives and false negatives
// @returns {num[]} any colinear points are excluded
i.curvePts:{[x;y]
  (x;y)@\:where(1b,2_differ deltas[y]%deltas x),1b
  }

// @private
// @kind function
// @category metricUtility
// @fileoverview Calculate the area under an ROC cirve
// @param x {num[]} X coordinate of true positives and false negatives
// @param y {num[]} Y coorfinate of true positives and false negatives
// @returns {num[]} Area under the curve
i.auc:{[x;y]
  sum 1_deltas[x]*y-.5*deltas y
  }

// Preproc utility functions

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Drop any constant numeric values
// @param data {dict} Numerical data
// @return {dict} All keys with zero variance are removed
i.dropConstant.num:{[num]
  (where 0=0^var each num)_num
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Drop any constant values that aren't numeric
// @param data {dict} Non-numerical data
// @return {dict} All keys with zero variance are removed
i.dropConstant.other:{[data]
  (where{all 1_(~':)x}each data)_data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Find keys of certain types
// @param dict {dict} Data stored as a dictionary
// @param char {char[]} Type of key to find  
// @return {sym[]} Keys containing the type being searched
i.findKey:{[dict;char]
  where({.Q.t abs type dict}each dict)in char
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Fill nulls with 0 
// @param data {tab;num[]} Numerical data
// @return {tab;num[]} Nulls filled with 0 
i.fillMap.zero:{[data]
  0^data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Fill nulls with the median value 
// @param data {tab;num[]} Numerical data
// @return {tab;num[]} Nulls filled with the median value
i.fillMap.median:{[data]
  med[data]^data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Fill nulls with the average value
// @param data {tab;num[]} Numerical data
// @return {tab;num[]} Nulls filled with the average value
i.fillMap.mean:{[data]
  avg[data]^data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Fill nulls forward
// @param data {tab;num[]} Numerical data
// @return {tab;num[]} Nulls filled foward  
i.fillMap.forward:{[data]
  "f"$(data first where not null data)^fills data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Fill nulls depening on timestamp component
// @param time {time[]} Data containing a time component
// @param nulls {any[]} Contains null values
// @return {tab;num[]} Nulls filled in respect to time component
i.fillMap.linear:{[time;vals]
  nullVal:null vals;
  i:where not nullVal; 
  if[2>count i;:vals];
  diffs:1_deltas[vals i]%deltas time i;
  nullVal:where nullVal;
  iBin:0|(i:-1_i)bin nullVal;
  "f"$@[vals;nullVal;:;vals[i][iBin]+diffs[iBin]*time[nullVal]-time[i]iBin]
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Encode categorical features using one-hot encoding
// @param data {sym[]} Data to encode
// @return {dict} One-hot encoded representation 
i.oneHot:{[data]
  vals:asc distinct data;
  vals!"f"$data=/:vals
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Encode categorical features with frequency of 
//   category occurrence
// @param data {sym[]} Data to encode
// @return {num[]} Frequency of occurrance of individual symbols within 
//   a column
i.freqEncode:{[data]
  (groupVals%sum groupVals:count each group data)data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break date column into constituent components
// @param date {date} Data containing a date component
// @return {dict} A date broken into its constituent components
i.timeSplit.d:{[date]
  dateDict:`dayOfWeek`year`month`day!`date`year`mm`dd$/:\:date;
  update weekday:1<dayOfWeek from update dayOfWeek:dayOfWeek mod 7,
    quarter:1+(month-1)div 3 from dateDict
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break month column into constituent components
// @param month {month} Data containing a monthly component
// @return {dict} A month broken into its constituent components
i.timeSplit.m:{[month]
  monthDict:monthKey!(monthKey:`year`mm)$/:\:month;
  update quarter:1+(mm-1)div 3 from monthDict
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break time column into constituent components
// @param time {time} Data containing a time component
// @return {dict} A time broken into its constituent components
i.timeSplit[`n`t`v]:{[time]
  `hour`minute`second!`hh`uu`ss$/:\:time
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break minute columns into constituent components
// @param time {minute} Data containing a minute component
// @return {dict} A minute broken into its constituent components
i.timeSplit.u:{[time]
  `hour`minute!`hh`uu$/:\:time
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break datetime and timestamp columns into constituent 
//   components
// @param time {datetime;timestamp} Data containing a datetime or 
//   datetime component
// @return {dict} A datetime or timestamp broken into its constituent
//   components
i.timeSplit[`p`z]:{[time]raze i.timeSplit[`d`n]@\:time}

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break time endog columns into constituent components
// @param data {any} Data containing a time endog component
// @return {dict} Time or date types broken into their constituent components
i.timeSplit1:{[data]
  i.timeSplit[`$.Q.t type data]data:raze data
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Break time endog columns into constituent components
// @param tab {tab} Contains time endog columns
// @param timeCols {sym[]} Columns to apply coding to, if set to :: all columns
//   with date/time types will be encoded
// @return {dict} All time or date types broken into labeled versions of their
//   constituent components
i.timeDict:{[tab;timeCol]
  timeVals:i.timeSplit1 tab timeCol;
  timeKeys:`$"_"sv'string timeCol,'key timeVals;
  timeKeys!value timeVals
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Ensure that keys in the mapping dictionary matches values in 
//   the sym dictionary
// @param tab {tab} Numerical and categorical data
// @param symDict {dict} Keys indicate columns in the table to be encoded, 
//   values indicate what mapping to use when encoding
// @params mapDict {dict} Map cateogorical values to their encoded values
// @return {err;dict} Error if mapping keys don't match sym values or update
//  symDict if null is passed
i.mappingCheck:{[tab;symDict;mapDict]
  map:key mapDict;
  if[(::)~symDict;
    symCols:i.findCols[tab;"s"];
    symDict:@[symCols!;map;{'"Length of mapping and sym keys don't match"}]
    ];
  if[not all value[symDict]in map;
    '"Mapping keys do not match mapping dictionary"
    ];
  symDict
  }

// @private
// @kind function
// @category preprocessingUtility
// @fileoverview Create one hot encoded columns 
// @param tab {tab} Numerical and categorical data
// @param colName {sym[]} Name of columns in the table to apply encoding to
// @params val {sym[]} One hot encoded values
// @return {dict} Columns in tab transformed to one hot encoded representation
i.oneHotCols:{[tab;colName;val]
  updCols:`$"_"sv'string colName,'val;
  updVals:"f"$tab[colName]='/:val;
  updCols!updVals
  }

// General utility functions

// @private
// @kind function
// @category utility
// @fileoverview Save a model locally
// @param modelName {str;sym} Name of the model to be saved
// @param path {str;sym} The path in which to save the model. If ()/(::) is 
//  used then saves to the current directory 
// @return {null;err} Saves locally or returns an error
i.saveModel:{[modelName;path]
  savePath:i.constructPath[modelName;path];
  save savePath
  }

// @private
// @kind function
// @category utility
// @fileoverview Load a model
// @param modelName {str;sym} Name of the model to be loaded
// @param path {str;sym} The path in which to load the model from. If ()/(::)
//   is used then saves to the current directory 
// @return {null;err} Loads a model or returns an error
i.loadModel:{[modelName;path]
  loadPath:i.constructPath[modelName;path];
  load loadPath
  }


// @private
// @kind function
// @category utility
// @fileoverview Construct a path to save/load a model
// @param modelName {str;sym} Name of the model to be saved/loaded
// @param path {str;sym} The path in which to save/load the model. If ()/(::)
//   is used then saves to the current directory 
// @return {sym;err} Constructs a path or returns an error
i.constructPath:{[modelName;path]  
  pathType:abs type path;
  modelType:abs type modelName;
  if[not modelType in 10 11h;i.inputError"modelName"];
  if[11h=abs modelType;modelName:string modelName];
  joinPath:$[(path~())|path~(::);
      ;
    pathType=10h;
      path,"/",;
    pathType=11h;
      string[path],"/",;
    i.inputError"path"
    ]modelName;
   hsym`$joinPath
   }

// @private
// @kind function
// @category utility
// @fileoverview Return an error for the wrong input type
// @param input {str} Name of the input parameter
// @return {err} Error for the wrong input typr
i.inputError:{[input]
  '`$input," must be a string or a symbol"
  }

// @private
// @kind function
// @category deprecation
// @fileoverview Mapping between old names and new names - can read from file
i.versionMap:.j.k raze read0 hsym`$path,"/util/functionMapping.json"

// @private
// @kind function
// @category utility
// @fileoverview Warning function
i.deprecatedWarning:"Deprecation Warning: function no longer supported as of",
  " version '"

// @private
// @kind function
// @category utility
// @fileoverview Warning function
i.futureWarning:"Future Deprecation Warning: function will no longer be ",
  "callable after version '"

// @private
// @kind function
// @category utility
// @fileoverview Give deprecation warning along with returning the result
//   of the function
// @param func {str} Name of updated function
// @pararm warn {str} Warning message to use
// @param ver {str} Version of the update
// @param res {any} Result from the updated function
// @returns {any} Results from the function
i.depWarn :{[func;warn;ver;res]
  if[not i.ignoreWarning;
    depFunction:$[warn~"deprecatedWarning";{'x};-1];
    depFunction get[".ml.i.",warn],ver,"'. Please use '",func,"' instead."
    ];
  res
  }

// @private
// @kind function
// @category utility
// @fileoverview Run new function and warn user of deprecation of old function
// @param dict {dict} Contains information pertaining to what the new function
//   name is along with warning error information needed
// @returns {any} Results from the updated function 
i.depApply:{[dict]
  (i.depWarn . dict`function`warning`version)get[dict`function]::
  }

// @private
// @kind function
// @category utility
// @fileoverview Run new function and warn user of deprecation of old function
// @param dict {dict} Contains information pertaining to what the new function
//   name is along with warning error information needed
// @returns {any} Results from the updated function 
i.deprecWarning:{[nameKey;versionMap]
  mapping:versionMap nameKey;
  newNames:key mapping;
  newFunctions:i.depApply each value mapping;
  {@[x set y]}'[newNames;newFunctions];
  }[;i.versionMap]

// @private
// @fileOverview Check that the length of the endog and another parameter
//   are equal 
// @param endog {float[]} The endogenous variable
// @param param {num[][];num[]} A parameter to compare the length of
// @param paramName {str} The name of the parameter
// @returns {null;err} Return an error if they aren't equal
i.checkLen:{[endog;param;paramName]
  if[not count[endog]=count param;
    '"The length of the endog variable and ",paramName," must be equal"
    ]
  }

// @private
// @fileOverview Calculate descriptive stats for an OLS regression
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param trend {bool} Whether a trend is added to the model
// @returns {dict[]} The descriptive statistics
i.OLSstats:{[coef;endog;exog;trend]
  n:count endog;
  p:count[coef]-trend;
  statsDict:i.OLScalcs[coef;endog;exog;n;p];
  variables:i.coefStats[coef;endog;exog;trend;n;p];
  `coef`variables`statsDict!(coef;variables;statsDict)
  }

// @private
// @fileOverview Calculate descriptive stats for an OLS regression
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param n {long} The number of endog variables
// @param p {long} Number of coefs not including trend value
// @returns {dict[]} The descriptive statistics
i.OLScalcs:{[coef;endog;exog;n;p]
  expected:OLS.predict[exog;enlist[`coef]!enlist coef];
  // DF - Degrees of freedom
  DFTotal:n-1;
  DFResidual:DFTotal-p;
  // Mean squares is SS (sum squares) divided by the degrees of freedom
  // F-statistic is  F(modelDF, residualDF) = modelMS/residualMS
  // r2 is SSmodel/SStotal
  SSTotal:sum{x*x}endog-avg endog;
  SSModel:sum{x*x}expected-first avg expected;
  SSResidual:SSTotal-SSModel;
  MSTotal:SSTotal%DFTotal;
  MSModel:SSModel%p;
  MSResidual:SSResidual%DFResidual;
  fStat:MSModel%MSResidual;
  r2: SSModel%SSTotal;
  r2Adj:1-(1-r2)*(n-1)%(n-p)-1;
  residuals:endog-expected;
  mse:avg{x*x}residuals;
  rse:sqrt(sum{x*x}residuals)%DFResidual;
  pValue:2*1-stats[`:t][`:cdf;<][fStat;p;DFResidual];
  dictKeys:(`SSTotal;`SSModel;`SSResidual;`MSTotal;`MSModel;`MSResidual;
    `fStat;`r2;`r2Adj;`mse;`rse;`pValue);
  dictVals:(SSTotal;SSModel;SSResidual;MSTotal;MSModel;MSResidual;fStat;
    r2;r2Adj;mse;rse;pValue);
  dictKeys!dictVals
  }

// @private
// @fileOverview Calculate descriptive stats for the calculated coefficients
// @param coef {float[]} The coefficients for each predictor variable
// @param endog {float[]} The endogenous variable
// @param exog {float[][]} Values that predict the endog variable
// @param trend {bool} Whether a trend is added to the model
// @param n {long} The number of endog variables
// @param p {long} Number of coefs not including trend value
// @returns {dict[]} The descriptive statistics for the calculated coefficients
i.coefStats:{[coef;endog;exog;trend;n;p]
  varNames:`$"x",'string til count coef;
  if[trend;varNames:`yIntercept,-1_varNames];
  stdErr:i.coefStdErr[coef;exog;endog];
  tStat:coef%stdErr;
  pValue:2*1-stats[`:t][`:cdf;<][;n-p-1]each abs tStat;
  // Calculate the confidence interval
  C195:i.CI95[n;p]each stdErr;
  ([name: varNames]coef;stdErr;tStat;pValue;C195)
  }
  
// @private
// @fileOverview Calculate the standard errors of the coefficients
// @param coef {float[]} The calculated coefficiant
// @param exog {float[][]} Values that predict the endog variable
// @param endog {float[]} The endogenous variable
// @returns {float[]} The standard error of the coefficients
i.coefStdErr:{[coef;exog;endog]
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
// @fileOverview Calculate the 95% confidence interval of the standard error
//   of teh coefficient
// @param n {long} Number of endog values
// @param p {long} Number of coefficients
// @param stdErr {float} The standard error of the coefficient
// @returns {float} The confidence interval
i.CI95:{[n;p;stdErr]
  alpha:(1-.95)%2;
  // Degrees of freedom
  df:(n-p)-1;
  // Calculate the percent point function
  ppf:stats[`:t][`:ppf][alpha; df]`;
  neg ppf*stdErr
  }
