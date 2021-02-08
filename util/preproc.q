\d .ml

// @kind function
// @category preprocessing
// @fileoverview Remove columns/keys with zero variance
// @param data {tab;dict} Data in various formats
// @return {tab;dict} All columns/keys with zero variance are removed
dropConstant:{[data]
  typeData:type data;
  if[not typeData in 98 99h;
    '"Data must be simple table or dictionary"
    ];
  if[99h=typeData;
    if[98h~type value data;
      '"Data cannot be a keyed table"
      ]
    ];
  // Find keys/cols that contain non-numeric data
  findFunc:$[typeData=99h;i.findKey;i.findCols];
  findKeys:findFunc .(data;"csg ",upper .Q.t);
  // Store instructions to flip table and execute this
  flipData:$[99=typeData;;flip];
  dataDict:flipData data;
  // Drop constant numeric and non numeric cols/keys
  dropNum:i.dropConstant.num[findKeys _ dataDict];
  dropOther:i.dropConstant.other findKeys#dataDict;
  flipData dropNum,dropOther
  }

// @kind function
// @category preprocessing
// @fileoverview Fit min max scaling model
// @param data {tab;dict;num[]} Numerical data
// @return {dict} modelInfo containing min and max value of fitted data 
//  along with a predict function projection
minMaxScaler.fit:{[data]
  typData:type[data] in 0 99h;
  minData:$[typData;min each;min]data;
  maxData:$[typData;max each;max]data;
  scalingInfo:`minData`maxData!(minData;maxData);
  returnInfo:enlist[`modelInfo]!enlist scalingInfo;
  predict:i.apUpd minMaxScaler.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @kind function
// @category preprocessing
// @fileoverview Scale data between 0-1 based on fitted model
// @params config {dict} Information returned from `ml.minMaxScaler.fit`
// @param data {tab;dict;num[]} Numerical data
// @return {tab;dict;num[]} A min-max scaled representation with values
//   scaled between 0 and 1f
minMaxScaler.predict:{[config;data]
  minData:config[`modelInfo;`minData];
  maxData:config[`modelInfo;`maxData];
  (data-minData)%maxData-minData
  }

// @kind function
// @category preprocessing
// @fileoverview Scale data between 0-1
// @param data {tab;dict;num[]} Numerical data
// @return {tab;dict;num[]} A min-max scaled representation with values
//   scaled between 0 and 1f
minMaxScaler.fitPredict:{[data]
  scaler:minMaxScaler.fit data;
  scaler[`predict]data
  }

// @kind function
// @category preprocessing
// @fileoverview Fit standard scaler model
// @param data {tab;dict;num[]} Numerical data
// @return {dict} modelInfo containing avg and dev value of fitted data 
//  along with a predict function projection
stdScaler.fit:{[data]
  typData:type[data];
  if[typData=98;data:flip data];
  avgData:$[typData in 0 98 99h;avg each;avg]data;
  devData:$[typData in 0 98 99h;dev each;dev]data;
  scalingInfo:`avgData`devData!(avgData;devData);
  returnInfo:enlist[`modelInfo]!enlist scalingInfo;
  predict:i.apUpd stdScaler.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @kind function
// @category preprocessing
// @fileoverview Standard scaler transform-based representation of data
//  using a fitted model
// @params config {dict} Information returned from `ml.stdScaler.fit`
// @param data {tab;dict;num[]} Numerical data
// @return {tab;dict;num[]} All data has undergone standard scaling
stdScaler.predict:{[config;data]
  avgData:config[`modelInfo;`avgData];
  devData:config[`modelInfo;`devData];
  (data-avgData)%devData
  }

// @kind function
// @category preprocessing
// @fileoverview Standard scaler transform-based representation of data
// @param data {tab;dict;num[]} Numerical data
// @return {dict} All data has undergone standard scaling
stdScaler.fitPredict:{[data]
  scaler:stdScaler.fit data;
  scaler[`predict]data
  }

// @kind function
// @category preprocessing
// @fileoverview Replace +/- infinities with data min/max
// @param data {tab;dict;num[]} Numerical data
// @return {tab;dict;num[]} Data with positive/negative infinities are 
//   replaced by max/min values
infReplace:i.ap{[data;inf;func]
  @[data;i;:;func@[data;i:where data=inf;:;0n]]
  }/[;-0w 0w;min,max]

