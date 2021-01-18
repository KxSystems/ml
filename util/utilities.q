\d .ml

// @kind function
// @category utilities
// @fileoverview Range of values
// @param array {num[]} A numerical array 
// @returns {float} Range of its values
range:{[array]
  max[array]-min array
  }

// @kind function
// @category utilities
// @fileoverview Percentile calculation for an array
// @param array {num[]} A numerical array
// @param perc {float} Percentile of interest
// @returns {float} The value below which `perc` percent of the observations 
//   within the array are found
percentile:{[array;perc]
  percent:perc*-1+count array;
  i:0 1+\:floor percent;
  iDiff:0^deltas asc[array]i;
  iDiff[0]+(percent-i 0)*last iDiff
  }

// @kind function
// @category utilities
// @fileoverview Descriptive information
// @param tab {tab} A simple table
// @returns {dict} A tabular description of aggregate information
//  (count, standard deviation, quartiles etc) for each numeric column
describe:{[tab]
  descKeys:`count`mean`std`min`q1`q2`q3`max;
  funcs:(count;avg;sdev;min;percentile[;.25];percentile[;.5];
    percentile[;.75];max);
  types:"hijefpmdznuvt";
  descVals:flip funcs@\:/:flip(exec c from meta[tab]where t in types)#tab;
  descKeys!descVals
  }

// @kind function
// @category utilities
// @fileoverview Evenly-spaced values
// @param start {num} Start of the interval (inclusive)
// @param end {num} End of the interval (non-inclusive)
// @param step {num} Spacing between values 
// @return {num[]} A vector of evenly-spaced values between start and end
//   in steps of length `step`
arange:{[start;end;step]
  start+step*til 0|ceiling(end-start)%step
  }

// @kind function
// @category utilities
// @fileoverview Unique combinations of a vector or matrix
// @param n {int} Number of values required for combinations
// @param degree {int} Degree of the combinations to be produced
// @return {int[]} Unique combinations of values from the data 
combs:{[n;degree]
  flip(degree-1)i.combFunc[n]/enlist til n
  }

// @kind function
// @category utilities
// @fileoverview Create identity matrix 
// @param n {int} Width/height of identity matrix
// @return {int[]} Identity matrix of height/width n
eye:{[n]
  @[n#0.;;:;1.]each til n
  }

// @kind function
// @category utilities
// @fileoverview Index of maximum element of a list
// @param array {num[]} Array of values 
// @return {num} The index of the maximum element of the array
iMax:{[array]
  array?max array
  }

// @kind function
// @category utilities
// @fileoverview Index of minimum element of a list
// @param array {num[]} Array of values 
// @return {num} The index of the minimum element of the array
iMin:{[array]
  array?min array
  }

// @kind function
// @category utilities
// @fileoverview Create an array of evenly-spaced values
// @param start {num} Start of the interval (inclusive)
// @param end {num} End of the interval (non-inclusive)
// @param n {int} How many spaces are to be created
// @return {num[]} A vector of `n` evenly-spaced values between start and end
linearSpace:{[start;end;n]
  start+til[n]*(end-start)%n-1
  }

// @kind function
// @category utilities
// @fileoverview Shape of a matrix
// @param matrix {num[]} Matrix of values
// @return {num[]} Its shape as a list of dimensions
shape:{[matrix]
  -1_count each first scan matrix
  }

// @kind function
// @category utilities
// @fileoverview Split data into training and test sets
// @param data {num[];tab} Matrix of input values
// @param target {num[]} A vector of target values the same count as data
// @param size {float[]} Percentage size of the testing set
// @return {dict} Contains the data matrix and target split into a training
//   and testing set
trainTestSplit:{[data;target;size]
  dictKeys:`xtrain`ytrain`xtest`ytest;
  n:count data;
  split:(0,floor n*1-size)_neg[n]?n;
  dictVals:raze(data;target)@\:/:split;
  dictKeys!dictVals
  }

// @kind function
// @category utilities
// @fileoverview Convert q table to Pandas dataframe
// @param tab {tab} A q table
// @return {<} a Pandas dataframe
tab2df:{[tab]
  updTab:@[flip 0!tab;i.findCols[tab;"c"];enlist each];
  transformTab:@[updTab;i.findCols[tab]"pmdznuvt";i.q2npDate];
  pandasDF:i.pandasDF[transformTab][@;cols tab];
  $[count keyTab:keys tab;
    pandasDF[`:set_index]keyTab;
    pandasDF
    ]
  }

// @kind function
// @category utilities
// @fileoverview Convert a pandas dataframe containing datetime timezones and
//   datetime objects (datetime.datetime, datetime.time) to a q table
// @param tab {<} An embedPy representation of a Pandas dataframe
// @param local {bool} Indicates if timezone objects are to be converted
//   to local time (1b) or UTC (0b)
// @param qObj {bool} Indicates if python datetime.date/datetime.time objects
//   are returned as q (1b) or foreign objects (0b)
// @return {<} a q table
df2tabTimezone:{[tab;local;qObj]
  index:$[enlist[::]~tab[`:index.names]`;0;tab[`:index.nlevels]`];
  tab:$[index;tab[`:reset_index][];tab];
  numpyCols:`$tab[`:columns.to_numpy][]`;
  dataArgs:enlist[`exclude]!enlist`float32`datetime`datetimetz`timedelta;
  dict:tab[`:select_dtypes][pykwargs dataArgs][`:to_dict;`list]`;
  dateTimeData:tab[`:select_dtypes][`include pykw`datetime];
  dict,:i.dateConvert dateTimeData;
  timeDeltaData:tab[`:select_dtypes][`include pykw`timedelta];
  dict,:i.dateDict[timeDeltaData]+"n"$0;
  timezoneData:tab[`:select_dtypes][`include pykw`datetimetz];
  dict,:i.timezoneConvert[timezoneData;local];
  float32Data:tab[`:select_dtypes][`include pykw`float32][`:to_dict;`list]`;
  dict,:i.float32Convert[float32Data;local];
  // Check if the first value in columns are foreign
  foreign:where 112h=type each first each value dict;
  if[0<count foreign;
    dictKeys:key[dict]foreign;
    dictVals:i.dateTimeConvert[;qObj] each dict dictKeys;
    dict,:dictKeys!dictVals
    ];
  index!flip numpyCols#dict
  }

// @kind function
// @category utilities
// @fileoverview Convert pandas dataframe to q table
// @param tab {<} An embedPy representation of a Pandas dataframe
// @return {<} a q table
df2tab:df2tabTimezone[;0b;0b]
