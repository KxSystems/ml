\d .automl

// Definitions of the main callable functions used in the application of
//    .automl.dataPreprocessing

// @kind function
// @category dataPreprocessing
// @fileoverview Symbol encoding applied to feature data
// @param features {tab} Feature data as a table
// @param config {dict} Information relating to the current run of AutoML
// @return {tab} Feature table encoded appropriately for the task
dataPreprocessing.symEncoding:{[features;config;symEncode]
  typ:config`featureExtractionType;
  // If no symbol columns, return table or empty encoding schema
  if[all{not` in x}each value symEncode;
    if[count symEncode`freq;
      features:$[`fresh~typ;
	    [aggColData:0!config[`aggregationColumns]xgroup features;
         raze .ml.freqencode[;symEncode`freq]each flip each aggColData
		 ];
        .ml.freqencode[features;symEncode`freq]
        ]; 
      ];
    features:.ml.onehot[0!features;symEncode`ohe];
    // Extract symbol columns from dictionary
    symbolCols:distinct raze symEncode;
    :flip symbolCols _ flip features
    ];
  features
  }

// @kind function
// @category dataPreprocessing
// @fileoverview  Apply preprocessing depending on feature extraction type
// @param features {tab} Feature data as a table
// @param config {dict} Information relating to the current run of AutoML
// @return {tab} Feature table with appropriate feature preprocessing applied
dataPreprocessing.featPreprocess:{[features;config]
  typ:config`featureExtractionType;
  // For FRESH the aggregate columns need to be excluded from the preprocessing
  // steps. This ensures that encoding is not performed on the aggregate 
  // columns if this is a symbol and/or this column is constant.
  if[`fresh=typ;
    aggData:(config[`aggregationColumns],())#flip features;
    features:flip(cols[features]except config`aggregationColumns)#flip features
    ];
  featTable:$[not typ in`nlp;
    dataPreprocessing.nonTextPreprocess features;
    dataPreprocessing.textPreprocess features
    ];
  // Rejoin separated aggregate columns for FRESH
  config[`logFunc]utils.printDict`preproc;
  $[`fresh=typ;flip[aggData],';]featTable
  }

// @kind function
// @category dataPreprocessing
// @fileoverview Apply preprocessing for non NLP feature extraction type
// @param features {tab} Feature data as a table
// @return {tab} Feature table with appropriate feature preprocessing applied
dataPreprocessing.nonTextPreprocess:{[features]
  features:dataPreprocessing.nullEncode[features;med];
  features:.ml.dropconstant features;
  dataPreprocessing.infreplace features
  }

// @kind function
// @category dataPreprocessing
// @fileoverview  Apply preprocessing for NLP feature extraction type
// @param features {tab} Feature data as a table
// @return {tab} Feature table with appropriate feature preprocessing applied
dataPreprocessing.textPreprocess:{[features]
  if[count[cols features]>count charCol:.ml.i.fndcols[features;"C"];
    nonTextPreproc:dataPreprocessing.nonTextPreprocess charCol _features;
    :?[features;();0b;charCol!charCol],'nonTextPreproc
    ];
  features
  }

// @kind function
// @category dataPreprocessingUtility
// @fileoverview null encoding of feature data 
// @param features {tab} Feature data as a table
// @param func {lambda} Function to be applied to column from which the value 
//   to fill nulls is derived (med/min/max)
// @return {tab} Feature table with null values filled if required
dataPreprocessing.nullEncode:{[features;func]
  nullCheck:flip null features;
  nullFeat:where 0<sum each nullCheck;
  nullValues:nullCheck nullFeat;
  names:`$string[nullFeat],\:"_null";
  // 0 filling needed if return value also null
  // Encoding maintained through added columns
  $[0=count nullFeat;
   features;
   flip 0^(func each flip features)^flip[features],names!nullValues
   ]
  }

// Temporary infreplace function until toolkit is updated
dataPreprocessing.infreplace:{
  $[98=t:type x;
    [appCols:.ml.i.fndcols[x;"hijefpnuv"];
    typCols:type each dt:appCols!x appCols;
    flip flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
    ];
    0=t;
     [appIndex:where all each string[type each x]in key i.inftyp;
      typIndex:type each dt:x appIndex;
     (x til[count x]except appIndex),dataPreprocessing.i.infrep'[dt;typIndex]
     ];
    98=type keyX:key x;
     [appCols:.ml.i.fndcols[x:value x;"hijefpnuv"];
     typCols:type each dt:appCols!x appCols;
     cols[keyX]xkey flip flip[keyX],flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
     ];
    [appCols:.ml.i.fndcols[x:flip x;"hijefpnuv"];
    typCols:type each dt:appCols!x appCols;
     flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
     ]
   ]
  }

// Utilities for functions to be added to the toolkit
dataPreprocessing.i.infrep:{
  // Character representing the type
  typ:.Q.t@abs y;
  // the relevant null+infs for type
  t:typ$(0N;-0w;0w);
  {[n;x;y;z]@[x;i;:;z@[x;i:where x=y;:;n]]}[t 0]/[x;t 1 2;(min;max)]
  }