// @kind function
// @category preprocessing
// @fileoverview Tunable polynomial features from an input table
// @param tab {tab} Numerical data
// @param n {int} Order of the polynomial feature being created
// @return {tab} The polynomial derived features of degree n 
polyTab:{[tab;n]
  colsTab:cols tab;
  colsTab@:combs[count colsTab;n];
  updCols:`$"_"sv'string colsTab;
  updVals:prd each tab colsTab;
  flip updCols!updVals
  }

// @kind function
// @category preprocessing
// @fileoverview Tunable filling of null data for a simple table
// @param tab {tab} Numerical and non numerical data
// @param groupCol {sym} A grouping column for the fill 
// @param timeCol {sym} A time column in the data 
// @param dict {sym} Defines fill behavior, setting this to (::) will result 
//   in forward followed by reverse filling
// @return {tab} Columns filled according to assignment of keys in the 
//   dictionary dict, the null values are also encoded within a new column 
//   to maintain knowledge of the null positions
fillTab:{[tab;groupCol;timeCol;dict]
 dict:$[0=count dict;
     :tab;
   (::)~dict;
     [fillCols:i.findCols[tab;"ghijefcspmdznuvt"]except groupCol,timeCol;
      fillCols!(count fillCols)#`forward
      ];
   dict
   ];
  keyDict:key dict;
  nullKeys:`$string[keyDict],\:"_null";
  nullVals:null tab keyDict;
  tab:flip flip[tab],nullKeys!nullVals;
  grouping:$[count groupCol,:();groupCol!groupCol;0b];
  ![tab;();grouping;@[i.fillMap;`linear;,';timeCol][dict],'keyDict]
  }

// @kind function
// @category preprocessing
// @fileoverview Fit one-hot encoding model to categorical data
// @param tab {tab} Numerical and non numerical data
// @param symCols {sym[]} Columns to apply encoding to
// @return {dict} modelInfo containing mapping information and a projection of
//   the prediction function to be applied to data
oneHot.fit:{[tab;symCols]
  if[(::)~symCols;symCols:i.findCols[tab;"s"]];
  mapVals:asc each distinct each tab symCols,:(); 
  mapDict:symCols!mapVals;
  returnInfo:enlist[`modelInfo]!enlist mapDict;
  predict:oneHot.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical features using one-hot encoded fitted model
// @params config {dict} Information returned from `ml.oneHot.fit`
// @param tab {tab} Numerical and non numerical data
// @param symDict {dict} Keys indicate the columns in the table to be encoded,
//   values indicate what mapping to use when encoding 
// @return {tab} One-hot encoded representation of categorical data
oneHot.predict:{[config;tab;symDict]
  mapDict:config`modelInfo;
  symDict:i.mappingCheck[tab;symDict;mapDict];
  oneHotVal:mapDict value symDict;
  oneHotData:key symDict;
  updDict:i.oneHotCols[tab]'[oneHotData;oneHotVal];
  flip(oneHotData _ flip tab),raze updDict
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical features using one-hot encoding
// @param tab {tab} Numerical and non numerical data
// @param symCols {sym[]} Columns to apply coding to
// @return {tab} One-hot encoded representation of categorical data
oneHot.fitPredict:{[tab;symCols]
  encode:oneHot.fit[tab;symCols];
  map:raze key encode`modelInfo;
  symDict:map!map;
  encode[`predict][tab;symDict]
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical features with frequency of 
//   category occurrence
// @param tab {tab} Numerical data
// @param symCols {sym[]} Columns to apply coding to
// @return {tab} Frequency of occurrance of individual symbols within a column
freqEncode:{[tab;symCols]
  if[(::)~symCols;symCols:i.findCols[tab;"s"]];
  updCols:`$string[symCols],\:"_freq";
  updVals:i.freqEncode each tab symCols,:();
  updDict:updCols!updVals;
  flip(symCols _ flip tab),updDict
  }

// @kind function
// @category preprocessing
// @fileoverview Fit lexigraphical ordering model to cateogorical data
// @param tab {tab} Numerical and categorical data
// @param symCols {sym[]} Columns to apply coding to
// @return {dict} modelInfo containing mapping information and a projection
//  of the prediction function to be used on data
lexiEncode.fit:{[tab;symCols]
  if[(::)~symCols;symCols:i.findCols[tab;"s"]];
  mapping:labelEncode.fit each tab symCols,:();
  mapVals:exec modelInfo from mapping;
  mapDict:symCols!mapVals;
  returnInfo:enlist[`modelInfo]!enlist mapDict;
  predict:lexiEncode.predict returnInfo;
  returnInfo,enlist[`predict]!enlist predict
  }

// @kind function
// @category preprocessing
// @fileoverview Lexicode encode data based on previously fitted model
// @params config {dict} Information returned from `ml.lexiEncode.fit`
// @param tab {tab} Numerical and categorical data
// @param symDict {dict} Keys indicate the columns in the table to be encoded,
//   values indicate what mapping to use when encoding 
// @return {tab} Addition of lexigraphical order of symbol column
lexiEncode.predict:{[config;tab;symDict]
  mapDict:config`modelInfo;
  symDict:i.mappingCheck[tab;symDict;mapDict];
  tabCols:key symDict;
  mapCols:value symDict;
  updCols:`$string[tabCols],\:"_lexi";
  modelInfo:enlist[`modelInfo]!/:enlist each mapDict mapCols;
  updVals:labelEncode.predict'[modelInfo;tab tabCols];
  updDict:updCols!updVals;
  flip(tabCols _ flip tab),updDict
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical features based on lexigraphical order
// @param tab {tab} Numerical data
// @param symCols {sym[]} Columns to apply coding to
// @return {tab} Addition of lexigraphical order of symbol column
lexiEncode.fitPredict:{[tab;symCols]
  encode:lexiEncode.fit[tab;symCols];
  map:raze key encode`modelInfo;
  symDict:map!map;
  encode[`predict][tab;symDict]
  }

// @kind function
// @category preprocessing
// @fileoverview Fit a label encoder model
// @param data {any[]} Data to encode
// @return {dict} Schema mapping values and a predict function to be used on 
//   new data
labelEncode.fit:{[data]
  uniqueData:asc distinct data;
  map:uniqueData!til count uniqueData;
  returnInfo:enlist[`modelInfo]!enlist map;
  predict:labelEncode.predict returnInfo;
  encoding:uniqueData?data;
  returnInfo,enlist[`predict]!enlist predict
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical data to an integer value representation
// @params config {dict} Information returned from `ml.labelEncode.fit`
// @param data {any[]} Data to be reverted to original representation
// @return {int[]} List transformed to integer value 
labelEncode.predict:{[config;data]
  map:config`modelInfo;
  -1^map data
  }

// @kind function
// @category preprocessing
// @fileoverview Encode categorical data to an integer value representation
// @param data {any[]} Data to encode
// @return {int[]} List is encoded to an integer representation 
labelEncode.fitPredict:{[data]
  encoder:labelEncode.fit data;
  encoder[`predict]data
  }

// @kind function
// @category preprocessing
// @fileoverview Transform a list of integers based on a previously generated
//    label encoding
// @param data {int[]} Data to be reverted to original representation
// @param map {dict} Maps true representation to associated integer or
//   the return from .ml.labelencode
// @return {sym[]} Integer values of `data` replaced by their appropriate 
//  'true' representation. Values that do not appear in the mapping supplied
//   by `map` are returned as null values 
applyLabelEncode:{[data;map]
  if[99h<>type map;'"Input must be a dictionary"];
  $[`modelInfo`predict~key map;map[`modelInfo]?;map?]data
  }

// @kind function
// @category preprocessing
// @fileoverview Break specified time columns into constituent components
// @param tab {tab} Contains time columns
// @param timeCols {sym[]} Columns to apply coding to, if set to :: all columns
//   with date/time types will be encoded
// @return {dict} All time or date types broken into labeled versions of their
//   constituent components
timeSplit:{[tab;timeCols]
  if[(::)~timeCols;timeCols:i.findCols[tab;"dmntvupz"]];
  timeDict:i.timeDict/:[tab]timeCols,:();
  flip(timeCols _ flip tab),raze timeDict
  }
